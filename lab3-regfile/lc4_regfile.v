/* Anton Khabbaz
 *
 * lc4_regfile.v
 * Implements an 8-register register file parameterized on word size.
 *
 */

`timescale 1ns / 1ps

// Prevent implicit wire declaration
`default_nettype none


/* n is the number of bits in a  register;  s is  the width of the
 * selector, there are 2**s registers accessed.  This regfile code could work
 * for any width selectors (any s) or any width register (n)
*/
    
    
module lc4_regfile #(parameter n = 16,  s = 3)
   (input  wire         clk,
    input  wire         gwe,
    input  wire         rst,
    input  wire [s-1:0] i_rs,      // rs selector
    output wire [n-1:0] o_rs_data, // rs contents
    input  wire [s-1:0] i_rt,      // rt selector
    output wire [n-1:0] o_rt_data, // rt contents
    input  wire [s-1:0] i_rd,      // rd selector
    input  wire [n-1:0] i_wdata,   // data to write
    input  wire         i_rd_we    // write enable
    );
    localparam l = 2**s;  // number of registers stored
    localparam k = l * n; // number of intermediate registers
    wire [k-1:0] regOut;  // the output of all the registers;
    wire [l-1:0] hotwire; // decoded i_rd destination register
    wire [l-1:0] we, we_all; // we, writeEnable to each register, repeated we
			     //signal repeated 
    // get the decoded signal
    decoder decode(.sel(i_rd), .hotwire(hotwire));
    defparam  decode.s = s;
    // get we one per register 
    assign  we_all = {l {i_rd_we}}; // repeat i_rd_we
    assign we = hotwire & we_all;  // we is one register per file
    //and (we, we_all, hotwire);
    // write to the register and connect regOut
    generate 
    genvar i;
       for (i = 0; i < l; i = i + 1)
	    begin
 		localparam regMax = (i + 1) * n -1;
                localparam regMin = i * n;
		Nbit_reg  oneReg(.in(i_wdata), .out(regOut[regMax:regMin]),
			.clk(clk), .we(we[i]), .gwe(gwe), .rst(rst));
		defparam oneReg.n = n;
            end
    endgenerate
    // get rs Mux
    multiplex  rsMux(.sel(i_rs), .in(regOut), .out(o_rs_data));
    defparam   rsMux.s = s; // width of i_rs 
    defparam   rsMux.n = n; // width of the registers 
    // get rt mux
    multiplex rtMux(.sel(i_rt), .in(regOut), .out(o_rt_data));
    defparam   rtMux.s = s; // width of i_rt 
    defparam   rtMux.n = n; // width of the registers 
endmodule 
