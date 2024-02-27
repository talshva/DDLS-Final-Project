# Systolic Array Processor for Matrix Multiplication

## Project Overview
This repository hosts a Systolic Array Processor project aimed at optimizing matrix multiplication operations.
The project is developed using Verilog and SystemVerilog, showcasing a practical application of systolic arrays to enhance computational efficiency in tasks such as digital signal processing and machine learning algorithms.

## Components
The project comprises several Verilog and SystemVerilog files, each serving a unique role within the systolic array processor architecture:

### Verilog Components
- `matmul.v`: The top module orchestrating the matrix multiplication process.
- `matmul_calc.v`: Manages the calculation logic for matrix multiplication.
- `matmul_shifter.v`: Implements logic for shifting matrix elements for alignment.
- `operand.v`: Manages operands within the array.
- `pe.v`: The Processing Element (PE), executing multiplication and accumulation.
- `scratchpad.v`: Temporary storage for intermediate results.
- `apbslave.v`: APB slave interface for component communication.

### SystemVerilog Components
- `matmul_golden.sv`: Contains the golden model for verification of the matrix multiplication.
- `matmul_intf.sv`: Defines the interface for the matrix multiplication module.
- `matmul_pkg.sv`: Package file that includes common definitions and imports.
- `matmul_stimulus.sv`: Provides stimulus for the testbench, generating input matrices.
- `matmul_tb.sv`: The top-level testbench for verifying the matrix multiplication functionality.
- `matmul_checker.sv`: Verifies the output of the matrix multiplication against the golden model.
- `matmul_coverage.sv`: Implements coverage models to ensure thorough testing.

## Installation
To utilize this project, clone the repository and ensure you have a Verilog/SystemVerilog simulation environment (QuestaSim/ModelSim, and HDL Designer) installed on your machine.

## Usage
To run a simulation:
1. Navigate to the project directory.
2. Compile the Verilog and SystemVerilog files with your simulation tool.
3. Execute the simulation using the `matmul_tb.sv` testbench.
4. Review the simulation results to verify the correctness of the matrix multiplication.

