//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : HT_TOP.v
//   	Module Name : HT_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "SORT_IP.v"
//synopsys translate_on

module HT_TOP(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_weight, 
	out_mode,
    // Output signals
    out_valid, 
	out_code
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid, out_mode;
input [2:0] in_weight;

output reg out_valid, out_code;


// ===============================================================
// Reg & Wire Declaration
// ===============================================================
reg [15:0] cnt;
reg reg_out_mode;
reg [3:0] characters[0:7];
reg [4:0] weight[0:7];
reg [3:0] sort_character[0:7];
reg [3:0] outcharacters[0:7];
reg [4:0] small2add;


reg [4:0] state_cs, state_ns;
parameter IDLE = 0;
parameter LOAD = 1;
parameter SORT1 = 2;
parameter SORT2 = 3;
parameter SORT3 = 4;
parameter SORT4 = 5;
parameter SORT5 = 6;
parameter SORT6 = 7;
parameter SORT7 = 8;
parameter SORT8 = 9;

reg in_valid_d;
reg [2:0] rge_in_weight;

parameter IP_WIDTH = 8;
reg [IP_WIDTH*4-1:0]  IN_character;
reg [IP_WIDTH*5-1:0]  IN_weight;
wire [IP_WIDTH*4-1:0] OUT_character;
SORT_IP #(.IP_WIDTH(IP_WIDTH)) I_SORT_IP(.IN_character(IN_character), .IN_weight(IN_weight), .OUT_character(OUT_character));

// ===============================================================
// Design
// ===============================================================



always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state_cs <= IDLE;
    end
    else state_cs <= state_ns;
end
always @(*) begin
    case (state_cs) 
        IDLE : begin
            if (in_valid) begin
                state_ns = LOAD;
            end
            else state_ns = IDLE;
        end 
        LOAD : begin
            if (in_valid == 0 && cnt == 7) begin
                state_ns = SORT1;
            end
            else state_ns = LOAD;
        end 
        SORT1 : begin
            state_ns = SORT2;
        end 
        SORT2 : begin
            state_ns = SORT3;
        end 
        SORT3 : begin
            state_ns = SORT4;
        end 
        SORT4 : begin
            state_ns = SORT5;
        end 
        SORT5 : begin
            state_ns = SORT6;
        end 
        SORT6 : begin
            state_ns = SORT7;
        end 
        SORT7 : begin
            state_ns = SORT8;
        end 
        // OUT : begin
        //     if (cnt == 7) begin
        //         state_ns = IDLE;
        //     end
        //     else state_ns = OUT;
        // end 
        // default: state_ns = IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end
    else if (state_cs == LOAD) begin
        if (cnt == IP_WIDTH - 1) begin
            cnt <= 0;
        end
        else cnt <= cnt + 1;
    end

    else cnt <= cnt;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rge_in_weight <= 0;
    end
    else rge_in_weight <= in_weight;
end
// input and store which number //
genvar i;
generate 
	for (i = 0 ; i < 8 ; i  = i + 1) begin 
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                characters[i] <= 0;
            end
            else if (in_valid) begin
                characters[i] <= 7 - i;
            end
            else characters[i] <= characters[i];
        end
        // always @(posedge clk or negedge rst_n) begin
        //     if (!rst_n) begin
        //         weight[i] <= 0;
        //     end
        //     else if (state_cs == LOAD && cnt == i) begin
        //         weight[i] <= rge_in_weight;
        //     end
        //     else weight[i] <= weight[i];
        // end
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                IN_character <= 0;
            end
            else if (state_cs == LOAD)begin
                IN_character[(IP_WIDTH-i)*4-1 -: 4] <= characters[i];
            end
        end
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                IN_weight <= 0;
            end
            else begin
                IN_weight[(IP_WIDTH-i)*5-1 -: 5] <= weight[i];
            end
            // else if (state_cs == LOAD)begin
            //     IN_weight[(IP_WIDTH-i)*5-1 -: 5] <= weight[i];
            // end
        end
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                sort_character[i] <= 0;
            end
            else sort_character[i] <= OUT_character[(IP_WIDTH-i)*4-1 -: 4];
        end
	end
endgenerate
// input and store which number //
always @ (posedge clk or negedge rst_n) begin 
    if (!rst_n) begin 
        for (int i = 0 ; i < 8 ; i = i + 1) begin 
            weight[i] <= 0 ;
        end
    end
    else begin 
        if (in_valid) begin 
            weight[0] <= in_weight;
            weight[1] <= weight[0];
            weight[2] <= weight[1];
            weight[3] <= weight[2];
            weight[4] <= weight[3];
            weight[5] <= weight[4];
            weight[6] <= weight[5];
            weight[7] <= weight[6];                     
        end
        else if (state_cs == 1 && in_valid == 0) begin 
            // weight[7] <= weight[OUT_character[31:28]];
            // weight[6] <= weight[OUT_character[27:24]];
            // weight[5] <= weight[OUT_character[23:20]];
            // weight[4] <= weight[OUT_character[19:16]];
            // weight[3] <= weight[OUT_character[15:12]];
            // weight[2] <= weight[OUT_character[11:8]];            
            // weight[1] <= weight[OUT_character[7:4]];
            // weight[0] <= weight[OUT_character[3:0]] ;
            weight[7] <= weight[7];
            weight[6] <= weight[6];
            weight[5] <= weight[5];
            weight[4] <= weight[4];
            weight[3] <= weight[3];
            weight[2] <= weight[2];            
            weight[1] <= weight[1];
            weight[0] <= weight[0];
        end
        else if (state_cs == SORT1) begin 
            weight[7] <= weight[OUT_character[31:28]];
            weight[6] <= weight[OUT_character[27:24]];
            weight[5] <= weight[OUT_character[23:20]];
            weight[4] <= weight[OUT_character[19:16]];
            weight[3] <= weight[OUT_character[15:12]];
            weight[2] <= weight[OUT_character[11:8]] + weight[OUT_character[7:4]] ;
            weight[1] <=0;
        end
        else if (state_cs == SORT2) begin 
            weight[7] <= weight[OUT_character[31:28]];
            weight[6] <= weight[OUT_character[27:24]];
            weight[5] <= weight[OUT_character[23:20]];
            weight[4] <= weight[OUT_character[19:16]];
            weight[3] <= weight[OUT_character[15:12]] + weight[OUT_character[11:8]] ;
            weight[2] <=0;
        end
        else if (state_cs == SORT3) begin 
            weight[7] <= weight[OUT_character[31:28]];
            weight[6] <= weight[OUT_character[27:24]];
            weight[5] <= weight[OUT_character[23:20]];
            weight[4] <= weight[OUT_character[19:16]] + weight[OUT_character[15:12]] ;
            weight[3] <=0;
        end
        else if (state_cs == SORT4) begin 
            weight[7] <= weight[OUT_character[31:28]];
            weight[6] <= weight[OUT_character[27:24]];
            weight[5] <= weight[OUT_character[23:20]] + weight[OUT_character[19:16]] ;
            weight[4] <=0;
        end
        else if (state_cs == SORT5) begin 
            weight[7] <= weight[OUT_character[31:28]];
            weight[6] <= weight[OUT_character[27:24]] + weight[OUT_character[23:20]] ;
            weight[5] <=0;
        end
        else if (state_cs == SORT6) begin 
            weight[7] <= weight[OUT_character[31:28]] + weight[OUT_character[27:24]] ;
            weight[6] <=0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_d <= 0;
    end
    else in_valid_d <= in_valid;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_out_mode <= 0;
    end
    else if (in_valid && !in_valid_d) begin
        reg_out_mode <= out_mode;
    end
    else reg_out_mode <= reg_out_mode;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    // else if (state_cs == OUT) begin
    //     out_valid <= 1;
    // end
    else out_valid <= out_valid;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_code <= 0;
    end
    // else if (state_cs == OUT) begin
    //     out_code <= OUT_character;
    // end
    else out_code <= out_code;
end
endmodule