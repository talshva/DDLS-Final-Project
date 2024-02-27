//
// Verilog Module project1_ws.matmul_coverage
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 14:09:55 18/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`include "headers.vh"

module matmul_coverage (
	matmul_intf.COVERAGE intf
);
	import matmul_pkg::*;
	
	localparam MAX_DIM = BUS_WIDTH/DATA_WIDTH;
	localparam SUB_ADDRESS_WIDTH = MAX_DIM > 2 ? 4 : 2;
	int current_value;
	bit current_sign;

	covergroup cg_matmul_inputs @(posedge intf.clk);
		// Cover RESET condition based on rst_n_i (active low reset)
		RESET: coverpoint intf.rst_n {
			bins low = {0}; // Reset asserted
			bins high = {1}; // Reset not asserted
		}		
		
		// Cover PSEL condition based on psel_i (peripheral select)
		PSEL: coverpoint intf.psel {
			bins low = {0};
			bins high = {1};
		}

		// Cover ENABLE condition based on psel_i (peripheral select)
		ENABLE: coverpoint intf.penable {
			bins low = {0};
			bins high = {1};
		}
		
		// Cover WRITE operation based on pwrite_i
		WRITE: coverpoint intf.pwrite iff (intf.psel == 1){
			bins read = {0}; // Read operation
			bins write = {1}; // Write operation
		}
		
		// Coverpoint that counts the number of 1's in pstrb_i
		STROBE: coverpoint $countones(intf.pstrb) {
			bins no_strobe = {0}; 
			bins strobe_1 = {1}; 
			bins strobe_11 = {2}; 
			bins strobe_111 = {3}; 
			bins strobe_1111 = {4}; 
		}

		// Cover the address range
		ADDRESS_SLICE: coverpoint intf.paddr[SUB_ADDRESS_WIDTH + 5 : SUB_ADDRESS_WIDTH] {
				bins control  = {5'b00000};
				bins op_A     = {5'b00100};
				bins OP_B     = {5'b01000};
				bins flags    = {5'b01100};
				bins SP_0     = {5'b10000};
				bins SP_1     = {5'b10100};
				bins SP_2     = {5'b11000};
				bins SP_3     = {5'b11100};
		}

		// Cover pready_i to track ready signal's behavior
		READY: coverpoint intf.pready {
			bins not_ready = {0};
			bins ready = {1};
		}

		// Cover pslverr_i to track if a slave error occurs
		SLAVE_ERR: coverpoint intf.pslverr {
			bins no_error = {0};
			bins error = {1};
		}
		
	    // Cover busy signal
		BUSY: coverpoint intf.busy {
			bins not_busy = {0};
			bins busy = {1};
		}

		// Cover total_err_counter with ranges
		TOTAL_ERR: coverpoint intf.cmp_err_flag {
			bins no_test_case_error = {0}; // No error
			bins test_case_error = {1}; // No error
		}

		// Cover N dimension
		DIM_N: coverpoint intf.N_file {
			bins sizes[] = {[1:4]};
		}

		// Cover K dimension
		DIM_K: coverpoint intf.K_file {
			bins sizes[] = {[1:4]};
		}

		// Cover M dimension
		DIM_M: coverpoint intf.M_file {
			bins sizes[] = {[1:4]};
		}
		
		// Cover Biased flags values
		BIASED: coverpoint intf.Biased_flag {
			bins not_biased = {0}; 
			bins biased = {1};
		}			

		// Cover M dimension
		SPN_SELECT: coverpoint intf.SPN_SELECT {
			bins sizes[] = {[0:3]};
		}	
	endgroup

	// cover result matrix element's sign
	covergroup cg_mat_elements_sign with function sample(bit sign_bit);
		coverpoint sign_bit {
			bins negative = {1};
			bins positive = {0};
		}
	endgroup


	always @(posedge intf.clk) begin
		if ( intf.start_cmp ) begin
			for (int i = 0; i < MAX_DIM; i++) begin
				for (int j = 0; j < MAX_DIM; j++) begin
					// Get the value and sign bit from the current element
					current_value = intf.mat_res_actual[i][j];
					current_sign = current_value[DATA_WIDTH-1];
					cg_sign_inst.sample(current_sign);
				end
			end
		end
	end
	
	// Instantiate the covergroup
	cg_matmul_inputs cg_inputs = new();
	cg_mat_elements_sign cg_sign_inst = new();

endmodule

