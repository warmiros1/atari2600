module 6502(output logic 		 R, //Also ~W
				inout  logic [8:0]  Data,
				output  logic [12:0] Addr)

	//Registers
	logic [7:0] IR;
	logic [7:0] A, X, Y, S;

	//Internal buses
	logic [7:0] ADH, ADL, DataBus;

	//Gates to drive internal busses
	logic Gate_ADH_ALU, Gate_ADH_PCH, Gate_ADH_DataBus, Gate_ADH_Reset;
	logic Gate_ADL_ALU, Gate_ADL_S, Gate_ADL_PCL, Gate_ADL_DataBus, Gate_ADH_Reset_0, Gate_ADH_Reset_1;
	logic Gate_DataBus_S, Gate_DataBus_A, Gate_DataBus_X, Gate_DataBus_Y, Gate_DataBus_ALU, Gate_DataBus_PCL, Gate_DataBus_PCH, Gate_DateBus_ALU;

	logic LD_S_DataBus;

	logic [9:0] {RESET_0,
					 FETCH_0, FETCH_1_0, FETCH_1_1, FETCH_2, //Opcode fetch states
					 LDA_IMM, LDA_ZP, LDA_ZPX, LDA_ABS, LDA_ABSX, LDA_ABSY, LDA_INDX, LDA_INDY, 
					 STA_ZP, STA_ZPX, STA_ABS, STA_ABSX, STA_ABSY, STA_INDX, STA_INDY,
					 LDX_IMM, LDX_ZP, LDX_ZPX, LDX_ABS, LDX_ABSX, LDX_ABSY, LDX_INDX, LDX_INDY, 
					 STX_ZP, STX_ZPX, STX_ABS, STX_ABSX, STX_ABSY, STX_INDX, STX_INDY,
					 INX,
					 JMP_ABS, JMP_IND } state, next_state;
					
	//Next state logic 
	always_comb begin
		case state
		FETCH_0: next_state = FETCH_1_0;
		FETCH_1_0: next_state = FETCH_1_1;
		FETCH_1_1: next_state = FETCH_2;
		default: next_state = FETCH_0;
		endcase
	end	
	//Control signals 
	always_comb begin
		Gate_ADH_ALU = 1'b0;
		Gate_ADH_PCH = 1'b0;
		Gate_ADH_DataBus = 1'b0;
		Gate_ADH_RESET = 1'b0;
		
		Gate_ADL_ALU = 1'b0;
		Gate_ADL_S = 1'b0;
		Gate_ADL_PCL = 1'b0;
		Gate_ADL_DataBus = 1'b0;
		Gate_ADL_RESET_0 = 1'b0;
		Gate_ADL_RESET_1 = 1'b0;

		case (state)
		RESET_0: begin
			Gate_ADH_Reset = 1'b1;
			Gate_ADL_Reset_0 = 1'b1;
			R = 1'b1;
			
		RESET_1: begin
			Gate_ADH_Reset = 1'b1;
			Gate_ADL_Reset_1 = 1'b1;
		end
		endcase
	end
	
	//Datapath
	always_ff begin
		if (GATE_ADH_PCH)
			ADH = PC[15:8];
		else if (GATE_ADH_DATABUS)
			ADH = DataBus
		else if (GATE_ADH_RESET)
			ADH = 8'hff;
		else
			ADH = 8'bZ;

		if (GATE_ADL_PCL)
			ADL = PC[7:0];
		else if (GATE_ADL_DATABUS)
			ADL = DataBus
		else if (GATE_ADL_RESET_1)
			ADL = 8'hfc;
		else if (GATE_ADL_RESET_2)
			ADL = 8'hfd;
		else
			ADH = 8'bZ;
			
	end
	
	//Reset Vector 0xFFFC
	
	//Absolute Jump
	//MAR < PC
	//PC+= 1
	//R = 1
	
	//tmp < MDR
	//MAR < PC
	//PC+= 1
	
	//PC < (MDR,tmp)
	
	//Indirect Jump
	//MAR < PC
	//PC+= 1
	//R = 1
	
	//PC < MDR
endmodule
