# MIPS16 Single-Cycle Processor

A custom implementation of a 16-bit MIPS processor based on a **single-cycle datapath architecture**. Each instruction is fetched, decoded, executed, accesses memory (if required), and writes back results within a single clock cycle.

## Features

- 16-bit instruction set architecture (MIPS16)
- Single-cycle execution model
- Register file with two read ports and one write port
- ALU supporting arithmetic and logical operations
- Instruction memory and data memory
- Branch and jump support
- FPGA-compatible VHDL design

## Supported Instructions

### R-Type
- ADD
- SUB
- SLL
- SRL
- AND
- OR
- XOR
- SLT

### I-Type
- ADDI
- LW
- SW
- BEQ
- ANDI
- ORI

### J-Type
- J

## Datapath Components

- Program Counter (PC)
- Instruction Memory
- Control Unit
- Register File
- Extension Unit
- ALU Control
- Arithmetic Logic Unit (ALU)
- Data Memory
- Multiplexers

## Project Structure

- `Instr_Fetch.vhd`
- `Instr_Decode.vhd`
- `Execute_Unit.vhd`
- `Memory_Unit.vhd`
- `Control_Unit.vhd`
- `MIPS.vhd` - top-level processor module

## Test and I/O Modules

- `SSD.vhd` - seven-segment display controller
- `MPG.vhd` - button debouncing / pulse generation module