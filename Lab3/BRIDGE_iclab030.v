//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2023 ICLAB Fall Course
//   Lab03      : BRIDGE
//   Author     : Ting-Yu Chang
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : BRIDGE_encrypted.v
//   Module Name : BRIDGE
//   Release version : v1.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module BRIDGE(
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

// Input Signals
input clk, rst_n;
input in_valid;
input direction;
input [12:0] addr_dram;
input [15:0] addr_sd;

// Output Signals
output reg out_valid;
output reg [7:0] out_data;

// DRAM Signals
// write address channel
output reg [31:0] AW_ADDR;
output reg AW_VALID;
input AW_READY;
// write data channel
output reg W_VALID;
output reg [63:0] W_DATA;
input W_READY;
// write response channel
input B_VALID;
input [1:0] B_RESP;
output reg B_READY;
////////////////////////////////
// read address channel
output reg [31:0] AR_ADDR;
output reg AR_VALID;
input AR_READY;
// read data channel
input [63:0] R_DATA;
input R_VALID;
input [1:0] R_RESP;
output reg R_READY;

// SD Signals
input MISO;
output reg MOSI;
reg [63:0]RS_DATA ;

//==============================================//
//       parameter & integer declaration        //
//==============================================//
integer i;


//==============================================//
//           reg & wire declaration             //
//==============================================//
reg in_valid_d;
reg reg_direction;
reg [12:0] reg_addr_dram;
reg [15:0] reg_addr_sd;
reg AR_READY_d;
reg R_VALID_d;
reg [15:0] cnt_s;
reg flag;
reg flag1;
reg flag2;
reg flag3;
reg flag4;
reg AW_VALID_d;
reg MISO_d;
reg [15:0]cnt_s_d;
//==============================================//
//           reg for FSM                        //
//==============================================//
reg [3:0] state_cs;
reg [3:0] state_ns;
parameter IDLE = 4'd0;
parameter LOAD = 4'd1;
parameter DtoS = 4'd2;
parameter StoD = 4'd3;
parameter R_SD = 4'd4;
parameter D_AW = 4'd5;
parameter OUT = 4'd6;
parameter W_SD = 4'd7;
parameter T_SD = 4'd8;
parameter TEMP = 4'd9;
parameter temp1 = 4'd10;

//==============================================//
//                  design                      //
//==============================================//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_s_d <= 0;
    end
    else cnt_s_d <= cnt_s;
end
// one delay for in_valid
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_d <= 0;
        AR_READY_d <= 0;
        R_VALID_d <= 0;
        AW_VALID_d <= 0;
        MISO_d <= 0;
    end
	else begin
		in_valid_d <= in_valid;
        AR_READY_d <= AR_READY;
        R_VALID_d <= R_VALID;
        AW_VALID_d <= AW_VALID;
        MISO_d <= MISO;
	end
end
// make the direction stable
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		reg_direction <= 0 ;
	end
	else if (in_valid && in_valid_d==0) begin
		reg_direction <= direction;
	end
	else reg_direction <= reg_direction ;
end
// put data in reg
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		reg_addr_dram <= 0 ;
	end
	else if (in_valid == 1) begin
        reg_addr_dram <= addr_dram;
    end 
    else reg_addr_dram <= reg_addr_dram;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		reg_addr_sd <= 0 ;
	end
	else if (in_valid) begin
        reg_addr_sd <= addr_sd;
    end
    else reg_addr_sd <= reg_addr_sd;
