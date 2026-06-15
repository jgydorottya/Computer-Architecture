# MIPS 16 Pipeline Processor

A pipelined implementation of a 16-bit MIPS processor using the classic **5-stage pipeline architecture**. Multiple instructions can execute simultaneously, improving throughput compared to the single-cycle design. Hazards

## Pipeline Stages

1. **IF** – Instruction Fetch
2. **ID** – Instruction Decode / Register Read
3. **EX** – Execute / Address Calculation
4. **MEM** – Data Memory Access
5. **WB** – Write Back

## Hazard Handling

Data and control hazards are handled by manually inserting NOP instructions into the assembly program. This prevents incorrect execution caused by pipeline dependencies between consecutive instructions.

## Features

- 16-bit MIPS architecture
- Five-stage pipeline
- Pipeline registers between stages
- Higher instruction throughput than the single-cycle design
- FPGA-compatible VHDL implementation

## Supported Instructions

### R-Type
- ADD
- SUB
- AND
- OR
- SLT

### I-Type
- LW
- SW

### J-Type
- J

## Pipeline Registers

- IF/ID
- ID/EX
- EX/MEM
- MEM/WB

These registers store data and control signals between pipeline stages, allowing multiple instructions to be processed concurrently.

## Datapath Components

- Program Counter (PC)
- Instruction Memory
- Control Unit
- Register File
- ALU
- Data Memory
- Pipeline Registers

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

## Notes

The pipeline processor demonstrates the principles of instruction-level parallelism. Pipeline registers separate the execution stages, allowing several instructions to be active in the processor at the same time and significantly increasing throughput.