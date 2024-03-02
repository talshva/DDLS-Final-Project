//
// Verilog Module project1_ws.matmul
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 14:09:55 18/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`include "headers.vh"

module matmul(clk_i, rst_n_i, psel_i, penable_i, pwrite_i, pstrb_i, pwdata_i, paddr_i, pready_o, pslverr_o, prdata_o, busy_o);

	parameter DATA_WIDTH = 8 ; // Bit-width of a single element. Can be 8,16 or 32. 	<=BW/2
	parameter BUS_WIDTH = 32;  // APB Bus data bit-width. Can be 16,32 or 64. 	BW%DW=0
	parameter ADDR_WIDTH = 16; // APB address space bit-width. Can be 16,24 or 32.
	parameter SP_NTARGETS = 4; // The number of addressable targets in SP (SPN), Can be 1,2 or 4.
	localparam MAX_DIM = BUS_WIDTH / DATA_WIDTH; // Max dimension size for matrix (MIN(BW/DW),4)

	input wire  clk_i; // matmul
	input wire  rst_n_i; // matmul
	input wire  psel_i; // bus
	input wire  penable_i;// bus
	input wire  pwrite_i;// bus
	input wire  [MAX_DIM-1:0] pstrb_i; // bus
	input wire  [BUS_WIDTH-1:0] pwdata_i; // bus
	input wire  [ADDR_WIDTH-1:0] paddr_i; // bus
	output wire  pready_o; // bus
	output wire  pslverr_o; // bus
	output wire  [BUS_WIDTH-1:0] prdata_o; // bus
	output wire  busy_o; // Busy signal, indicating the design cannot be written to
	// Internal signals for data flow and control
	wire  [MAX_DIM*MAX_DIM-1:0] ov; 
	wire  EOP;
	wire [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] result;
	wire [BUS_WIDTH*MAX_DIM-1:0] operand_A; 
	wire [BUS_WIDTH*MAX_DIM-1:0] operand_B;
	wire [(MAX_DIM*DATA_WIDTH)-1:0] in_A;
	wire [(MAX_DIM*DATA_WIDTH)-1:0] in_B;
	wire [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] operand_C;
	wire [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] operand_C_fitted;
	wire [15:0] control_reg; 

	// Instance of APB Slave
	apbslave #(
		.DATA_WIDTH(DATA_WIDTH),
		.BUS_WIDTH(BUS_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.SP_NTARGETS(SP_NTARGETS)
	)
	apb_instance (
		.clk_i(clk_i),
		.rst_n_i(rst_n_i),
		.psel_i(psel_i),
		.penable_i(penable_i),
		.pwrite_i(pwrite_i),
		.pstrb_i(pstrb_i),
		.pwdata_i(pwdata_i),
		.paddr_i(paddr_i),
		.ov_i(ov),
		.EOP_i(EOP),
		.result_i(result),
		.operand_A_o(operand_A),
		.operand_B_o(operand_B),
		.operand_C_o(operand_C),
		.control_reg_o(control_reg),
		.pready_o(pready_o),
		.pslverr_o(pslverr_o),
		.prdata_o(prdata_o),
		.busy_o(busy_o)
		);


	// Instance of Matrix Shifter
	matmul_shifter #(
	.DATA_WIDTH(DATA_WIDTH),
	.BUS_WIDTH(BUS_WIDTH)
	)
	shifter_instance (
		.clk_i(clk_i),
		.rst_n_i(rst_n_i),
		.start_bit_i(control_reg[0]),
		.matrix_A(operand_A),
		.matrix_B(operand_B),
		.c_flat_in(operand_C),
		.N_i(control_reg[9:8]),
		.K_i(control_reg[11:10]),
		.M_i(control_reg[13:12]),
		.out_vector_a(in_A), 
		.out_vector_b(in_B),
		.c_flat_out(operand_C_fitted),
		.done_o(EOP)
	);


	// Instance of Matrix Multiplication Calculator
	matmul_calc #(
		.DATA_WIDTH(DATA_WIDTH),
		.BUS_WIDTH(BUS_WIDTH)
	)
	calc_instance (
		.clk_i(clk_i),
		.rst_n_i(rst_n_i),
		.start_operation_i(control_reg[0]),
		.a_flat_i(in_A),
		.b_flat_i(in_B),
		.c_flat_i(operand_C_fitted),
		.result_flat_o(result),
		.ov_reg_o(ov)
	);


endmodule

