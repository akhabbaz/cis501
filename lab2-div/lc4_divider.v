/* TODO: :INSERT NAME AND PENNKEY HERE */
`include "lc4_cla.v"
`timescale 1ns / 1ps
`default_nettype none
`define zeroH 16'h0
`define oneH  16'h1
`define FH  16'hF
module lc4_divider(input  wire [15:0] i_dividend,
                   input  wire [15:0] i_divisor,
                   output wire [15:0] o_remainder,
                   output wire [15:0] o_quotient);

      // store all intermediate values in these wires
      // 0th iteration inputs are from function inputs or constants
      // 15th output is either not needed or the output variables
      // 16*15 lines
      wire [239:0] remainder, dividend, quotient;
      //size of intermediate and final results
      parameter N = 16;
      parameter N_1 = 15;
      parameter N_2 = 14;
      parameter srt = N_2 *N;
      parameter stp = srt + N_1;
      // first loop initialize 
      lc4_divider_one_iter div0(.i_dividend(i_dividend), .i_divisor(i_divisor),
		.i_remainder(`zeroH), .i_quotient(`zeroH),
		.o_dividend(dividend[N_1:0]), .o_remainder(remainder[N_1:0]),
		.o_quotient(quotient[N_1:0])); 
      genvar i;
      generate
          for (i = 0; i < N_2; i = i + 1)
            begin
               parameter k = i*N;
               parameter kn = (i+1)*N;
               lc4_divider_one_iter div(.i_dividend(dividend[N_1+ k:k]), 
                   .i_divisor(i_divisor), .i_remainder(remainder[N_1+ k:k]), 
                   .i_quotient(quotient[N_1+ k:k]), .o_dividend(dividend[N_1+ kn:kn]), 
                   .o_remainder(remainder[N_1+ kn:kn]), .o_quotient(quotient[N_1+ kn:kn])); 
            end
      endgenerate
      lc4_divider_one_iter div1(.i_dividend(dividend[stp:srt]), .i_divisor(i_divisor),
		.i_remainder(remainder[stp:srt]), .i_quotient(quotient[stp:srt]),
		.o_dividend(), .o_remainder(o_remainder),
		.o_quotient(o_quotient)); 
  
endmodule // lc4_divider

module lc4_divider_one_iter(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [15:0] i_remainder,
                            input  wire [15:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output reg  [15:0] o_remainder,
                            output reg  [15:0] o_quotient);
       reg [15:0] rem;
       always @(i_dividend, i_quotient, i_divisor, i_remainder)
       begin 
           if ( i_divisor == `zeroH) 
               begin
                 o_remainder = `zeroH;
                 o_quotient  = `zeroH;
               end
           else
               begin
  	         rem  = (i_remainder << `oneH) | 
	     			(i_dividend>> `FH) & `oneH;
                 if ( rem < i_divisor)
           	     begin
              	       o_quotient  = i_quotient << `oneH;
                       o_remainder = rem;
                     end
                 else
                     begin
              	       o_quotient  = i_quotient << `oneH | `oneH;
                       //cla16Sub claSub(.a(rem), .b(i_divisor), .d(o_remainder)); 
                       o_remainder = rem - i_divisor;
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
