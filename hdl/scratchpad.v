//
// Verilog Module project1_ws.scratchpad
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 21:25:54 08/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//


`resetall
`timescale 1ns/10ps

module scratchpad(clk_i, rst_n_i ,addr, bus_element_sel, din, ien, element_read_sel, element_write_sel, mat_flat_out, element_out);
   
    // Port Declarations
	parameter BUS_WIDTH = 32; // == BUS_WIDTH
	parameter MAX_DIM = 4;
	parameter ELEMENT_NUM = 1;
	parameter ADDR_WIDTH = 4;

	input wire clk_i;	
	input wire rst_n_i;
	input wire [ADDR_WIDTH-1:0] addr;
	input wire [1:0] bus_element_sel;
	input wire [BUS_WIDTH - 1:0] din;
	input wire ien; 
	input wire [1:0] element_read_sel; // bus
	input wire [1:0] element_write_sel; // bus		
	output reg [BUS_WIDTH*MAX_DIM*MAX_DIM - 1:0] mat_flat_out; 
	output reg [BUS_WIDTH - 1:0] element_out;

	localparam MEM_SIZE = MAX_DIM*MAX_DIM*ELEMENT_NUM;
	
	//reg [ADDR_WIDTH:0] k;
	reg [BUS_WIDTH - 1:0] mem [MEM_SIZE - 1:0];
	wire [BUS_WIDTH*MAX_DIM*MAX_DIM - 1:0] flat_mats [ELEMENT_NUM - 1:0];
	integer l, k;
	
	genvar i,j;	
	generate
		for (i = 0; i < ELEMENT_NUM; i = i + 1) begin : elements	
			for (j = 0; j < MAX_DIM*MAX_DIM; j = j + 1) begin : pack_mem_mat
				assign flat_mats[i][(j+1)*BUS_WIDTH-1 -: BUS_WIDTH] = mem[i*MAX_DIM*MAX_DIM + j]; 
			end	
			
			always @(posedge clk_i) begin : w_data
				if (!rst_n_i) begin
					for (k = 0; k < MAX_DIM*MAX_DIM; k = k + 1) begin
						mem[i*MAX_DIM*MAX_DIM + k] <= {BUS_WIDTH{1'b0}};  
					end 
				end        
				else if (ien) begin 
					if(element_write_sel == i) begin
						mem[i*MAX_DIM*MAX_DIM + addr] <= din;
					end
				end
			end	
		end		
	endgenerate	

	// Selection logic for mat_flat_out based on element_read_sel
	always @(*) begin : mat_output
		// Selection for mat_flat_out
		if (element_read_sel == 0) begin
			if (ELEMENT_NUM > 0) mat_flat_out = flat_mats[0];
			else mat_flat_out = {BUS_WIDTH*MAX_DIM*MAX_DIM{1'b0}};
		end else if (element_read_sel == 1) begin
			if (ELEMENT_NUM > 1) mat_flat_out = flat_mats[1];
			else mat_flat_out = {BUS_WIDTH*MAX_DIM*MAX_DIM{1'b0}};
		end else if (element_read_sel == 2) begin
			if (ELEMENT_NUM > 2) mat_flat_out = flat_mats[2];
			else mat_flat_out = {BUS_WIDTH*MAX_DIM*MAX_DIM{1'b0}};
		end else if (element_read_sel == 3) begin
			if (ELEMENT_NUM > 3) mat_flat_out = flat_mats[3];
			else mat_flat_out = {BUS_WIDTH*MAX_DIM*MAX_DIM{1'b0}};
		end
	end
	always @(*) begin : element_output
		// Selection for element_out
		if (bus_element_sel == 0) begin
			if (ELEMENT_NUM > 0) element_out = mem[addr];
			else element_out = {BUS_WIDTH{1'b0}};
		end else if (bus_element_sel == 1) begin
			if (ELEMENT_NUM > 1) element_out = mem[MAX_DIM*MAX_DIM + addr];
			else element_out = {BUS_WIDTH{1'b0}};
		end else if (bus_element_sel == 2) begin
			if (ELEMENT_NUM > 2) element_out = mem[2*MAX_DIM*MAX_DIM + addr];
			else element_out = {BUS_WIDTH{1'b0}};
		end else if (bus_element_sel == 3) begin
			if (ELEMENT_NUM > 3) element_out = mem[3*MAX_DIM*MAX_DIM + addr];
			else element_out = {BUS_WIDTH{1'b0}};
		end
	end
	
endmodule