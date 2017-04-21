//Top-level module for 2600

module a2600(input logic b,
				 output logic a);

	logic Clk = 1'b1;

	logic [5:0] I;
	logic R;
	logic [12:0] A;
	logic [7:0] D;
	logic [6:0] CurColor;
	logic [8:0] ScanLine;
	logic [7:0] xPos;
	logic RDY;

	TIA TIA_Inst(.*, .NTSC_Clk(Clk));
endmodule
