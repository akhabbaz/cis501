/* test_lc4_decoderMux
 *
 * Testbench for the decoder Mux file
 */

`timescale 1ns / 1ps
`default_nettype none

`define EOF 32'hFFFF_FFFF
`define NEWLINE 10
`define NULL 0

`define REGISTER_INPUT "decoder.txt"
`define REGISTER_OUTPUT "decoderMux_test.output.txt"

module test_regfile;

`include "print_points.v"
   
   integer     input_file, output_file, errors, tests;


   // Inputs
   reg         clk;
   parameter    s = 2;
   localparam   l = 2**s;
   reg [2:0]   sel;
   
   // Outputs
   wire [l-1:0] hotwire;
   
   // Instantiate the Unit Under Test (UUT)
   
  decoder decode ( .sel(sel), .hotwire(hotwire));
  defparam   decode.s = s;
   
   reg [l-1:0]  expectedValue1;
   
   always #5 clk <= ~clk;
   
   initial begin
      
      // Initialize Inputs
      clk = 0;
      sel = 0; 
      errors = 0;
      tests = 0;
      output_file = 0;

      // open the test inputs
      input_file = $fopen(`REGISTER_INPUT, "r");
      if (input_file == `NULL) begin
         $display("Error opening file: ", `REGISTER_INPUT);
         $finish;
      end

      // open the output file
`ifdef REGISTER_OUTPUT
      output_file = $fopen(`REGISTER_OUTPUT, "w");
      if (output_file == `NULL) begin
         $display("Error opening file: ", `REGISTER_OUTPUT);
         $finish;
      end
`endif
      
      // Wait for global reset to finish
      #100;
      
      
      #2;         

      while (2 == $fscanf(input_file, "%d %d", sel, expectedValue1)) begin
         
         #8;
         
         tests = tests + 2;
         
         // $display("tests: ", tests);
         
         if (output_file) begin
            $fdisplay(output_file, "%d %d", sel, hotwire);
         end

         if (hotwire !== expectedValue1) begin
            $display("Error at test %d: input %d output expected: %h, but was %h instead", tests, sel, expectedValue1, hotwire);
            errors = errors + 1;
         end
         
         
         #2;         
         
      end // end while
      
      if (input_file) $fclose(input_file); 
      if (output_file) $fclose(output_file);
      $display("Simulation finished: %d test cases %d errors [%s]", tests, errors, `REGISTER_INPUT);
      printPoints(tests, tests - errors);
      $finish;
   end
   
endmodule
