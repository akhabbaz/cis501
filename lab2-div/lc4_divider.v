/* TODO: INSERT NAME AND PENNKEY HERE */

`timescale 1ns / 1ps
`default_nettype none

module lc4_divider(input  wire [15:0] i_dividend,
                   input  wire [15:0] i_divisor,
                   output wire [15:0] o_remainder,
                   output wire [15:0] o_quotient);

      /*** YOUR CODE HERE ***/

endmodule // lc4_divider

module lc4_divider_one_iter2(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [15:0] i_remainder,
                            input  wire [15:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output reg  [15:0] o_remainder,
                            output reg  [15:0] o_quotient);
       always @(i_dividend, i_quotient, i_divisor, i_remainder)
       begin 
              o_remainder = (i_remainder << 16'h1) | (i_dividend>> 16'hf) & 16'h1;
              o_quotient = i_quotient << 16'h1;
              if ( o_remainder >= i_divisor)
              begin
                 o_quotient  = o_quotient| 16'h1;
                 o_remainder = o_remainder - i_divisor;
              end
      end 
      assign o_dividend = i_dividend >> 16'h1;  
endmodule
module lc4_divider_one_iter(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [15:0] i_remainder,
                            input  wire [15:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output wire  [15:0] o_remainder,
                            output wire  [15:0] o_quotient);
       wire [15:0] rem;
       assign rem = (i_remainder << 16'h1) | (i_dividend>> 16'hf) & 16'h1;
       wire  remTooSmall = rem < i_divisor;
       assign o_remainder =(remTooSmall)? rem: rem - i_divisor;
       assign o_quotient = (remTooSmall)? i_quotient << 16'h1 :
                                           i_quotient << 16'h1 |16'h1;
       assign o_dividend = i_dividend >> 16'h1;  
endmodule
