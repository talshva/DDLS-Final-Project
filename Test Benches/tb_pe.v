//
// Verilog Module project1_ws.tb_pe
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 21:25:54 08/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`resetall
`timescale 1ns/10ps

module tb_pe;
  
parameter DATA_WIDTH = 8; // Width of data
parameter BUS_WIDTH = 32;
parameter CLK_PERIOD = 10; // Clock period in ns

reg clk = 1'b0;                   // Clock signal
reg rst_n = 1'b1;                 // Reset signal (active low)
reg start_operation = 1'b0;       // Start operation signal
reg [DATA_WIDTH-1:0] data_A = {DATA_WIDTH{'b0}}; // Input data A
reg [DATA_WIDTH-1:0] data_B = {DATA_WIDTH{'b0}}; // Input data B
wire [BUS_WIDTH-1:0] accum;     // Accumulator output
wire [DATA_WIDTH-1:0] data_A_out;// Output data A
wire [DATA_WIDTH-1:0] data_B_out;// Output data B
wire ov_flag;

    always 
    #5 clk <= ~clk;

    // Instantiate the pe module
    pe #(.DATA_WIDTH(DATA_WIDTH),.BUS_WIDTH(BUS_WIDTH)) PE_instance (
        .clk_i(clk),
        .rst_n_i(rst_n),
        .start_operation_i(start_operation),
        .data_A_i(data_A),
        .data_B_i(data_B),
        .accum_o(accum),
        .data_A_o(data_A_out),
        .data_B_o(data_B_out),
		.ov_flag_o(ov_flag)
    );

    // Initial block for signal initialization and clock generation
    initial begin : clear_inputs
        // Initialize signals
        #(CLK_PERIOD) 
        rst_n <= 1'b0;
        #(CLK_PERIOD) 
        rst_n <= 1'b1;
        #(CLK_PERIOD) 
        start_operation <= 1'b1;
		#(CLK_PERIOD) 
        data_A = 7;
        data_B = 3;
        #(CLK_PERIOD) 
        data_A = 2;
        data_B = 1;
        #(CLK_PERIOD) 
        data_A = 0;
        data_B = 0;
		#(CLK_PERIOD)
		start_operation <= 1'b0;
                
        $monitor("Time: %t, accum: %d, data_A_out: %d, data_B_out: %d", $time, accum, data_A_out, data_B_out);
        #(CLK_PERIOD * 50);
        $finish;
    end

endmodule
