/* Anton Khabbaz
 *
 * lc4_single.v
 * Implements a single-cycle data path
 *
 */

`timescale 1ns / 1ps

// disable implicit wire declaration
`default_nettype none

`define zero16  16'h0
`define one1     1'b1
`define DataWidth 16
`define cntrlWidth 1
`define NZPWidth   3
`define selTwo     1  // width s**SelTwo allows 2 choices
`define selFour    2  // s**selFour is 4
`define selEight   3  // s**selEight is 8

/* lc4_branch decides whether the branch should be taken.  It considers the nzp
 * bits and the instruction bits. */
module lc4_branch( input wire [2:0] insnbr,   // instruction bits
		   input wire [2:0]  nzp,     // input from nzp register
		     output wire takeBranch); // true if branch should be taken
   wire [3:0] insnbr4, nzp4;
   assign insnbr4 = { 1'b0, insnbr};
   assign nzp4    = { 1'b0, nzp};
   mux_hotwire  #(.s(`selFour), .n(`cntrlWidth)) mhw(.hotwire(insnbr4), 
			.in(nzp4), .out(takeBranch));
endmodule 
/* lc4_nzp reduces the 16 bits alu output to three bits negative true, zero true
 * or positive true.  Here we take all the bits and treat it as a signed number.
 * This way if another operation that writes to the register file is used for
 * the comparison, the nzp register will still be correct. */
module lc4_nzp( input wire [15:0] cmp,  // the compare signal output of ALU
                 output wire [2:0] nzp); // neg, zero, pos true

    assign nzp[2] = cmp[15]; // negative
    assign nzp[1] = ~|cmp[15:0];  // zero
    assign nzp[0] = ~cmp[15] & (|cmp[14:0]);// positive
endmodule

// Here you output the current pc and memory retrieves thi i_cur_insn;  You
// output o_dmem_addr and you get back i_cur_dmem_data

module lc4_processor
   (input  wire        clk,                // Main clock
    input  wire        rst,                // Global reset
    input  wire        gwe,                // Global we for single-step clock
   
    output wire [15:0] o_cur_pc,           // Address to read from instruction memory
    input  wire [15:0] i_cur_insn,         // Output of instruction memory
    output wire [15:0] o_dmem_addr,        // Address to read/write from/to data memory; SET TO 0x0000 FOR NON LOAD/STORE INSNS
    input  wire [15:0] i_cur_dmem_data,    // Output of data memory
    output wire        o_dmem_we,          // Data memory write enable
    output wire [15:0] o_dmem_towrite,     // Value to write to data memory

    // Testbench signals are used by the testbench to verify the correctness of your datapath.
    // Many of these signals simply export internal processor state for verification (such as the PC).
    // Some signals are duplicate output signals for clarity of purpose.
    //
    // Don't forget to include these in your schematic!

    output wire [1:0]  test_stall,         // Testbench: is this a stall cycle? (don't compare the test values)
    output wire [15:0] test_cur_pc,        // Testbench: program counter
    output wire [15:0] test_cur_insn,      // Testbench: instruction bits
    output wire        test_regfile_we,    // Testbench: register file write enable
    output wire [2:0]  test_regfile_wsel,  // Testbench: which register to write in the register file 
    output wire [15:0] test_regfile_data,  // Testbench: value to write into the register file
    output wire        test_nzp_we,        // Testbench: NZP condition codes write enable
    output wire [2:0]  test_nzp_new_bits,  // Testbench: value to write to NZP bits
    output wire        test_dmem_we,       // Testbench: data memory write enable
    output wire [15:0] test_dmem_addr,     // Testbench: address to read/write memory
    output wire [15:0] test_dmem_data,     // Testbench: value read/writen from/to memory
    output wire [15:0] test_alu_out,      // Testbench: lc4_output
    input  wire [7:0]  switch_data,        // Current settings of the Zedboard switches
    output wire [7:0]  led_data            // Which Zedboard LEDs should be turned on?
    );

   // By default, assign LEDs to display switch inputs to avoid warnings about
   // disconnected ports. Feel free to use this for debugging input/output if
   // you desire.
   assign led_data = switch_data;

   
   /* DO NOT MODIFY THIS CODE */
   // Always execute one instruction each cycle (test_stall will get used in your pipelined processor)
   assign test_stall = 2'b0; 
   assign test_cur_insn = i_cur_insn;
   // pc wires attached to the PC register's ports
   wire [15:0]   pc;      //  34 Current program counter (read out from pc_reg)
   wire [15:0]   next_pc; //  44 Next program counter (you compute this and feed it into next_pc)

   // Program counter register, starts at 8200h at bootup
   Nbit_reg #(`DataWidth, 16'h8200) pc_reg (.in(next_pc), .out(pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   /* END DO NOT MODIFY THIS CODE */

   /*******************************
    * MY CODE                     *
    *******************************/
   wire                      loadCntrl;        // 20  is_load
   wire                      storeCntrl;       // 21  is_store
   wire                      branchCntrl;      // 22  is_branch
   wire                      insnCntrl;        // 23  is_control_insn
   wire                      branchAsserted;   // 24  output of lc4 branch
   wire                      pcMuxSel;         // 25  outut of or2 to PCMux
   wire [`NZPWidth - 1:0]    NZPCurrBits;      // 26  nzp register output
   wire	                     branchTrue;       // 27  and out to or2 in
   wire [`selEight - 1:0]    r1SelAddr;        // 28  to i_rs regfile
   wire [`selEight - 1:0]    r2SelAddr;        // 29   to i_rt regfile
   wire [`selEight - 1:0]    regWriteSel;      // 30 to i_rd regfile
   wire                      regWriteEn;       // 31 to i_rd we regfile
   wire                      nzpWriteEn;       // 32  nzp_we to nzp register
   wire                      pcPlusOneWrite;   // 33 select_pc_plus_one (write to register)
   wire [`DataWidth - 1:0]   PCPlusOneData;    // 35 claPC  sum to PCMux, Register_Mux 
   wire [`DataWidth - 1:0]   regfileWriteData; // 36 register Mux to regfile
   wire [`DataWidth - 1:0]   o_rs_data;        // 37 output of lc4_regfile RS output
   wire [`DataWidth - 1:0]   o_rt_data;        // 38 output of lc4_regfile Rt output
   wire                      memAddrSel;       // 39  control for address Mux
   wire [`DataWidth - 1:0]   lc4AluOut;        // 40 lc4_alu o_result to pc_Mux, addr mux,
	                      		       //    regMux 
   wire [`NZPWidth - 1:0]    NZP_new_bits;     // 41 nzp_reducer nzp to NZP_register in
   wire [2*`cntrlWidth- 1:0] RegMuxSel;        // 42 merge, out to register_mux sel control;
   wire [2*`cntrlWidth- 1:0] DataMuxSel;       // 43 merge, out to Data_mux sel
   wire [2*`DataWidth - 1:0] pcMuxIn;          // 45 Merge2 of PCMux in
   wire [4*`DataWidth - 1:0] dataMuxIn;        // 46 merge , out to Data_mux in data in;
   wire [2*`DataWidth - 1:0] addressMuxIn;     // 47 merge2, out to address_Mux data in; 
   wire [4*`DataWidth - 1:0] registerMuxIn;    // 48 merge4 , out to register_mux in data in;
   // set test_cur_pc
   assign test_cur_pc = pc;
   assign    o_cur_pc = pc;
   // instantiate the decoder
   lc4_decoder lc4Decode(.insn(i_cur_insn), .r1sel(r1SelAddr), .r1re(),
			.r2sel(r2SelAddr), .r2re(), .wsel(regWriteSel),
			.regfile_we(regWriteEn), .nzp_we(nzpWriteEn), 
			.select_pc_plus_one(pcPlusOneWrite),
			.is_load(loadCntrl), .is_store(storeCntrl),
			.is_branch(branchCntrl), .is_control_insn(insnCntrl));
   assign test_regfile_wsel = regWriteSel;
   assign test_regfile_we = regWriteEn;
   assign test_nzp_we     = nzpWriteEn;
   assign test_dmem_we = storeCntrl;
   assign o_dmem_we = storeCntrl;
   // Memory address sel
   assign memAddrSel = storeCntrl | loadCntrl;
   // decide if the branch condition is true
   lc4_branch   lc4Branch(.insnbr(i_cur_insn[11:9]), .nzp(NZPCurrBits),
				.takeBranch(branchAsserted));
   // regfile set up
   lc4_regfile #(.s(`selEight), .n(`DataWidth)) lc4Regfile(.clk(clk), 
			.gwe(gwe), .rst(rst), 
		.i_rs(r1SelAddr), .o_rs_data(o_rs_data), 
		.i_rt(r2SelAddr), .o_rt_data(o_rt_data),
		.i_rd(regWriteSel), .i_wdata(regfileWriteData), 
		.i_rd_we(regWriteEn));
   assign o_dmem_towrite = o_rt_data;
 
   //25 pcMuxSel Logic to decide next_pc
   assign branchTrue = branchCntrl & branchAsserted;
   assign pcMuxSel   = insnCntrl | branchTrue;

   // get PC + 1
   cla16  claPC(.a(pc), .b(`zero16), .cin(`one1),.sum(PCPlusOneData));
   // pc_Mux Select
   merge2 #(.n(`DataWidth)) pcMuxInMerge(.a(PCPlusOneData), .b(lc4AluOut), .out(pcMuxIn)); 
   multiplex #(.s(`selTwo), .n(`DataWidth))  PC_Mux(.sel(pcMuxSel), .in(pcMuxIn), .out(next_pc));
   //LC4_ALU
   lc4_alu  LC4_ALU(.i_insn(i_cur_insn), .i_pc(pc), 
		     .i_r1data(o_rs_data), .i_r2data(o_rt_data),
		      .o_result(lc4AluOut));
   assign test_alu_out = lc4AluOut;
   // data_Mux to select test_dmem_data
   merge2 #(.n(`cntrlWidth))  dataMuxSelMerge(.a( storeCntrl), 
			.b(loadCntrl), .out(DataMuxSel));
   merge4 #(.n(`DataWidth)) dataMuxdataMerge(.a(`zero16), .b(o_rt_data), 
				.c(i_cur_dmem_data), .d(`zero16),
				.out(dataMuxIn));
   multiplex #(.s(`selFour), .n(`DataWidth)) Data_mux(.sel(DataMuxSel), 
                                              .in(dataMuxIn),
                                              .out(test_dmem_data));
   //address Mux to select address
   merge2  #(.n(`DataWidth)) addressMuxMerge(.a(`zero16), .b(lc4AluOut),
				.out(addressMuxIn));
   multiplex #(.s(`cntrlWidth), .n(`DataWidth)) Address_Mux(.sel(memAddrSel), 
				.in(addressMuxIn), .out(o_dmem_addr));
   assign test_dmem_addr = o_dmem_addr;
   // register Mux
   merge2 #(.n(`cntrlWidth)) regMuxSel(.a(pcPlusOneWrite), .b(loadCntrl),
					.out(RegMuxSel));
   merge4 #(.n(`DataWidth))  regMuxIn(.a(lc4AluOut), .b(PCPlusOneData),
				      .c(i_cur_dmem_data), .d(`zero16),
                                      .out(registerMuxIn));
   multiplex #(.s(`selFour), .n(`DataWidth)) Register_Mux( .sel(RegMuxSel), 
                                             .in(registerMuxIn), 
					     .out(regfileWriteData));
   assign test_regfile_data = regfileWriteData;
   // nzp reducer
   lc4_nzp nzp_reducer(.cmp(lc4AluOut), .nzp(NZP_new_bits));
   assign test_nzp_new_bits = NZP_new_bits;
   // NZP register
   Nbit_reg #( .n(`NZPWidth) , .r(0) ) NZP_register (.in(NZP_new_bits), 
     .out(NZPCurrBits), .clk(clk), .we(nzpWriteEn), .gwe(gwe), .rst(rst));
   /* Add $display(...) calls in the always block below to
    * print out debug information at the end of every cycle.
    *
    * You may also use if statements inside the always block
    * to conditionally print out information.
    *
    * You do not need to resynthesize and re-implement if this is all you change;
    * just restart the simulation.
    * 
    * To disable the entire block add the statement
    * `define NDEBUG
    * to the top of your file.  We also define this symbol
    * when we run the grading scripts.
    */
