//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2023 ICLAB Fall Course
//   Lab03      : BRIDGE
//   Author     : Tzu-Yun Huang
//	 Editor		: Ting-Yu Chang
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : pseudo_DRAM.v
//   Module Name : pseudo_DRAM
//   Release version : v3.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module pseudo_DRAM(
	clk, rst_n,
	AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY,
	AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP
);

input clk, rst_n;
// write address channel
input [31:0] AW_ADDR;
input AW_VALID;
output reg AW_READY;
// write data channel
input W_VALID;
input [63:0] W_DATA;
output reg W_READY;
// write response channel
output reg B_VALID;
output reg [1:0] B_RESP;
input B_READY;
// read address channel
input [31:0] AR_ADDR;
input AR_VALID;
output reg AR_READY;
// read data channel
output reg [63:0] R_DATA;
output reg R_VALID;
output reg [1:0] R_RESP;
input R_READY;

//================================================================
// parameters & integer
//================================================================

parameter DRAM_p_r = "../00_TESTBED/DRAM_init.dat";

//================================================================
// wire & registers 
//================================================================
reg [63:0] DRAM[0:8191];
initial begin
	$readmemh(DRAM_p_r, DRAM);
end
reg [31:0] DRAMaddr;
reg AW_VALID_d;
reg flag;
//////////////////////////////////////////////////////////////////////
// Write your own task here
//////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) 
begin
  if (AW_VALID) 
  begin
    DRAMaddr <= AW_ADDR;
  end
  else if (AR_VALID) 
  begin
	DRAMaddr <= AR_ADDR;
  end	
end
always @(posedge clk or negedge rst_n) 
begin
  if (AW_VALID & AW_VALID_d==0) 
    AW_READY <= 1;	
  else 
    AW_READY <= 0;
end
always @(posedge clk or negedge rst_n) begin
	AW_VALID_d <= AW_VALID;
end
always @(posedge clk or negedge rst_n) 
begin
  if (AW_READY) 
  begin
    W_READY <= 1;	
  end	
  else if (W_VALID)
  begin
    W_READY <= 0;	
  end
end
always @(posedge clk or negedge rst_n) 
begin
  if (W_VALID) 
  begin
    DRAM[DRAMaddr] <= W_DATA;
	flag <= 1;
  end	
  else if(B_READY & flag)
    flag <= 0;
end
always @(posedge clk or negedge rst_n)
begin
  if (B_READY & flag) 
  begin
	B_RESP <= 0;
	B_VALID <= 1;
  end
  else begin
	B_VALID <= 0;
	B_RESP <= 0;
  end
end
//////////////////////////////////////////////////////////////////////

task YOU_FAIL_task; begin
    $display("*                              FAIL!                                    *");
    $display("*                 Error message from pseudo_SD.v                        *");
end endtask

endmodule