end
// counter ------------------------------------------ counter //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_s <= 0;
    end
    else if (state_cs == 0) begin
        cnt_s <= 0;
    end
    else if (state_cs == LOAD) begin
        cnt_s <= 0;
    end
    else if (state_cs == StoD && MISO == 1) begin
        cnt_s <= cnt_s + 1;
    end
    else if (state_cs == 4) begin
        if (flag1 == 1) begin
            cnt_s <= cnt_s + 1;
        end
        else cnt_s <= 0; 
    end
    else if (state_cs == 5) begin
        if (AW_VALID_d == 1) begin
            cnt_s <= cnt_s + 1;
        end
        else cnt_s <= 0;
    end
    else if (state_cs == 6) begin        
        cnt_s <= cnt_s + 1;
        if (cnt_s == 8) begin
            cnt_s <= 0;
        end
    end
    else if (state_cs == 7) begin
        if (flag3 == 0 && MISO == 1) begin
            cnt_s <= cnt_s + 1;  
        end
        else cnt_s <= 0;
    end
    else if (state_cs == T_SD) begin
        if (cnt_s == 98) begin
            cnt_s <= 0;
        end
        else cnt_s <= cnt_s + 1;

    end
    else if (state_cs == 9) begin
        cnt_s <= cnt_s + 1;
        if (cnt_s == 36)begin
            cnt_s <= 0;
        end
        else cnt_s <= cnt_s + 1;
    end
    else if (state_cs == 10) begin
        cnt_s <= 0;
    end
    else cnt_s <= cnt_s;
end

always @(*) begin
    if (!rst_n) begin
        flag4 = 0;
    end
    else if (state_cs == 8 && MISO == 1) begin
        flag4 = 1;
    end
    else flag4 = 0;
end
// FSM ---------------------------------------------------- FSM //
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
            state_cs <= IDLE;
    else
            state_cs <= state_ns;
end
always @(*) begin
    case (state_cs)
        IDLE : begin
            if (in_valid == 1) begin
                state_ns = LOAD;
            end
            else state_ns = IDLE;
        end
        LOAD : begin
            case (reg_direction)
                1'b0 : state_ns = DtoS;
                1'b1 : state_ns = StoD; 
            endcase
        end
        StoD : begin
            if (MISO == 0) begin
                state_ns = R_SD;
            end
            else state_ns = StoD;
        end
        R_SD :begin
            if (cnt_s >= 79 && flag1 == 1) begin
                state_ns = D_AW;
            end
            else state_ns = R_SD;
        end
        D_AW :begin
            if (B_VALID) begin
                state_ns = OUT;
            end
            else state_ns = D_AW;
        end
        OUT :begin
            if (cnt_s == 8) begin
                state_ns = IDLE;
            end
            else state_ns = OUT;
        end
        DtoS : begin
            if(flag2 == 1 && R_READY == 0)begin
                state_ns = W_SD;
            end
            else state_ns = DtoS;
        end
        W_SD : begin
            if(MISO == 0)begin
                state_ns = 9;
            end
            else state_ns = W_SD;
        end
        TEMP : begin
            if (cnt_s == 36) begin
                state_ns = T_SD;
            end
            else state_ns = TEMP;
        end
        T_SD : begin
            if(cnt_s == 98)begin
                state_ns = temp1;
            end
            else state_ns = T_SD;
        end
        temp1 : begin
            if(MISO == 1)begin
                state_ns = OUT;
            end
            else state_ns = temp1;
        end
        default: state_ns = IDLE;
    endcase
end
// DRAM READ ----------------------------------------------------- DRAM READ//

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag2 <= 0;
    end
    else if (state_cs == 2) begin
        if (AR_READY == 1) begin
            flag2 <= 1;
        end
        else flag2 <= flag2;
    end
    else flag2 <= 0;
end
// if addr_dram is the code for AR_ADDR
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        AR_ADDR <= 0;
    end 
    else if (state_cs == 2) begin

        if (AR_READY == 1) begin
            AR_ADDR <= 0;
        end
        else if (flag2 == 1) begin
            AR_ADDR <= 0;
        end
        else AR_ADDR <= reg_addr_dram;
    end
    else AR_ADDR <= AR_ADDR;
end
// same as AR_ADDR 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        AR_VALID <= 0;
    end
    else if (state_cs == 2) begin
        if (AR_READY == 1) begin
            AR_VALID <= 1'b0;
        end
        else if (flag2 == 1) begin
            AR_VALID <= 1'b0;
        end
        else AR_VALID <= 1; 
    end
    else AR_VALID <= AR_VALID;
