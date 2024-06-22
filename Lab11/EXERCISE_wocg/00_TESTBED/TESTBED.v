//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2024 ICLAB Spring Course
//   Lab11      : SNN
//   Author     : ZONG-RUI CAO
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   DESCRIPTION: 2024 Spring IC Lab / Exercise Lab11 / SNN
//   Release version : v1.0 (Release Date: May-2024)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps

// PATTERN
`include "PATTERN.v"

// DESIGN
`ifdef RTL
	`include "SNN_wocg.v"
`elsif GATE
	`include "SNN_SYN.v"
`endif


module TESTBED();
	wire clk, rst_n, in_valid;
	wire [7:0] img;
	wire [7:0] ker;
	wire [7:0] weight;
	wire out_valid;
	wire [9:0] out_data;	

initial begin
 	`ifdef RTL
    	`ifdef CG
        	$fsdbDumpfile("SNN_CG.fsdb");
    	`elsif NCG
    		$fsdbDumpfile("SNN.fsdb");
    	`endif
		$fsdbDumpvars(0,"+mda");
	`elsif GATE
		`ifdef CG
			$fsdbDumpfile("SNN_SYN_CG.fsdb");
		`elsif NCG
			$fsdbDumpfile("SNN_SYN.fsdb");
		`endif
		$fsdbDumpvars(0,"+mda");
		$sdf_annotate("SNN_SYN.sdf",I_SNN);      
	`endif
end

SNN I_SNN
(
	// Input signals
	.clk(clk),
	.rst_n(rst_n),
	.in_valid(in_valid),
	.img(img),
	.ker(ker),
	.weight(weight),

	// Output signals
	.out_valid(out_valid),
	.out_data(out_data)
);


PATTERN I_PATTERN
(
	// Output signals
	.clk(clk),
	.rst_n(rst_n),
	.in_valid(in_valid),
	.img(img),
	.ker(ker),
	.weight(weight),

	// Input signals
	.out_valid(out_valid),
	.out_data(out_data)
);

endmodule
