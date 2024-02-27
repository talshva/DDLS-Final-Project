//
// Verilog Module project1_ws.apbslave
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 21:25:54 08/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//


`timescale 1ns / 1ps

module tb_apbslave();

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter BUS_WIDTH = 32;
    parameter ADDR_WIDTH = 16;
	parameter SP_NTARGETS = 4;
    localparam MAX_DIM = BUS_WIDTH/DATA_WIDTH;
    // Testbench Signals
    reg clk;
    reg rst_n;
    reg psel;
    reg penable;
    reg pwrite;
    reg [MAX_DIM-1:0] pstrb;
    reg [BUS_WIDTH-1:0] pwdata;
    reg [ADDR_WIDTH-1:0] paddr;
	reg [MAX_DIM*MAX_DIM-1:0]ov;
	reg EOP;
	reg [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] result;
	wire [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] operand_C;
    wire [BUS_WIDTH-1:0] prdata;
    wire pready;
    wire pslverr;
    wire busy;
	wire [BUS_WIDTH*MAX_DIM-1:0] operand_A; 
	wire [BUS_WIDTH*MAX_DIM-1:0] operand_B; 
	wire [15:0] control_reg; 


    // Instantiate the Unit Under Test (UUT)
    apbslave #(
        .DATA_WIDTH(DATA_WIDTH),
        .BUS_WIDTH(BUS_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
		.SP_NTARGETS(SP_NTARGETS)
    ) apb_instance (
        .clk_i(clk),
        .rst_n_i(rst_n),
        .psel_i(psel),
        .penable_i(penable),
        .pwrite_i(pwrite),
        .pstrb_i(pstrb),
        .pwdata_i(pwdata),
        .paddr_i(paddr),
		.ov_i(ov),
		.EOP_i(EOP),
		.result_i(result),
		.operand_A_o(operand_A),
		.operand_B_o(operand_B),
		.operand_C_o(operand_C),
		.control_reg_o(control_reg),
        .pready_o(pready),
        .pslverr_o(pslverr),
	    .prdata_o(prdata),
        .busy_o(busy)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz Clock
    end

    // Test Sequence
    initial begin
        // Initialize Signals
        rst_n = 1'b0;
        psel = 1'b0;
        penable = 1'b0;
        pwrite = 1'b0;
        pstrb = 4'b1111;
        pwdata = 32'd0;
        paddr = 16'd4;
		EOP = 0;
		result = {BUS_WIDTH*MAX_DIM{4'b0000}};
		ov = {MAX_DIM{4'b0000}};
		
        // Reset the system
        #10;
        rst_n = 1'b1;

        // Write Sequence A

        @(posedge clk);
		pwrite = 1'b1;
        psel = 1'b1;
        paddr = 16'd4; // Target address
        pwdata = 32'h04030201; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		@(posedge clk);
		psel = 1'b1;
        paddr = 16'd5; // Target address
        pwdata = 32'h08070605; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		@(posedge clk);
		psel = 1'b1;
        paddr = 16'd6; // Target address
        pwdata = 32'h0C0B0A09; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		@(posedge clk);
		psel = 1'b1;
        paddr = 16'd7; // Target address
        pwdata = 32'h100F0E0D; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		// Write Sequence B

		 @(posedge clk);
		pwrite = 1'b1;
        psel = 1'b1;
        paddr = 16'd8; // Target address
        pwdata = 32'h04030201; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		@(posedge clk);
		psel = 1'b1;
        paddr = 16'd9; // Target address
        pwdata = 32'h08070605; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		@(posedge clk);
		psel = 1'b1;
        paddr = 16'd10; // Target address
        pwdata = 32'h0C0B0A09; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		@(posedge clk);
		psel = 1'b1;
        paddr = 16'd11; // Target address
        pwdata = 32'h100F0E0D; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;

		// start op [15:14 -dontcare , 13:12 - M, 11:10 - K, 9:8 - N, 7:6 - dontcare, 5:4 - sp mat select, 3:2 - row in sp, 1 - biased_flag, 0 - start_op]
		@(posedge clk);
		psel = 1'b1;
        paddr = 16'd0; // Target address
        pwdata = 32'h0000FF01; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		repeat (4) @(posedge clk);
		EOP = 1;
		result = {BUS_WIDTH*MAX_DIM{4'b1010}};
		ov = {MAX_DIM{4'b0010}};
		
		repeat (16) @(posedge clk);
		
        // Read Sequence
        @(posedge clk);
        psel = 1'b1;
        pwrite = 1'b0;
        paddr = 16'h0010; // Target address to read from
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;

        // Additional read/write operations can be added here

        // End of Test
        #200;
        $finish;
    end

endmodule
