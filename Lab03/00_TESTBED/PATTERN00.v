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
integer dram_read;
integer sd_read;

integer i, a, b;
reg [63:0] dram_data [0:8191];
reg [63:0] sd_data [0:65535];

integer PAT_NUM;
integer total_latency, latency;
integer i_pat;
parameter CYCLE_DELAY = 10000;
integer cnt ;

reg in_mode;
reg [13:0] in_addforDRAM;
reg [15:0] in_addforSD;
reg [3:0]out_idx;
reg [63:0]golden [7:0];
reg [63:0]golden_r [7:0];
reg total_error;
reg reg_direction;

initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;

initial begin
    pat_read = $fopen("../00_TESTBED/Input.txt", "r"); 
    dram_read = $fopen("../00_TESTBED/DRAM_init.dat", "r");
    sd_read = $fopen("../00_TESTBED/SD_init.dat", "r");
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
// SPEC MAIN-1: All output signals should be reset after the reset signal is asserted.
// OK
always @(negedge clk ) begin
    if (W_VALID == 1) begin
        golden[7] <= W_DATA[63:56];
        golden[6] <= W_DATA[55:48];
        golden[5] <= W_DATA[47:40];
        golden[4] <= W_DATA[39:32];
        golden[3] <= W_DATA[31:24];
        golden[2] <= W_DATA[23:16];
        golden[1] <= W_DATA[15:8];
        golden[0] <= W_DATA[7:0];
    end
    else if (out_valid == 1) begin
        for (i = 0; i < 8; i = i + 1) begin
            golden[i] <= golden[i];
        end
    end
    // else begin
    //     for (i = 0; i < 8; i = i + 1) begin
    //         golden[i] <= 0;
    //     end
    // end
end
always @(negedge clk ) begin
    if (R_VALID == 1 && reg_direction == 0) begin
        golden_r[7] <= R_DATA[63:56];
        golden_r[6] <= R_DATA[55:48];
        golden_r[5] <= R_DATA[47:40];
        golden_r[4] <= R_DATA[39:32];
        golden_r[3] <= R_DATA[31:24];
        golden_r[2] <= R_DATA[23:16];
        golden_r[1] <= R_DATA[15:8];
        golden_r[0] <= R_DATA[7:0];
    end
    else if (out_valid == 1) begin
        for (i = 0; i < 8; i = i + 1) begin
            golden_r[i] <= golden_r[i];
        end
    end
end
task reset_signal_task ; begin 
    // rst_n      = 'b1;
    // in_valid   = 'b0;
    // direction  = 'bx;
    // addr_dram  = 'bx;
    // addr_sd    = 'bx;

    // #(CYCLE);       rst_n = 1'b0; 
    // addr_dram  = 'b0;
    // #(CYCLE*3); rst_n = 1'b1;
    
    // if(out_valid !== 1'b0 || out_data !== 'b0 || AW_ADDR !== 'b0 || AW_VALID !== 'b0 || W_VALID !== 'b0 || W_DATA !== 'b0
    //     || B_READY !== 'b0 || AR_ADDR !== 'b0 || AR_VALID !== 'b0 || R_READY !== 'b0 || MOSI !== 'b1) begin
    //     $display("----------------------------------------------------------------------------------------");
    //     $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
    //     $display("    ▄▀            ▀▄      ▄▄                                          ");
    //     $display("    █  ▀   ▀       ▀▄▄   █  █      FAIL !                            ");
    //     $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  Output signal should be 0 after RESET  at %8t", $time);
    //     $display("    █  ▄▀▀▀▄                 █  ╭                                        ");
    //     $display("    ▀▄                       █                                           ");
    //     $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
    //     $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
    //     $display("----------------------------------------------------------------------------------------");
    //     repeat(1) #CYCLE;
    //     $finish;
        
    // end
    // @(negedge clk);


	rst_n = 1'b1;
	in_valid = 1'b0;
	direction = 1'bx;
	addr_dram = 14'bx;
	addr_sd = 16'bx;
	
	force clk = 0;
	#(0.5);
	rst_n = 1'b0;
	// #(200);
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

