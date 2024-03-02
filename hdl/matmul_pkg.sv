//
// Verilog Module project1_ws.matmul_pkg
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 14:09:55 18/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

package matmul_pkg;
	// DUT Params
	parameter bit VERBOSE = 1; // Change to 1 to show more run info in terminal
	parameter NUM_FOLDERS = 10000;
  parameter BUS_WIDTH = 64;
	parameter DATA_WIDTH = 16;
  parameter ADDR_WIDTH = 32;
	parameter SP_NTARGETS = 4;
	parameter string PROJECT_PATH =  $sformatf("C:/HDS/Project1_verilog/Project1_verilog_lib/hdl/GM/BW_%0d_DW_%0d_AW_%0d_SPN_%0d",
												BUS_WIDTH, DATA_WIDTH, ADDR_WIDTH, SP_NTARGETS);
	// TB Params
	localparam time CLK_NS = 10ns; // 100MHz Clock
	localparam int unsigned RST_CYC = 1;
	
endpackage