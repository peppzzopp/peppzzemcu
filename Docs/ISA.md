# RV32I
### Integer Register-Immediate Instructions.
- ADDI      : Add immediate.
- ANDI      : And immediate.
- ORI       : Or immediate.
- XORI      : Xor immediate.
- SLTI      : Set less than immediate.
- SLTIU     : Set less than immediate unsigned.
- SLLI      : Shift left logic immediate.
- SRLI      : Shift right logic immediate.
- SRAI      : Shift right arthematic immediate.
- LUI       : Load upper immediate.
- AUIPC     : Add upper immediate to Program Counter.

### Integer Register-Register Instructions.
- ADD       : Addition.
- SUB       : Subtraction.
- AND       : And logic operator.
- OR        : Or logic operator.
- XOR       : Xor logic operator.
- SLT       : Set less than.
- SLTU      : Set less than unsigned.
- SLL       : Shift left logic.
- SRL       : Shift right logic.
- SRA       : Shift right arthematic.

### Control Transfer Instructions.
#### Unconditional Jumps.
- JAL       : Jump and Link.
- JALR      : Jump and Link Register.
#### Conditional Branches.
- BEQ       : Branch Equal.
- BNQ       : Branch Not Equal.
- BLT       : Branch Less Than.
- BLTU      : Branch Less Than Unsigned.
- BGE       : Branch Greater or Equal.
- BGEU      : Branch Greater or Equal Unsigned.

### Load and Store Instruction.
- LB        : Load Byte.
- LH        : Load Halfword.
- LW        : Load Word.
- LBU       : Load Byte Unsigned.
- LHU       : Load Halfword Unsigned.
- SB        : Store Byte.
- SH        : Store Halfword.
- SW        : Store Word.

### Memory Ordering.
- FENCE     : Fence Instruction.

### Environment Call and Breakpoints.
- ECALL     : Environment Call.
- EBREAK    : Environment Break.