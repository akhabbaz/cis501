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

module sext (input wire [15:0] a, output wire [15:0] signExtend);
      // this is the number of bits to take for sign extend
      parameter N = 9;
      localparam N_1 = N -1;
      wire [N_1:0]   imm;
      assign imm = a[N_1:0];
      
      localparam pd = 16 - N;
      wire   s = a[N_1];
      assign signExtend = { { pd {s}}, imm};
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

/*  inputs are function controls i_insn, i_r1data, i_r2data, returns
 *  corresponding logical funciotn
*/
module logicalOps( input wire [15:0] i_insn, input wire[15:0] i_r1data, 
                   input wire [15:0] i_r2data,
		   output wire[15:0] o_result);
      wire [15:0] andprod, orprod, xorprod, sextb, secondInput, notvalue;
      wire      immediateAND   = i_insn[5]; 
      assign          orprod   = i_r1data | i_r2data;
      assign          notvalue = ~i_r1data;
      assign         xorprod   = i_r1data ^ i_r2data;
      wire      immediateAnd   = i_insn[5]; 
      sext sextAdd ( .a(i_insn), .signExtend(sextb));
      defparam      sextAdd.N = 5;
      mux2to1_16bit  selectAndInput(.s(immediateAnd), .a(i_r2data), 
                                    .b(sextb),  .y(secondInput));
      
      assign         andprod = i_r1data & secondInput;
      wire        [2:0] control = immediateAND? 2'b0: i_insn[4:3];
       //choose the correct signal..
       mux4to1_16bit selectLogical( .s(control), .a(andprod), .b(notvalue),
				.c(orprod),  .d(xorprod), .y(o_result));
endmodule
      
/*  inputs are function controls i_r1, i_r2 data, its inverse; returns
 *  corresponding logical funciotn
*/
module shiftOps( input wire [15:0] i_insn, input wire[15:0] i_r1data, 
                   input wire [15:0] mod,
		   output wire[15:0] o_result);
    
      wire [15:0] sll, srl;
      wire signed [15:0] sra, i_r1Signed;
      assign i_r1Signed = i_r1data;
      wire [3:0] uimm4 = i_insn[3:0];
      wire [1:0] control = i_insn[5:4];
      assign          sll   = i_r1data << uimm4;
      assign          sra   = i_r1Signed >>> uimm4;
      assign          srl   = i_r1data >> uimm4;
       //choose the correct signal..
       mux4to1_16bit selectShift( .s(control), .a(sll), .b(sra),
				.c(srl),  .d(mod), .y(o_result));
endmodule
/* selectInstuction will select the actual o_result based on the opcode
 * summary*/    
module selectInstruction( s,  br, arth, cmp, jsr, log,  ldstr,  rti, const,
		shift, jmp, hiconst, trap, o_result);
	input wire [3:0] s;
	input wire [15:0] br, arth, cmp, jsr, log, ldstr, rti, 
		const, shift, jmp, hiconst, trap;
	output reg [15:0] o_result;
        always @(s, br, arth, cmp, jsr, log, ldstr, rti, const, shift,
                    jmp, hiconst, trap)
           begin
              case (s)
 		4'b00     : o_result  = br;
                4'b01     : o_result  = arth;
                4'b0101   : o_result  = log;
                4'b1010   : o_result  = shift;
                default   : o_result  = `zeroH;
              endcase
           end
endmodule



module lc4_alu(input  wire [15:0] i_insn,
               input  wire [15:0]  i_pc,
               input  wire [15:0]  i_r1data,
               input  wire  [15:0]  i_r2data,
               output wire [15:0] o_result);   
      

       wire [3:0] op = i_insn[15:12];
       wire [2:0] func = i_insn[5:3];

       // add subtract
       wire [15:0]   nb, sextb, multab, divab, modab, secondInput, addout, 
                     arithmetic, Rs, firstInput, logicalOut, shiftOut; 
       wire [1:0]    selMultDivide;
       wire         immediateAdd = i_insn[5]; 
       wire          cin;
       assign nb  = ~i_r2data;
       sext sextAdd ( .a(i_insn), .signExtend(sextb));
       defparam sextAdd.N = 5;
       //assign arithmetic = `zeroH;
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

       // handle the logical possibilities;
       logicalOps logOps (.i_insn(i_insn), .i_r1data(i_r1data), .i_r2data(i_r2data),
                        .o_result(logicalOut));
       // shift operators
       shiftOps   shiftOps1(.i_insn(i_insn), .i_r1data(i_r1data), .mod(modab), 
                                .o_result(shiftOut)); 
       selectInstruction sInstr(.s(op), .br(`zeroH), .arth(arithmetic), .cmp(`zeroH),
		.jsr(`zeroH), .log(logicalOut), .ldstr(`zeroH), .rti(`zeroH),
		.const(`zeroH), .shift(shiftOut), .jmp(`zeroH), .hiconst(`zeroH), .trap(`zeroH),
		.o_result(o_result));
      /*** YOUR CODE HERE ***/

endmodule
