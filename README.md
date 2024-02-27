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
- `matmul_checker.sv`: Verifies the behaviour and relations of signals in the design.
- `matmul_coverage.sv`: Implements coverage models to ensure thorough testing.

## Installation and prerequisites
- To utilize this project, firstly clone the repository and ensure you have a Verilog/SystemVerilog simulation environment (QuestaSim/ModelSim, and HDL Designer) installed on your machine.
- After creating a project enviroment, copy all .v and .sv files to "hdl" project directory.
- Copy GM folder to "hdl" project directory.

## Usage
To run a simulation:
1. Navigate to GM folder inside project directory:
<img width="390" alt="0" src="https://github.com/talshva/DDLS_Final_Project/assets/82408347/baeee18f-19b0-47b6-8818-d1e6e15b01a6">

2. Run the batch file RUN_SINGLE to generate variety of test cases, using a single pre-defined set of parameters (BUS_WIDTH, DATA_WIDTH, ADDRESS_WIDTH, SPN_SELECT).

* Another option is to run the RUN_ALL .bat file to generate all possible parameters combinations (may takes long time, depends on the generation amount):
<img width="598" alt="1" src="https://github.com/talshva/DDLS_Final_Project/assets/82408347/38406510-c77d-46bf-8f84-bdb4381651e6">

3. Open the matmul_pkg file (via HDL Designer or directly using notepad), and adjust the parameters, based on the values you used to generate the test cases.
* Optional: set VERBOSE flag to '1' to display detailed simulation logs.
<img width="403" alt="3" src="https://github.com/talshva/DDLS_Final_Project/assets/82408347/3b973dda-3e86-455a-ad92-7e0045d0eb5d">

4. Compile the Verilog and SystemVerilog files with your simulation tool, and execute the simulation using the `matmul_tb.sv` testbench.
If using HDL Designer, select matmul_tb and press "Simulation" icon:

<img width="141" alt="4" src="https://github.com/talshva/DDLS_Final_Project/assets/82408347/821ad919-6f93-43d1-9b47-4b4654f9cf6f">

6. On the pop-up window, enter the simulation args: `-voptargs=+acc`, and make sure to enable Code Covarage:
<img width="176" alt="5" src="https://github.com/talshva/DDLS_Final_Project/assets/82408347/a14273c4-2b4d-4d8f-86b1-b1e9fa240d36">

* Alternatively, you can add the arg `-coverage` to the simulation args.

6. Run the simulation by typing `run -all` in the QuestaSim terminal, and review the simulation results to verify the correctness of the matrix multiplication:
 <img width="362" alt="6" src="https://github.com/talshva/DDLS_Final_Project/assets/82408347/45642ea0-0d66-49f9-b7f0-ffbae4cbcb0e">

7. For additional analysis, open the Coverage Report to see all simulation covered data:
<img width="134" alt="7" src="https://github.com/talshva/DDLS_Final_Project/assets/82408347/1786ecf2-64c8-49ba-91de-4b48f4073e6a">

