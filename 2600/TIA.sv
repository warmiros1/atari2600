module TIA(input  logic        NTSC_Clk,
			  input  logic [5:0]  I,
			  input  logic 		 R,
			  input  logic [12:0] A,
			  inout  logic [7:0]  D,
			  output logic [6:0]  CurColor,
			  output logic [8:0]  ScanLine,
			  output logic [7:0]  xPos,
			  output logic        RDY);

	//Determine CS from address
	logic CS;
	assign CS = (~A[12] & ~A[7]);

	//VSync and HSync are internal, since 
	logic VSync, HSync;
	
	//Is processor waiting for Sync?
	logic WSync;
	assign RDY = ~WScync

	//Nothing is drawn during VBlank period
	logic VBlank;

	//TIA Registers
	logic [6:0] COLUP0; //Player 0 and missile 0 color
	logic [6:0] COLUP1; //Player 1 and missile 1 color
	logic [6:0] COLUPF; //Playfield and ball Color
	logic [6:0] COLUBK; //BG Color

	//Graphics registers
	//These are all basically 1D bitmaps
	logic [3:0] PF0; //Playfield
	logic [7:0] PF1;
	logic [7:0] PF2;
	
	logic [7:0] GRP0; //Player 0
	logic [7:0] GRP1; //Player 1
	
	//CTRLPF
	logic ReflectPF;
	logic PFScoreMode;
	logic PFPriority;
	logic [1:0] BallSize;

	//Object positions
	logic [7:0] P0_Pos;
	logic [7:0] M0_Pos;
	logic [7:0] P1_Pos;
	logic [7:0] M1_Pos;
	logic [7:0] Ball_Pos;
	
	//Enable or disable objects
	logic ENAM0, ENAM1, ENABL;
	
	logic REFP0, REFP1;
	
	//Which objects should be drawn
	logic Draw_M0, Draw_M1, Draw_P0, Draw_P1, Draw_BL, Draw_PF;
	
	//Colision Latches
	logic COL_M0-P1, COL_M0-P0, COL_M1-P0, COL_M1-P1, COL_P0-PF, COL_P0-BL, COL_P1-PF, COL_P1-BL,
			COL_M0-PF, COL_M0-BL, COL_M1-PF, COL_M1-BL, COL_BL-PF, COL_P0-P1, COL_M0-M1;

	//Notes: Image is scanlines 40-231, Pixels 68-227

	//Update Scanline and/or xPos
	always_ff @ (posedge NTSC_Clk)
	begin
		xPos = xPos + 1;
		if (xPos >= 8'd228)
		begin
			xPos = 0;
			ScanLine = ScanLine + 1;
			if (WSync == 1'b1) //If waiting for Sync, resume
				WSync = 1'b0;
		end
		if (ScanLine >= 9'd282)
			ScanLine = 0;
	end

	//Output the proper color
	always_comb
	begin
		if (VBlank || ScanLine < 40 || xPos < 68)
			CurColor = 7'h00; //Black is output during a VBlank. Also, we don't bother with calculations while off screen
		else
		begin
			Draw_M0 = 1'b0;
			Draw_M1 = 1'b0;
			Draw_P0 = 1'b0;
			Draw_P1 = 1'b0;
			Draw_BL = 1'b0;
			Draw_PF = 1'b0;
			//Rough procedure for this block:
			//1. Determine which, if any, objects should be drawn at current beam position
			//2. Appropriately set collision latches
			if (Draw_M0 && Draw_M1) COL_M0-M1 = 1'b1;
			if (Draw_M0 && Draw_P0) COL_M0-P0 = 1'b1;
			if (Draw_M0 && Draw_P1) COL_M0-P1 = 1'b1;
			if (Draw_M0 && Draw_BL) COL_M0-BL = 1'b1;
			if (Draw_M0 && Draw_PF) COL_M0-PF = 1'b1;
			if (Draw_M1 && Draw_P0) COL_M1-P0 = 1'b1;
			if (Draw_M1 && Draw_P1) COL_M1-P1 = 1'b1;
			if (Draw_M1 && Draw_BL) COL_M1-BL = 1'b1;
			if (Draw_M1 && Draw_PF) COL_M1-PF = 1'b1;
			if (Draw_P0 && Draw_P1) COL_P0-P1 = 1'b1;
			if (Draw_P0 && Draw_BL) COL_P0-BL = 1'b1;
			if (Draw_P0 && Draw_PF) COL_P0-PF = 1'b1;
			if (Draw_P1 && Draw_BL) COL_P1-BL = 1'b1;
			if (Draw_P1 && Draw_PF) COL_P1-PF = 1'b1;
			if (Draw_BL && Draw_PF) COL_BL-PF = 1'b1;

			//3. Draw the proper pixel
			CurColor = COLUBK;
			if (PFBallPriority) begin //PF and ball have higher priority
				if (Draw_P1 || Draw_M1) CurColor = COLUP1;
				if (Draw_P0 || Draw_M0) CurColor = COLUP0;
				if (Draw_PF || Draw_BL) CurColor = COLUPF;
			end
			else begin
				if ((Draw_PF && !PFScoreMode) || Draw_BL) CurColor = COLUPF;
				if (Draw_P1 || Draw_M1 || (PFScoreMode && DrawPF)) CurColor = COLUP1;
				if (Draw_P0 || Draw_M0 || (PFScoreMode && DrawPF)) CurColor = COLUP0;
			end
		end
	end
	
	//Handle TIA I/O
	always_ff @ (posedge NTSC_Clk)
	begin
		D = 8'bZ; //By default, data output must be held at high Z
	
		if (CS) //Check we are accessing TIA on Databus
		begin
			if (~R)
				unique case (A[5:0]) //Handle writes to TIA
					6'h00: //VSync
					begin
						if (A[1]) //TODO: What happens if we VSYNC at a random time?
						begin
							VSync = 1'b1;
							ScanLine = 8'd0;
							xPos = 8'd0;
						end
					end
					6'h01: //VBLANK
					begin
						VBlank = D[1]; //TODO: bits 6 and 7 (Someting to do with input control?)
					end
					6'h02: //WSYNC
						WSync = 1'b1; //Halt processor
					6'h06:
						COLUP0 = D[7:1]
					6'h07:
						COLUP1 = D[7:1]
					6'h08:
						COLUPF = D[7:1];
					6'h09:
						COLUBK = D[7:1];
					6'h0A: //CTRLPF:
					begin
						ReflectPF = D[0];
						PFScoreMode = D[1];
						PFBallPriority = D[2];
						BallSize = D[5:4];
					end
					6'h0D:
						PF0 = D[7:4];
					6'h0E:
						PF1 = D[7:1];
					6'h0F:
						PF2 = D[7:1];
					6'h2C: //Clear all the collision latches.
					begin
						COL_M0-P1 = 1'b0;
						COL_M0-P0 = 1'b0;
						COL_M1-P0 = 1'b0;
						COL_M1-P1 = 1'b0;
						COL_P0-PF = 1'b0;
						COL_P0-BL = 1'b0;
						COL_P1-PF = 1'b0;
						COL_P1-BL = 1'b0;
						COL_M0-PF = 1'b0;
						COL_M0-BL = 1'b0;
						COL_M1-PF = 1'b0;
						COL_M1-BL = 1'b0;
						COL_BL-PF = 1'b0;
						COL_P0-P1 = 1'b0;
						COL_M0-M1 = 1'b0;
					end
				endcase
				unique case (A[3:0]) //Handle Reads from TIA
					4'h00:
					begin
						D[7] = COL_M0-P1;
						D[6] = COL_M0-P0;
					end
					4'h01:
					begin
						D[7] = COL_M0-P1;
						D[6] = COL_M0-P0;
					end
					4'h02:
					begin
						D[7] = COL_P0-PF;
						D[6] = COL_M0-P0;
					end
					4'h03:
					begin
						D[7] = COL_P1-PF;
						D[6] = COL_M1-BL;
					end
					4'h04:
					begin
						D[7] = COL_M0-PF;
						D[6] = COL_M0-BL;
					end
					4'h05:
					begin
						D[7] = COL_M1-PF;
						D[6] = COL_M1-BL;
					end
					4'h06:
					begin
						D[7] = COL_BL-PF;
					end
					4'h07:
					begin
						D[7] = COL_P0-P1;
						D[6] = COL_M0-M1;
					end
					//8-B is some pot stuff we don't worry about
				endcase
		end
	end
endmodule
