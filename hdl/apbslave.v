//
// Verilog Module project1_ws.apbslave
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 21:25:54 08/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`timescale 1ns/1ps
`define IDLE     3'b000
`define W_ENABLE  3'b001
`define R_ENABLE  3'b010
`define BUSY  3'b011 // In matmul operation
`define SAVE_RES  3'b100 // save to sp
`define ADDR_CONTROL_REG 3'h0 // Define base addresses for each register
`define ADDR_OPERAND_A   3'h1
`define ADDR_OPERAND_B   3'h2
`define ADDR_RESULT_FLAG 3'h3
`define ADDR_SCRATCH_PAD_1 3'h4
`define ADDR_SCRATCH_PAD_2 3'h5
`define ADDR_SCRATCH_PAD_3 3'h6
`define ADDR_SCRATCH_PAD_4 3'h7

module apbslave (clk_i, rst_n_i, psel_i, penable_i, pwrite_i, pstrb_i, pwdata_i, paddr_i, ov_i, EOP_i, result_i, operand_A_o, operand_B_o, operand_C_o, control_reg_o, pready_o, pslverr_o, prdata_o, busy_o);
    
	parameter DATA_WIDTH = 8; // Bit-width of a single element. Can be 8,16 or 32. 	<=BW/2
	parameter BUS_WIDTH = 32;  // APB Bus data bit-width. Can be 16,32 or 64. 	BW%DW=0
	parameter ADDR_WIDTH = 16; // APB address space bit-width. Can be 16,24 or 32.
	parameter SP_NTARGETS = 4; // The number of addressable targets in SP (SPN), Can be 1,2 or 4.
	localparam MAX_DIM = BUS_WIDTH / DATA_WIDTH; // Max dimension size for matrix (MIN(BW/DW),4)
	localparam SP_ADDR_WIDTH = MAX_DIM > 2 ? 4 : 2; 
	localparam OP_ADDR_WIDTH = MAX_DIM > 2 ? 2 : 1; 

	input wire  clk_i; // matmul
	input wire  rst_n_i; // matmul
	input wire  psel_i; // bus
	input wire  penable_i;// bus
	input wire  pwrite_i;// bus
	input wire  [MAX_DIM-1:0] pstrb_i; // bus
	input wire  [BUS_WIDTH-1:0] pwdata_i; // bus
	input wire  [ADDR_WIDTH-1:0] paddr_i; // bus
	input wire  [MAX_DIM*MAX_DIM-1:0] ov_i; // mamtul_calc
	input wire EOP_i;
	input wire [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] result_i;
	output wire [BUS_WIDTH*MAX_DIM-1:0] operand_A_o; // shifter
	output wire [BUS_WIDTH*MAX_DIM-1:0] operand_B_o; // shifter
	output wire [15:0] control_reg_o; // matmul & shifter
	output reg  pready_o; // bus
	output reg  pslverr_o; // bus
	output reg  [BUS_WIDTH-1:0] prdata_o; // bus
	output reg  busy_o; // Busy signal, indicating the design cannot be written to
	output reg [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] operand_C_o; // mamtul_calc


	wire [BUS_WIDTH - 1:0] result_elements [MAX_DIM*MAX_DIM-1:0];
	wire [1:0] operand_addr;  // Address signals for each register
	wire [BUS_WIDTH*MAX_DIM-1:0] operands[1:0];
	wire [BUS_WIDTH-1:0] operand_dout[1:0]; // Data output signals from each register	
	wire [BUS_WIDTH*MAX_DIM*MAX_DIM-1:0] sp_operand;
	wire [BUS_WIDTH-1:0] sp_dout;	
	reg [BUS_WIDTH-1:0] sp_din;
	reg [SP_ADDR_WIDTH-1:0] sp_address;
	reg [2:0] operand_ien; // Input enable signals for each register
	reg [SP_ADDR_WIDTH:0] write_counter;
	reg [15:0] control_register;
	reg [MAX_DIM*MAX_DIM-1:0] flags_register;
	reg [2:0] current_state, next_state;
	reg [BUS_WIDTH-1:0] operand_din[1:0];   // Data input signals for each register	

	assign control_reg_o = control_register;
	assign operand_A_o = operands[0];
	assign operand_B_o = operands[1];
	assign operand_addr = paddr_i[OP_ADDR_WIDTH - 1 + 5:5];
	
	operand #(.DATA_WIDTH(DATA_WIDTH), .MAX_DIM(MAX_DIM)) operandA_instance (
			.clk_i(clk_i),
			.rst_n_i(rst_n_i),
			.addr(operand_addr), 
			.din(operand_din[0]), 
			.ien(operand_ien[0]), 
			.pstrb_i(pstrb_i),
			.row_out(operand_dout[0]),
			.mat_flat_out(operands[0])
	);
      
	operand #(.DATA_WIDTH(DATA_WIDTH), .MAX_DIM(MAX_DIM)) operandB_instance (
			.clk_i(clk_i),
			.rst_n_i(rst_n_i),	
			.addr(operand_addr), 
			.din(operand_din[1]), 
			.ien(operand_ien[1]), 
			.pstrb_i(pstrb_i),			
			.row_out(operand_dout[1]),
			.mat_flat_out(operands[1])
	);

	scratchpad #(.BUS_WIDTH(BUS_WIDTH), .MAX_DIM(MAX_DIM),.ELEMENT_NUM(SP_NTARGETS),.ADDR_WIDTH(SP_ADDR_WIDTH)) SP_instance (
			.clk_i(clk_i),
			.rst_n_i(rst_n_i),
			.addr(sp_address),
			.bus_element_sel(paddr_i[3:2]),
			.din(sp_din), 
			.ien(operand_ien[2]),
			.element_read_sel(control_register[5:4]),
			.element_write_sel(control_register[3:2]),
			.element_out(sp_dout),
			.mat_flat_out(sp_operand)
	);
        
	genvar k;
	
	generate
        for (k = 0; k < MAX_DIM*MAX_DIM; k = k + 1)
        begin : unpack_result
			assign result_elements[k] = result_i[(k+1)*BUS_WIDTH-1 : k*BUS_WIDTH];
        end
    endgenerate
	
	always @(*) begin: always_block
		current_state = next_state;
		pready_o  = 1'b0;
		pslverr_o = 1'b0;
		operand_ien = 3'b000;
		operand_din[0] = {BUS_WIDTH{1'b0}};
		operand_din[1] = {BUS_WIDTH{1'b0}};
		operand_C_o = (control_register[1] ? sp_operand : {BUS_WIDTH*MAX_DIM*MAX_DIM{1'b0}});
		sp_din = {BUS_WIDTH*MAX_DIM*MAX_DIM{1'b0}};
		prdata_o  = {BUS_WIDTH{1'b0}};
		sp_address = {SP_ADDR_WIDTH{1'b0}};
		case (current_state)
			`IDLE : begin
				pready_o  = 1'b0;
				pslverr_o = 1'b0;
				operand_ien = 3'b000;
				operand_din[0] = {BUS_WIDTH{1'b0}};
				operand_din[1] = {BUS_WIDTH{1'b0}};
				operand_C_o = {BUS_WIDTH*MAX_DIM*MAX_DIM{1'b0}};
				sp_din = {BUS_WIDTH*MAX_DIM*MAX_DIM{1'b0}};
			end

			`W_ENABLE : begin
				if (psel_i && penable_i) begin
					pready_o = 1'b1;
					case (paddr_i[4:2])
						`ADDR_OPERAND_A: begin
							operand_ien = 3'b001;
							operand_din[0] = pwdata_i;						
						end
						`ADDR_OPERAND_B: begin
							operand_ien = 3'b010;
							operand_din[1] = pwdata_i;
						end
					endcase
				end
			end

			`R_ENABLE : begin
				if (psel_i && penable_i) begin
					pready_o = 1'b1;
					case (paddr_i[4:2])
						`ADDR_CONTROL_REG: begin
							prdata_o[15:0] = control_register;
						end
						`ADDR_OPERAND_A: begin
							prdata_o = operand_dout[0];
						end
						`ADDR_OPERAND_B: begin
							prdata_o = operand_dout[1];								
						end
						`ADDR_RESULT_FLAG: begin
							prdata_o[MAX_DIM*MAX_DIM - 1:0] = flags_register;
						end
						`ADDR_SCRATCH_PAD_1, `ADDR_SCRATCH_PAD_2, `ADDR_SCRATCH_PAD_3, `ADDR_SCRATCH_PAD_4: begin
							sp_address = paddr_i[SP_ADDR_WIDTH-1 + 5:5];
							prdata_o = sp_dout;								
						end
					endcase
				end
			end
			
			`BUSY : begin
				pready_o  = 1'b0;
				pslverr_o = psel_i ? 1'b1 : 1'b0;	// in operation approach									
				if (EOP_i) begin
					sp_address = write_counter;
					operand_ien = 3'b100;
					sp_din = result_elements[write_counter];
				end
			end
			
			`SAVE_RES : begin						
				pslverr_o = psel_i ? 1'b1 : 1'b0;	// in operation approach									
				sp_address = write_counter;
				if (write_counter < MAX_DIM*MAX_DIM) begin
					operand_ien = 3'b100;
					sp_din = result_elements[write_counter];
				end
				else begin 
					operand_ien = 3'b000;
				end
			end
		endcase
	end
	
	always @(negedge rst_n_i or posedge clk_i) begin : FSM
		if (!rst_n_i) begin
			next_state <= `IDLE;
			flags_register <= {MAX_DIM*MAX_DIM{1'b0}};
			control_register <= 4'h0000;
			busy_o  <= 1'b0;
		end	
		else begin	
			case (current_state)
				`IDLE : begin
				  write_counter <= 0;
					if (psel_i) begin
						next_state <= pwrite_i ? `W_ENABLE : `R_ENABLE;
					end
				end
				
				`W_ENABLE : begin
					case (paddr_i[4 : 2])
						`ADDR_CONTROL_REG: begin
						  control_register <= pwdata_i[15:0];
							next_state <= pwdata_i[0] ? `BUSY : `IDLE;
							busy_o <= pwdata_i[0] ? 1'b1 : 1'b0;
						end
						`ADDR_OPERAND_A: begin
							next_state <= `IDLE;
						end
						`ADDR_OPERAND_B: begin
							next_state <= `IDLE;							
						end
						default: begin
							next_state <= `IDLE;	
						end
					endcase
				end

				`R_ENABLE : begin
					next_state <= `IDLE;
				end
				
				`BUSY : begin						
					// Data transfer to Matmul, wait until eop.
					if (EOP_i) begin
						next_state  <= `SAVE_RES;
						write_counter <= write_counter + 1;
					end
				end

				`SAVE_RES : begin						
					// Data transfer to Matmul, wait until eop.				
					write_counter <= write_counter + 1;
					if (write_counter == MAX_DIM*MAX_DIM) begin
					  flags_register <= ov_i;
						next_state  <= `IDLE;
						busy_o <= 1'b0;
						control_register[0] <= 1'b0;
					end	
				end		
				default: begin
					next_state <= `IDLE;	
				end				
			endcase		
		end
	end						
endmodule