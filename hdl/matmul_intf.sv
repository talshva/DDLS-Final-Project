//
// Verilog Module project1_ws.matmul_intf
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 14:09:55 18/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`include "headers.vh"

interface matmul_intf(input wire clk, input wire rst_n);
	import matmul_pkg::*;

	localparam MAX_DIM = BUS_WIDTH/DATA_WIDTH;
	
	logic psel;
    logic penable;
    logic pwrite;
    logic [MAX_DIM-1:0] pstrb;
    logic [BUS_WIDTH-1:0] pwdata;
    logic [ADDR_WIDTH-1:0] paddr;
    logic [BUS_WIDTH-1:0] prdata;
    logic pready;
    logic pslverr;
    logic busy;
	logic start_cmp;
	logic cmp_err_flag;
	integer N_file, M_file, K_file, SPN_SELECT, Biased_flag;
	integer mat_res_gm [MAX_DIM-1:0][MAX_DIM-1:0];
	integer mat_res_actual [MAX_DIM-1:0][MAX_DIM-1:0]; 


	modport COVERAGE (input clk, rst_n, psel, penable, pwrite, pstrb, pwdata, paddr, pready, pslverr, prdata, busy, start_cmp, cmp_err_flag, N_file, K_file, M_file, SPN_SELECT, Biased_flag, mat_res_actual);
	modport CHECKER  (input clk, rst_n, psel, penable, pwrite, pstrb, pwdata, paddr, pready, pslverr, prdata, busy);
	modport DUT 	 (input clk, rst_n, psel, penable, pwrite, pstrb, pwdata, paddr, 
					  output pready, pslverr, prdata, busy);
	modport STIMULUS (input clk, rst_n, prdata, pready, pslverr, busy,
					  output psel, penable, pwrite, pstrb, pwdata, paddr, start_cmp, mat_res_gm ,mat_res_actual ,N_file, K_file, M_file, SPN_SELECT, Biased_flag);
	modport GOLDEN	 (input clk, rst_n, start_cmp, mat_res_gm, mat_res_actual, N_file, M_file, 
					  output cmp_err_flag);	
	
endinterface
