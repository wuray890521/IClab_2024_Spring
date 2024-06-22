`ifdef RTL
    `define CYCLE_TIME 40.0
`endif
`ifdef GATE
    `define CYCLE_TIME 40.0
`endif

`include "../00_TESTBED/pseudo_DRAM.v"
`include "../00_TESTBED/pseudo_SD.v"

module PATTERN(
    // Input Signals
    clk,
    rst_n,
    in_valid,
    direction,
    addr_dram,
    addr_sd,
    // Output Signals
    out_valid,
    out_data,
    // DRAM Signals
    AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY,
	AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP,
    // SD Signals
    MISO,
    MOSI
);

/* Input for design */
output reg        clk, rst_n;
output reg        in_valid;
output reg        direction;
output reg [13:0] addr_dram;
output reg [15:0] addr_sd;

/* Output for pattern */
input        out_valid;
input  [7:0] out_data; 

// DRAM Signals
// write address channel
input [31:0] AW_ADDR;
input AW_VALID;
output AW_READY;
// write data channel
input W_VALID;
input [63:0] W_DATA;
output W_READY;
// write response channel
output B_VALID;
output [1:0] B_RESP;
input B_READY;
// read address channel
input [31:0] AR_ADDR;
input AR_VALID;
output AR_READY;
// read data channel
output [63:0] R_DATA;
output R_VALID;
output [1:0] R_RESP;
input R_READY;

// SD Signals
output MISO;
input MOSI;

