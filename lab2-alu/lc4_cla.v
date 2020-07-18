/* TODO: Anton Khabbaz akhabbaz */
/**/
//`include "lc4_cla.h"

`timescale 1ns / 1ps
 /* @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals 
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits collectively generate a carry (ignoring cin)
 * @param pout whether these 4 bits collectively would propagate an incoming carry (ignoring cin)
 * @param cout the carry outs for the low-order 3 bits
 */  
// this one works
//module gp4(input wire [3:0] gin, pin,
//           input wire cin,
//           output wire gout, pout,
//           output wire [2:0] cout);
//   assign cout[0] = gin[0] | pin[0] & cin;
//   assign cout[1] = gin[1] | pin[1] & gin[0] 
//                    | (& pin[1:0] ) & cin;
//   assign cout[2] = gin[2] | pin[2] &  gin[1] 
//   		    | (& pin[2:1])  & gin[0] 
//		    | (& pin[2:0])  & cin;
//   assign gout    = gin[3] | pin[3] & gin[2]  
//                    | ( &pin[3:2] ) & gin[1] 
//		    | ( &pin[3:1] ) & gin[0];
//   assign pout   = & pin[3:0];
//endmodule
/*   mergegp  merges the gp values of 2 sequential gps where ga, pa is a less
 *   significant bit that gb, pb.  Output is gout, pout) */
module mergegp(input wire ga, pa, gb, pb, output wire gout, pout);
    assign gout = gb | pb & ga;
    assign pout = pa & pb;
endmodule
/*  cfromGP computes cout from gp and cin. */  
module c_gp(input wire g, p, cin, output wire cout);
    assign cout  = g | p & cin;
endmodule
module gp4(input wire [3:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [2:0] cout);

   wire  [3:0] g, p;
   assign g[0] = gin[0];
   assign p[0] = pin[0];
   genvar i;
   generate
   	for (i = 0; i < 3; i = i + 1) begin
   	     mergegp gp(.ga(g[i]), .pa(p[i]) ,.gb(gin[i+1]) , 
			.pb(pin[i+1]), .gout(g[i+1]), .pout(p[i+1]));
   	end
   endgenerate
   //integer k;
   //reg [2:0] cout;   
   //always @(g or p or cin)
   //begin :block1
   //for (k =0; k < 2; k = k+ 1) begin 
   //        cout[k] = g[k] | p[k] & cin;
   //end
   //end
   assign cout[0] = g[0] | p[0] & cin;
   assign cout[1] = g[1] | p[1] & cin;
   assign cout[2] = g[2] | p[2] & cin; 
   assign gout = g[3];
   assign pout = p[3];
endmodule
//module gp4(input wire [3:0] gin, pin,
//           input wire cin,
//           output wire gout, pout,
//           output wire [2:0] cout);
//   // these are the generate and propogate signals for c(i,0)
//   wire g[3:0], p[3,0];
//   assign p[0] = pin[0];
//   assign g[0] = gin[0];
//   genvar i;
//   for (i= 1, i < 4; i= i + 1) begin
//	   assign  p[i] = (pin[i] &  p[i-1]);
//	   assign  g[i] = gin[i] |  pin[i] & g[i-1];
//   end
//   assign pout = p[3];
//   assign gout = g[3];
//   genvar k;
//   for (k = 0; k < 3; k = k + 1) begin
//	   assign cout[k] = g[k] | (p[k] & cin);
//   end
//endmodule

/**
 * 16-bit Carry-Lookahead Adder
 * @param a first input
 * @param b second input
 * @param cin carry in
 * @param sum sum of a + b + carry-in
 */
module cla16
  (input wire [15:0]  a, b,
   input wire         cin,
   output wire [15:0] sum);
   // size of gp4
   parameter N = 4;
   // gin and pin loaded
   wire [15:0] gin, pin, ca_in;
   // the carries
   assign ca_in[0] = cin;
   // generate, propogate 4 wires at a time
   // gin3[0] is g(3,0) gin3[1] is g(7, 4)
   genvar i;
   generate
   	for (i=0; i < 16; i = i + 1) begin
	   	gp1   gp(.a(a[i]), .b(b[i]), .g(gin[i]), .p(pin[i]));
   	end
   endgenerate
   wire [N:0] gint, pint;
   genvar k;
   generate
   	for (k = 0; k < N; k = k + 1) begin
   		gp4  m(.gin(gin[N*k + 3:N*k]), .pin(pin[N*k + 3:N*k]), 
		  .cin(ca_in[N*k]), .gout(gint[k]), .pout(pint[k]), 
		  .cout(ca_in[N*k + 3:N*k + 1]));
   	end
   endgenerate
  // wire [15:0] ctemp;   
   // use gint, pint to generate ca_in[12, 8, 4].
   //wire [2:0] coutI;
   gp4  m03(.gin(gint[3:0]), .pin(pint[3:0]), .cin(ca_in[0]), 
                   .gout(gint[N]), .pout(pint[N]), 
        	   .cout({ca_in[3*N], ca_in[2*N], ca_in[1*N]}));
        	    //.cout(coutI));
   
   // sum is xor of gin, pin, ca_in (or ca_in, a, b)
  // assign ctemp = {2'b0, coutI,  gint, pint};
   //assign ctemp = {12'b0,  pint[3:0]};
   //assign   sum = ctemp; 
   assign   sum = gin ^ pin ^ ca_in; 
endmodule
/** Lab 2 Extra Credit, see details at
  https://github.com/upenn-acg/cis501/blob/master/lab2-alu/lab2-cla.md#extra-credit
 If you are not doing the extra credit, you should leave this module empty.
 */
module gpn
  #(parameter N = 4)
  (input wire [N-1:0] gin, pin,
   input wire  cin,
   output wire gout, pout,
   output wire [N-2:0] cout);
 
   wire  [N-1:0] g, p;
   assign g[0] = gin[0];
   assign p[0] = pin[0];
   genvar i;
   generate
   	for (i = 0; i < N-1; i = i + 1) begin
   	     mergegp gp(.ga(g[i]), .pa(p[i]) ,.gb(gin[i+1]) , 
			.pb(pin[i+1]), .gout(g[i+1]), .pout(p[i+1]));
            c_gp    ccomp( .g(g[i]), .p(p[i]), .cin(cin), .cout(cout[i])); 
   	end
   endgenerate
   //integer k;
   //reg [2:0] cout;   
   //always @(g or p or cin)
   //begin :block1
   //for (k =0; k < 2; k = k+ 1) begin 
   //        cout[k] = g[k] | p[k] & cin;
   //end
   //end
   assign gout = g[N-1];
   assign pout = p[N-1];
endmodule


//cla64 is like cla16 but it is 64 bits and uses gpn 8 it is a full 64 bit adder
module cla64
  (input wire [63:0]  a, b,
   input wire         cin,
   output wire [63:0] sum);
   // size of gp4
   parameter N = 8;
   // gin and pin loaded
   wire [63:0] gin, pin, ca_in;
   // the carries
   assign ca_in[0] = cin;
   // generate, propogate 4 wires at a time
   // gin3[0] is g(3,0) gin3[1] is g(7, 4)
   genvar i;
   generate
   	for (i=0; i < 64; i = i + 1) begin
	   	gp1   gp(.a(a[i]), .b(b[i]), .g(gin[i]), .p(pin[i]));
   	end
   endgenerate
   wire [N:0] gint, pint;
   genvar k;
   // two ways to instantiate parameters shown here
   generate
   	for (k = 0; k < N; k = k + 1) begin
   		gpn #(N)  m(.gin(gin[N*k + 7:N*k]), .pin(pin[N*k + 7:N*k]), 
		  .cin(ca_in[N*k]), .gout(gint[k]), .pout(pint[k]), 
		  .cout(ca_in[N*k + 7:N*k + 1]));
   	end
   endgenerate
  // wire [63:0] ctemp;   
   // use gint, pint to generate ca_in[12, 8, 4].
   //wire [2:0] coutI;
   gpn   m07(.gin(gint[7:0]), .pin(pint[7:0]), .cin(ca_in[0]), 
                   .gout(gint[N]), .pout(pint[N]), 
        	   .cout({ca_in[7*N], ca_in[6*N], ca_in[5*N], 
                       ca_in[4*N], ca_in[3*N], ca_in[2*N], 
                       ca_in[1*N]}));
   defparam m07.N = N;
   // sum is xor of gin, pin, ca_in (or ca_in, a, b)
  // assign ctemp = {2'b0, coutI,  gint, pint};
   //assign ctemp = {12'b0,  pint[3:0]};
   //assign   sum = ctemp; 
   assign   sum = gin ^ pin ^ ca_in; 
endmodule
/* cla16Sub subtracts b from a, a - b,  using cla16. 
*/
module cla16Sub
  (input wire [15:0]  a, b,
   output wire [15:0] d);
   cla16  thisM(.a(a[15:0]), .b(~b[15:0]), .cin(1'b1), .sum(d[15:0]));
endmodule  
