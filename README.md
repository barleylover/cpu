# Computer Architecture (Verilog)

ALU → Vending Machine(FSM) → Single Cycle CPU

| 단계 | 디렉터리 | 핵심 내용 | 상태 |
|---|---|---|---|
| 1 | [`ALU/`](ALU/) | 16비트 ALU (산술·논리·시프트 16종) | 완료 |
| 2 | [`VendingMachine/`](VendingMachine/) | FSM 기반 자판기 (v1 → v3) | 완료 |
| 3 | [`SingleCycle_cpu/`](SingleCycle_cpu/) | TSC ISA 기반 Single Cycle CPU | Control Unit 진행 중 |

```
cpu/
├── ALU/
│   ├── ALU_Template.v              # ALU 구현
│   └── ALU.xpr                     # Vivado 프로젝트
├── VendingMachine/
│   ├── VendingMachine_template.v   # v1: 기본 FSM
│   ├── VendingMachine_template2.v  # v2: 상품 재고 제한
│   ├── VendingMachine_template3.v  # v3: 동전 재고 제한 + 거스름돈 가능 여부 판단
│   └── VendingMachine.xpr
└── SingleCycle_cpu/
    ├── cpu.v                       # Top module (CPU_W16_R4)
    ├── control_unit.v              # Control Unit
    ├── alu.v                       # 1단계 ALU 재사용
    ├── register_file.v             # 레지스터 파일 (16bit x 4)
    └── opcodes.v                   # opcode / funct / ALU opcode 정의
```

---

## 1. ALU

📄 [`ALU/ALU_Template.v`](ALU/ALU_Template.v)

16비트 피연산자 2개(`A_i`, `B_i`)와 4비트 연산 선택 신호(`OP_i`)를 받아 결과 `F_o`와 캐리 `C_o`를 내는 **조합 회로**입니다.

---

## 2. Vending Machine (FSM)

📄 [`VendingMachine/`](VendingMachine/)

동전(100 / 500 / 1000원)을 넣고 상품(400 / 500 / 1000 / 2000원)을 고르면 상품을 내주고, 반환 버튼을 누르면 거스름돈을 돌려주는 자판기입니다.
**순차 회로(상태 레지스터) + 조합 회로(다음 상태 계산)** 로 나누는 FSM 설계 패턴을 연습했습니다.

```verilog
always @(posedge clk)  state <= state_nxt;   // 순차: 상태 저장
always @(*)            state_nxt = ...;      // 조합: 다음 상태 계산
```

### 버전별 변화

#### v1 — 기본 FSM ([`VendingMachine_template.v`](VendingMachine/VendingMachine_template.v))
상태 2개로 구성됩니다.

| 상태 | 동작 |
|---|---|
| `zero` (대기) | 동전 투입 → 총액 증가 / 상품 선택 → 잔액이 충분하면 배출 / 반환 버튼 → `first`로 이동 |
| `first` (반환) | 큰 동전부터 잔액을 차감하며 반환하고, 잔액이 0이 되면 `zero`로 복귀 |

- `available_item_o`는 `total >= 가격`으로 계산합니다.

#### v2 — 상품 재고 추가 ([`VendingMachine_template2.v`](VendingMachine/VendingMachine_template2.v))
- 입력 `num_items_i`로 상품별 재고를 받습니다. 리셋할 때 초기값으로 저장합니다.
- 상품을 배출하면 재고를 1 감소시킵니다. 구매 가능 조건은 `잔액 >= 가격 && 재고 > 0`입니다.
- 반환 시 `flag`를 써서 **한 사이클에 동전 1개만** 반환하도록 바꿨습니다.

#### v3 — 동전 재고 + 거스름돈 가능 여부 판단 ([`VendingMachine_template3.v`](VendingMachine/VendingMachine_template3.v))
- 자판기가 보유한 동전 개수(`coins`)를 추적합니다. 투입된 동전은 재고에 더합니다.
- 상태를 3개로 늘렸습니다.

| 상태 | 동작 |
|---|---|
| `zero` (대기) | v2와 동일 + 투입된 동전을 동전 재고에 반영 |
| `first` (판단) | 보유 동전으로 잔액을 **정확히 거슬러 줄 수 있는지** 미리 계산합니다. 가능하면 `second`로, 불가능하면 `zero`로 이동 |
| `second` (반환) | 재고가 있는 큰 동전부터 한 사이클에 1개씩 반환하고, 동전 재고를 차감 |


---

## 3. Single Cycle CPU

📄 [`SingleCycle_cpu/`](SingleCycle_cpu/)

### 과제 요구사항
- 16비트 워드, 레지스터 4개 (`CPU_W16_R4`)
- **TSC ISA** 기반. 지원할 명령어는 **ADD, ADI, LHI, JMP, WWD**
- Load/Store 미지원
- `inst_addr`(PC)는 클럭에 동기화하고, `reset_n`이 들어오면 0으로 초기화
- WWD => 인터럽트 발생

### TSC 명령어 형식

```
          15    12 11  10 9   8 7   6 5          0
R-format |opcode  | rs    | rt   | rd  | function  |
I-format |opcode  | rs    | rt   | immediate (8b)  |
J-format |opcode  |      target address (12b)      |
```

### Control Unit

📄 [`SingleCycle_cpu/control_unit.v`](SingleCycle_cpu/control_unit.v)

- 입력 : `rd_inst`
- **출력**
    | 출력 | 의미 |
    |---|---|
    | `RegWrite` | 레지스터 파일 쓰기 활성화 |
    | `ALU_src` | ALU B 입력 선택 (0: `$rt`, 1: immediate). RegDst 역할도 겸함 |
    | `alu_opcode` | ALU 연산 (1단계 ALU의 opcode) |
    | `is_jump` | JMP 실행 (PC ← jump target) |
    | `is_wwd` | WWD 실행 (인터럽트 요청 / PC 정지는 cpu.v에서 처리) |

**현재 진리표**

| 명령어 | RegWrite | ALU_src | alu_opcode | is_jump | is_wwd |
|---|---|---|---|---|---|
| ADD | 1 | 0 | ADD | 0 | 0 |
| ADI | 1 | 1 | ADD | 0 | 0 |
| LHI | 1 | 1 | ADD | 0 | 0 |
| JMP | 0 | 0 | – | 1 | 0 |
| WWD | 0 | 0 | ID | 0 | 1 |


