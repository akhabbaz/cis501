/* Anton Khabbaz*/

`timescale 1ns / 1ps
//`include "lc4_divider.v"
`define zeroH 16'h0
`define oneH  16'h1
`define negOne 16'hFFFF
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
/*  mux8to1_16 bit chooses an input a to h  and sends it to the output y
*/
module mux8to1_16bit( input wire[2:0] s, input wire [15:0] a, 
                      input wire [15:0] b, input wire [15:0] c, 
                      input wire [15:0] d, input wire [15:0] e, 
                      input wire [15:0] f, input wire [15:0] g, 
                      input wire [15:0] h, output reg [15:0] y);
	always @(a, b, c, d, e, f, g, h, s)
           begin
              case (s)
 		3'b000   : y = a;
                3'b001   : y = b;
                3'b010	 : y = c;
 		3'b011   : y = d;
                3'b100   : y = e;
                3'b101	 : y = f;
 		3'b110   : y = g;
                default  : y = h;
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
 *  them to a bus width of W.  N must be less than W.*/
module sext (a, signExtend);
      // this is the number of bits to take for sign extend
      parameter N = 9;
      parameter W = 16;
      localparam N_1 = N -1;
      localparam W_1  = W-1;
      input wire [N_1:0] a;
      output wire [W_1:0] signExtend;
      wire [N_1:0]   imm;
      assign imm = a[N_1:0];
      
      localparam pd = W - N;
      wire   s = a[N_1];
      assign signExtend = { { pd {s}}, imm};
endmodule
/*  pad pads the input with zeros.  It uses the least significant N bits and
 *  pads them to a bus width of W.  N must be less than W.*/
module pad (a, y);
      // this is the number of bits to take for pad
      parameter N = 9;
      parameter W = 16;
      localparam N_1 = N - 1;
      localparam W_1 = W - 1;
      input wire [N_1:0] a; 
      output wire [W_1:0] y;
      localparam pd = W - N;
      wire   s = 1'b0;
      assign y = { { pd {s}}, a};
endmodule
/*  output oneH, zeroH, or  negOne if a >, = or < b)*/
module compareUnsigned(input wire [15:0] a, input wire [15:0] b, output
			wire [15:0] result);
	wire greaterThan = (a > b);
        wire lessThan    = (a < b);
        assign result = greaterThan? `oneH:( lessThan? `negOne:`zeroH);
endmodule

