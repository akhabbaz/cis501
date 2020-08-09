/* Anton Khabbaz*/

`timescale 1ns / 1ps
`include "lc4_divider.v" 
`default_nettype none
`define zeroH 16'h0
/*   mux2to1_16bit will choose input based on s, choosing a (s = 0) or b( s =
 *   1)
*/

module mux2to1_16bit( input wire s, input wire [15:0] a, input wire [15:0] b,
                   output reg [15:0] y);
      
	always @(a, b, s)
           begin
              case (s)
 		1'b0   : y = a;
                1'b1   : y = b;
              endcase
           end
endmodule
             
module mux4to1_16bit( input wire[1:0] s, input wire [15:0] a, 
                      input wire [15:0] b, input wire [15:0] c, 
                      input wire [15:0] d, output reg [15:0] y);
      
	always @(a, b, c, d, s)
           begin
              case (s)
 		2'b00   : y = a;
                2'b01   : y = b;
                2'b10   : y = c;
                default : y = d;
              endcase
           end
endmodule
// one bit version
module mux4to1_1bit( input wire[1:0] s, input wire  a, 
                      input wire  b, input wire  c, 
                      input wire  d, output reg  y);
      
	always @(a, b, c, d, s)
           begin
              case (s)
 		2'b00   : y = a;
                2'b01   : y = b;
                2'b10   : y = c;
                default : y = d;
              endcase
           end
endmodule
/*  sext  sign extends.  It uses the least significant N bits and sign extends
 *  them. N must be less than 16.*/

module sext (input wire [15:0] a, output wire [15:0] y);
      // this is the number of bits to take for sign extend
      parameter N = 9;
      localparam N_1 = N -1;
      localparam pd = 16 - N;
      wire   s = a[N_1];
      assign y = { {pd {s}}, a[N_1:0]};
endmodule


/*  addSubtract adds or subtracts the two inputs based on the control.
    s = 0  addition s = 1 subtraction
*/
/*module addSubtract(input wire  s,  input wire [15:0] i_r1data, input wire [15:0]
		i_r2data, output wire[15:0] o_result);
           
       reg [15:0] addend;
       always @(s, i_r2data)
       begin
		case(s)
                1'b0:  addend = i_r2data;
                1'b1:  addend = ~i_r2data;

        end
       cla16(.cin(s), .a(i_r1data), .b(addend), .sum(o_result));      
endmodule
 */       
/*   produce the result of either multiply/divide, and mod;  
     multDvidie is 0 if multiply and 1 if divide
*/
module multDivideMod(input  wire [15:0]  i_r1data,
               input  wire  [15:0]  i_r2data,
               output wire [15:0]  multab,
               output wire [15:0] divab,   
               output wire [15:0] modab);   

       assign multab = i_r1data * i_r2data;
       // get quotient and mod
       lc4_divider lc4div(.i_dividend(i_r1data), .i_divisor(i_r2data),
		.o_remainder(modab), .o_quotient( divab));
endmodule


module lc4_alu(input  wire [15:0] i_insn,
               input  wire [15:0]  i_pc,
               input  wire [15:0]  i_r1data,
               input  wire  [15:0]  i_r2data,
               output wire [15:0] o_result);   


       // add subtract
       wire [15:0]   nb, sextb, multab, divab, modab, secondInput, addout, 
                     arithmetic, Rs, firstInput; 
       wire [1:0]    selMultDivide;
       wire         immediateAdd = i_insn[5]; 
       wire          cin;
       assign nb  = ~i_r2data;
       sext sextAdd ( .a(i_r2data), .y(sextb));
       defparam sextAdd.N = 5;
       multDivideMod multdiv_mod(.i_r1data(i_r1data), .i_r2data(i_r2data), .multab(multab),
                      .divab(divab), .modab(modab));
       //choose the correct binput000...
       mux4to1_16bit selectBAdd( .s(i_insn[5:4]), .a(i_r2data), .b(nb), .c(sextb), 
                               .d(sextb), .y(secondInput));
       // choose correct cin
       mux4to1_1bit cinSel( .s(i_insn[5:4]), .a(i_insn[4]), .b(i_insn[4]),
                            .c(1'b0),   .d(1'b0), .y(cin));
       // choose the correct a input;
       // place holder mux for when we need a different A input
       mux2to1_16bit selectAadd(.s(1'b0), .a(i_r1data), .b(16'b0),
				.y(firstInput));
       // here is the one cla16 module needed for add/subtract
       cla16  addSum(.a(firstInput), .b(secondInput), .cin(cin),
                                                           .sum(addout));
      
       //  bits 4:3 work select add mult divide subtract except for immediate.
       //  In that case set to 00 so that addout selected.
       assign selMultDivide = i_insn[5]? 2'h0: i_insn[4:3];
       mux4to1_16bit selMultDivideAdd( .s(selMultDivide), .a(addout),
		.b(multab), .c(addout), 
                               .d(divab), .y(arithmetic));
      //assign o_result =immediateAdd?firstInput:arithmetic;
      assign o_result = arithmetic;
   
       

 


      /*** YOUR CODE HERE ***/

endmodule
