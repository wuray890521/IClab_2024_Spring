module Handshake_syn #(parameter WIDTH=8) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
output reg flag_handshake_to_clk1;
input flag_clk1_to_handshake;

output flag_handshake_to_clk2;
input flag_clk2_to_handshake;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

reg [WIDTH-1:0] s_data;
// assign sidle = sreq;
assign sidle = (sreq || sack) ? 0 : 1 ;
// quote ---------------------------------------------- quote //
NDFF_syn syn_s (.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
NDFF_syn syn_d (.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));
// quote ---------------------------------------------- quote //
// sreq by sclk -------------------------------- sreq by sclk //
always @(posedge sclk or negedge rst_n) begin
    if (!rst_n) begin
        sreq <= 0;
    end
    else begin
       if (sack)              sreq <= 0; 
       else if (sready == 1)  sreq <= 1;
       else                   sreq <= sreq;
    end
end
// scak by sclk -------------------------------- sack by sclk //
// s_data by sclk ---------------------------- s_data by sclk //
always @(posedge sclk or negedge rst_n) begin
    if (!rst_n) begin
        s_data <= 0;
    end
    else if (sready == 1)s_data <= din;
    else s_data <= s_data;
end
// s_data by sclk ---------------------------- s_data by sclk //
// dack by dclk -------------------------------- dack by dclk //
always @(posedge dclk or negedge rst_n) begin
    if(!rst_n) begin
        dack <= 0;
    end
    else if(dreq) begin
        dack <= 1;
    end
    else begin
        dack <= 0;
    end
end
// dack by dclk -------------------------------- dack by dclk //
// dout by dclk -------------------------------- dout by dclk //
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) begin
        dout <= 0;
    end
    else if (dbusy == 0 && dreq == 1) begin
        dout <= s_data;
    end
    else dout <= dout;
end
// dout by dclk -------------------------------- dout by dclk //
// dvalid by dclk -------------------------------- dvalid by dclk //
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) begin
        dvalid <= 0;
    end
    else if (dbusy == 0 && dreq == 1) begin
        dvalid <= 1;
    end
    else dvalid <= 0;
end
// dvalid by dclk -------------------------------- dvalid by dclk //
// flag_handshake_to_clk1 ================ flag_handshake_to_clk1 //
always @(*) begin
    if (!rst_n) begin
        flag_handshake_to_clk1 = 0;
    end
    else flag_handshake_to_clk1 = dreq;
end
// flag_handshake_to_clk1 ================ flag_handshake_to_clk1 //
endmodule