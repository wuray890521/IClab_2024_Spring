module FIFO_syn #(parameter WIDTH=8, parameter WORDS=64) (
    wclk,
    rclk,
    rst_n,
    winc,
    wdata,
    wfull,
    rinc,
    rdata,
    rempty,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo,

    flag_fifo_to_clk1,
	flag_clk1_to_fifo
);

input wclk, rclk;
input rst_n;
input winc;
input [WIDTH-1:0] wdata;
output reg wfull;
input rinc;
output reg [WIDTH-1:0] rdata;
output reg rempty;

// You can change the input / output of the custom flag ports
output  flag_fifo_to_clk2;
input flag_clk2_to_fifo;

output flag_fifo_to_clk1;
input flag_clk1_to_fifo;

wire [WIDTH-1:0] rdata_q;

// Remember: 
//   wptr and rptr should be gray coded
//   Don't modify the signal name
reg [$clog2(WORDS):0] wptr;
reg [$clog2(WORDS):0] rptr;

// rdata
//  Add one more register stage to rdata
always @(posedge rclk, negedge rst_n) begin
    if (!rst_n) begin
        rdata <= 0;
    end
    else begin
		//if (rinc & !rempty) begin
			rdata <= rdata_q;
		end
    end


//==========================================
//start design
//==========================================
wire web_write;
assign web_write = !(winc & !wfull);
reg  [$clog2(WORDS):0]waddr;
reg  [$clog2(WORDS):0]raddr;

DUAL_64X8X1BM1 u_dual_sram (
    .CKA(wclk),
    .CKB(rclk),
    .WEAN(web_write), 
    .WEBN(1'b1),
    .CSA(1'b1),
    .CSB(1'b1),
    .OEA(1'b1),
    .OEB(1'b1),
    .A0(waddr[0]),
    .A1(waddr[1]),
    .A2(waddr[2]),
    .A3(waddr[3]),
    .A4(waddr[4]),
    .A5(waddr[5]),
    
    .B0(raddr[0]),
    .B1(raddr[1]),
    .B2(raddr[2]),
    .B3(raddr[3]),
    .B4(raddr[4]),
    .B5(raddr[5]),

    .DIA0(wdata[0]),
    .DIA1(wdata[1]),
    .DIA2(wdata[2]),
    .DIA3(wdata[3]),
    .DIA4(wdata[4]),
    .DIA5(wdata[5]),
    .DIA6(wdata[6]),
    .DIA7(wdata[7]),
    .DIB0(1'b0),
    .DIB1(1'b0),
    .DIB2(1'b0),
    .DIB3(1'b0),
    .DIB4(1'b0),
    .DIB5(1'b0),
    .DIB6(1'b0),
    .DIB7(1'b0),
    .DOB0(rdata_q[0]),
    .DOB1(rdata_q[1]),
    .DOB2(rdata_q[2]),
    .DOB3(rdata_q[3]),
    .DOB4(rdata_q[4]),
    .DOB5(rdata_q[5]),
    .DOB6(rdata_q[6]),
    .DOB7(rdata_q[7])
);



//=========================================================================================
//FIFO START WRITE   & READ
//=========================================================================================
reg  [$clog2(WORDS):0] wq2_rptr;
reg  [$clog2(WORDS):0] rq2_wptr;
NDFF_BUS_syn #(.WIDTH($clog2(WORDS) + 1)) rsy (.D(wptr), .Q(rq2_wptr), .clk(rclk), .rst_n(rst_n));
NDFF_BUS_syn #(.WIDTH($clog2(WORDS) + 1)) wsy (.D(rptr), .Q(wq2_rptr), .clk(wclk), .rst_n(rst_n));

// FIFO WRITE ======================== FIFO WRITE //
wire wfull_q;
wire [$clog2(WORDS):0] wptr_q;
wire [$clog2(WORDS):0]waddr_q;
assign waddr_q = waddr + (winc & !wfull);
assign wptr_q  = (waddr_q >> 1) ^ waddr_q;
assign wfull_q = ((wptr_q[$clog2(WORDS)] != wq2_rptr[$clog2(WORDS)]) && (wptr_q[$clog2(WORDS) - 1] != wq2_rptr[$clog2(WORDS) - 1]) && (wptr_q[$clog2(WORDS) - 2 : 0] == wq2_rptr[$clog2(WORDS) - 2 : 0]));

always @(posedge wclk or negedge rst_n) begin
    if(!rst_n) begin
        wfull <= 0;
    end
    else begin
        wfull <= wfull_q;
    end
end

always @(posedge wclk or negedge rst_n) begin
    if(!rst_n) begin
        wptr  <= 0;
    end
    else begin
        wptr  <= wptr_q;
    end
end

always @(posedge wclk or negedge rst_n) begin
    if(!rst_n) begin
        waddr <= 0;
    end
    else if (winc & !wfull) begin
        waddr <= waddr + 1;
    end
end
// FIFO READ ================================== FIFO READ //
wire rempty_q;
wire [$clog2(WORDS):0]raddr_q;
wire [$clog2(WORDS):0] rptr_q;

assign raddr_q  = raddr + (rinc & ~rempty);
assign rptr_q   = (raddr_q >> 1) ^ raddr_q;
assign rempty_q = (rptr_q == rq2_wptr);

always @(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        rptr  <= 0;
    end
    else begin
        rptr  <= rptr_q;
    end
end
always @(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        raddr <= 0;
    end
    else begin
        raddr <= raddr_q;
    end
end

always @(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        rempty <= 1;
    end
    else begin
        rempty <= rempty_q;
    end
end
// FIFO READ ================================== FIFO READ //

reg [6:0] raddr_d;
reg [6:0] raddr_d_d;
always @(posedge rclk or negedge rst_n) begin
    if (!rst_n) begin
        raddr_d <= 0;
        raddr_d_d <= 0;
    end
    else begin
        raddr_d   <= raddr;
        raddr_d_d <= raddr_d;
    end
end

assign flag_fifo_to_clk1 = (raddr_d != raddr_d_d) ? 1 : 0;
endmodule
