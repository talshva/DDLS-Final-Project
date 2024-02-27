//
// Verilog Module project1_ws.pe
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 14:09:55 18/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`include "headers.vh"


// Define a module named 'pe' with parameterizable data width for processing elements in a systolic array
module pe(clk_i, rst_n_i, start_operation_i, data_A_i, data_B_i, accum_o, data_A_o, data_B_o, ov_flag_o);
  
	parameter DATA_WIDTH = 8;  // Defines the width of input data ports A and B
	parameter BUS_WIDTH = 32;  // Defines the width of the accumulator output

	// Interface definitions
	input wire clk_i;              // Clock signal input for synchronous operation
	input wire rst_n_i;            // Reset signal (active low) for initializing or resetting the module
	input wire start_operation_i;  // Signal to start the multiply-accumulate operation
	input wire signed [DATA_WIDTH-1:0] data_A_i; // Input data A from the left or above PE
	input wire signed [DATA_WIDTH-1:0] data_B_i; // Input data B from the left or above PE
	output reg [BUS_WIDTH-1:0] accum_o;  // Output for the accumulated result of multiply-accumulate operations
	output reg [DATA_WIDTH-1:0] data_A_o; // Output data A, forwarded to the right or below PE
	output reg [DATA_WIDTH-1:0] data_B_o;  // Output data B, forwarded to the right or below PE
	output reg ov_flag_o; // Overflow flag indicating if an overflow occurred during accumulation

	// Internal registers for holding intermediate values and computation results
	reg signed [BUS_WIDTH-1:0] accum_prev; // Buffer for the accumulator to hold intermediate sum
	reg ov_buffer; // Buffer to keep track of overflow occurrence during operations
	reg signed [BUS_WIDTH-1:0] accum_curr;

	// Compute the multiplication of input data A and B
	wire signed [2*DATA_WIDTH-1:0] mul; // Temporary wire for holding the product of A and B
	assign mul = ($signed(data_A_i) * $signed(data_B_i)); // Perform multiplication operation

	always @(posedge clk_i) begin: pe_comb
		if (start_operation_i) begin
			// Multiply-accumulate operation: update accumulator and forward inputs
			accum_curr = accum_prev + mul;  // Perform signed addition
			// Check for overflow conditions 	  
			ov_buffer = ((accum_prev[BUS_WIDTH-1] == mul[2*DATA_WIDTH-1:0]) && (accum_curr[BUS_WIDTH-1] != accum_prev[BUS_WIDTH-1]));
			accum_prev = accum_curr[BUS_WIDTH-1:0]; // Update with the lower bits, discarding overflow
			accum_o = accum_curr[BUS_WIDTH-1:0]; // Update with the lower bits, discarding overflow
			ov_flag_o = ov_flag_o | ov_buffer;  // Set overflow flag if an overflow occurred
		end else begin
		  // No operation or reset: ensure clean state for next operation cycle
		  data_A_o = {DATA_WIDTH{1'b0}};
		  data_B_o = {DATA_WIDTH{1'b0}};
		  accum_curr = {BUS_WIDTH{1'b0}};		  
		  ov_buffer = 1'b0;
		  accum_prev = {BUS_WIDTH{1'b0}};  
		  accum_o = {BUS_WIDTH{1'b0}};	  
		  ov_flag_o = 1'b0;
		end 
	end  
	  
	always @(posedge clk_i or negedge rst_n_i) begin : reset_block
		if (!rst_n_i) begin
			// reset: ensure clean state for system
			data_A_o <= {DATA_WIDTH{1'b0}};
			data_B_o <= {DATA_WIDTH{1'b0}};
			accum_curr <= {BUS_WIDTH{1'b0}};		  
			ov_buffer <= 1'b0;
			accum_prev <= {BUS_WIDTH{1'b0}};  
			accum_o <= {BUS_WIDTH{1'b0}};	  
			ov_flag_o <= 1'b0;
			data_A_o <= {DATA_WIDTH{1'b0}};
			data_B_o <= {DATA_WIDTH{1'b0}};
		end else begin
			data_A_o <= data_A_i;  // Forward input A to the next PE
			data_B_o <= data_B_i;  // Forward input B to the next PE
		end
	end    
endmodule