/*  output oneH, zeroH, or  negOne if a >, = or < b)*/
module compareSigned(input wire signed [15:0] a, input wire signed [15:0] b, output
			wire [15:0] result);
	wire greaterThan = (a > b);
        wire lessThan    = (a < b);
        assign result = greaterThan? `oneH:( lessThan? `negOne:`zeroH);
endmodule
/* compare ab governed by i_insn (00 CMP, 01 CMPU, 10 CMPI, CMPIU  11)  does
 * sign extend or padding for immediate operands*/ 
module compare(input wire[8:0] imm_ins, input wire [15:0] a, 
	input wire  [15:0] b, output wire [15:0] result);

         	wire [15:0]  imm7, uimm7, cmp, cmpu, cmpi, cmpiu;
                pad   u7 (.a(imm_ins[6:0]), .y(uimm7));
                defparam u7.N = 7;
                sext  i7 (.a(imm_ins[6:0]), .signExtend(imm7));
                defparam i7.N = 7;
                compareSigned cmp1( .a(a), .b(b), .result(cmp));
                compareUnsigned cmpu1 (.a(a), .b(b), .result(cmpu));
                compareSigned cmp2(.a(a), .b(imm7), .result(cmpi));
                compareUnsigned cmpu2( .a(a), .b(uimm7), .result(cmpiu));
                mux4to1_16bit   outR( .s(imm_ins[8:7]), .a(cmp), .b(cmpu),
					.c(cmpi), .d(cmpiu), .y(result)); 
endmodule                
/* jsr calculates jsrr or jsr based on the instruction. It shifts Imm by 4 and
 * masks the PC for the MSB.  imm_ins:lower 11 is immediate, 12th  is
 * instruction 0 use i_r1data or Rs, 1 means use the immediate and the pc15 to
 * get the address */      
module jsr (input  wire [11:0] imm_ins,
               input  wire   pc15,
               input  wire [15:0]  i_r1data,
               output wire  [15:0] o_result);

       wire [15:0] pcVal;
       assign pcVal = { pc15,  imm_ins[10:0], 4'b0};
       wire sel  = imm_ins[11];
       mux2to1_16bit m2To1(.s(sel), .a(i_r1data), .b(pcVal), .y(o_result));
endmodule

/* hiconst calculates hiconst based on the instruction. uimm is the lower 8 bits
 * of instruction.  Const is the low 8 bits of const */      
module hiconst (input  wire [7:0] uimm,
               input  wire [7:0]  const,
               output wire  [15:0] o_result);

       assign o_result = {uimm, const};
endmodule

/* trap calculates trap value  based on the instruction. */      
module trap (input  wire [7:0] immediatePC,
               output wire  [15:0] o_result);

       assign o_result = { 8'h80, immediatePC};
endmodule

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

/*  inputs are function controls immediateAnd, i_r1data, i_r2data, and sext5, returns
 *  corresponding logical function.  ImmediateAnd is a logical level (1)
 *  indicating immediate And (i_insn[5]), and sext5 if the input is not
 *  immediateAnd has in wires  4:3 the logic to choose theoutput value.
*/
module logicalOps( input wire immediateAnd, input wire[15:0] i_r1data, 
                   input wire [15:0] i_r2data, input wire [15:0] sext5,
		   output wire[15:0] o_result);
      wire [15:0] andprod, orprod, xorprod,  secondInput, notvalue;
      assign          orprod   = i_r1data | i_r2data;
      assign          notvalue = ~i_r1data;
      assign         xorprod   = i_r1data ^ i_r2data;
      mux2to1_16bit  selectAndInput(.s(immediateAnd), .a(i_r2data), 
                                    .b(sext5),  .y(secondInput));
      
      assign         andprod = i_r1data & secondInput;
      wire        [1:0] control = immediateAnd? 2'b0: sext5[4:3];
       //choose the correct signal..
       mux4to1_16bit selectLogical( .s(control), .a(andprod), .b(notvalue),
				.c(orprod),  .d(xorprod), .y(o_result));
endmodule
      
/*  inputs are function controls i_r1, i_r2 data, its inverse; returns
 *  corresponding logical funciotn
*/
module shiftOps( input wire [5:0] ins_imm, input wire[15:0] i_r1data, 
                   input wire [15:0] mod,
		   output wire[15:0] o_result);
    
      wire [15:0] sll, srl;
      wire signed [15:0] sra, i_r1Signed;
      assign i_r1Signed = i_r1data;
      wire [3:0] uimm4 = ins_imm[3:0];
      wire [1:0] control = ins_imm[5:4];
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
 		4'b0000     : o_result  = br;
                4'b0001     : o_result  = arth;
                4'b0010     : o_result  = cmp;
                4'b0100     : o_result  = jsr;
                4'b0101     : o_result  = log;
                4'b0110     : o_result  = ldstr;
                4'b0111     : o_result  = ldstr;
                4'b1000     : o_result  = rti;
                4'b1001     : o_result  = const;
                4'b1010     : o_result  = shift;
                4'b1100     : o_result  = jmp;
                4'b1101     : o_result  = hiconst;
                4'b1111     : o_result  = trap; 
                default     : o_result  = `zeroH;
              endcase
           end
endmodule
   


