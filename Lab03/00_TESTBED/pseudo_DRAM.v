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
///////////////////////////
//	 write
//////////////////////////
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
///////////////////////////
//	 read
//////////////////////////
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
parameter SEED = 1250;
parameter CYCLE = 40;


//================================================================
// TEST REG
//================================================================

reg [12:0] temp;
reg [63:0] read_dram_test_data;
reg AR_READY_d;
reg [9:0]cnt;





//================================================================
// wire & registers 
//================================================================
reg [63:0] DRAM[0:8191];
initial begin
	$readmemh(DRAM_p_r, DRAM);
end

//////////////////////////////////////////////////////////////////////
// Write your own task here
//////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		AR_READY <= 0;
		cnt <= 0;
	end
	// cnt <= cnt + 1;
	if (AR_VALID == 1) begin
		// AR_READY <= 1;
		cnt <= cnt + 1;
	end
	if (cnt == 1)begin 
		AR_READY <= 1;
	end
	if (cnt == 2) begin
		AR_READY <= 0;
		cnt <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (AR_READY == 1 || R_READY == 1) begin
		temp <= AR_ADDR;
	end
	if (R_READY == 1) begin
		temp <= temp;
	end
end

///////////////////////////////////////////////////////////////.
// R_VALID
///////////////////////////////////////////////////////////////////
reg [9:0] cnt_r;
always @(*) begin
	if (!rst_n) begin
		R_VALID = 0;
		cnt_r = 0;
	end
	else if (R_READY == 1 & cnt_r == 0)begin 
		R_VALID = 1;
		#(CYCLE*100);
		R_VALID =0;
		cnt_r <= 1; 
	end
	else if (cnt_r == 1) begin
		// R_VALID <= 0;
		cnt_r = 0;
	end
end

always @(*) begin
	if (R_VALID == 1) begin
		R_DATA = DRAM[temp];
	end
	else begin
		R_DATA = 0;
	end
end
////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////
//////////////////////////////                                WRITE
/////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
reg [9:0] cnt_aw;
always @(posedge clk or negedge rst_n ) begin
	if (!rst_n) begin
		AW_READY <= 0;
		cnt_aw <= 0;
	end
	else if (AW_VALID ==1 && cnt_aw == 0) begin
		cnt_aw <= cnt_aw + 1;
		AW_READY <= 1;
	end
	else begin//if (cnt_aw == 1) begin
		AW_READY <= 0;
		cnt_aw <= 0;
	end
end

reg [9:0] cnt_b;
reg [9:0] cnt_w;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		W_READY = 0;
		// cnt_w <= 0;
	end
	else if(AW_READY == 1 /*&& AW_VALID == 0 && cnt_b == 0*/) begin
		W_READY <= 1;
	end
	else if (B_READY == 0) begin
		W_READY <= 0;
	end	
end

reg [31:0] temp_AW_ADDR;
always @(posedge clk or negedge rst_n ) begin
	if (AW_READY == 1) begin
		temp_AW_ADDR <= AW_ADDR;
	end
	else temp_AW_ADDR <= temp_AW_ADDR;
end

always @(*) begin
	if (W_VALID == 1) begin
		DRAM[temp_AW_ADDR] = W_DATA;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		B_RESP <= 0;
	end
	else B_RESP <= 0;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		R_RESP <= 0;
	end
	else R_RESP <= 0;
end

// reg [9:0] cnt_b;
always @(posedge clk or negedge rst_n ) begin
	if (!rst_n) begin
		B_VALID <= 0;
		cnt_b <= 0;
	end
	else if (W_VALID == 1 & B_READY == 1 & cnt_b == 0) begin
		cnt_b <= cnt_b + 1;
		B_VALID <= 1;
	end
	// else if (cnt_b == 1)begin 
	// 	B_VALID <= 1;
	// end
	else if (cnt_b == 1) begin
		B_VALID <= 0;
		cnt_b <= 0;
	end
end

// reg [9:0] cnt_b;
// always @(posedge clk or negedge rst_n ) begin
// 	if (!rst_n) begin
// 		B_VALID <= 0;
// 		cnt_b <= 0;
// 	end
// 	else if (W_VALID == 1 & B_READY == 1 & cnt_b == 0) begin

// 		B_VALID <= 1;
// 		#(CYCLE*100);
// 		B_VALID <= 0;
// 		cnt_b <= 1;
// 	end
// 	// else if (cnt_b == 1)begin 
// 	// 	B_VALID <= 1;
// 	// end
// 	else if (cnt_b == 1) begin
// 		// B_VALID <= 0;
// 		cnt_b <= 0;
// 	end
// end
//////////////////////////////////////////////////////////////////////

task YOU_FAIL_task; begin
    $display("*                              FAIL!                                    *");
    $display("*                 Error message from pseudo_SD.v                        *");
end endtask

endmodule
