//Convert signal from TIA to VGA buffer

//Notes: Image is scanlines 40-231, Pixels 68-227

module NTSCtoVGA(input logic clk,
					  input       [7:0] NTSC_R, NTSC_G, NTSC_B, //I believe the NTSC outputs straight RGB vals?
					  input logic ready, //signal to start reading signals to buffer again
					  input  logic ??, //will be all signals sent to NTSC port
					  output logic [420000:0] buffer,
					  output ??);

					  
/*TODO: 
-include a 16X16 array as a lookup table for the color palette. Use site on research page
-figure out where to implement RGB 8-bit vals bc they are not mapped to RGB
-determine the rest of the inputs and outputs to the NTSC and VGA, respectively. Namely sync/blank signals, depends on implementation
-load all of NTSC output to the buffer output
-stop loading new values until some signal is given that VGA has read the buffered values
-set other signals to appropriate values
*/

endmodule
