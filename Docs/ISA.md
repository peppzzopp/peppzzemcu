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
- SUB RD RS1 RS2.
- OPCODE : 7'b011 0011.
- FUNCT3 : 3'b000.
- Func7 is different for ADD and SUB.
- R - type.
#### AND :
- And logic operator.
- AND RD RS1 RS2.
- OPCODE : 7'b0011 0011.
- FUNCT3 : 3'b111.
- R - type.
#### OR :
- Or logic operator.
- OR RD RS1 RS2.
- OPCODE : 7'b0011 0011.
- FUNCT3 : 3'b110.
- R - type.
#### XOR :
- Xor logic operator.
- XOR RD RS1 RS2.
- OPCODE : 7'b0011 0011.
- FUNCT3 : 3'b100.
- R - type.
#### SLT :
- Set less than.
- SLT RD RS1 RS2.
- OPCODE : 7'b0011 0011.
- FUNCT3 : 3'b010.
- R - type.
#### SLTU :
- Set less than unsigned.
- SLT RD RS1 RS2.
- OPCODE : 7'b0011 0011.
- FUNCT3 : 3'b011.
- R - type.
#### SLL :
- Shift left logic.
- SLL RD RS1 RS2.
- OPCODE : 7'b0011 0011.
- FUNCT3 : 3'b001.
- R - type.
#### SRL :
- Shift right logic.
- SRL RD RS1 RS2.
- OPCODE : 7'b0011 0011.
- FUNCT3 : 3'b101.
- R - type.
#### SRA :
- Shift right arthematic.
- SRA RD RS1 RS2.
- OPCODE : 7'b0011 0011.
- FUNCT3 : 3'b101.
- FUNCT7 is different from SRL.
- R - type.

## Control Transfer Instructions.
### Unconditional Jumps.
#### JAL :
- Jump and Link.
- JAL RD IMM.
- OPCODE : 7'b110 1111.
- J - type.
#### JALR :
- Jump and Link Register.
- JALR RD IMM(RS1).
- OPCODE : 7'b110 0111.
- I - type.
### Conditional Branches.
#### BEQ :
- Branch Equal.
- BEQ RS1 RS2 IMM.
- OPCODE : 7'b110 0011.
- FUNCT3 : 3'b000.
- B - type.
#### BNE :
- Branch Not Equal.
- BNE RS1 RS2 IMM.
- OPCODE : 7'b110 0011.
- FUNCT3 : 3'b001.
- B - type.
#### BLT :
- Branch Less Than.
- BLT RS1 RS2 IMM.
- OPCODE : 7'b110 0011.
- FUNCT3 : 3'b100.
- B - type.
#### BLTU :
- Branch Less Than Unsigned.
- BLTU RS1 RS2 IMM.
- OPCODE : 7'b110 0011.
- FUNCT3 : 3'b110.
- B - type.
#### BGE :
- Branch Greater or Equal.
- BGE RS1 RS2 IMM.
- OPCODE : 7'b110 0011.
- FUNCT3 : 3'b101.
- B - type.
#### BGEU :
- Branch Greater or Equal Unsigned.
- BGEU RS1 RS2 IMM.
- OPCODE : 7'b110 0011.
- FUNCT3 : 3'b111.
- B - type.

## Load and Store Instruction.
#### LB : 
- Load Byte.
- LB RD IMM(RS1).
- OPCODE : 7'b000 0011.
- FUNCT3 : 3'b000.
- I - type.
#### LH : 
- Load Halfword.
- LH RD IMM(RS1).
- OPCODE : 7'b000 0011.
- FUNCT3 : 3'b001.
- I - type.
#### LW : 
- Load Word.
- LW RD IMM(RS1).
- OPCODE : 7'b000 0011.
- FUNCT3 : 3'b010.
- I - type.
#### LBU : 
- Load Byte Unsigned.
- LBU RD IMM(RS1).
- OPCODE : 7'b000 0011.
- FUNCT3 : 3'b100.
- I - type.
#### LHU : 
- Load Halfword Unsigned.
- LHU RD IMM(RS1).
- OPCODE : 7'b000 0011.
- FUNCT3 : 3'b101.
- I - type.
#### SB : 
- Store Byte.
- SB RS2 IMM(RS1).
- OPCODE : 7'b010 0011.
- FUNCT3 : 3'b000.
- S - type.
#### SH : 
- Store Halfword.
- SH RS2 IMM(RS1).
- OPCODE : 7'b010 0011.
- FUNCT3 : 3'b001.
- S - type.
#### SW : 
- Store Word.
- SW RS2 IMM(RS1).
- OPCODE : 7'b010 0011.
- FUNCT3 : 3'b010.
- S - type.

## Memory Ordering.
#### FENCE : 
- Fence Instruction.
- FENCE PRED SUCC.
- OPCODE : 7'b000 1111.
- I - type.

## Environment Call and Breakpoints.
#### ECALL : 
- Environment Call.
- ECALL.
- OPCODE : 7'b111 0011.
- I - type.
#### EBREAK :
- Environment Break.
- EBREAK.
- OPCODE : 7'b111 0011.
- FUNCT12 is different from ECALL.
- I - type.