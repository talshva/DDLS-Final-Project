//
// Verilog Module project1_ws.matmul_calc
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 14:09:55 18/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`include "headers.vh"


module matmul_calc(clk_i, rst_n_i, start_operation_i, a_flat_i, b_flat_i, c_flat_i, result_flat_o, ov_reg_o);
  
/*This matmul_calc module embodies the core of a systolic array architecture designed for performing matrix multiplication operations efficiently. 
  By employing a grid of processing elements (PEs), it facilitates parallel computation, significantly accelerating the matrix multiplication process. 
  The inputs to the module are flattened matrices A and B, along with a pre-calculated accumulator matrix, which are then dynamically unpacked, 
  processed through the interconnected PEs, and repacked into the output matrix. The systolic design ensures that data flows seamlessly through the PEs,
  with each element performing a portion of the computation and passing the elements to its neighbors, thus optimizing both throughput and latency. 
*/  
  
    // Define the width of the input data and the size of the bus.
    parameter DATA_WIDTH = 8; // Width of the matrix elements
    parameter BUS_WIDTH = 32; // Width for the accumulator output
    
 	localparam MAX_DIM = BUS_WIDTH/DATA_WIDTH ;// Size of the matrix

   // Input and output ports
    input  clk_i; // Clock input
    input  rst_n_i; // Reset input, active low
	input  start_operation_i; // Start signal for matrix multiplication
	input  [DATA_WIDTH*MAX_DIM-1:0] a_flat_i; // Flattened input matrix A
    input  [DATA_WIDTH*MAX_DIM-1:0] b_flat_i; // Flattened input matrix B
    input  [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] c_flat_i; // Flattened accumulator matrix from previous calculations
    output [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] result_flat_o; // Flattened output matrix
    output [MAX_DIM*MAX_DIM-1:0] ov_reg_o; // Overflow flag for each PE
    


    // Interconnect arrays between PEs for horizontal and vertical data movement
    wire [DATA_WIDTH-1:0] pe_a [MAX_DIM*MAX_DIM-1:0]; // Horizontal connections (left to right)
    wire [DATA_WIDTH-1:0] pe_b [MAX_DIM*MAX_DIM-1:0]; // Vertical connections (top to bottom)
    wire [BUS_WIDTH-1:0]  pe_accum [MAX_DIM*MAX_DIM-1:0]; // Accumulator outputs from PEs


    // 2D arrays to hold parsed flattened input arrays for easier handling
    wire [DATA_WIDTH-1:0] a [MAX_DIM-1:0]; // Matrix A elements
    wire [DATA_WIDTH-1:0] b [MAX_DIM-1:0]; // Matrix B elements
    wire [BUS_WIDTH-1:0] c [MAX_DIM*MAX_DIM-1:0]; // Pre-calculated accumulator values
	
	
	wire [MAX_DIM*MAX_DIM-1:0] systolic_ov; // Overflow flags from systolic operation
	reg [MAX_DIM*MAX_DIM-1:0] c_ov; // Overflow flags from accumulation
    assign ov_reg_o = systolic_ov | c_ov; // Combine overflow flags
    
    genvar i,j;
    // Unpack the flattened input array into a 2D array    
    generate
        for (i = 0; i < MAX_DIM; i = i + 1)
        begin : unpack_a_b
        	// Unpack Matrix A and B elements into 2D arrays
        			assign a[i] = a_flat_i[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH];
        			assign b[i] = b_flat_i[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH];
        end
    endgenerate

    generate
        for (i = 0; i < MAX_DIM*MAX_DIM; i = i + 1)
        begin : unpack_c_i
			     assign c[i] = c_flat_i[(i+1)*BUS_WIDTH-1 : i*BUS_WIDTH];
        end
    endgenerate

    // Instantiate the PEs and connect them
    generate
        for (i = 0; i < MAX_DIM; i = i + 1)
        begin : row
            for (j = 0; j < MAX_DIM; j = j + 1)
            begin : col
                pe #(.DATA_WIDTH(DATA_WIDTH),.BUS_WIDTH(BUS_WIDTH)) PE_instance(
                // Instantiate PE with proper connections for data A, data B, and accumulation
                    .clk_i(clk_i),
                    .rst_n_i(rst_n_i),
				            .start_operation_i(start_operation_i),
                    // Select input from left or previous PE in row for data A
                    .data_A_i((j == 0 ? a[i] : pe_a[i*MAX_DIM + j - 1])), // Left or above PE's output
                    // Select input from above or previous PE in column for data B
                    .data_B_i((i == 0 ? b[j] : pe_b[j*MAX_DIM + i - 1])), 
                    .data_A_o(pe_a[i*MAX_DIM + j]), // Output to the right PE in the row
                    .data_B_o(pe_b[j*MAX_DIM + i]), // Output to the below PE in the column
                    .accum_o(pe_accum[i*MAX_DIM + j]), // Accumulated result
                    .ov_flag_o(systolic_ov[i*MAX_DIM + j]) // Overflow flag
                );
            end
        end
    endgenerate

    // Pack the outputs from PEs into the result output vector
    generate
      for (i = 0; i < MAX_DIM*MAX_DIM; i = i + 1)
      begin : pack_loop
        // Combine accumulator outputs with pre-calculated values and check for Carry (need to change to ov checking later......)
		assign result_flat_o[(i+1)*BUS_WIDTH-1 : i*BUS_WIDTH] = (pe_accum[i] + c[i]);
		
		always @(posedge clk_i or negedge rst_n_i) begin : ov_check
			if (!rst_n_i) begin
				// reset: ensure clean state for system
				c_ov[i] <= {MAX_DIM*MAX_DIM{1'b0}};
			end else begin
				c_ov[i] <= ((pe_accum[i][BUS_WIDTH-1] == c[i][BUS_WIDTH-1]) && (result_flat_o[(i+1)*BUS_WIDTH-1] != pe_accum[i][BUS_WIDTH-1]));
			end
		end    
	
		  
      end 
    endgenerate
	
	

	

endmodule