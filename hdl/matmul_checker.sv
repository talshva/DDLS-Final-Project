//
// Verilog Module project1_ws.matmul_checker
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 14:09:55 18/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`include "headers.vh"

module matmul_checker(
	matmul_intf.CHECKER intf
);
	import matmul_pkg::*;
	
	localparam MAX_DIM = BUS_WIDTH/DATA_WIDTH;
	localparam SUB_ADDRESS_FACTOR = MAX_DIM > 2 ? 16 : 4; 
	
	property valid_R_W; 
		@(posedge intf.clk) disable iff(!intf.rst_n)
			$rose(intf.psel) && !intf.busy |=> $rose(intf.pready);
	endproperty
	a_valid_R_W: assert property(valid_R_W) else $error("\n\tAssertion valid_R_W failed!\n\pready : %0d", intf.pready);
	cover property(valid_R_W); 

	property valid_busy; 
		@(posedge intf.clk) disable iff(!intf.rst_n)
			(intf.paddr == {ADDR_WIDTH{1'b0}}) && ($past(intf.paddr) != intf.paddr) && intf.pwdata[0] |->  ##2 intf.busy;
	endproperty
	a_valid_busy: assert property(valid_busy) else $error("\n\tAssertion valid_busy failed!\n\busy : %0d", intf.busy);
	cover property(valid_busy);

	property in_operation_approach; 
		@(posedge intf.clk) disable iff(!intf.rst_n)
			intf.busy && intf.psel |->intf.pslverr;
	endproperty
	a_in_operation_approach: assert property(in_operation_approach) else $error("\n\tAssertion in_operation_approach failed!\n\pslverr : %0d", intf.pslverr);
	cover property(in_operation_approach);
	
	property valid_address; 
		@(posedge intf.clk) disable iff(!intf.rst_n)
			intf.psel |-> intf.paddr inside {[0:(16 + 4*SP_NTARGETS)*SUB_ADDRESS_FACTOR]};
	endproperty
	a_valid_address: assert property(valid_address) else $error("\n\tAssertion valid_address failed!\n\paddr : %0d", intf.paddr);
	cover property(valid_address);

endmodule