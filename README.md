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

## Installation and prerequisites
- To utilize this project, firstly clone the repository and ensure you have a Verilog/SystemVerilog simulation environment (QuestaSim/ModelSim, and HDL Designer) installed on your machine.
- After creating a project enviroment, copy all .v and .sv files to "hdl" project directory.
- Copy GM folder to "hdl" project directory.

## Usage
To run a simulation:
1. Navigate to GM folder inside project directory:
<img width="390" alt="0" src="https://github.com/talshva/DDLS_Final_Project/assets/82408347/baeee18f-19b0-47b6-8818-d1e6e15b01a6">
2. 
- Run the batch file RUN_SINGLE to generate variety of test cases, using a single pre-defined set of parameters (BUS_WIDTH, DATA_WIDTH, ADDRESS_WIDTH, SPN_SELECT).
- Another option is to run the RUN_ALL .bat file to generate all possible parameters combinations (may takes long time, depends on the generation amount):
<img width="598" alt="1" src="https://github.com/talshva/DDLS_Final_Project/assets/82408347/38406510-c77d-46bf-8f84-bdb4381651e6">

3. Compile the Verilog and SystemVerilog files with your simulation tool.
3. Execute the simulation using the `matmul_tb.sv` testbench.
4. Review the simulation results to verify the correctness of the matrix multiplication.

