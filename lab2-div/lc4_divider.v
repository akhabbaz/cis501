/* Anton Khabbaz */
`timescale 1ns / 1ps
//`include "lc4_cla.v"  This is not needed because the make file includes this
`default_nettype none
`define zeroH 16'h0
`define zeroShort 15'h0
`define oneH  16'h1
`define negOne 16'hFFFF
`define FH  16'hF
module lc4_divider(input  wire [15:0] i_dividend,
                   input  wire [15:0] i_divisor,
                   output wire [15:0] o_remainder,
                   output wire [15:0] o_quotient);

      // store all intermediate values in these wires
      // 0th iteration inputs are from function inputs or constants
      // 15th output is either not needed or the output variables
      // 16*15 lines
      parameter N = 16;
      localparam N_1 = N - 1;
      localparam N_2 =N - 2;
      localparam srt = N_2 *N;
      localparam stp = srt + N_1;
      localparam k = 0;
      localparam kn = N;
      wire [stp:0] remainder, dividend, quotient;
      //size of intermediate and final results
      // first loop initialize 
      lc4_divider_one_iter div0(.i_dividend(i_dividend), .i_divisor(i_divisor),
		.i_remainder(`zeroShort), .i_quotient(`zeroShort),
		.o_dividend(dividend[N_1:0]), .o_remainder(remainder[N_1:0]),
		.o_quotient(quotient[N_1:0])); 
      genvar i;
      generate
          for (i = 0; i < N_2; i = i + 1)
            begin
               localparam   k = i*N;
               localparam  kn = (i+1)*N;
               lc4_divider_one_iter div(.i_dividend(dividend[N_1+ k:k]), 
                   .i_divisor(i_divisor), .i_remainder(remainder[N_2+ k:k]), 
                   .i_quotient(quotient[N_2+ k:k]), .o_dividend(dividend[N_1+ kn:kn]), 
                   .o_remainder(remainder[N_1+ kn:kn]), .o_quotient(quotient[N_1+ kn:kn])); 
            end
      endgenerate
      lc4_divider_one_iter div1(.i_dividend(dividend[stp:srt]), .i_divisor(i_divisor),
		.i_remainder(remainder[stp-1:srt]), .i_quotient(quotient[stp-1:srt]),
		.o_dividend(), .o_remainder(o_remainder),
		.o_quotient(o_quotient)); 
  
endmodule // lc4_divider

module lc4_divider_one_iter(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [14:0] i_remainder,
                            input  wire [14:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output reg  [15:0] o_remainder,
                            output reg  [15:0] o_quotient);
       wire [15:0] rem, newRem, quotientShift;
       assign  rem  = (i_remainder << `oneH) | 
	     			(i_dividend>> `FH) & `oneH;
       cla16Sub claSub(.a(rem), .b(i_divisor), .d(newRem));
       assign quotientShift = i_quotient << `oneH; 
       always @(quotientShift, i_divisor, i_remainder, rem, newRem)
       begin 
           if ( i_divisor == `zeroH) 
               begin
                 o_remainder = `zeroH;
                 o_quotient  = `zeroH;
               end
           else
               begin
                 if ( rem < i_divisor)
           	     begin
              	       o_quotient  = quotientShift;
                       o_remainder = rem;
                     end
                 else
                     begin
              	       o_quotient  = quotientShift | `oneH;
                       o_remainder = newRem;
                     end
               end
       end 
       assign o_dividend = i_dividend << `oneH;
endmodule 
module lc4_divider_one_iter2(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [15:0] i_remainder,
                            input  wire [15:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output wire  [15:0] o_remainder,
                            output wire  [15:0] o_quotient);
       wire [15:0] rem, newRem;
       assign rem = (i_remainder << `oneH) | (i_dividend>> `FH) & `oneH;
       wire  remTooSmall = rem < i_divisor;
       wire  div0 = i_divisor == `zeroH;
       cla16Sub claSub(.a(rem), .b(i_divisor), .d(newRem)); 
       assign o_remainder =(div0)? `zeroH:
                    (remTooSmall)? rem: //rem - i_divisor;
                                      newRem;
       assign o_quotient = (div0)? `zeroH:
                    (remTooSmall)? i_quotient << `oneH :
                                  i_quotient << `oneH |`oneH;
       assign o_dividend = i_dividend << `oneH;  
endmodule
