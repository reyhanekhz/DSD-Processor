# DSD-Processor – Digital Systems Design Processor

> A custom processor design implemented in **Verilog** for the *Digital Systems Design* course.  

This repository contains the RTL implementation, synthesis scripts, and documentation for a processor that demonstrates key concepts of digital logic design, datapath/control unit interaction, and a simplified instruction set architecture (ISA).

---

## Repository Structure

```
DSD-Processor/
├── src/          # All Verilog source files (processor modules, testbenches)
├── syn/          # Synthesis constraints, scripts, and output reports
├── doc.pdf       # Complete project documentation (specification, diagrams, analysis)
└── README.md     
```

---

## Processor Overview

The processor is a **custom-designed CPU** (e.g., RISC-like, accumulator-based, or microcoded) that includes:

- **Datapath** – ALU, register file, multiplexers, program counter
- **Control Unit** – FSM or hardwired logic generating control signals
- **Memory interface** – Instruction and data memory (simulated)
- **Basic ISA** – Arithmetic, logic, load/store, branching instructions

**Details about the exact ISA, pipeline stages, and instruction formats are provided in `doc.pdf`.**

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/reyhanekhz/DSD-Processor.git
cd DSD-Processor
```

### 2. Simulation (using a Verilog simulator)

You can use **Icarus Verilog**, **ModelSim**, **VCS**, or **Verilator**.

Example with Icarus Verilog:

```bash
cd src
iverilog -o processor_tb.vvp processor_tb.v    # include all design files
vvp processor_tb.vvp
```

Look for waveform dumps (e.g., `dump.vcd`) to analyze signals.

### 3. Synthesis (optional)

The `syn/` folder contains scripts for **Synopsys Design Compiler** or **Yosys**.  
To synthesize with Yosys:

```bash
cd syn
yosys -s synth_script.ys
```

Check the output area/timing reports.

---

## Documentation

All design details – **block diagram, instruction set, datapath, control logic, verification strategy, and synthesis results** – are in **[doc.pdf](./doc.pdf)**.


---

## Testbenches

Testbenches are included in `src/`. They typically:

- Load a small machine-code program into instruction memory
- Simulate clock cycles
- Check register/memory outputs against expected values

Run the testbench to verify correctness of:
- Arithmetic/logic instructions
- Control flow (branches, jumps)
- Load/store operations

---

