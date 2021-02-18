/* test_lc4_nzp
 *
 * Testbench for the lc4_nzp reducer
 */

`timescale 1ns / 1ps
`default_nettype none

`define EOF 32'hFFFF_FFFF
`define NEWLINE 10
`define NULL 0

`define REGISTER_INPUT "lc4_nzp.txt"
`define REGISTER_OUTPUT "lc4_nzp.output.txt"

module test_lc4_nzp;

`include "print_points.v"
   
   integer     input_file, output_file, errors, tests;


   // Inputs
   reg     [15:0]    cmp;
   // Outputs
   wire [2:0] nzp;
//instantiate UUT 
lc4_nzp   lc4_nzp(  .cmp(cmp),  
                    .nzp(nzp)); // neg, zero, pos true

  
   
   
   
   reg [2:0]  expectedValue;
   
   
   initial begin
      
      // Initialize Inputs
      errors = 0;
      tests = 0;
      output_file = 0;

      // open the test inputs
      input_file = $fopen(`REGISTER_INPUT, "r");
      $display("No Error opening file: ", `REGISTER_INPUT);
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
      //read the data and write the output file
      while (2 == $fscanf(input_file, "%d  %h", cmp, expectedValue )) begin
           
         #2 // write the hotwire value to file
         if (output_file) 
            $fdisplay(output_file, "%h %h %h", cmp, nzp, expectedValue);
         #8
         // $display("tests: ", tests);
         
         if (expectedValue != nzp) begin
            $display("Error hotwire test %2d: :  output expected: 0x%3h, \
	        	but was 0x%3h instead", 
	        	tests, expectedValue, nzp);
            errors = errors + 1;
         end
         tests = tests + 1;

         #2;         
      end // end while
      
      if (input_file) $fclose(input_file); 
      if (output_file) $fclose(output_file);
      $display("Simulation finished: %d test cases %d errors [%s]", tests, errors, `REGISTER_INPUT);
      printPoints(tests, tests - errors);
      $finish;
   end
   
endmodule
