/* Anton Khabbaz*/

`timescale 1ns / 1ps
`include "lc4_divider.v" 
`default_nettype none

/*   mux2to1_16bit will choose input based on s, choosing a (s = 0) or b( s =
 *   1)
*/

module mux2to1_16bit( input wire s, input wire [15:0] a, input wire [15:0] b,
                   output reg [15:0] y);
      
	always @(a, b, s)
           begin
              case (s)
 		1`b0   : y = a;
                1`b1   : y = b;
              endcase
           end
endmodule
             
       	       

assign c = (s)


/*  addSubtract adds or subtracts the two inputs based on the control.
    s = 0  addition s = 1 subtraction
*/
module addSubtract(input wire  s,  input wire [15:0] i_r1data, input wire [15:0]
		i_r2data, output wire[15:0] o_result);
           
       reg [15:0] addend;
       always @(s, i_r2data)
       	begin
		case(s)
                1`b0:  addend = i_r2data;
                1`b1:  addend = ~i_r2data;
                endcase
        end
       cla16(.cin(s), .a(i_r1data), .b(addend), .sum(o_result));      
endmodule
        
 



module lc4_alu(input  wire [15:0] i_insn,
               input  wire [15:0]  i_pc,
               input  wire [15:0]  i_r1data,
               input  wire  [15:0]  i_r2data,
               output wire [15:0] o_result);
   

      /*** YOUR CODE HERE ***/

endmodule