end
// same as R_ready
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        R_READY <= 0;
    end
    else if (state_cs == 2) begin
        if (AR_READY == 1) begin
            R_READY <= 1;
        end
        else if (R_VALID) begin
            R_READY <= 0;
        end
    end
    else R_READY <= R_READY;
end
// write ---------------------------------------------------------------------- write// 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        AW_ADDR <= 0;
    end 
    else if (state_cs == 5) begin
        if (AW_READY == 1) begin
            AW_ADDR <= 0;
        end
        else if (B_READY == 1) begin
            AW_ADDR <= 0;
        end
        else AW_ADDR <= reg_addr_dram;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        AW_VALID <= 0;
    end
    else if (state_cs == 5) begin
        if (AW_READY == 1) begin
            AW_VALID <= 1'b0;
        end
        else if (B_READY == 1) begin
            AW_VALID <= 1'b0;
        end
        else AW_VALID <= 1; 
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        B_READY <= 0;
    end
    else if (AW_READY == 1) begin
        B_READY <= 1;
    end
    else if (B_VALID == 1) begin
        B_READY <= 0;
    end
    else B_READY <= B_READY;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        W_VALID <= 0;
    end
    else if (AW_READY == 1) begin
        W_VALID <= 1;
    end
    else if (W_READY == 1) begin
        W_VALID <= 0;
    end
    else W_VALID <= W_VALID;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        W_DATA <= 0;
    end
    else if (AW_READY == 1) begin
        W_DATA <= RS_DATA;
    end
    else if (W_READY == 1) begin
        W_DATA <= 0;
    end
    else W_DATA <= W_DATA;
end

reg [63:0]temp_R_DATA;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        temp_R_DATA <= 0;
    end
    else if (R_VALID) begin
        temp_R_DATA <= R_DATA;
    end
    else temp_R_DATA <= temp_R_DATA;
end

