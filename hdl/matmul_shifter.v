//
// Verilog Module project1_ws.matrix_shifter
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 21:25:54 08/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//


`resetall
`timescale 1ns/10ps

    
module matmul_shifter(
    clk_i,
    rst_n_i,
    start_bit_i,
    matrix_A,
    matrix_B,
    c_flat_in,
    N_i,
    K_i,
    M_i,
    out_vector_a,
    out_vector_b,
    c_flat_out,
    done_o
);
    parameter DATA_WIDTH = 8; // Define as per requirement
    parameter BUS_WIDTH = 32; // Define as per requirement
    localparam MAX_DIM = BUS_WIDTH / DATA_WIDTH; // Do not change

    // Parameters for FSM states

    parameter [1:0] STATE_IDLE = 2'b00;
    parameter [1:0] STATE_SHIFT = 2'b01;
    parameter [1:0] STATE_DONE = 2'b10;

    // Inputs and Outputs
    input wire clk_i;
    input wire rst_n_i;
    input wire start_bit_i;
    input wire [(MAX_DIM*MAX_DIM*DATA_WIDTH)-1:0] matrix_A;
    input wire [(MAX_DIM*MAX_DIM*DATA_WIDTH)-1:0] matrix_B;
    input wire [(BUS_WIDTH*MAX_DIM*MAX_DIM)-1:0] c_flat_in;
    input wire [1:0] N_i,K_i,M_i;
    output reg [(MAX_DIM*DATA_WIDTH)-1:0] out_vector_a;
    output reg [(MAX_DIM*DATA_WIDTH)-1:0] out_vector_b;
    output reg [(BUS_WIDTH*MAX_DIM*MAX_DIM)-1:0] c_flat_out;
    output reg done_o;

    // Internal Variables
    integer i, j, cycle_count, N, K, M;
    reg [(MAX_DIM*MAX_DIM*DATA_WIDTH)-1:0] shifted_matrix_A;
    reg [(MAX_DIM*MAX_DIM*DATA_WIDTH)-1:0] shifted_matrix_B;
    wire [(MAX_DIM*MAX_DIM*DATA_WIDTH)-1:0] matrix_B_T;
    
    reg [DATA_WIDTH-1:0] temp_a [MAX_DIM-1:0];
    reg [DATA_WIDTH-1:0] temp_b [MAX_DIM-1:0];
    reg [1:0] current_state;

    genvar row, col;
    generate
        for (row = 0; row < MAX_DIM; row = row + 1) begin: row_loop
            for (col = 0; col < MAX_DIM; col = col + 1) begin: col_loop
               assign matrix_B_T[(col*MAX_DIM+row+1)*DATA_WIDTH-1 -: DATA_WIDTH] = matrix_B[(row*MAX_DIM+col+1)*DATA_WIDTH-1 -: DATA_WIDTH];
            end
        end
    endgenerate
  
    // FSM Implementation
    always @(posedge clk_i or negedge rst_n_i) begin : FSM
        if (!rst_n_i) begin
            // Reset logic
            out_vector_a <= 0;
            out_vector_b <= 0;
            shifted_matrix_A <= 0;
            shifted_matrix_B <= 0;
            done_o <= 0;
            current_state <= STATE_IDLE;
            cycle_count <= 0;
            for (i = 0; i < MAX_DIM; i = i + 1) begin
                temp_a[i] <= 0;
                temp_b[i] <= 0;
            end
            N <= 0;
            K <= 0;
            M <= 0;
        end 
        else begin
            case (current_state)
                STATE_IDLE: begin
                    if (start_bit_i) begin  
                        shifted_matrix_A <= matrix_A;
                        shifted_matrix_B <= matrix_B_T;
                        current_state <= STATE_SHIFT;
                        cycle_count <= 0;
                        done_o <= 0;
                        N <= N_i + 1;
                        K <= K_i + 1;
                        M <= M_i + 1;
                    end
                end
				
				// Cycle 3
				// N=3
				// K=4
				// M=4
                STATE_SHIFT: begin
                    if (cycle_count < (2*MAX_DIM)) begin      
                        // Shift data and insert zeros as per the described pattern
                        
                          // Handle different cases for N
                          case(N)
                              1: begin
                                  // Implement logic for N=1
                                  for (i = 0; i < 1; i = i + 1) begin
                                      if ((i <= cycle_count) && (cycle_count-i<K)) begin
                                        temp_a[i] <=  shifted_matrix_A[((MAX_DIM-1)*i+1)*DATA_WIDTH-1 -: DATA_WIDTH];
                                      end 
                                      else begin
                                        temp_a[i] <= 0;
                                      end
                                  end
                        
                                  // Concatenate each element of temp_a and temp_b into the output vectors
                                  for (i = 0; i < 1; i = i + 1) begin
                                      out_vector_a[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= temp_a[i];
                                  end
    
                              end
                              2: begin
                                  // Implement logic for N=2
                                 for (i = 0; i < 2; i = i + 1) begin
                                      if ((i <= cycle_count) && (cycle_count-i<K)) begin
                                        temp_a[i] <=  shifted_matrix_A[((MAX_DIM-1)*i+1)*DATA_WIDTH-1 -: DATA_WIDTH];
                                      end 
                                      else begin
                                        temp_a[i] <= 0;
                                      end
                                  end
                                  // Concatenate each element of temp_a and temp_b into the output vectors
                                  for (i = 0; i < 2; i = i + 1) begin
                                      out_vector_a[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= temp_a[i];
                                  end
                              end
                              3: begin
                                  // Implement logic for N=3
                                 for (i = 0; i < 3; i = i + 1) begin
                                      if ((i <= cycle_count) && (cycle_count-i<K)) begin
                                        temp_a[i] <=  shifted_matrix_A[((MAX_DIM-1)*i+1)*DATA_WIDTH-1 -: DATA_WIDTH];
                                      end 
                                      else begin
                                        temp_a[i] <= 0;
                                      end
                                  end
                                  // Concatenate each element of temp_a and temp_b into the output vectors
                                  for (i = 0; i < 3; i = i + 1) begin
                                      out_vector_a[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= temp_a[i];
                                  end
                              end
                              4: begin
                                  // Implement logic for N=4
                                 for (i = 0; i < 4; i = i + 1) begin
                                      if ((i <= cycle_count) && (cycle_count-i<K)) begin
                                        temp_a[i] <=  shifted_matrix_A[((MAX_DIM-1)*i+1)*DATA_WIDTH-1 -: DATA_WIDTH];
                                      end 
                                      else begin
                                        temp_a[i] <= 0;
                                      end
                                  end
                                  // Concatenate each element of temp_a and temp_b into the output vectors
                                  for (i = 0; i < 4; i = i + 1) begin
                                      out_vector_a[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= temp_a[i];
                                  end
                              end
                          endcase
                          
                          // Handle different cases for M     
                          case(M)
                              1: begin
                                  // Implement logic for M=1
                                  for (j = 0; j < 1; j = j + 1) begin   
                                      if ((j <= cycle_count) && (cycle_count-j<K)) begin
                                          temp_b[j] <= shifted_matrix_B[((MAX_DIM-1)*j+1)*DATA_WIDTH-1 -: DATA_WIDTH];
                                      end else begin
                                          temp_b[j] <= 0;
                                      end
                                  end  
                        
                                  // Concatenate each element of temp_a and temp_b into the output vectors
                                  for (j = 0; j < 1; j = j + 1) begin
                                      out_vector_b[(j+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= temp_b[j];
                                  end
    
                              end
                              2: begin
                                  // Implement logic for M=2
                                  for (j = 0; j < 2; j = j + 1) begin   
                                      if ((j <= cycle_count) && (cycle_count-j<K)) begin
                                          temp_b[j] <= shifted_matrix_B[((MAX_DIM-1)*j+1)*DATA_WIDTH-1 -: DATA_WIDTH];
                                      end else begin
                                          temp_b[j] <= 0;
                                      end
                                  end  
                                  // Concatenate each element of temp_a and temp_b into the output vectors
                                  for (j = 0; j < 2; j = j + 1) begin
                                      out_vector_b[(j+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= temp_b[j];
                                  end
                              end
                              3: begin
                                  // Implement logic for M=3
                                  for (j = 0; j < 3; j = j + 1) begin   
                                      if ((j <= cycle_count) && (cycle_count-j<K)) begin
                                          temp_b[j] <= shifted_matrix_B[((MAX_DIM-1)*j+1)*DATA_WIDTH-1 -: DATA_WIDTH];
                                      end else begin
                                          temp_b[j] <= 0;
                                      end
                                  end  
                                  // Concatenate each element of temp_a and temp_b into the output vectors
                                  for (j = 0; j < 3; j = j + 1) begin
                                      out_vector_b[(j+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= temp_b[j];
                                  end
                              end
                              4: begin
                                  // Implement logic for M=4
                                  for (j = 0; j < 4; j = j + 1) begin   
                                      if ((j <= cycle_count) && (cycle_count-j<K)) begin
                                          temp_b[j] <= shifted_matrix_B[((MAX_DIM-1)*j+1)*DATA_WIDTH-1 -: DATA_WIDTH];
                                      end else begin
                                          temp_b[j] <= 0;
                                      end
                                  end  
                                  // Concatenate each element of temp_a and temp_b into the output vectors
                                  for (j = 0; j < 4; j = j + 1) begin
                                      out_vector_b[(j+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= temp_b[j];
                                  end
                              end
                          endcase                                     
                                                 
                        // Shift matrices for next cycle
      
                        shifted_matrix_A <= shifted_matrix_A >> DATA_WIDTH;
                        shifted_matrix_B <= shifted_matrix_B >> DATA_WIDTH;
                    end
                    else if(cycle_count >= (2*MAX_DIM) && cycle_count < (3*MAX_DIM)) begin
                        out_vector_a <= 0;
                        out_vector_b <= 0;                      
                    end
                    else begin
                        // Finish shifting operation
						done_o <= 1;
                        current_state <= STATE_DONE;
                    end
                    cycle_count <= cycle_count + 1;
                    
                end
                STATE_DONE: begin                  
                // Signal that the operation is done
                    if(!start_bit_i) begin
						current_state <= STATE_IDLE;
						done_o <= 0;
					end
                end
                default: begin
                    current_state <= STATE_IDLE;
                end
            endcase
        end
    end
    
    always @(posedge clk_i or negedge rst_n_i) begin : C_IN_OUT
        if (!rst_n_i) begin
            c_flat_out <= 0;
        end 
        else begin   
             // Process c_flat_in to clear elements outside MxN boundaries and assign to c_flat_out
            for (i = 0; i < MAX_DIM; i = i + 1) begin
                for (j = 0; j < MAX_DIM; j = j + 1) begin
                    if (i < N && j < M) begin
                        // Keep elements within MxN boundaries
                        c_flat_out[(i*MAX_DIM+j + 1)*BUS_WIDTH-1 -: BUS_WIDTH] <= c_flat_in[(i*MAX_DIM+j + 1)*BUS_WIDTH-1 -: BUS_WIDTH];
                    end else begin
                        // Clear elements outside MxN boundaries
                        c_flat_out[(i*MAX_DIM+j + 1)*BUS_WIDTH-1 -: BUS_WIDTH] <= 0;
                    end
                end
            end   
        end        
    end
    
endmodule