real CYCLE = `CYCLE_TIME;
integer pat_read;
integer PAT_NUM;
integer total_latency, latency;
integer i_pat;
integer output_counter;
integer axi_write_counter;

initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;

initial begin
    pat_read = $fopen("../00_TESTBED/Input.txt", "r"); 
    reset_signal_task;

    i_pat = 0;
    total_latency = 0;
    $fscanf(pat_read, "%d", PAT_NUM); 
    for (i_pat = 1; i_pat <= PAT_NUM; i_pat = i_pat + 1) begin
        input_task;
        wait_out_valid_task;
        check_ans_task;
        total_latency = total_latency + latency;
        $display("PASS PATTERN NO.%4d", i_pat);
    end
    $fclose(pat_read);

    $writememh("../00_TESTBED/DRAM_final.dat", u_DRAM.DRAM); //Write down your DRAM Final State
    $writememh("../00_TESTBED/SD_final.dat", u_SD.SD);		 //Write down your SD CARD Final State
    YOU_PASS_task;
end

//////////////////////////////////////////////////////////////////////
// Write your own task here
//////////////////////////////////////////////////////////////////////
reg [7:0] miso_shift_register;
always @ (posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		miso_shift_register <= 8'b0;
	end
	else begin
		miso_shift_register <= {miso_shift_register[6:0], MISO};
	end
end


task reset_signal_task; begin
	rst_n = 1'b1;
	in_valid = 1'b0;
	direction = 1'bx;
	addr_dram = 14'bx;
	addr_sd = 16'bx;
	
	force clk = 0;
	#(0.5);
	rst_n = 1'b0;
	#(2);
	if((out_valid !== 0) || (out_data !== 8'b0))begin
		$display("SPEC MAIN-1 FAIL");
		$finish;
	end
	//if((AW_READY !== 0) || (W_READY !== 0) || (B_READY !== 0) || (AR_READY !== 0) ||(R_VALID !== 0) || (R_DATA !== 64'b0) ||(R_RESP !== 2'b0)) begin
	if((AW_ADDR !== 0) || (AW_VALID !== 0) || (AW_VALID !== 0) || (W_VALID !== 0) || (W_DATA !== 0) || (B_READY !== 0) || (AR_ADDR !== 0) || (AR_VALID !== 0) || (R_READY !== 0) || (MOSI !== 1) ) begin
		$display("SPEC MAIN-1 FAIL");
		$display("AW_ADDR = %d", AW_ADDR);
		$display("AW_VALID = %d", AW_VALID);
		$display("AW_VALID = %d", AW_VALID);
		$display("W_VALID = %d", W_VALID);
		$display("W_DATA = %d", W_DATA);
		$display("B_READY = %d", B_READY);
		$display("AR_ADDR = %d", AR_ADDR);
		$display("AW_VALID = %d", AR_VALID);
		$display("R_READY = %d", R_READY);
		$display("MOSI = %d", MOSI);
		
		$finish;
	end
	#(10);
	rst_n = 1'b1;
	#(3); 
	release clk;
	
end endtask

reg [63:0] DRAM[0:8191];
reg [63:0] SD[0:65535];

parameter DRAM_p_r = "../00_TESTBED/DRAM_init.dat";
parameter SD_p_r = "../00_TESTBED/SD_init.dat";

initial begin
	$readmemh(DRAM_p_r, DRAM);
	$readmemh(SD_p_r, SD);
end

task input_task; begin
	@(negedge clk);
	in_valid = 1'b1;
	$fscanf(pat_read, "%d %d %d", direction, addr_dram, addr_sd);
	
	if(direction === 1'b0) begin
		// DRAM to SD Card
		SD[addr_sd] = DRAM[addr_dram]; 
	end
	else if(direction === 1'b1) begin
		// SD Card to DRAM
		DRAM[addr_dram] = SD[addr_sd];
				
	end
	@(negedge clk);
	in_valid = 1'b0;
	if(out_data !== 8'b0) begin
		$display("SPEC MAIN-2 FAIL");
		$finish;
	end
	
	if(addr_sd > 65535) begin
		$display("SPEC MAIN-6 FAIL");
		$finish;
	end
	
	//$display("direction: %d, addr_dram: %d, addr_sd: %d", direction, addr_dram, addr_sd);
end endtask

task wait_out_valid_task; begin
	latency = 0;
	axi_write_counter = 0;
	
	forever begin
		if(out_valid === 1) break;
		
		if(AW_VALID && AW_READY)begin
			if(AW_ADDR !== addr_dram)begin
				$display("SPEC MAIN-6 FAIL");
				$finish;
			end
		end
		
		if(W_VALID && W_READY)begin
			if(W_DATA === 0)begin
				$display("SPEC MAIN-6 FAIL");
				$finish;
			end
		end
		
		
		if(B_READY && B_VALID)	begin
			axi_write_counter = axi_write_counter + 1;
		end
		
		if(out_valid !== 1'b1)begin
			if(out_data !== 8'b0)begin
				$display("SPEC MAIN-2 FAIL");
				$finish;
			end
			else if(latency == 10000)begin
				$display("SPEC MAIN-3 FAIL");
				$finish;
			end
		end
		
		
		latency = latency + 1;
		@(negedge clk);
	end
	
	if(miso_shift_register === 8'b00000101)begin
		$display("SPEC MAIN-6 FAIL");
		$finish;
	end
	
	if(direction === 1 && axi_write_counter === 0)begin
		$display("SPEC MAIN-6 FAIL");
		$finish;
	end
		
end endtask

integer out_cnt;
task check_ans_task; begin
	out_cnt = 0;
	@(posedge clk);
	while (out_valid === 1'b1) begin
		
		// check out_data
		if(out_cnt + 1 > 8)begin
			$display("SPEC MAIN-4 FAIL");
			$finish;
		end
		else begin
			if(direction === 1'b0) begin
				
				
				if(SD[addr_sd] !== DRAM[addr_dram]) begin
					$display("SPEC MAIN-6 FAIL");
					$finish;
				end
				
				
				case(out_cnt)
					0:	if(out_data !== DRAM[addr_dram][63 : 56]) begin
							$display("SPEC MAIN-5 FAIL");
							$finish;
						end
					1:	if(out_data !== DRAM[addr_dram][55 : 48]) begin
							$display("SPEC MAIN-5 FAIL");
							$finish;
						end
					2:	if(out_data !== DRAM[addr_dram][47 : 40]) begin
							$display("SPEC MAIN-5 FAIL");
							$finish;
						end
					3:	if(out_data !== DRAM[addr_dram][39 : 32]) begin
							$display("SPEC MAIN-5 FAIL");
							$finish;
						end
					4:	if(out_data !== DRAM[addr_dram][31 : 24]) begin
							$display("SPEC MAIN-5 FAIL");
							$finish;
						end
					5:	if(out_data !== DRAM[addr_dram][23 : 16]) begin
							$display("SPEC MAIN-5 FAIL");
							$finish;
						end
					6:	if(out_data !== DRAM[addr_dram][15 : 8]) begin
							$display("SPEC MAIN-5 FAIL");
							$finish;
						end
					7:	if(out_data !== DRAM[addr_dram][7 : 0]) begin
							$display("SPEC MAIN-5 FAIL");
							$finish;
						end
					default:begin
							if(out_data !== 8'b0) begin
								$display("SPEC MAIN-5 FAIL");
								$finish;
							end
						end
				endcase
				
			end
			else if(direction === 1'b1) begin
				// SD Card to DRAM

				if(DRAM[addr_dram] !== SD[addr_sd]) begin
					$display("SPEC MAIN-6 FAIL");
					$finish;
				end
				
				case(out_cnt)
					0:	begin
							//$display("output_data = %h, SD[][63:56] = %h", out_data, SD[addr_sd][63:56]);
							if(out_data !== SD[addr_sd][63 : 56]) begin
								$display("SPEC MAIN-5 FAIL");
								
								$finish;
							end
						end
					1:	begin	
							//$display("output_data = %h, SD[55:48] = %h", out_data, SD[addr_sd][55:48]);
							if(out_data !== SD[addr_sd][55 : 48]) begin
								$display("SPEC MAIN-5 FAIL");
								//$finish;
							end
						end
					2:	begin
							//$display("output_data = %h, SD[47:40] = %h", out_data, SD[addr_sd][47:40]);
							if(out_data !== SD[addr_sd][47 : 40]) begin
								$display("SPEC MAIN-5 FAIL");
								//$finish;
							end
						end
					3:	begin
							if(out_data !== SD[addr_sd][39 : 32]) begin
								$display("SPEC MAIN-5 FAIL");
								$finish;
							end
						end
					4:	begin
							if(out_data !== SD[addr_sd][31 : 24]) begin
								$display("SPEC MAIN-5 FAIL");
								$finish;
							end
						end
					5:	begin
							if(out_data !== SD[addr_sd][23 : 16]) begin
								$display("SPEC MAIN-5 FAIL");
								$finish;
							end
						end
					6:	begin
							if(out_data !== SD[addr_sd][15 : 8]) begin
								$display("SPEC MAIN-5 FAIL");
								$finish;
							end
						end
					7:	begin
							if(out_data !== SD[addr_sd][7 : 0]) begin
								$display("SPEC MAIN-5 FAIL");
								$finish;
							end
						end
					default:begin
							if(out_data !== 8'b0) begin
								$display("SPEC MAIN-5 FAIL");
								$finish;
							end
						end
				endcase
			end
		end
		out_cnt = out_cnt + 1;
		@(posedge clk);
		if(out_cnt < 8 && (out_valid === 0))begin
			$display("SPEC MAIN-4 FAIL");
			$finish;
		end
	end
	
end endtask



task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("*                         Congratulations!                              *");
    $display("*                Your execution cycles = %5d cycles          *", total_latency);
    $display("*                Your clock period = %.1f ns          *", CYCLE);
    $display("*                Total Latency = %.1f ns          *", total_latency*CYCLE);
    $display("*************************************************************************");
    $finish;
end endtask

task YOU_FAIL_task; begin
    $display("*                              FAIL!                                    *");
    $display("*                    Error message from PATTERN.v                       *");
end endtask

pseudo_DRAM u_DRAM (
    .clk(clk),
    .rst_n(rst_n),
    // write address channel
    .AW_ADDR(AW_ADDR),
    .AW_VALID(AW_VALID),
    .AW_READY(AW_READY),
    // write data channel
    .W_VALID(W_VALID),
    .W_DATA(W_DATA),
    .W_READY(W_READY),
    // write response channel
    .B_VALID(B_VALID),
    .B_RESP(B_RESP),
    .B_READY(B_READY),
    // read address channel
    .AR_ADDR(AR_ADDR),
    .AR_VALID(AR_VALID),
    .AR_READY(AR_READY),
    // read data channel
    .R_DATA(R_DATA),
    .R_VALID(R_VALID),
    .R_RESP(R_RESP),
    .R_READY(R_READY)
);

pseudo_SD u_SD (
    .clk(clk),
    .MOSI(MOSI),
    .MISO(MISO)
);

endmodule
