  //
  // Verilog Module project1_ws.tb_matmul_calc
  //
  // Created:
  //          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
  //          at - 17:21:26 27/01/2024
  //
  // using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
  //    
  
  `timescale 1ns/10ps
  module tb_matmul_calc;
      localparam DATA_WIDTH = 8;  // Assuming 8-bit data width for simplicity
      localparam BUS_WIDTH = 32;     // 4x4 matrices
      localparam CLK_PERIOD = 10; // Clock period in ns
      localparam MAX_DIM = BUS_WIDTH/DATA_WIDTH;
      localparam ARRAY_LENGTH = 2*MAX_DIM - 1;
     
      // FSM State declarations
      localparam RESET =  3'b000;
      localparam INIT =   3'b001;
      localparam ACTION = 3'b010;
      localparam FINISH = 3'b011;
      localparam DONE   = 3'b100;

      reg [2:0] current_state = RESET;
      reg [2:0] next_state;
  
      // Cycle counter
      integer i, j, cycle = 0, zero_propegate = 0;
    
      // Define the 2D matrix
      reg [DATA_WIDTH-1:0] mat_A_2d [MAX_DIM-1:0][MAX_DIM-1:0];
      reg [DATA_WIDTH-1:0] mat_B_2d [MAX_DIM-1:0][MAX_DIM-1:0];
      
      // Define the shifted arrays
      reg [DATA_WIDTH-1:0] shifted_arrays_A [MAX_DIM-1:0][ARRAY_LENGTH-1:0];
      reg [DATA_WIDTH-1:0] shifted_arrays_B [MAX_DIM-1:0][ARRAY_LENGTH-1:0];
  
      // Define the output vector
      reg [DATA_WIDTH-1:0] input_vector_A [MAX_DIM-1:0];
      reg [DATA_WIDTH-1:0] input_vector_B [MAX_DIM-1:0];
      reg [DATA_WIDTH*MAX_DIM-1:0] flat_input_vector_A = 0;//{DATA_WIDTH*MAX_DIM{'b0}}; 
      reg [DATA_WIDTH*MAX_DIM-1:0] flat_input_vector_B = 0;//{DATA_WIDTH*MAX_DIM{'b0}}; 
      // Inputs
      reg clk = 1'b1;
      reg rst_n = 1'b1;
      reg [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] c_flat = 0;//{DATA_WIDTH*MAX_DIM*MAX_DIM{'b0}};
      reg start_operation = 1'b0;
      reg [BUS_WIDTH-1:0] printed_element;  // Temporary register to hold each element
  
      // Outputs
      wire [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] result_flat;
      wire [MAX_DIM*MAX_DIM-1:0] ov_reg;
        
      // Instantiate the matmul_calc module
      matmul_calc #(
          .DATA_WIDTH(DATA_WIDTH),
          .BUS_WIDTH(BUS_WIDTH)  // Assuming BUS_WIDTH = DATA_WIDTH*MAX_DIM
      ) calc_instance (
          .clk_i(clk),
          .rst_n_i(rst_n),
          .start_operation_i(start_operation),
          .a_flat_i(flat_input_vector_A),
          .b_flat_i(flat_input_vector_B),
          .c_flat_i(c_flat),
          .result_flat_o(result_flat),
          .ov_reg_o(ov_reg)
      );
  
    // Clock generation
    initial begin : clock
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
      
    // FSM Implementation
    always @(negedge clk) begin : state_fsm
        current_state <= next_state;
    end

    // FSM Next State Logic
    always @(*) begin : next_state_fsm
        case (current_state)
            RESET: next_state <= INIT;
            INIT: next_state <= ACTION;
            ACTION: next_state <= (cycle < ARRAY_LENGTH) ? ACTION : FINISH;
            FINISH: next_state <= (zero_propegate < MAX_DIM-1) ? FINISH : DONE;
            DONE: next_state <= DONE;
        default: next_state <= RESET;
        endcase
    end

    // FSM Output Logic
    always @(negedge clk) begin : logic_fsm
        case (current_state)
            RESET: begin
                // Reset logic 
                rst_n <= 1'b0;
                flat_input_vector_A <= 0;
                flat_input_vector_B <= 0;
                c_flat <= 0;
                start_operation <= 1'b0;
                zero_propegate <= 0;
                cycle <= 0;
                
                // Initialize shifted arrays with zeros
                for (i = 0; i < MAX_DIM; i = i + 1) begin
                    for (j = 0; j < ARRAY_LENGTH; j = j + 1) begin
                        shifted_arrays_A[i][j] <= 0;
                        shifted_arrays_B[i][j] <= 0;
                    end
                end
                
                // Initialize the matrix
                mat_A_2d[0][0] <= 1; mat_A_2d[0][1] <= 2; mat_A_2d[0][2] <= 3; mat_A_2d[0][3] <= 4;
                mat_A_2d[1][0] <= 5; mat_A_2d[1][1] <= 6; mat_A_2d[1][2] <= 7; mat_A_2d[1][3] <= 8;
                mat_A_2d[2][0] <= 8; mat_A_2d[2][1] <= 7; mat_A_2d[2][2] <= 6; mat_A_2d[2][3] <= 5;
                mat_A_2d[3][0] <= 4; mat_A_2d[3][1] <= 3; mat_A_2d[3][2] <= 2; mat_A_2d[3][3] <= 1;
        
                mat_B_2d[0][0] <= 1; mat_B_2d[0][1] <= 2; mat_B_2d[0][2] <= 3; mat_B_2d[0][3] <= 4; 
                mat_B_2d[1][0] <= 5; mat_B_2d[1][1] <= 6; mat_B_2d[1][2] <= 7; mat_B_2d[1][3] <= 8;
                mat_B_2d[2][0] <= 8; mat_B_2d[2][1] <= 7; mat_B_2d[2][2] <= 6; mat_B_2d[2][3] <= 5; 
                mat_B_2d[3][0] <= 4; mat_B_2d[3][1] <= 3; mat_B_2d[3][2] <= 2; mat_B_2d[3][3] <= 1; 
                
                               
            end      
            INIT: begin
                // Shift the matrix elements into the arrays
                for (i = 0; i < MAX_DIM; i = i + 1) begin
                    for (j = 0; j < MAX_DIM; j = j + 1) begin
                        shifted_arrays_A[i][j + i] <= mat_A_2d[i][j];
                        shifted_arrays_B[i][j + i] <= mat_B_2d[j][i];
                    end
                end    
                rst_n <= 1'b1;
                start_operation = 1'b1;
      
            end
            ACTION: begin
                $display("Cycle: %d, input_A: %h , input_B: %h", cycle, flat_input_vector_A, flat_input_vector_B);
                // Generate output vector based on the current cycle
                for (i = 0; i < MAX_DIM; i = i + 1) begin
                    //idx = MAX_DIM - 1 - i;
                    if (i == MAX_DIM-1) begin
                      flat_input_vector_A[DATA_WIDTH-1:0] <= shifted_arrays_A[0][cycle];
                      flat_input_vector_B[DATA_WIDTH-1:0] <= shifted_arrays_B[0][cycle];
                    end
                    else if (i==MAX_DIM-2) begin
                      flat_input_vector_A[2*DATA_WIDTH-1:DATA_WIDTH] <= shifted_arrays_A[1][cycle];
                      flat_input_vector_B[2*DATA_WIDTH-1:DATA_WIDTH] <= shifted_arrays_B[1][cycle];                      
                    end
                    else if (i==MAX_DIM-3) begin
                      flat_input_vector_A[3*DATA_WIDTH-1:2*DATA_WIDTH] <= shifted_arrays_A[2][cycle];
                      flat_input_vector_B[3*DATA_WIDTH-1:2*DATA_WIDTH] <= shifted_arrays_B[2][cycle];                      
                    end
                    else if (i==MAX_DIM-4) begin
                      flat_input_vector_A[4*DATA_WIDTH-1:3*DATA_WIDTH] <= shifted_arrays_A[3][cycle];
                      flat_input_vector_B[4*DATA_WIDTH-1:3*DATA_WIDTH] <= shifted_arrays_B[3][cycle];                      
                    end                    
                end
                
                cycle <= cycle + 1;
                if (cycle == ARRAY_LENGTH) begin
                    flat_input_vector_A <= 0;
                    flat_input_vector_B <= 0;
                end
            end
            FINISH: begin
                // zero the inputs
                flat_input_vector_A <= 0;
                flat_input_vector_B <= 0;
                zero_propegate <= zero_propegate + 1;
              
            end
            DONE: begin
				$display("Result Output Matrix: ");  // Print a new line
				for (i = 0; i < MAX_DIM*MAX_DIM; i = i + 1) begin
					printed_element = result_flat[i*BUS_WIDTH +: BUS_WIDTH];  // Extract 8 bits for each element

					// Print element, stay on the same line
					$write("%0d\t",printed_element);  // Use $write to stay on the same line

					// Check if we are at the end of a row
					if ((i + 1) % MAX_DIM == 0) begin
						$display("");  // Print a new line
					end   

					//$display("Element %0d: %0d", i, printed_element);  // Print element as integer
				end

				$display("Output result: %h", result_flat);
                $display("Overflow flag: %d", ov_reg);
				start_operation <= 1'b0;		
				$finish;
            end
        endcase
    end
  endmodule
