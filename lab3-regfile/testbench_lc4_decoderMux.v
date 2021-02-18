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
`define sTestFile  4  // log of the number of choices, l, l =4, this is 2
`define  OneOrGreater
`define  TwoOrGreater
`define  ThreeOrGreater
`define nTestFile   16   // the width of the datafield in bits

module test_regfile;

`include "print_points.v"
   
   integer     input_file, output_file, errors, tests, i;


   // Inputs
   reg         clk;
   parameter    s = `sTestFile;
   parameter    n = `nTestFile;
   reg [s-1:0]   sel;
   localparam   l = 2**s;
   localparam   k = l*n;
   integer   s1, n1;//s1, n1 is to confirm that s, n were set correctly for
	            // this trial
   reg  [n*l-1:0] datain;  //[n*l-1:0]
//instantiate UUT and define variables for the merge tests
       wire [n-1:0]    dataIn0;
       assign dataIn0 = datain[n-1:0];
`ifdef OneOrGreater
       wire [n-1:0]    dataIn1;
       wire [2*n -1:0] merge2Out;
       assign dataIn1 = datain[2*n-1:n];
       merge2  Merge2 (.a(dataIn0), .b(dataIn1), .out(merge2Out));
       defparam   Merge2.n = n;
`endif
`ifdef TwoOrGreater
       wire [n-1:0]    dataIn2, dataIn3;
       wire [4*n -1:0] merge4Out;
       assign dataIn2 = datain[3*n -1: 2 * n];
       assign dataIn3 = datain[4* n-1:3* n];
       merge4  Merge4 (.a(dataIn0), .b(dataIn1), .c(dataIn2), .d(dataIn3),
			.out(merge4Out));
       defparam  Merge4.n = n;
`endif
`ifdef ThreeOrGreater
       wire [n-1:0]    dataIn4, dataIn5, dataIn6, dataIn7;
       wire [8*n -1:0] merge8Out;
       assign dataIn4 = datain[5 * n - 1: 4 * n];
       assign dataIn5 = datain[6 * n - 1: 5 * n];
       assign dataIn6 = datain[7 * n - 1: 6 * n];
       assign dataIn7 = datain[8 * n - 1: 7 * n];
       merge8  Merge8 (.a(dataIn0), .b(dataIn1), .c(dataIn2), .d(dataIn3), 
		   .e(dataIn4), .f(dataIn5), .g(dataIn6), .h(dataIn7),
			.out(merge8Out));
       defparam Merge8.n = n;
`endif


   // Outputs
   wire [l-1:0] hotwire;
   wire [n-1:0] dataOutHW, dataOut;
  
   
   // Instantiate the Units Under Test (UUT)
   
   decoder decode ( .sel(sel), .hotwire(hotwire));
   defparam   decode.s = s;
   mux_hotwire   mux_hw(.hotwire(hotwire), .in(datain), .out(dataOutHW));
   defparam     mux_hw.s = s;
   defparam  	mux_hw.n = n;
   multiplex    multi(.sel(sel), .in(datain), .out(dataOut));
   defparam     multi.s = s;
   defparam     multi.n = n; 
  
   
   
   reg [l-1:0]  hotwireExpected;
   reg [n-1:0]  expectedValue;
   
   always #5 clk <= ~clk;
   
   initial begin
      
      // Initialize Inputs
      clk = 0;
      sel = 0; 
      errors = 0;
      tests = 0;
      output_file = 0;
      s1 = 0;
      n1 = 0;

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
      // read the first line to get s
      if (2 == $fscanf(input_file, "%h %h", s1, n1))  begin
      		$display("inputs:  %h %h", s1, n1);
        	if (output_file) 
            		$fdisplay(output_file, "%h  %h", s1, n1);
                if ((s1 != s) || (n1 != n)) begin
        	   $display("parameters do not match");
                   $finish;
                end 
      end
      #2;         
      //read the data and write the output file
      while (2 == $fscanf(input_file, "%h  %h", sel, hotwireExpected)) begin
           
         #2 // write the hotwire value to file
         if (output_file) 
            $fwrite(output_file, "%h %h", sel, hotwire);
	 //if (1 == $fscanf(input_file, "%1h", datain))
         //     if (output_file)
         //       $write(output_file, "%1h", datain);
         //else begin
         //       $fdisplay("Read data Error");
         //       $finish;
         //     end

         for (i = 0; i <l; i = i+ 1) begin
             if( 1 == $fscanf(input_file, "%h", datain[i*n +: n])) begin
                  if (output_file)    
	              $fwrite(output_file," %h",datain[i*n +:n]);
             end
             else begin
                    $fdisplay("Read data Error");
                    $finish;
                  end
   
         end
    
         if (1 != $fscanf(input_file, "%h", expectedValue)) begin
		$display("No expected value found");
                $finish;
         end 
         #8
         if (output_file) 
		$fdisplay(output_file," %h %h %h", expectedValue, 
						dataOutHW,  dataOut);
         // $display("tests: ", tests);
         
         if (hotwire != hotwireExpected) begin
            $display("Error hotwire test %2d: sel: 0x%3h output expected: 0x%3h, \
	        	but was 0x%3h instead", 
	        	tests, sel, hotwireExpected, hotwire);
            errors = errors + 1;
         end
         tests = tests +3 ;
`ifdef  OneOrGreater
         if (merge2Out != datain[2*n-1:0]) begin
            $display("Error at merge test %d:\nout expected: %h\nout found  : %h instead", 
			tests, datain, merge2Out);
            errors = errors + 1;
         end;
`endif
`ifdef  TwoOrGreater
         if (merge4Out != datain[4*n -1:0]) begin
            $display("Error at merge test %d:\nout expected: %h\nout found  : %h instead", 
			tests, datain, merge4Out);
            errors = errors + 1;
         end;
`endif
`ifdef ThreeOrGreater
         if (merge8Out != datain[8*n -1:0]) begin
            $display("Error at merge test %d:\nout expected: %h\nout found  : %h instead", 
			tests, datain, merge8Out);
            errors = errors + 1;
         end;
`endif
         if      (s >= 3) tests = tests + 3;
         else if (s >= 2) tests = tests + 2;
         else if (s >= 1) tests = tests + 1;

         #2;         
         $display("test %d; sel: %h; datain: %h; dataOutHW: %h; expectedValue %h", 
         			tests, sel, datain, dataOutHW, expectedValue);
         
         if ( dataOutHW != expectedValue) begin
            $display("Error mux_HW  test %d: hotwire: %h output expected: \
                       %h, but was %h instead.", 
	        	tests, hotwire, expectedValue, dataOutHW);
            errors = errors + 1;
         end
         if ( dataOut != expectedValue) begin
            $display("Error multiplex  test %d: sel: %h output expected: %h \
                      but was %8h instead.", 
	        	tests, sel, expectedValue, dataOut);
            errors = errors + 1;
         end
      end // end while
      
      if (input_file) $fclose(input_file); 
      if (output_file) $fclose(output_file);
      $display("Simulation finished: %d test cases %d errors [%s]", tests, errors, `REGISTER_INPUT);
      printPoints(tests, tests - errors);
      $finish;
   end
   
endmodule
