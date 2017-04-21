module TIA_Testbench();

timeunit 10ns;

timeprecision 1ns;

logic Clk = 1'b1;

always begin CLOCK_GENERATION:
#1 Clk = ~Clk;
end

logic [5:0] I;
logic R;
logic [12:0] A;
logic [7:0] D;
logic [6:0] CurColor;
logic [8:0] ScanLine;
logic [7:0] xPos;
logic RDY;

TIA TIA_Inst(.*, .NTSC_Clk(Clk));


initial begin: TEST_VECTORS
//Send VSync to signal start of frame
R = 1'b0;
A = 12'h00;
D = 8'h02;

#3
//Write value of BG color to TIA Register
R = 1'b0;
A = 12'h09;
D = 8'h00;

end
endmodule
