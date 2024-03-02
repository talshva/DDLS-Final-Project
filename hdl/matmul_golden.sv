//
// Verilog Module project1_ws.matmul_golden
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 14:09:55 18/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`include "headers.vh"


// Matrix Multiplication Stimulus Module
module matmul_golden(
  	matmul_intf.GOLDEN intf
);
	import matmul_pkg::*;
	localparam MAX_DIM = BUS_WIDTH/DATA_WIDTH;

	integer i, j, error_count, folder_idx;
	integer total_err_counter;

	always @(posedge intf.clk or negedge intf.rst_n) begin: golden_cmp
		if (!intf.rst_n) begin
			folder_idx=0;
			total_err_counter = 0;
			intf.cmp_err_flag = 0;
			
		end
		else if( intf.start_cmp ) begin
			error_count = 0;
			for (i = 0; i < intf.N_file; i = i + 1) begin
				for (j = 0; j < intf.M_file; j = j + 1) begin
					if (intf.mat_res_gm[i][j] !== intf.mat_res_actual[i][j]) begin
						$display("[GOLDEN] Time: %0d [ns],  Mismatch found at mat_res[%1d][%1d]: Expected %0d, Got %0d", $realtime, i, j, intf.mat_res_gm[i][j], intf.mat_res_actual[i][j]);
						error_count = error_count + 1;
					end
				end 
			end
			if (error_count == 0) begin
				intf.cmp_err_flag = 0;
				if (VERBOSE) $display("[GOLDEN] Time: %0d [ns],  All elements matching. Verification passed.\n", $realtime);
			end else begin
				$display("[GOLDEN] Time: %0d [ns],  Verification failed with %0d mismatches.\n", $realtime, error_count);
				total_err_counter = total_err_counter + 1;
				intf.cmp_err_flag = 1;
			end			
			
			folder_idx = folder_idx + 1;
			if (folder_idx == NUM_FOLDERS)
			begin
				$display("[GOLDEN] Time: %0d [ns],  Passed %0d/%0d tests. Well Done!!!\n", $realtime, (NUM_FOLDERS-total_err_counter), NUM_FOLDERS);
				
			end
		end
	end
	
	
endmodule

