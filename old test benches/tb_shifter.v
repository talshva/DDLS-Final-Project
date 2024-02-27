//
// Verilog Module project1_ws.tb_matrix_shifter
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 21:25:54 08/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`resetall
`timescale 1ns/10ps

module tb_matrix_shifter;

    // Parameters as per the DUT (Device Under Test)
    parameter DATA_WIDTH = 8;
    parameter BUS_WIDTH = 32;
    localparam MAX_DIM = BUS_WIDTH / DATA_WIDTH;

    // Testbench Signals
    reg clk;
    reg rst_n;
    reg start_bit;
    reg [(MAX_DIM*MAX_DIM*DATA_WIDTH)-1:0] matrix_A;
    reg [(MAX_DIM*MAX_DIM*DATA_WIDTH)-1:0] matrix_B;
    reg [(BUS_WIDTH*MAX_DIM*MAX_DIM)-1:0] matrix_C;
    wire [(BUS_WIDTH*MAX_DIM*MAX_DIM)-1:0] matrix_C_out;
    wire [(MAX_DIM*DATA_WIDTH)-1:0] out_vector_a, out_vector_b;
    reg [1:0] N, K, M;
    wire done;

    // Instantiate the Device Under Test (DUT)
    matrix_shifter #(

        .DATA_WIDTH(DATA_WIDTH),
        .BUS_WIDTH(BUS_WIDTH)
    ) shifter_instance (
        .clk_i(clk),
        .rst_n_i(rst_n),
        .start_bit_i(start_bit),
        .matrix_A(matrix_A),
        .matrix_B(matrix_B),
        .c_flat_in(matrix_C),
        .N_i(N),
        .K_i(K),
        .M_i(M),
        .out_vector_a(out_vector_a),
        .out_vector_b(out_vector_b),
        .done_o(done),
        .c_flat_out(matrix_C_out)
    );

    // Clock Generation
    always #5 clk = ~clk; // 100MHz Clock

    // Initial Block for Test Sequence
    initial begin
        // Initialize Signals
        clk = 0;
        rst_n = 0;
        start_bit = 0;
        matrix_A = 0;
        matrix_B = 0;
        matrix_C = 0;
        N <= 2'd1;
        K <= 2'd1;
        M <= 2'd3;
        // Reset Pulse
        #10;
        rst_n = 1;
        #10;

        // Flatten 2D matrices into 1D vectors
        // Matrix A
        matrix_A = {8'd1, 8'd2, 8'd3, 8'd4, 
                    8'd5, 8'd6, 8'd7, 8'd8, 
                    8'd8, 8'd7, 8'd6, 8'd5, 
                    8'd4, 8'd3, 8'd2, 8'd1};
                    
        // Matrix B
        matrix_B = {8'd1, 8'd2, 8'd3, 8'd4, 
                    8'd5, 8'd6, 8'd7, 8'd8, 
                    8'd8, 8'd7, 8'd6, 8'd5, 
                    8'd4, 8'd3, 8'd2, 8'd1};
                    
                    
          
        // Matrix C
        matrix_C = {32'd1, 32'd1, 32'd1, 32'd1, 
                    32'd1, 32'd1, 32'd1, 32'd1, 
                    32'd1, 32'd1, 32'd1, 32'd1, 
                    32'd1, 32'd1, 32'd1, 32'd1};
        
        // Start the test
        start_bit = 1;
        #10;
        start_bit = 0;
        
        // Wait for done signal or a maximum timeout
        wait(done == 1'b1 || $time > 5000);
        
        // Test completed
        $display("Test Completed. Checking outputs...");
        $display("Output C mat: %h", matrix_C_out);


        // Finish simulation
        $finish;
    end

endmodule