//  SPEC MAIN-2: The out_data should be reset when your out_valid is low.
// OK
always@(*)begin
    @(negedge clk);
	if(~out_valid && out_data !== 0)begin
        $display("--------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █      FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  The out_data should be 0 when out_valid is low");
        $display("    █  ▄▀▀▀▄                 █  ╭                                        ");
        $display("    ▀▄                       █                                           ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("--------------------------------------------------------------------------------");
		repeat(1)@(negedge clk);
		$finish;			
	end	
end

task input_task; begin
    #(CYCLE);
    $fscanf(pat_read, "%d %d %d", in_mode, in_addforDRAM, in_addforSD ); 
    in_valid = 'b1;
    direction = in_mode;
    addr_dram = in_addforDRAM;
    addr_sd = in_addforSD;
    #(CYCLE);
    // direction = 'dx;
    addr_dram = 'dx;
    addr_sd   = 'dx;
    in_valid = 'b0;

end endtask

task wait_out_valid_task; begin
    latency = 'b0;
    while(out_valid !== 1'b1) begin
        latency = latency + 1;
    	if(latency == CYCLE_DELAY) begin
            $display("--------------------------------------------------------------------------------");
            $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
            $display("    ▄▀            ▀▄      ▄▄                                          ");
            $display("    █  ▀   ▀       ▀▄▄   █  █      FAIL !                            ");
            $display("    █   ▀▀            ▀▀▀   ▀▄  ╭   The execution cycles are over %3d\033[m", CYCLE_DELAY);
            $display("    █  ▄▀▀▀▄                 █  ╭                                        ");
            $display("    ▀▄                       █                                           ");
            $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
            $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
            $display("--------------------------------------------------------------------------------");
			repeat(2)@(negedge clk);
			$finish;
    	end
    	@(negedge clk);
   	end
end endtask

always@(*)begin
    cnt = 'b0;
    while(out_valid == 1'b1) begin
    cnt = cnt + 1;
    if (cnt == 7) begin
        cnt = 'b0;
    end
    if(cnt == 8) begin
        $display("--------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █      FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭   The execution cycles are over %3d\033[m", cnt);
        $display("    █  ▄▀▀▀▄                 █  ╭                                        ");
        $display("    ▀▄                       █                                           ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("--------------------------------------------------------------------------------");
        repeat(2)@(negedge clk);
        $finish;
    end
    @(negedge clk);
   	end
end


always @(*) begin
    if (in_valid == 1) begin
        reg_direction = direction;
    end
    else reg_direction = reg_direction;
end
task check_ans_task; begin
    out_idx     = 0;
    total_error = 0;
    while(out_valid === 1 && reg_direction == 1) begin
        if (out_data !== golden[7 - out_idx]) begin
			$display("\033[0;32;31m--------------------------------------------------------\033[m");
            $display("\033[0;32;31m		          FAIL  at code %0d                        \033[m", out_idx);
            $display("\033[0;32;31m                 golden = %h,                           \033[m", golden[7 - out_idx] );
			$display("\033[0;32;31m--------------------------------------------------------\033[m");
            total_error = total_error + 1;
            out_idx = out_idx + 1;
            repeat(2)@(negedge clk);

            $finish;
        end
        @(negedge clk);
        out_idx = out_idx + 1;
    end
    while(out_valid === 1 && reg_direction == 0) begin
        if (out_data !== golden_r[7 - out_idx]) begin
			$display("\033[0;32;31m--------------------------------------------------------\033[m");
            $display("\033[0;32;31m		          FAIL  at code %0d                        \033[m", out_idx);
            $display("\033[0;32;31m                 golden = %h,                           \033[m", golden_r[7 - out_idx] );
			$display("\033[0;32;31m--------------------------------------------------------\033[m");
            total_error = total_error + 1;
            out_idx = out_idx + 1;
            repeat(2)@(negedge clk);

            $finish;
        end
        // golden[out_idx] = ascii_out(out_code);
        @(negedge clk);
        out_idx = out_idx + 1;
    end
end endtask


//////////////////////////////////////////////////////////////////////


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