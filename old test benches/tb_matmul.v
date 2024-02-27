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

module tb_matmul();

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
	reg [BUS_WIDTH-1:0] printed_element;
	wire [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] operand_C;
    wire [BUS_WIDTH-1:0] prdata;
    wire pready;
    wire pslverr;
    wire busy;
	wire [BUS_WIDTH*MAX_DIM-1:0] operand_A; 
	wire [BUS_WIDTH*MAX_DIM-1:0] operand_B; 
	wire [15:0] control_reg; 
	integer i;

    // Instantiate the Unit Under Test (UUT)
    matmul #(
        .DATA_WIDTH(DATA_WIDTH),
        .BUS_WIDTH(BUS_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
		.SP_NTARGETS(SP_NTARGETS)
    ) matmul_instance (
        .clk_i(clk),
        .rst_n_i(rst_n),
        .psel_i(psel),
        .penable_i(penable),
        .pwrite_i(pwrite),
        .pstrb_i(pstrb),
        .pwdata_i(pwdata),
        .paddr_i(paddr),
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
        // Reset the system
        #10;
        rst_n = 1'b1;
        // Write Sequence A
        @(posedge clk);
		pwrite = 1'b1;
        psel = 1'b1;
        paddr = 16'b0000000001000000; // Target address
        pwdata = 32'h04030201; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		@(posedge clk);
		psel = 1'b1;
        paddr = paddr + 1; // Target address
        pwdata = 32'h08070605; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		@(posedge clk);
		psel = 1'b1;
        paddr = paddr + 1; // Target address
        pwdata = 32'h0C0B0A09; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		@(posedge clk);
		psel = 1'b1;
        paddr = paddr + 1; // Target address
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
        paddr = 16'b0000000010000000; // Target address
        pwdata = 32'h04030201; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		@(posedge clk);
		psel = 1'b1;
        paddr = paddr + 1; // Target address
        pwdata = 32'h08070605; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		@(posedge clk);
		psel = 1'b1;
        paddr = paddr + 1; // Target address
        pwdata = 32'h0C0B0A09; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
		
		@(posedge clk);
		psel = 1'b1;
        paddr = paddr + 1; // Target address
        pwdata = 32'h100F0E0D; // Data to write
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;

		// start op (write to control reg)
		//		[15:14 -dontcare , 13:12 - M, 11:10 - K, 9:8 - N, 7:6 - dontcare, 5:4 - sp mat select, 3:2 - row in sp, 1 - biased_flag, 0 - start_op]
		@(posedge clk);
		psel = 1'b1;
        paddr = 16'b0000000000000000; // Target address
        pwdata = 32'h0000FF01; // Data to write (n=4, k=4, m=4, no bias, start op)
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;	
		
		repeat (30) @(posedge clk); // wait extra time for matmul to calculate...
		
		for (i = 0; i < MAX_DIM*MAX_DIM; i = i + 1) begin 
			// Read Sequence
			@(posedge clk);
			psel = 1'b1;
			pwrite = 1'b0;
			paddr = 16'b0000000100000000 + i; // Target address to read from
			@(posedge clk);
			penable = 1'b1;
			@(posedge clk);
			psel = 1'b0;
			penable = 1'b0;
			printed_element = prdata;	
			$write("%0d\t",printed_element);  // Use $write to stay on the same line
			if ((i + 1) % MAX_DIM == 0) begin
			  $display("");  // Print a new line
			end   
		end
		
		
		// start op (write to control reg) A*B + C
		//		[15:14 -dontcare , 13:12 - M, 11:10 - K, 9:8 - N, 7:6 - dontcare, 5:4 - read mat sp, 3:2 - write mat sp, 1 - biased_flag, 0 - start_op]
		@(posedge clk);
		pwrite = 1'b1;
		psel = 1'b1;
        paddr = 16'b0000000000000000; // Target address
        pwdata = 32'h00002707; // Data to write (n=4, k=2, m=3, start op, bias, write to mat 1)
        @(posedge clk);
        penable = 1'b1;
        @(posedge clk);
        psel = 1'b0;
        penable = 1'b0;
        pwrite = 1'b0;
		
		
		repeat (30) @(posedge clk); // wait extra time for matmul to calculate...
		
		for (i = 0; i < MAX_DIM*MAX_DIM; i = i + 1) begin 
			// Read Sequence
			@(posedge clk);
			psel = 1'b1;
			pwrite = 1'b0;
			paddr = 16'b0000000101000000 + i; // Target address to read from
			@(posedge clk);
			penable = 1'b1;
			@(posedge clk);
			psel = 1'b0;
			penable = 1'b0;
			printed_element = prdata;	
			$write("%0d\t",printed_element);  // Use $write to stay on the same line
			if ((i + 1) % MAX_DIM == 0) begin
			  $display("");  // Print a new line
			end   
		end

 
        // Additional read/write operations can be added here

        // End of Test
        $finish;
    end

endmodule