`ifndef NDEBUG
   always @(posedge gwe) begin
       
        //$display("%d  %h %h %h ", $time, pc, lc4AluOut, NZP_new_bits);
      // $display("%d %h %h %h %h %h", $time, f_pc, d_pc, e_pc, m_pc, test_cur_pc);
      // if (o_dmem_we)
      //   $display("%d STORE %h <= %h", $time, o_dmem_addr, o_dmem_towrite);

      // Start each $display() format string with a %d argument for time
      // it will make the output easier to read.  Use %b, %h, and %d
      // for binary, hex, and decimal output of additional variables.
      // You do not need to add a \n at the end of your format string.
      // $display("%d ...", $time);

      // Try adding a $display() call that prints out the PCs of
      // each pipeline stage in hex.  Then you can easily look up the
      // instructions in the .asm files in test_data.

      // basic if syntax:
      // if (cond) begin
      //    ...;
      //    ...;
      // end

      // Set a breakpoint on the empty $display() below
      // to step through your pipeline cycle-by-cycle.
      // You'll need to rewind the simulation to start
      // stepping from the beginning.

      // You can also simulate for XXX ns, then set the
      // breakpoint to start stepping midway through the
      // testbench.  Use the $time printouts you added above (!)
      // to figure out when your problem instruction first
      // enters the fetch stage.  Rewind your simulation,
      // run it for that many nano-seconds, then set
      // the breakpoint.

      // In the objects view, you can change the values to
      // hexadecimal by selecting all signals (Ctrl-A),
      // then right-click, and select Radix->Hexadecial.

      // To see the values of wires within a module, select
      // the module in the hierarchy in the "Scopes" pane.
      // The Objects pane will update to display the wires
      // in that module.

      // $display();
   end
`endif
endmodule
