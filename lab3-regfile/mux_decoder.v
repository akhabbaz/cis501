/* Anton Khabbaz
 *
 * mux_decoder.v
 * implements a decoder and a mux that are parameterized.  N is the bits in the
 * selection bus and M is generally the width of the bus that is selected.
 *
 */

`timescale 1ns / 1ps

// Prevent implicit wire declaration
`default_nettype none

/* decoder will decode sel, an s bit wide selector, into one hot wire with  2**s bits, where lsb is 000.  */
module decoder  ( sel, hotwire);
    parameter s = 3;
    localparam l = 2**s;
    input wire [s-1:0] sel;
    output wire [l-1:0] hotwire;
    generate 
    genvar i;
 	for (i = 0; i < l; i = i + 1)
  	    begin
		assign hotwire[i] = (sel == i);
            end
    endgenerate 
endmodule
    
/* mux_hotwire_1B takes a hotwire that is 2**s bits wide, and an input that
 * is 2**s bits wide and outputs only one of them (1bit), governed by the hotwire.  For
 * example, s = 2, hotwire = 0010, in = 1101, out = 0;  When s = 0, the least
 * significant bit is chosen.*/
module mux_hotwire_1B(hotwire, in, out);
    parameter s = 3;
    localparam l = 2**s;
    input wire [l-1:0] hotwire, in;
    wire [l - 1:0] temp;
    output wire out;
    assign temp = hotwire & in;
    //and  ( temp,  hotwire, in);
    assign out = |temp;
endmodule

/* mux_hotwire, in an multiplexer for n bit wide signals, governed by an l
 * bit hotwire.  The hotwire is l= 2**s  bits wide, where s is the first input
 * parameter. The input is  l * n bits wide and the output is n bits wide, and
 * is selected from the input, governed by the
 * hotwire. The inputs are a large bus where the LSB n bits correspond to
 * hotwire 1.*/
module mux_hotwire (hotwire, in, out);
    parameter s = 3; // 2**s is the size of the hotwire 
    parameter  n = 16;  // the bus width of the output
    localparam l = 2**s; // hotwire width
    localparam  l_1 = l -1;
    localparam  k = n * l; // number of wires in input
    input wire [l_1:0] hotwire;
    input wire [k-1:0] in;
    output wire [n-1:0] out;
    generate 
    genvar i,j;
 	for (i = 0; i < n; i = i + 1)
  	    begin
              // take one bit from each separate bus input. This reorders the
		// input bus.
              wire  [l_1:0] oneBitInput; 
    	      for (j = 0; j < l; j = j + 1)
			begin
                    	   assign oneBitInput[j] = in[j*n + i];
                        end
              // now use assign the ith bit of output
              mux_hotwire_1B  thisMux(.hotwire(hotwire), .in(oneBitInput),
				.out(out[i]));
              defparam thisMux.s = s; 
            end
    endgenerate
endmodule 

/* multiplex, in an multiplexer for n bit wide signals, governed by an  s bit
 * wide selector.  s, n are input parameters.  A decoder is used to make a
 * hotwire from the selector. The hotwire is l= 2**s  bits wide, where s is the first input
 * parameter. The input is  l * n bits wide and the output is n bits wide, and
 * is selected from the input, governed by the
 * hotwire. The input is  a large bus where the LSB n bits correspond to
 * hotwire 0.
 *    This version has been debugged and it passes all tests.  */
module multiplex (sel, in, out);
    parameter   s = 3; // the width of the selector
    parameter   n = 16;  // the bus width of the output
    localparam  l = 2**s; // hotwire width
    localparam  k = n * l; // number of wires in input
    input wire [s - 1:0] sel;
    input wire [k - 1:0] in;
    output wire [n - 1 :0] out;
    wire      [l - 1:0]  hotwire;
    decoder decode(.sel(sel), .hotwire(hotwire));
    defparam    decode.s = s;
    mux_hotwire muxSel(.hotwire(hotwire), .in(in), .out(out));
    defparam   muxSel.s = s;
    defparam   muxSel.n = n;
endmodule

/* multiplex, in an multiplexer for n bit wide signals, governed by an  s bit
 * wide selector.  s, n are input parameters.  The hotwire is l= 2**s  bits wide, 
 * where s is the first input parameter. The input is  l * n bits wide and the output 
 * is n bits wide, and is selected from the input.  The input is  a large bus where 
 * the LSB n bits correspond to hotwire 0.
 *   This version uses an always loop to choose a section of the input to copy
 * to the output.  This is easier to understand than the above code and may be
 * faster. */

module multiplex2 (sel, in, out);
    parameter   s = 3; // the width of the selector
    parameter   n = 16;  // the bus width of the output
    localparam  l = 2**s; // hotwire width
    localparam  k = n * l; // number of wires in input
    input wire [s - 1:0] sel;
    input wire [k - 1:0] in;
    output reg  [n - 1 :0] out;
    always  @(sel, in)
	begin
	  out = in[sel*n +: n];
	end  
endmodule
/*Merge2 will merge two inputs into a larger bus. Inputs are concatenated from
 * least significant bit lowest (a)  to highest (b). */
module merge2(a, b, out);
	parameter n = 16;
  	localparam max = 2*n;
	input wire  [n-1:0] a;
	input wire  [n-1:0] b;
	output wire [max -1:0] out;
        assign out = {b, a};
endmodule
    
/* Merge4 will merge inputs into a larger bus. Inputs are concatenated from
 *  least significant bits lowest (a) to highest (d). */
module merge4(a, b, c, d,  out);
	parameter n = 16;
  	localparam max = 4*n;
	input wire  [n-1:0] a;
	input wire  [n-1:0] b;
	input wire  [n-1:0] c;
	input wire  [n-1:0] d;
	output wire [max -1:0] out;
        assign out = {d, c, b, a};
endmodule
    
/* Merge8 will merge inputs into a larger bus. Inputs are concatenated from
 * least significant bits (a) to most Significant bits (h). */
module merge8(a, b, c, d, e, f, g, h, out);
	parameter n = 16;
  	localparam max = 8*n;
	input wire  [n-1:0] a;
	input wire  [n-1:0] b;
	input wire  [n-1:0] c;
	input wire  [n-1:0] d;
	input wire  [n-1:0] e;
	input wire  [n-1:0] f;
	input wire  [n-1:0] g;
	input wire  [n-1:0] h;
	output wire [max -1:0] out;
        assign out = {h, g, f, e, d, c, b, a};
endmodule
/* Merge16 will merge inputs into a larger bus. Inputs are concatenated from
 * least significant bits (a) to most Significant bits (p).  Because of
 * conflict, w is used for the number of bits (data Width).*/
module merge16(a, b, c, d, e, f, g, h,
	       i, j, k, l, m, n, o, p, out);
	parameter w = 16;
  	localparam max = 16 * w;
	input wire  [w - 1:0] a, b, c, d, e, f, g, h;
	input wire  [w - 1:0] i, j, k, l, m, n, o, p;
	output wire [max -1:0] out;
        assign out = {p, o, n, m, l, k, j, i, h, g, f, e, d, c, b, a};
endmodule
