//
// Verilog Module project1_ws.matmul_stimulus
//
// Created:
//          by - Tal Shvartzberg.UNKNOWN (TAL-SHVARTZBERG)
//          at - 14:09:55 18/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`include "headers.vh"


// Matrix Multiplication Stimulus Module
module matmul_stimulus(
	matmul_intf.STIMULUS intf
);
	import matmul_pkg::*;
	
	localparam MAX_DIM = BUS_WIDTH/DATA_WIDTH;
	localparam SUB_ADDRESS_BITS = MAX_DIM > 2 ? 4 : 2;
	localparam ADDRESS_BITS = ADDR_WIDTH - SUB_ADDRESS_BITS - 5;	

    // Placeholder for parameters read from files
    integer DW, BW, AW, SPN, SPN_SELECT, Biased_flag, N_file, K_file, M_file;
    // File descriptors
    integer params_fd, a_matrix_fd, b_matrix_fd, c_matrix_fd, i_matrix_fd, res_matrix_fd;
    integer line_read_fd, line_assign_fd;
	// Variables to hold start and end times
	realtime start_time, end_time;
    // Testbench Signals
	reg [BUS_WIDTH-1:0] printed_element;
	integer matA [MAX_DIM-1:0][MAX_DIM-1:0];
    integer matB [MAX_DIM-1:0][MAX_DIM-1:0];
	integer matC [MAX_DIM-1:0][MAX_DIM-1:0];
    integer matI [MAX_DIM-1:0][MAX_DIM-1:0];
	integer mat_res_gm [MAX_DIM-1:0][MAX_DIM-1:0];
	integer mat_res_actual [MAX_DIM-1:0][MAX_DIM-1:0];
	wire [BUS_WIDTH-1:0] matA_flat [MAX_DIM-1:0];
    wire [BUS_WIDTH-1:0] matB_flat [MAX_DIM-1:0];
	wire [BUS_WIDTH-1:0] matC_flat [MAX_DIM-1:0];
    wire [BUS_WIDTH-1:0] matI_flat [MAX_DIM-1:0];
	string line;
	string PARAMETERS_FILE;
	string A_MATRIX_FILE;
	string B_MATRIX_FILE;
	string C_MATRIX_FILE;
	string I_MATRIX_FILE;
	string RES_MATRIX_FILE;
	
	assign intf.mat_res_gm = mat_res_gm;
	assign intf.mat_res_actual = mat_res_actual;
	assign intf.N_file = N_file;
	assign intf.M_file = M_file;
	assign intf.K_file = K_file;
	assign intf.SPN_SELECT = SPN_SELECT;
	assign intf.Biased_flag = Biased_flag;
	
    genvar g,l;	
	generate
		for (g = 0; g < MAX_DIM; g = g + 1) begin
			for (l = 0; l < MAX_DIM; l = l + 1) begin : unpack_loop
				// Combine accumulator outputs with pre-calculated values and check for overflow
				assign matA_flat[g][(l+1)*DATA_WIDTH - 1 -: DATA_WIDTH] = matA[g][l][DATA_WIDTH-1:0];
			end
		end

		for (g = 0; g < MAX_DIM; g = g + 1) begin
			for (l = 0; l < MAX_DIM; l = l + 1) begin : unpack_loop
				// Combine accumulator outputs with pre-calculated values and check for overflow
				assign matB_flat[g][(l+1)*DATA_WIDTH - 1 -: DATA_WIDTH] = matB[g][l][DATA_WIDTH-1:0];
			end
		end

		for (g = 0; g < MAX_DIM; g = g + 1) begin
			for (l = 0; l < MAX_DIM; l = l + 1) begin : unpack_loop
				// Combine accumulator outputs with pre-calculated values and check for overflow
				assign matC_flat[g][(l+1)*DATA_WIDTH - 1 -: DATA_WIDTH] = matC[g][l][DATA_WIDTH-1:0];
			end
		end	

		for (g = 0; g < MAX_DIM; g = g + 1) begin
			for (l = 0; l < MAX_DIM; l = l + 1) begin : unpack_loop
				// Combine accumulator outputs with pre-calculated values and check for overflow
				assign matI_flat[g][(l+1)*DATA_WIDTH - 1 -: DATA_WIDTH] = matI[g][l][DATA_WIDTH-1:0];
			end
		end			
    endgenerate
	
    task open_files; begin
        // Open files and read parameters
        params_fd = $fopen(PARAMETERS_FILE, "r");
        if (params_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed to open %s", $realtime, PARAMETERS_FILE));

        a_matrix_fd = $fopen(A_MATRIX_FILE, "r");
        if (a_matrix_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed to open %s", $realtime, A_MATRIX_FILE));
        
        b_matrix_fd = $fopen(B_MATRIX_FILE, "r");
        if (b_matrix_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed to open %s", $realtime, B_MATRIX_FILE));
		
		c_matrix_fd = $fopen(C_MATRIX_FILE, "r");
        if (c_matrix_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed to open %s", $realtime, C_MATRIX_FILE));
		
		i_matrix_fd = $fopen(I_MATRIX_FILE, "r");
        if (i_matrix_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed to open %s", $realtime, I_MATRIX_FILE));
		
		res_matrix_fd = $fopen(RES_MATRIX_FILE, "r");
        if (res_matrix_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed to open %s", $realtime, RES_MATRIX_FILE));
    end endtask

    task read_parameters; begin
		line_read_fd = ($fgets(line, params_fd));
		if (line_read_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed reading parameters line", $realtime));
		else begin
            line_assign_fd = $sscanf(line, "DW=%d, BW=%d, AW=%d, SPN=%d, SPN_SELECT=%d, Biased_flag=%d, N=%d, K=%d, M=%d\n", DW, BW, AW, SPN, SPN_SELECT, Biased_flag, N_file, K_file, M_file);
		    if (line_assign_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed assigning parameters line to variables", $realtime));
		end		
		if (DW != DATA_WIDTH) $fatal("[STIMULUS] Time: %0d [ns], Read DW= %2d\t!=\t Defined DW= %2d", $realtime,DW , DATA_WIDTH);
		if (BW != BUS_WIDTH) $fatal("[STIMULUS] Time: %0d [ns], Read BW= %2d\t!=\t Defined BW= %2d", $realtime, BW, BUS_WIDTH);
		if (AW != ADDR_WIDTH) $fatal("[STIMULUS] Time: %0d [ns], Read AW= %2d\t!=\t Defined AW= %2d", $realtime, AW, ADDR_WIDTH);
		if (SPN != SP_NTARGETS) $fatal("[STIMULUS] Time: %0d [ns], Read SPN=%2d\t!=\t Defined SPN=%2d", $realtime, SPN, SP_NTARGETS);
		if (VERBOSE) $display("[STIMULUS] Time: %0d [ns], Read Biased=%0d", $realtime, Biased_flag);
		
    end endtask

	task clear_matrices; begin
		for (int i = 0; i < MAX_DIM; i = i + 1) begin 
			for (int j = 0; j < MAX_DIM; j = j + 1) begin 
				matA[i][j] = 0;
				matB[i][j] = 0;
				matC[i][j] = 0;
				matI[i][j] = 0;			
			end
		end	
	end endtask
	
	task read_matrices; begin
		// Read and populate matA
		for (int i = 0; i < N_file && !$feof(a_matrix_fd); i++) begin
			line_read_fd = $fgets(line, a_matrix_fd);
			if (line_read_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed reading matrixA line", $realtime));
			else begin
				case(K_file)
					1: line_assign_fd = $sscanf(line, "%d\n", matA[i][0]);
					2: line_assign_fd = $sscanf(line, "%d,%d\n", matA[i][0], matA[i][1]);
					3: line_assign_fd = $sscanf(line, "%d,%d,%d\n", matA[i][0], matA[i][1], matA[i][2]);
					4: line_assign_fd = $sscanf(line, "%d,%d,%d,%d\n", matA[i][0], matA[i][1], matA[i][2], matA[i][3]);
					
					default: begin
						// Handle unexpected K value
						$display("[STIMULUS] Time: %0d [ns], Unexpected K value: %d", $realtime, K_file);
					end
				endcase
				if (line_assign_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed assigning matrixA line to variables", $realtime));
			end
		end
		
		// Read and populate matB
		for (int i = 0; i < K_file && !$feof(b_matrix_fd); i++) begin
			line_read_fd = $fgets(line, b_matrix_fd);
			if (line_read_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed reading matrixB line", $realtime));
			else begin
				case(M_file)
					1: line_assign_fd = $sscanf(line, "%d\n", matB[i][0]);
					2: line_assign_fd = $sscanf(line, "%d,%d\n", matB[i][0], matB[i][1]);
					3: line_assign_fd = $sscanf(line, "%d,%d,%d\n", matB[i][0], matB[i][1], matB[i][2]);
					4: line_assign_fd = $sscanf(line, "%d,%d,%d,%d\n", matB[i][0], matB[i][1], matB[i][2], matB[i][3]);
					default: begin
						// Handle unexpected M value
						$display("[STIMULUS] Time: %0d [ns], Unexpected M value: %d", $realtime, M_file);
					end
				endcase
				if (line_assign_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed assigning matrixB line to variables", $realtime));
			end			
		end
		
		// Read and populate matC
		for (int i = 0; i < N_file && !$feof(c_matrix_fd); i++) begin
			line_read_fd = $fgets(line, c_matrix_fd);
			if (line_read_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed reading matrixC line", $realtime));
			else begin
				case(M_file)
					1: line_assign_fd = $sscanf(line, "%d\n", matC[i][0]);
					2: line_assign_fd = $sscanf(line, "%d,%d\n", matC[i][0], matC[i][1]);
					3: line_assign_fd = $sscanf(line, "%d,%d,%d\n", matC[i][0], matC[i][1], matC[i][2]);
					4: line_assign_fd = $sscanf(line, "%d,%d,%d,%d\n", matC[i][0], matC[i][1], matC[i][2], matC[i][3]);
					default: begin
						// Handle unexpected M value
						$display("[STIMULUS] Time: %0d [ns], Unexpected M value: %d", $realtime, M_file);
					end
				endcase
				if (line_assign_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed assigning matrixC line to variables", $realtime));
			end			
		end
		
		// Read and populate matI
		for (int i = 0; i < M_file && !$feof(i_matrix_fd); i++) begin
			line_read_fd = $fgets(line, i_matrix_fd);
			if (line_read_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed reading matrixI line", $realtime));
			else begin
				case(M_file)
					1: line_assign_fd = $sscanf(line, "%d\n", matI[i][0]);
					2: line_assign_fd = $sscanf(line, "%d,%d\n", matI[i][0], matI[i][1]);
					3: line_assign_fd = $sscanf(line, "%d,%d,%d\n", matI[i][0], matI[i][1], matI[i][2]);
					4: line_assign_fd = $sscanf(line, "%d,%d,%d,%d\n", matI[i][0], matI[i][1], matI[i][2], matI[i][3]);
					default: begin
						// Handle unexpected M value
						$display("[STIMULUS] Time: %0d [ns], Unexpected M value: %d", $realtime, M_file);
					end
				endcase
				if (line_assign_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed assigning matrixI line to variables", $realtime));
			end			
		end

		// Read and populate Res Mat
		for (int i = 0; i < N_file && !$feof(res_matrix_fd); i++) begin
			line_read_fd = $fgets(line, res_matrix_fd);
			if (line_read_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed reading Res Matrix line", $realtime));
			else begin
				case(M_file)
					1: line_assign_fd = $sscanf(line, "%d\n", mat_res_gm[i][0]);
					2: line_assign_fd = $sscanf(line, "%d,%d\n", mat_res_gm[i][0], mat_res_gm[i][1]);
					3: line_assign_fd = $sscanf(line, "%d,%d,%d\n", mat_res_gm[i][0], mat_res_gm[i][1], mat_res_gm[i][2]);
					4: line_assign_fd = $sscanf(line, "%d,%d,%d,%d\n", mat_res_gm[i][0], mat_res_gm[i][1], mat_res_gm[i][2], mat_res_gm[i][3]);
					default: begin
						// Handle unexpected M value
						$display("[STIMULUS] Time: %0d [ns], Unexpected M value: %d", $realtime, M_file);
					end
				endcase
				if (line_assign_fd == 0) $fatal(1, $sformatf("[STIMULUS] Time: %0d [ns], Failed assigning Res Matrix line to variables", $realtime));
			end			
		end


		// Display Matrices A and B:
		if (VERBOSE) begin
			$display("[STIMULUS] Time: %0d [ns], matA: \n", $realtime);
			for (int i = 0; i < N_file; i = i + 1) begin 
				for (int j = 0; j < K_file; j = j + 1) begin 
					$write("%d\t",matA[i][j]);  // Use $write to stay on the same line
					if ((j+1) % K_file == 0) begin
						$display("");  // Print a new line
					end			
				end
			end		
			
			$display("\n[STIMULUS] Time: %0d [ns], matB: \n", $realtime);
			for (int i = 0; i < K_file; i = i + 1) begin 
				for (int j = 0; j < M_file; j = j + 1) begin 
					$write("%d\t",matB[i][j]);  // Use $write to stay on the same line
					if ((j+1) % M_file == 0) begin
						$display("");  // Print a new line
					end			
				end
			end	

			if (Biased_flag[0]) begin
				$display("\n[STIMULUS] Time: %0d [ns], matC: \n", $realtime);
				for (int i = 0; i < N_file; i = i + 1) begin 
					for (int j = 0; j < M_file; j = j + 1) begin 
						$write("%d\t",matC[i][j]);  // Use $write to stay on the same line
						if ((j+1) % M_file == 0) begin
							$display("");  // Print a new line
						end			
					end
				end	
			end			
		end
	end endtask

	task apb_master_sim; begin
		integer res_row, res_col, addr_offset;
		// Initialize Signals
        intf.psel = 1'b0;
        intf.penable = 1'b0;
        intf.pwrite = 1'b0;
        intf.pstrb = {MAX_DIM{1'b0}};
        intf.pwdata = {BUS_WIDTH{1'b0}};
        intf.paddr = {ADDR_WIDTH{1'b0}};
		
		if(Biased_flag[0]) begin: add_C
			// Write matrix C
			addr_offset = {{ADDRESS_BITS{1'b0}} ,{SUB_ADDRESS_BITS{1'b0}}, 5'b00100}; // Starting address for operand A, adjust as needed
			for (int i = 0; i < N_file; i = i + 1) begin
				@(posedge intf.clk);
				intf.pwrite = 1'b1;
				intf.psel = 1'b1;
				intf.paddr = addr_offset + (i << 5); // Calculate address based on index and data width
				case (M_file)
					1: intf.pstrb = 1'b1;
					2: intf.pstrb = 2'b11;
					3: intf.pstrb = 3'b111;
					4: intf.pstrb = 4'b1111;
				endcase
				intf.pwdata = matC_flat[i]; // Use actual data from matrix C
				@(posedge intf.clk);
				intf.penable = 1'b1;
			end
			
			@(posedge intf.clk);
			intf.psel = 1'b0;
			intf.penable = 1'b0;
			intf.pstrb = {MAX_DIM{1'b0}};			
			
			// Write I
			addr_offset = {{ADDRESS_BITS{1'b0}} ,{SUB_ADDRESS_BITS{1'b0}}, 5'b01000}; // Starting address for operand B, adjust as needed
			for (int i = 0; i < M_file; i = i + 1) begin
				@(posedge intf.clk);
				intf.pwrite = 1'b1;
				intf.psel = 1'b1;
				intf.paddr = addr_offset + (i << 5); // Calculate address based on index and data width
				case (M_file)
					1: intf.pstrb = 1'b1;
					2: intf.pstrb = 2'b11;
					3: intf.pstrb = 3'b111;
					4: intf.pstrb = 4'b1111;
				endcase
				intf.pwdata = matI_flat[i]; // Use actual data from matrix I
				@(posedge intf.clk);
				intf.penable = 1'b1;
			end
			
			@(posedge intf.clk);
			intf.psel = 1'b0;
			intf.penable = 1'b0;
			intf.pstrb = {MAX_DIM{1'b0}};						
			
			// Start operation (write to control reg)
			// Adjust intf.pwdata based on actual N, K, M, Biased_flag values read from file
			@(posedge intf.clk);
			intf.psel = 1'b1;
			intf.paddr = {ADDR_WIDTH{1'b0}}; // Control register address
			intf.pwdata = {{(BUS_WIDTH-16){1'b0}}, 2'b00, (M_file[1:0] - 1'b1),  (M_file[1:0] - 1'b1), (N_file[1:0] - 1'b1), 2'b00, SPN_SELECT[1:0], SPN_SELECT[1:0], 1'b0, 1'b1}; // Construct control word dynamically
			@(posedge intf.clk);
			intf.penable = 1'b1;
			@(posedge intf.clk);
			intf.psel = 0; intf.penable = 0;

			repeat (35) @(posedge intf.clk); // Wait for operation to complete
		end
		
		
		// Write matrix A
		addr_offset = {{ADDRESS_BITS{1'b0}} ,{SUB_ADDRESS_BITS{1'b0}}, 5'b00100}; // Starting address for operand A, adjust as needed
		for (int i = 0; i < N_file; i = i + 1) begin
			@(posedge intf.clk);
			intf.pwrite = 1'b1;
			intf.psel = 1'b1;
			intf.paddr = addr_offset + (i << 5); // Calculate address based on index and data width
			case (K_file)
				1: intf.pstrb = 1'b1;
				2: intf.pstrb = 2'b11;
				3: intf.pstrb = 3'b111;
				4: intf.pstrb = 4'b1111;
			endcase
			intf.pwdata = matA_flat[i]; // Use actual data from matrix A
			@(posedge intf.clk);
			intf.penable = 1'b1;
		end
		
		@(posedge intf.clk);
        intf.psel = 1'b0;
        intf.penable = 1'b0;	
		intf.pstrb = {MAX_DIM{1'b0}};			
			
		// Write matrix B
		addr_offset = {{ADDRESS_BITS{1'b0}} ,{SUB_ADDRESS_BITS{1'b0}}, 5'b01000}; // Starting address for operand B, adjust as needed
		for (int i = 0; i < K_file; i = i + 1) begin
			@(posedge intf.clk);
			intf.pwrite = 1'b1;
			intf.psel = 1'b1;
			intf.paddr = addr_offset + (i << 5); // Calculate address based on index and data width
			case (M_file)
				1: intf.pstrb = 1'b1;
				2: intf.pstrb = 2'b11;
				3: intf.pstrb = 3'b111;
				4: intf.pstrb = 4'b1111;
			endcase
			intf.pwdata = matB_flat[i]; // Use actual data from matrix B
			@(posedge intf.clk);
			intf.penable = 1'b1;
		end
		
		@(posedge intf.clk);
        intf.psel = 1'b0;
        intf.penable = 1'b0;
		intf.pstrb = {MAX_DIM{1'b0}};					
		
		// Start operation (write to control reg)
		// Adjust intf.pwdata based on actual N, K, M, Biased_flag values read from file
		@(posedge intf.clk);
		intf.psel = 1'b1;
		intf.paddr = {ADDR_WIDTH{1'b0}};
		intf.pwdata = {{(BUS_WIDTH-16){1'b0}}, 2'b00, (M_file[1:0] - 1'b1),  (K_file[1:0] - 1'b1), (N_file[1:0] - 1'b1), 2'b00, SPN_SELECT[1:0], SPN_SELECT[1:0], Biased_flag[0], 1'b1}; // Construct control word dynamically
		@(posedge intf.clk);
		intf.penable = 1'b1;
		@(posedge intf.clk);
		intf.psel = 0; intf.penable = 0;

		repeat (35) @(posedge intf.clk); // Wait for operation to complete
		
		// Read SP mat 0
		if (VERBOSE) $display("\n[STIMULUS] Time: %0d [ns], Result Matrix: \n", $realtime); 
		
		case(SPN_SELECT[1:0])
				0: addr_offset = {{ADDRESS_BITS{1'b0}} ,{SUB_ADDRESS_BITS{1'b0}}, 5'b10000}; // SPN 0
				1: addr_offset = {{ADDRESS_BITS{1'b0}} ,{SUB_ADDRESS_BITS{1'b0}}, 5'b10100}; // SPN 1
				2: addr_offset = {{ADDRESS_BITS{1'b0}} ,{SUB_ADDRESS_BITS{1'b0}}, 5'b11000}; // SPN 2
				3: addr_offset = {{ADDRESS_BITS{1'b0}} ,{SUB_ADDRESS_BITS{1'b0}}, 5'b11100}; // SPN 3
		endcase
		for (int i = 0; i < MAX_DIM*MAX_DIM; i = i + 1) begin 
			// Read Sequence
			@(posedge intf.clk);
			intf.psel = 1'b1;
			intf.pwrite = 1'b0;
			intf.paddr = addr_offset + (i << 5);
			@(posedge intf.clk);
			intf.penable = 1'b1;
			@(posedge intf.clk);
			intf.psel = 1'b0;
			intf.penable = 1'b0;
			printed_element = intf.prdata;
			res_row = i / MAX_DIM; 	//  res_row updates after every MAX_DIM elements read from memory.
			res_col = i % MAX_DIM; 	//  res_col updates in each iteration, and zero'ed every MAX_DIM elements read from memory.
			// Check if within N x M bounds before printing
			if (res_row < N_file && res_col < M_file) begin
				if (VERBOSE) $write("%d\t", $signed(printed_element));  // Use $write to stay on the same line
				mat_res_actual[res_row][res_col] = $signed(printed_element);
			end
			// Print new line after MAX_DIM elements read from memory, and if you still have any relevant rows left.
			if (((i + 1) % MAX_DIM == 0) && (res_row < N_file))  begin 
				if (VERBOSE) $display(""); // Print a new line
			end
		end
		if (VERBOSE) $display("\n"); // Print a new line
		
		@(posedge intf.clk);
		intf.psel = 0; intf.penable = 0;

	end endtask

	task checking_ov; begin		
		for (int i = 0; i < 1000; i = i + 1) begin 
      //$display("[STIMULUS] Iteration Number %0d:\n", i);
      // Start operation (write to control reg)
      @(posedge intf.clk);
      intf.psel = 1'b1;
      intf.pwrite = 1'b1;
      intf.paddr = {ADDR_WIDTH{1'b0}};
      intf.pwdata = {{(BUS_WIDTH-16){1'b0}}, 2'b00, (M_file[1:0] - 1'b1),  (K_file[1:0] - 1'b1), (N_file[1:0] - 1'b1), 2'b00, SPN_SELECT[1:0], SPN_SELECT[1:0], 1'b1, 1'b1};
      @(posedge intf.clk);
      intf.penable = 1'b1;
      @(posedge intf.clk);
      intf.psel = 0; 
      intf.penable = 0;
      intf.pwrite = 1'b0;
      repeat (30) @(posedge intf.clk); // Wait for operation to complete
      
      // reading data	from flag reg
      intf.psel = 1'b1;
      intf.pwrite = 1'b0;
      intf.paddr = {{ADDRESS_BITS{1'b0}} ,{SUB_ADDRESS_BITS{1'b0}}, 5'b01100}; // reading from flag reg
      @(posedge intf.clk);
      intf.penable = 1'b1;
      @(posedge intf.clk);
      // Check if intf.prdata != 0 and break the loop if true
      if (intf.prdata != 0) begin
        if (VERBOSE) $display("[STIMULUS] Breaking loop at iteration %0d due to non-zero status flag register\n", i);
        @(posedge intf.clk);
        intf.psel = 0; intf.penable = 0;
        break; // Exit the loop
      end
      @(posedge intf.clk);
      intf.psel = 0; intf.penable = 0;
    end
		  
	  if (VERBOSE && !intf.prdata) $display("[STIMULUS] Time: %0d [ns], Unsuccessfully created overflow sequence, try changing parameters (i.e BW/DW 16/8)\n", $realtime);

	end endtask

	task apb_master_sim_extreme; begin	
		// Sending normal multipication for start:
		@(posedge intf.clk);
		intf.psel = 1'b1;
		intf.pwrite = 1'b1;
		intf.paddr = {ADDR_WIDTH{1'b0}};
		intf.pwdata = {{(BUS_WIDTH-16){1'b0}}, 2'b00, (M_file[1:0] - 1'b1),  (K_file[1:0] - 1'b1), (N_file[1:0] - 1'b1), 2'b00, SPN_SELECT[1:0], SPN_SELECT[1:0], 1'b1, 1'b1};
		@(posedge intf.clk);
		intf.penable = 1'b1;
		@(posedge intf.clk);
		intf.psel = 0; 
		intf.penable = 0;
		intf.pwrite = 1'b0;
		@(posedge intf.clk); // not waiting enough time...
		
		if (VERBOSE) $display("[STIMULUS] Time: %0d [ns], Extreme Scenarios: Trying to write while busy \n", $realtime);
		@(posedge intf.clk);
		intf.psel = 1'b1;
		intf.pwrite = 1'b1;
		intf.paddr = {ADDR_WIDTH{1'b0}};
		intf.pwdata = {{(BUS_WIDTH-16){1'b0}}, 2'b00, (M_file[1:0] - 1'b1),  (K_file[1:0] - 1'b1), (N_file[1:0] - 1'b1), 2'b00, SPN_SELECT[1:0], SPN_SELECT[1:0], 1'b1, 1'b1};
		@(posedge intf.clk);
		intf.penable = 1'b1;
		@(posedge intf.clk);
		intf.psel = 0; 
		intf.penable = 0;
		intf.pwrite = 1'b0;
		repeat (35) @(posedge intf.clk); // Wait for operation to complete
		
		
		if (VERBOSE) $display("[STIMULUS] Time: %0d [ns], Extreme Scenarios: Sending N,K,M that are greater than MAX_DIM \n", $realtime);
		@(posedge intf.clk);
		intf.psel = 1'b1;
		intf.pwrite = 1'b1;
		intf.paddr = {ADDR_WIDTH{1'b0}};
		intf.pwdata = {{(BUS_WIDTH-16){1'b0}}, 2'b00, (MAX_DIM<4 ? 2'b11 : (M_file[1:0] - 1'b1)), (MAX_DIM<4 ? 2'b11 : (K_file[1:0] - 1'b1)), (MAX_DIM<4 ? 2'b11 : (N_file[1:0] - 1'b1)), 2'b00, SPN_SELECT[1:0], SPN_SELECT[1:0], 1'b1, 1'b1};
		@(posedge intf.clk);
		intf.penable = 1'b1;
		@(posedge intf.clk);
		intf.psel = 0; 
		intf.penable = 0;
		intf.pwrite = 1'b0;
		repeat (35) @(posedge intf.clk); // Wait for operation to complete
		
		
		if (VERBOSE) $display("[STIMULUS] Time: %0d [ns], Extreme Scenarios: Writing 'X's to control \n", $realtime);
		@(posedge intf.clk);
		intf.psel = 1'b1;
		intf.pwrite = 1'b1;
		intf.paddr = {ADDR_WIDTH{1'b0}};
		intf.pwdata = {{(BUS_WIDTH-16){1'b0}}, 16'bxxxxxxxxxxxxxxxx};
		@(posedge intf.clk);
		intf.penable = 1'b1;
		@(posedge intf.clk);
		intf.psel = 0; 
		intf.penable = 0;
		intf.pwrite = 1'b0;
		repeat (35) @(posedge intf.clk); // Wait for operation to complete		
		
	end endtask
	
	task close_files;
		begin
			$fclose(params_fd);
			$fclose(a_matrix_fd);
			$fclose(b_matrix_fd);
			$fclose(c_matrix_fd);
			$fclose(i_matrix_fd);
			$fclose(res_matrix_fd);
		end
	endtask
	
	always @(negedge intf.rst_n) begin: main_block
		if(!intf.rst_n) begin
			intf.start_cmp = 0 ;
			N_file <= 0;
			K_file <= 0;
			M_file <= 0;
			for (int i = 0; i < MAX_DIM; i = i + 1) begin
				for (int j = 0; j < MAX_DIM; j = j + 1) begin
					mat_res_gm[i][j] = 0;
					mat_res_actual[i][j] = 0;
				end 
			end
			
			clear_matrices();
			repeat(RST_CYC) @(posedge intf.clk);
			start_time = $realtime;
			for (int i = 0; i < NUM_FOLDERS; i = i + 1) begin
				// CHANGE PATHS IF NESSESARRY
				if (VERBOSE) $display("[STIMULUS] Time: %0d [ns], Test Number %0d:\n", $realtime, i);
				PARAMETERS_FILE = $sformatf("%0s/%0d/parameters.txt", PROJECT_PATH, i);
				A_MATRIX_FILE 	= $sformatf("%0s/%0d/A_matrix.txt", PROJECT_PATH, i);
				B_MATRIX_FILE 	= $sformatf("%0s/%0d/B_matrix.txt", PROJECT_PATH, i);
				C_MATRIX_FILE 	= $sformatf("%0s/%0d/C_matrix.txt", PROJECT_PATH, i);
				I_MATRIX_FILE 	= $sformatf("%0s/%0d/I_matrix.txt", PROJECT_PATH, i);
				RES_MATRIX_FILE = $sformatf("%0s/%0d/res_matrix.txt", PROJECT_PATH, i);
				open_files(); // Open parameter and matrix files based on new paths
				read_parameters(); // Read parameters from the parameter file
				read_matrices();
				apb_master_sim(); 
				@(posedge intf.clk);
				intf.start_cmp = 1'b1;
				@(posedge intf.clk);
				intf.start_cmp = 1'b0;
				close_files();
			end
			$display("[STIMULUS] Simulation Parameters: BW: %0d, DW: %0d, AW: %0d, SPN: %0d\n", BUS_WIDTH, DATA_WIDTH, ADDR_WIDTH, SP_NTARGETS);
			end_time = $realtime;
			$display("[STIMULUS] Total Calculation Time: %0d [ns], or %0.9f [s] (which is very very fast...)\n", (end_time - start_time), (end_time - start_time)/ 1_000_000_000.0);
			if (VERBOSE) $display("[STIMULUS] Time: %0d [ns], Checking OV Case\n", $realtime);
			checking_ov();
			if (VERBOSE) $display("[STIMULUS] Time: %0d [ns], Checking Extreme Scenarios: \n", $realtime);
			apb_master_sim_extreme();
			$display("Simulation Done!\n");
			if (!VERBOSE) $display("To see more simulation information, set VERBOSE flag in matmul_pkg\n");
			$finish;
		end
	end

endmodule