/*   AddOutput produce the   output of all operations that use addition;  This
 *   includes the calculat  ion for the branches, for add, sub, and add immediate,
 *   ldr, str, jump .  It takes the same inputs as the alu, but just calculates
 *   the addition.  It chooses the correct A input, b input and c in to do all
 *   the additions.  imm11 is the first 11 bits of the instruction, contol is
 *   bits 15, 13, 12.
*/
module AddOutput(input  wire [10:0] imm11,
               input  wire  [2:0]   control,
               input  wire [15:0]  i_pc,
               input  wire [15:0]  i_r1data,
               input  wire  [15:0]  i_r2data,
               output wire [15:0]   sextImm5,
               output wire [15:0]  sextImm9, 
               output wire  [15:0] o_result);

       wire [15:0] aInput, bIn, nb, sextImm6, sextImm11;
       wire [2:0]  bsel;
       // a_r1 is 0 if pc is the input 1 if it is r1data.
       wire       a_r1, sub, immedAdd, arith, jmp, cin;
       assign a_r1 = control[1] | control[0];
       // true if load store (or trap), false otherwise
       assign    arith   = control[1:0] == 2'b01;
       assign   immedAdd =  arith & imm11[5];
       assign   jmp      = control[2];
       // true if subtraction
       assign    sub = arith & ( imm11[5:4] == 2'b01);
       assign    cin = ~a_r1 | sub;
       assign   bsel[0] = cin; 
       assign   bsel[1] = jmp | immedAdd;
       assign   bsel[2] = arith;
       mux2to1_16bit aIn( .s(a_r1), .a(i_pc), .b(i_r1data), .y(aInput));
      // add 1 if there is the pc add 1 or if it is subtraction;
       
       //create alternative b inputs.
     
       assign nb  = ~i_r2data;
       sext sextAdd ( .a(imm11[4:0]), .signExtend(sextImm5));
       defparam sextAdd.N = 5;
       sext im9 (.a(imm11[8:0]), .signExtend(sextImm9));
       defparam im9.N = 9;
       sext im6 (.a(imm11[5:0]), .signExtend(sextImm6));
       defparam im6.N = 6;
       sext im11 (.a(imm11), .signExtend(sextImm11));
       defparam im11.N = 11;
       // choose the correct output
       mux8to1_16bit selectBAdd( .s(bsel), .a(sextImm6), .b(sextImm9),
		.c(`zeroH), .d(sextImm11), .e(i_r2data), .f(nb), .g(sextImm5), 
                .h(`zeroH), .y(bIn)); 
       // here is the one cla16 module needed for add/subtract
       cla16  addSum(.a(aInput), .b(bIn), .cin(cin), .sum(o_result));
endmodule   

module lc4_alu(input  wire [15:0] i_insn,
               input  wire [15:0]  i_pc,
               input  wire [15:0]  i_r1data,
               input  wire  [15:0]  i_r2data,
               output wire [15:0] o_result);   
       // add subtract
       wire [3:0] op = i_insn[15:12];
       wire [15:0]   multab, divab, modab, sextImm5, sextImm9, addout, 
                     arithmetic, Rs, firstInput, logicalOut, shiftOut, compare,
		     jsrVal, jmp, hiconstVal, trapVal; 
       wire [1:0]    selMultDivide;
       wire         immediateAdd = i_insn[5]; 
       wire          cin;
       wire [2:0]    cntrl = {i_insn[15], i_insn[13:12]};
       AddOutput  addRoutines(.imm11(i_insn[10:0]),.control(cntrl), .i_pc(i_pc), .i_r1data( i_r1data),
                  .i_r2data(i_r2data),  .sextImm5(sextImm5), .sextImm9(sextImm9), .o_result(addout));
       multDivideMod multdiv_mod(.i_r1data(i_r1data), .i_r2data(i_r2data), .multab(multab),
                      .divab(divab), .modab(modab));
       //  bits 4:3 work select add mult divide subtract except for immediate.
       //  In that case set to 00 so that addout selected.
       assign selMultDivide = i_insn[5]? 2'h0: i_insn[4:3];
       mux4to1_16bit selMultDivideAdd( .s(selMultDivide), .a(addout),
       		.b(multab), .c(addout),  .d(divab), .y(arithmetic));

       // handle the logical possibilities;
       logicalOps logOps (.immediateAnd(i_insn[5]), .i_r1data(i_r1data), .i_r2data(i_r2data),
                         .sext5(sextImm5), .o_result(logicalOut));
       // shift operators
       shiftOps   shiftOps1(.ins_imm(i_insn[5:0]), .i_r1data(i_r1data), .mod(modab), 
                                .o_result(shiftOut)); 
       // comparison operators
       compare      cmp1( .imm_ins(i_insn[8:0]), .a(i_r1data), .b(i_r2data), .result(compare));
       // jsr value
       jsr        jsr1(.imm_ins(i_insn[11:0]), .pc15(i_pc[15]), .i_r1data(i_r1data),
			.o_result(jsrVal));  
       // jmp/jmpr value
       wire selJump = i_insn[11];
       mux2to1_16bit jmpSel(.s(selJump), .a(i_r1data), .b(addout), .y(jmp));
       hiconst    hiV1(.uimm(i_insn[7:0]), .const(i_r1data[7:0]),
				.o_result(hiconstVal));
       trap      trap1(.immediatePC(i_insn[7:0]), .o_result(trapVal));
       selectInstruction sInstr(.s(op), .br(addout), .arth(arithmetic), .cmp(compare),
		.jsr(jsrVal), .log(logicalOut), .ldstr(addout), .rti(i_r1data),
		.const(sextImm9), .shift(shiftOut), .jmp(jmp),
		.hiconst(hiconstVal), .trap(trapVal),
		.o_result(o_result));

endmodule
