# RV32I
## Integer Register-Immediate Instructions.
#### ADDI :
- Add immediate.
- ADDI RD RS1 IMM.
- OPCODE : 7'b001 0011.
- FUNCT3 : 3'b000.
- I - type.
#### ANDI :
- And immediate.
- ANDI RD RS1 IMM.
- OPCODE : 7'b001 0011.
- FUNCT3 : 3'b111.
- I - type.
#### ORI :
- Or immediate.
- ORI RD RS1 IMM.
- OPCODE : 7'b001 0011.
- FUNCT3 : 3'b110.
- I - type.
#### XORI :
- Xor immediate.
- XORI RD RS1 IMM.
- OPCODE : 7'b001 0011.
- FUNCT3 : 3'b100.
- I - type.
#### SLTI :
- Set less than immediate.
- SLTI RD RS1 IMM.
- OPCODE : 7'b001 0011.
- FUNCT3 : 3'b010.
- I - type.
#### SLTIU :
- Set less than immediate unsigned.
- SLTIU RD RS1 IMM.
- OPCODE : 7'b001 0011.
- FUNCT3 : 3'b011.
- I - type.
#### SLLI :
- Shift left logic immediate.
- SLLI RD RS1 IMM. (immediates are only 5bits long here.)
- OPCODE : 7'b001 0011.
- FUNCT3 : 3'b001.
- I - type.
#### SRLI :
- Shift right logic immediate.
- SRLI RD RS1 IMM. (immediates are only 5bits long here.)
- OPCODE : 7'b001 0011.
- FUNCT3 : 3'b101.
- I - type.
#### SRAI :
- Shift right arhtematic immediate.
- SRAI RD RS1 IMM. (immediates are only 5bits long here and remaining MSB is different for SRAI and SRLI)
- OPCODE : 7'b001 0011.
- FUNCT3 : 3'b101.
- I - type.
#### LUI :
- Load upper immediate.
- LUI RD IMM.
- OPCODE : 7'b011 0111.
- No FUNCT3 field.
- U - type.
#### AUIPC :
- Add upper immediate to Program Counter.
- AUIPC RD IMM.
- OPCODE : 7'b001 0111.
- No FUNCT3 field.
- U - type.

## Integer Register-Register Instructions.
#### ADD :
- Addition.
- ADD RD RS1 RS2.
- OPCODE : 7'b011 0011.
- FUNCT3 : 3'b000.
- R - type.
#### SUB :
- Subtraction.
#### AND :
- And logic operator.
#### OR :
- Or logic operator.
#### XOR :
- Xor logic operator.
#### SLT :
- Set less than.
#### SLTU :
- Set less than unsigned.
#### SLL :
- Shift left logic.
#### SRL :
- Shift right logic.
#### SRA :
- Shift right arthematic.

## Control Transfer Instructions.
### Unconditional Jumps.
#### JAL :
- Jump and Link.
#### JALR :
- Jump and Link Register.
### Conditional Branches.
#### BEQ :
- Branch Equal.
#### BNQ :
- Branch Not Equal.
#### BLT :
- Branch Less Than.
#### BLTU :
- Branch Less Than Unsigned.
#### BGE :
- Branch Greater or Equal.
#### BGEU :
- Branch Greater or Equal Unsigned.

## Load and Store Instruction.
#### LB : 
- Load Byte.
#### LH : 
- Load Halfword.
#### LW : 
- Load Word.
#### LBU : 
- Load Byte Unsigned.
#### LHU : 
- Load Halfword Unsigned.
#### SB : 
- Store Byte.
#### SH : 
- Store Halfword.
#### SW : 
- Store Word.

## Memory Ordering.
#### FENCE : 
- Fence Instruction.

## Environment Call and Breakpoints.
#### ECALL : 
- Environment Call.
#### EBREAK :
- Environment Break.