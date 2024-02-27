//
// Verilog Module project1_ws.operand
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 21:25:54 08/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//


`resetall
`timescale 1ns/10ps

module operand(clk_i, rst_n_i, addr, din, ien, pstrb_i, mat_flat_out, row_out);
   
    // Port Declarations
	parameter DATA_WIDTH = 8;
	parameter MAX_DIM = 4;
	
	input wire clk_i;
	input wire rst_n_i;
 
	input wire [1:0] addr;
	input wire [DATA_WIDTH*MAX_DIM - 1:0] din;
	input wire ien; 
	input wire [MAX_DIM-1:0] pstrb_i; // bus	
	output wire [DATA_WIDTH*MAX_DIM*MAX_DIM - 1:0] mat_flat_out; 
	output wire [DATA_WIDTH*MAX_DIM - 1:0] row_out;
  
	reg [DATA_WIDTH*MAX_DIM - 1:0] mem [MAX_DIM - 1:0];
	assign row_out = mem[addr];
	integer j;
	
	genvar i;	
	
	generate
		for (i = 0; i < MAX_DIM; i = i + 1)
			begin : pack_mem_mat
				assign mat_flat_out[(i+1)*DATA_WIDTH*MAX_DIM-1 -: DATA_WIDTH*MAX_DIM] = mem[i]; 
			end
	endgenerate
	
	generate		
		for(i = 0; i < MAX_DIM; i = i + 1) begin: pstrb
      always @(posedge clk_i) begin : FSM
        if (!rst_n_i) begin
            for (j = 0; j < MAX_DIM; j = j + 1) begin
              mem[j] <= 0;  
            end 
        end        
        else begin                   
    				  if(ien) begin
    					 mem[addr][(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH] <= pstrb_i[i]? (din[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH]) : (mem[addr][(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH]);
    				  end
				end
			end
		end
	endgenerate
	
endmodule