// SD write ------------------------------------------------ SD write //
reg [15:0] temp_reg_addr_sd;
wire [6:0] temp_CRC7_code;
assign temp_CRC7_code = CRC7({2'b01, 6'd17, 16'd0, temp_reg_addr_sd});
reg [12:0] temp_reg_addr_dram;
wire [6:0] temp_CRC7_code_wsd;
assign temp_CRC7_code_wsd = CRC7({2'b01, 6'd24, 16'd0, temp_reg_addr_sd});
wire [15:0] temp_crc16;
assign temp_crc16 = CRC16_CCITT(temp_R_DATA);
reg[87:0]MOSI_t;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        temp_reg_addr_sd <= 0;
    end
    else if (state_cs == LOAD) begin
        temp_reg_addr_sd <= reg_addr_sd;
    end
    else temp_reg_addr_sd <= temp_reg_addr_sd;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        MOSI <= 1;
    end
    else if (state_cs == StoD) begin
        case (cnt_s)
        // start bit + transmission bit------------------------
            1 : MOSI <= 0; 
            2 : MOSI <= 1;
            3 : MOSI <= 0;
            4 : MOSI <= 1;
            5 : MOSI <= 0;
            6 : MOSI <= 0;
            7 : MOSI <= 0;
            8 : MOSI <= 1;
        // byte 2 to 5 ----------------------------------------
            9 : MOSI <= 0;
            10 : MOSI <= 0; 
            11 : MOSI <= 0; 
            12 : MOSI <= 0;
            13 : MOSI <= 0;
            14 : MOSI <= 0;
            15 : MOSI <= 0;
            16 : MOSI <= 0;
            17 : MOSI <= 0;
            18 : MOSI <= 0;
            19 : MOSI <= 0;
            20 : MOSI <= 0; 
            21 : MOSI <= 0; 
            22 : MOSI <= 0;
            23 : MOSI <= 0;
            24 : MOSI <= 0;
            25 : MOSI <= temp_reg_addr_sd[15];
            26 : MOSI <= temp_reg_addr_sd[14];
            27 : MOSI <= temp_reg_addr_sd[13];
            28 : MOSI <= temp_reg_addr_sd[12];
            29 : MOSI <= temp_reg_addr_sd[11]; 
            30 : MOSI <= temp_reg_addr_sd[10]; 
            31 : MOSI <= temp_reg_addr_sd[9];
            32 : MOSI <= temp_reg_addr_sd[8];
            33 : MOSI <= temp_reg_addr_sd[7];
            34 : MOSI <= temp_reg_addr_sd[6];
            35 : MOSI <= temp_reg_addr_sd[5];
            36 : MOSI <= temp_reg_addr_sd[4];
            37 : MOSI <= temp_reg_addr_sd[3];
            38 : MOSI <= temp_reg_addr_sd[2];
            39 : MOSI <= temp_reg_addr_sd[1]; 
            40 : MOSI <= temp_reg_addr_sd[0]; 
        // last one byte----------------------------------
            41 : MOSI <= temp_CRC7_code[6];
            42 : MOSI <= temp_CRC7_code[5];
            43 : MOSI <= temp_CRC7_code[4];
            44 : MOSI <= temp_CRC7_code[3];
            45 : MOSI <= temp_CRC7_code[2];
            46 : MOSI <= temp_CRC7_code[1];
            47 : MOSI <= temp_CRC7_code[0];
            48 : MOSI <= 1;
            default : MOSI <= 1; 
        endcase
    end
    else if (state_cs == 7) begin
        case (cnt_s)
        // start bit + transmission bit------------------------
            1 : MOSI <= 0; 
            2 : MOSI <= 1;
            3 : MOSI <= 0;
            4 : MOSI <= 1;
            5 : MOSI <= 1;
            6 : MOSI <= 0;
            7 : MOSI <= 0;
            8 : MOSI <= 0;
        // byte 2 to 5 ----------------------------------------
            9 : MOSI <= 0;
            10 : MOSI <= 0; 
            11 : MOSI <= 0; 
            12 : MOSI <= 0;
            13 : MOSI <= 0;
            14 : MOSI <= 0;
            15 : MOSI <= 0;
            16 : MOSI <= 0;
            17 : MOSI <= 0;
            18 : MOSI <= 0;
            19 : MOSI <= 0;
            20 : MOSI <= 0; 
            21 : MOSI <= 0; 
            22 : MOSI <= 0;
            23 : MOSI <= 0;
            24 : MOSI <= 0;
            25 : MOSI <= temp_reg_addr_sd[15];
            26 : MOSI <= temp_reg_addr_sd[14];
            27 : MOSI <= temp_reg_addr_sd[13];
            28 : MOSI <= temp_reg_addr_sd[12];
            29 : MOSI <= temp_reg_addr_sd[11]; 
            30 : MOSI <= temp_reg_addr_sd[10]; 
            31 : MOSI <= temp_reg_addr_sd[9];
            32 : MOSI <= temp_reg_addr_sd[8];
            33 : MOSI <= temp_reg_addr_sd[7];
            34 : MOSI <= temp_reg_addr_sd[6];
            35 : MOSI <= temp_reg_addr_sd[5];
            36 : MOSI <= temp_reg_addr_sd[4];
            37 : MOSI <= temp_reg_addr_sd[3];
            38 : MOSI <= temp_reg_addr_sd[2];
            39 : MOSI <= temp_reg_addr_sd[1]; 
            40 : MOSI <= temp_reg_addr_sd[0];  
        // last one byte----------------------------------
            41 : MOSI <= temp_CRC7_code_wsd[6];
            42 : MOSI <= temp_CRC7_code_wsd[5];
            43 : MOSI <= temp_CRC7_code_wsd[4];
            44 : MOSI <= temp_CRC7_code_wsd[3];
            45 : MOSI <= temp_CRC7_code_wsd[2];
            46 : MOSI <= temp_CRC7_code_wsd[1];
            47 : MOSI <= temp_CRC7_code_wsd[0];
            48 : MOSI <= 1;
            default : MOSI <= 1; 
        endcase
    end
    else if (state_cs == 8) begin
        // MOSI_t <= {8'hfe,R_DATA,temp_crc16};
        // if (cnt_s == 0) begin
        //     MOSI <= 1;
        // end
        // else begin 
        // for (i = 87; i < 88 ; i = i + 1) begin
        //     MOSI <= MOSI_t[87 - i];
        // end
        // end
        case (cnt_s)  
            1: MOSI <= 1; //fe = 11111110  
            2: MOSI <= 1;
            3: MOSI <= 1;
            4: MOSI <= 1;
            5: MOSI <= 1;
            6: MOSI <= 1;
            7: MOSI <= 1;
            8: MOSI <= 0;
    //------ data --------------         
            9: MOSI <= temp_R_DATA[63];
            10: MOSI <= temp_R_DATA[62];
            11: MOSI <= temp_R_DATA[61];
            12: MOSI <= temp_R_DATA[60];
            13: MOSI <= temp_R_DATA[59];
            14: MOSI <= temp_R_DATA[58];
            15: MOSI <= temp_R_DATA[57];
            16: MOSI <= temp_R_DATA[56];
            17: MOSI <= temp_R_DATA[55];
            18: MOSI <= temp_R_DATA[54];
            19: MOSI <= temp_R_DATA[53];
            20: MOSI <= temp_R_DATA[52];
            21: MOSI <= temp_R_DATA[51];
            22: MOSI <= temp_R_DATA[50];
            23: MOSI <= temp_R_DATA[49];
            24: MOSI <= temp_R_DATA[48];
            25: MOSI <= temp_R_DATA[47];
            26: MOSI <= temp_R_DATA[46];
            27: MOSI <= temp_R_DATA[45];
            28: MOSI <= temp_R_DATA[44];
            29: MOSI <= temp_R_DATA[43];
            30: MOSI <= temp_R_DATA[42];
            31: MOSI <= temp_R_DATA[41];
            32: MOSI <= temp_R_DATA[40];
            33: MOSI <= temp_R_DATA[39];
            34: MOSI <= temp_R_DATA[38];
            35: MOSI <= temp_R_DATA[37];
            36: MOSI <= temp_R_DATA[36];
            37: MOSI <= temp_R_DATA[35];
            38: MOSI <= temp_R_DATA[34];
            39: MOSI <= temp_R_DATA[33];
            40: MOSI <= temp_R_DATA[32];
            41: MOSI <= temp_R_DATA[31];
            42: MOSI <= temp_R_DATA[30];
            43: MOSI <= temp_R_DATA[29];
            44: MOSI <= temp_R_DATA[28];
            45: MOSI <= temp_R_DATA[27];
            46: MOSI <= temp_R_DATA[26];
            47: MOSI <= temp_R_DATA[25];
            48: MOSI <= temp_R_DATA[24];
            49: MOSI <= temp_R_DATA[23];
            50: MOSI <= temp_R_DATA[22];
            51: MOSI <= temp_R_DATA[21];
            52: MOSI <= temp_R_DATA[20];
            53: MOSI <= temp_R_DATA[19];
            54: MOSI <= temp_R_DATA[18];
            55: MOSI <= temp_R_DATA[17];
            56: MOSI <= temp_R_DATA[16];
            57: MOSI <= temp_R_DATA[15];
            58: MOSI <= temp_R_DATA[14];
            59: MOSI <= temp_R_DATA[13];
            60: MOSI <= temp_R_DATA[12];
            61: MOSI <= temp_R_DATA[11];
            62: MOSI <= temp_R_DATA[10];
            63: MOSI <= temp_R_DATA[9];
            64: MOSI <= temp_R_DATA[8];
            65: MOSI <= temp_R_DATA[7];
            66: MOSI <= temp_R_DATA[6];
            67: MOSI <= temp_R_DATA[5];
            68: MOSI <= temp_R_DATA[4];
            69: MOSI <= temp_R_DATA[3];
            70: MOSI <= temp_R_DATA[2];
            71: MOSI <= temp_R_DATA[1];
            72: MOSI <= temp_R_DATA[0];
            73: MOSI <= temp_crc16[15];
            74: MOSI <= temp_crc16[14];
            75: MOSI <= temp_crc16[13];
            76: MOSI <= temp_crc16[12];
            77: MOSI <= temp_crc16[11];
            78: MOSI <= temp_crc16[10];
            79: MOSI <= temp_crc16[9];
            80: MOSI <= temp_crc16[8];
            81: MOSI <= temp_crc16[7];
            82: MOSI <= temp_crc16[6];
            83: MOSI <= temp_crc16[5];
            84: MOSI <= temp_crc16[4];
            85: MOSI <= temp_crc16[3];
            86: MOSI <= temp_crc16[2];
            87: MOSI <= temp_crc16[1];
            88: MOSI <= temp_crc16[0];
            default: MOSI <= 1;
        endcase
    end
end 

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag3 <= 0;
    end
    else if (state_cs == 7 && MISO == 0) begin
        flag3 <= 1;
    end
    else if (state_cs == 0) begin
        flag3 <= 0;
    end
    else flag3 <= flag3;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag <= 0;
    end
    else if (state_cs == 4 && cnt_s == 0 && MISO == 1) begin
        flag <= 1;
    end
    else flag <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag1 <= 0;
    end
    else if (flag == 1 && MISO == 0) begin
        flag1 <= 1;
    end
    else if (state_cs == 5) begin
        flag1 <= 0;
    end
    else flag1 <= flag1 ;
end

integer j;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (j = 0; j < 64; j = j+1) begin
            RS_DATA[j] <= 0;
        end
    end
    else if (state_cs == 4 && flag1 == 1 && cnt_s < 64) begin
        for (j = 0; j < 64; j = j+1) begin
            RS_DATA[j+1] <= RS_DATA[j];
        end
        RS_DATA [0] <= MISO ;
    end
    else if (state_cs == 6) begin
        RS_DATA <= 0;
    end
    else RS_DATA <= RS_DATA ;
end

// out_valid and out_data -------------------------------------- out_valid and out_data //
reg [63:0] ans;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ans <= 0;
    end
    else if (state_cs == 5) begin
        ans <= RS_DATA;
    end
    else if (state_cs == 8) begin
        ans <= temp_R_DATA;
    end
    else ans <= ans;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0; 
    end
    else if (state_cs == 6)begin
        if (cnt_s < 8) begin
            out_valid <= 1'b1;
        end
        else out_valid <= 0;
    end
    else begin
        out_valid <= out_valid;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data <= 0;
    end
    else if (state_cs == 6)begin
        case (cnt_s)
            0: out_data <= ans[63:56];
            1: out_data <= ans[55:48];
            2: out_data <= ans[47:40];
            3: out_data <= ans[39:32];
            4: out_data <= ans[31:24];
            5: out_data <= ans[23:16];
            6: out_data <= ans[15:8];
            7: out_data <= ans[7:0];
            default: out_data <= 0;
        endcase
    end
    else begin
        out_data <= out_data;
    end
end

//==============================================//
//             Example for function             //
//==============================================//

function automatic [6:0] CRC7;  // Return 7-bit result
    input [39:0] data;  // 40-bit data input
    reg [6:0] crc;
    integer i;
    reg data_in, data_out;
    parameter polynomial = 7'h9;  // x^7 + x^3 + 1

    begin
        crc = 7'd0;
        for (i = 0; i < 40; i = i + 1) begin
            data_in = data[39-i];
            data_out = crc[6];
            crc = crc << 1;  // Shift the CRC
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC7 = crc;
    end
endfunction

function automatic [15:0] CRC16_CCITT;
    // Try to implement CRC-16-CCITT function by yourself.
    input [63:0] data;  // 64-bit data input
    reg [15:0] crc;
    integer i;
    reg data_in, data_out;
    parameter polynomial = 16'b1000000100001;  // x^16 + x^15 + x^5 + x^0

    begin
        crc = 7'd0;
        for (i = 0; i < 64; i = i + 1) begin
            data_in = data[63-i];
            data_out = crc[15];
            crc = crc << 1;  // Shift the CRC
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC16_CCITT = crc;
    end
endfunction
endmodule

