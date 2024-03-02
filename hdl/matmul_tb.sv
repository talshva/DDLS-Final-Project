//
// Verilog Module project1_ws.matmul_tb
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 14:09:55 18/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`include "headers.vh"

// Matrix Multiplication Stimulus Module
module matmul_tb;
	import matmul_pkg::*;
	
	// Internal signal declarations
	logic clk = 1'b0, rst_n;
	// Interface instantiation
	matmul_intf intf(
		.clk(clk), .rst_n(rst_n)
	);

	// Init clock process
	initial forever 
		#(CLK_NS/2) clk = ~clk;
	// Init reset process
	initial begin: TOP_RST
		rst_n = 1'b0; // Assert reset
		// Reset for RST_CYC cycles
		repeat(RST_CYC) @(posedge clk);
		rst_n = 1'b1; // Deassert reset
	end		
	
	
	// Modules Instantiations
	// Stimulus
	matmul_stimulus stimulus_instance (
		.intf(intf)
	);
	// Golden model
	matmul_golden golden_instance (
		.intf(intf)
	);
	// Checker
    matmul_checker checker_instance(
		.intf(intf)
    );
	// Coverage
    matmul_coverage coverage_instance(
		.intf(intf)
    );
	// DUT (we kept matmul as verilog 2005 .v file..)
	matmul #(
        .DATA_WIDTH(DATA_WIDTH),
        .BUS_WIDTH(BUS_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
		.SP_NTARGETS(SP_NTARGETS)
    ) matmul_instance (
        .clk_i(clk),
        .rst_n_i(rst_n),
        .psel_i(intf.psel),
        .penable_i(intf.penable),
        .pwrite_i(intf.pwrite),
        .pstrb_i(intf.pstrb),
        .pwdata_i(intf.pwdata),
        .paddr_i(intf.paddr),
        .pready_o(intf.pready),
        .pslverr_o(intf.pslverr),
	    .prdata_o(intf.prdata),
        .busy_o(intf.busy)
    );
	

	
	
endmodule