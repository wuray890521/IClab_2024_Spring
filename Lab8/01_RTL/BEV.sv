module BEV(input clk, INF.BEV_inf inf);
import usertype::*;
// This file contains the definition of several state machines used in the BEV (Beverage) System RTL design.
// The state machines are defined using SystemVerilog enumerated types.
// The state machines are:
// - state_t: used to represent the overall state of the BEV system
//
// Each enumerated type defines a set of named states that the corresponding process can be in.
typedef enum logic [3:0]{
    IDLE,
    MAKE_DRINK,
    SUPPLY,
    CHECK_DATE,
    LOAD1,
    LOAD2,
    OUT,
    SUPPLY1,
    CHECK_DATE1,
    MAKE_CHECK_DAY,
    MAKE_CHECK_ML,
    MAKE_WRITE_BACK_DRAM
} state_t;

logic [1:0] actseq;
logic [2:0] typeseq;
logic [1:0] sizeseq;
Date dateseq;
logic [7:0] boxnumseq;


// supply ================== supply //
// counter ================= counter //
logic [2:0] cnt_supply;
// counter ================= counter //

// origin amount =============== origin amount //
logic [11:0] blacktea_origin;
logic [11:0] greentea_origin;
logic [11:0] milk_origin;
logic [11:0] pineapplejuice_origin;

logic [11:0] blacktea_supply_data;
logic [11:0] greentea_supply_data;
logic [11:0] milk_supply_data;
logic [11:0] pineapplejuice_supply_data;

logic [11:0] blacktea_total;
logic [11:0] greentea_total;
logic [11:0] milk_total;
logic [11:0] pineapplejuice_total;

logic [12:0] reg_black;
logic [12:0] reg_green;
logic [12:0] reg_milk;
logic [12:0] reg_pineapple;
// origin amount =============== origin amount //
// C_data_r ======== C_data_r //
logic [63:0] c_data_r;
// C_data_r ======== C_data_r //
// supply ================== supply //

// CHECK DRINK ====================== CHECK DRINK //
logic [4:0] check_date_day;
logic [3:0] check_date_mounth;
// CHECK DRINK ====================== CHECK DRINK //

// MAKE DRINK ======================== MAKE DRINK //
logic [9:0] blacktea_used;
logic [9:0] greentea_used;
logic [9:0] milk_used;
logic [9:0] pineapplejuice_used;

logic [12:0] reg_black_make;
logic [12:0] reg_green_make;
logic [12:0] reg_milk_make;
logic [12:0] reg_pineapple_make;

logic [1:0] ans_err_msg;
// MAKE DRINK ======================== MAKE DRINK //
// FSM ============================================= FSM //
// REGISTERS
state_t state, nstate;

// STATE MACHINE
always_ff @( posedge clk or negedge inf.rst_n) begin : TOP_FSM_SEQ
    if (!inf.rst_n) state <= IDLE;
    else state <= nstate;
end

always_comb begin : TOP_FSM_COMB
    case(state)
        IDLE: begin
            if (inf.sel_action_valid)
            begin
                nstate = LOAD1;
            end
            else
            begin
                nstate = IDLE;
            end
        end
        LOAD1 : begin
            if (inf.box_no_valid && actseq == 2'd1) begin
                nstate = LOAD2;
            end
            else if (inf.box_no_valid && actseq == 2'd0) begin
                nstate = MAKE_DRINK;
            end
            else if (inf.box_no_valid && actseq == 2'd2) begin
                nstate = CHECK_DATE;
            end
            else nstate = LOAD1;
        end
        LOAD2 : begin
            if (cnt_supply == 4) begin
                nstate = SUPPLY;
            end
            else nstate = LOAD2;
        end
        SUPPLY : begin
            if (inf.C_out_valid) begin
                nstate = SUPPLY1;
            end
            else nstate = SUPPLY;
        end
        SUPPLY1 : begin
            if(inf.C_out_valid)nstate = OUT;
            else nstate = SUPPLY1;
        end
        CHECK_DATE : begin
            if (check_date_day != 0 && check_date_mounth != 0) begin
                nstate = CHECK_DATE1;
            end
            else nstate = CHECK_DATE;
        end
        CHECK_DATE1 : begin
            nstate = OUT;
        end
        MAKE_DRINK : begin
            if (check_date_day != 0 && check_date_mounth != 0) begin
                nstate = MAKE_CHECK_DAY;
            end
            else nstate = MAKE_DRINK;
        end
        MAKE_CHECK_DAY : begin
            nstate = MAKE_CHECK_ML;
        end
        MAKE_CHECK_ML : begin
            nstate = MAKE_WRITE_BACK_DRAM;
        end
        MAKE_WRITE_BACK_DRAM : begin
            if(inf.C_out_valid)nstate = OUT;
            else nstate = MAKE_WRITE_BACK_DRAM;
        end
        OUT : begin
            nstate = IDLE;
        end
        default: nstate = state;
    endcase
end
// FSM ============================================= FSM //

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        actseq <= 0;
    end
    else if (inf.sel_action_valid == 1)begin
        actseq <= inf.D.d_act[0];
    end
    else actseq <= actseq;
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        typeseq <= 0;
    end
    else if (inf.type_valid == 1)begin
        typeseq <= inf.D.d_type[0];
    end
    else typeseq <= typeseq;
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        sizeseq <= 0;
    end
    else if (inf.size_valid == 1)begin
        sizeseq <= inf.D.d_size[0];
    end
    else sizeseq <= sizeseq;
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        dateseq <= 0;
    end
    else if (inf.date_valid == 1)begin
        dateseq <= inf.D.d_date[0];
    end
    else dateseq <= dateseq;
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        boxnumseq <= 0;
    end
    else if (inf.box_no_valid == 1)begin
        boxnumseq <= inf.D.d_box_no[0];
    end
    else boxnumseq <= boxnumseq;
end

// output to AXI Bridge =================  output to AXI Bridge //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.C_addr <= 0;
    end
    else begin
        if (inf.box_no_valid == 1) inf.C_addr <= inf.D.d_box_no[0];
        else inf.C_addr <= inf.C_addr;
    end
end
// C_r_wb ================ C_r_wb //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.C_r_wb <= 0;
    end
    else if (state !== SUPPLY && nstate == SUPPLY)begin
        inf.C_r_wb <= 1;
    end
    else if (state !== SUPPLY1 && nstate == SUPPLY1)begin
        inf.C_r_wb <= 0;
    end
    else if (state !== CHECK_DATE && nstate == CHECK_DATE) begin
        inf.C_r_wb <= 1;
    end
    // for make drink ================= for make drink //
    else if (state !== MAKE_DRINK && nstate == MAKE_DRINK) begin
        inf.C_r_wb <= 1;
    end
    else if (state == MAKE_CHECK_ML && nstate !== MAKE_CHECK_ML) begin
        inf.C_r_wb <= 0;
    end
    // for make drink ================= for make drink //
    else inf.C_r_wb <= inf.C_r_wb;
end
// C_r_wb ================ C_r_wb //

// C_in_valid ================ C_in_valid //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.C_in_valid <= 0;
    end
    else if (state == IDLE) begin
        inf.C_in_valid <= 0;
    end
    // for supply ======================= for supply //
    else if (state !== SUPPLY && nstate == SUPPLY)begin
        inf.C_in_valid <= 1;
    end
    else if (state !== SUPPLY1 && nstate == SUPPLY1)begin
        inf.C_in_valid <= 1;
    end
    // for supply ======================= for supply //
    // for check ======================= for check //
    else if (state !== CHECK_DATE && nstate == CHECK_DATE) begin
        inf.C_in_valid <= 1;
    end
    // for check ======================= for check //
    // for make drink ================= for make drink //
    else if (state !== MAKE_DRINK && nstate == MAKE_DRINK) begin
        inf.C_in_valid <= 1;
    end
    else if (state == MAKE_CHECK_ML && nstate !== MAKE_CHECK_ML) begin
        inf.C_in_valid <= 1;
    end
    // for make drink ================= for make drink //
    else inf.C_in_valid <= 0;
end
// C_in_valid ================ C_in_valid //

// C_data_w ================ C_data_w //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.C_data_w <= 0;
    end
    else if (state == IDLE) begin
        inf.C_data_w <= 0;
    end
    else if (state == SUPPLY1 && actseq == 1)begin
        inf.C_data_w <= {blacktea_total, greentea_total, 4'b0000, dateseq.M, milk_total, pineapplejuice_total, 3'b000, dateseq.D};
    end
    else if (state == MAKE_WRITE_BACK_DRAM && actseq == 0)begin
        inf.C_data_w <= {blacktea_total, greentea_total, 4'b0000, check_date_mounth, milk_total, pineapplejuice_total, 3'b000, check_date_day};
    end
    else inf.C_data_w <= inf.C_data_w;
end
// C_data_w ================ C_data_w //


// output to AXI Bridge =================  output to AXI Bridge //

// supply =============================== supply //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        cnt_supply <= 0;
    end
    else if (inf.box_sup_valid == 1) begin
        cnt_supply <= cnt_supply + 1;
    end
    else if (cnt_supply == 4) begin
        cnt_supply <= 0;
    end
    else cnt_supply <= cnt_supply;
end

// blacktea origin ============ blacktea origin //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        blacktea_origin <= 0;
    end
    else if (state == IDLE) begin
        blacktea_origin <= 0;
    end
    else if (inf.box_sup_valid == 1 && cnt_supply == 0) begin
        blacktea_origin <= inf.D.d_ing[0];
    end
    else if (state != MAKE_CHECK_ML && nstate == MAKE_CHECK_ML) begin
        blacktea_origin <= c_data_r[63:52];
    end
    else blacktea_origin <= blacktea_origin;
end
// blacktea origin ============ blacktea origin //

// greentea_origin ================ greentea_origin //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        greentea_origin <= 0;
    end
    else if (state == IDLE) begin
        greentea_origin <= 0;
    end
    else if (inf.box_sup_valid == 1 && cnt_supply == 1) begin
        greentea_origin <= inf.D.d_ing[0];
    end
    else if (state != MAKE_CHECK_ML && nstate == MAKE_CHECK_ML) begin
        greentea_origin <= c_data_r[51:40];
    end
    else greentea_origin <= greentea_origin;
end
// greentea_origin ================ greentea_origin //

// milk_origin ==================== milk_origin // 
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        milk_origin <= 0;
    end
    else if (state == IDLE) begin
        milk_origin <= 0;
    end
    else if (inf.box_sup_valid == 1 && cnt_supply == 2) begin
        milk_origin <= inf.D.d_ing[0];
    end
    else if (state != MAKE_CHECK_ML && nstate == MAKE_CHECK_ML) begin
        milk_origin <= c_data_r[31:20];
    end
    else milk_origin <= milk_origin;
end
// milk_origin ==================== milk_origin // 

// pineapplejuice_origin =========== pineapplejuice_origin //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        pineapplejuice_origin <= 0;
    end
    else if (state == IDLE) begin
        pineapplejuice_origin <= 0;
    end
    else if (inf.box_sup_valid == 1 && cnt_supply == 3) begin
        pineapplejuice_origin <= inf.D.d_ing[0];
    end
    else if (state != MAKE_CHECK_ML && nstate == MAKE_CHECK_ML) begin
        pineapplejuice_origin <= c_data_r[19:8];
    end
    else pineapplejuice_origin <= pineapplejuice_origin;
end
// pineapplejuice_origin =========== pineapplejuice_origin //

// supply data =========================== supply data//
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        c_data_r <= 0;
    end
    else if (state == IDLE) begin
        c_data_r <= 0;
    end
    else if (inf.C_out_valid == 1) begin
        c_data_r <= inf.C_data_r;
    end
    else c_data_r <= c_data_r;
end

// supply black tea ===========supply black tea //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        blacktea_supply_data <= 0;
    end
    else if (state == IDLE) begin
        blacktea_supply_data <= 0;
    end
    else blacktea_supply_data <= (actseq) ? c_data_r[63:52] : blacktea_used;
end
// supply black tea ===========supply black tea //

// supply green tea =========== supply green tea //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        greentea_supply_data <= 0;
    end
    else if (state == IDLE) begin
        greentea_supply_data <= 0;
    end
    else greentea_supply_data <= (actseq) ? c_data_r[51:40] : greentea_used;
end
// supply green tea =========== supply green tea // 

// supply milk ============ supply milk //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        milk_supply_data <= 0;
    end
    else if (state == IDLE) begin
        milk_supply_data <= 0;
    end
    else milk_supply_data <= (actseq) ? c_data_r[31:20] : milk_used;
    // else if (actseq == 0) begin
    //     milk_supply_data <= milk_used;
    // end
    // else if (actseq == 1) begin
    //     milk_supply_data <= c_data_r[31:20];
    // end
end
// supply milk ============ supply milk //

// supply pineapple ========== supply pineapple //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        pineapplejuice_supply_data <= 0;
    end
    else if (state == IDLE) begin
        pineapplejuice_supply_data <= 0;
    end
    else pineapplejuice_supply_data <= (actseq) ? c_data_r[19:8] : pineapplejuice_used;
    // else if (actseq == 0) begin
    //     pineapplejuice_supply_data <= pineapplejuice_used;
    // end
    // else if (actseq == 1) begin
    //     pineapplejuice_supply_data <= c_data_r[19:8];
    // end
end
// supply pineapple ========== supply pineapple //

// supply data =========================== supply data//

// blacktea total ============ blacktea total //

assign  reg_black = blacktea_origin + blacktea_supply_data;
assign  reg_black_make = blacktea_origin - blacktea_supply_data;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        blacktea_total <= 0;
    end
    else if (state == IDLE) begin
        blacktea_total <= 0;
    end
    else if (actseq)begin
        if (reg_black[12]) begin
            blacktea_total <= 4095;
        end
        else blacktea_total <= reg_black;
    end
    else if (actseq == 0) begin
        if (ans_err_msg) begin
            blacktea_total <= blacktea_origin;
        end
        else begin
            if (reg_black_make[12] || reg_green_make[12] || reg_milk_make[12] || reg_pineapple_make[12]) begin
                blacktea_total <= blacktea_total;
            end
            else blacktea_total <= reg_black_make;
        end
    end
    else blacktea_total <= blacktea_total;
end
// blacktea total ============ blacktea total //

// blacktea total ============ blacktea total //
assign reg_green = greentea_origin + greentea_supply_data;
assign reg_green_make = greentea_origin - greentea_supply_data;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        greentea_total <= 0;
    end
    else if (state == IDLE) begin
        greentea_total <= 0;
    end
    else if (actseq) begin
        if (reg_green[12]) begin
            greentea_total <= 4095;
        end
        else greentea_total <= reg_green;
    end
    else if (actseq == 0) begin
        if (ans_err_msg) begin
            greentea_total <= greentea_origin;
        end
        else begin
            if (reg_black_make[12] || reg_green_make[12] || reg_milk_make[12] || reg_pineapple_make[12]) begin
                greentea_total <= greentea_total;
            end
            else greentea_total <= reg_green_make;
        end
    end
    else greentea_total <= greentea_total;
end
// blacktea total ============ blacktea total //

// blacktea total ============ blacktea total //
assign reg_milk = milk_origin + milk_supply_data;
assign reg_milk_make = milk_origin - milk_supply_data;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        milk_total <= 0;
    end
    else if (state == IDLE) begin
        milk_total <= 0;
    end
    else if (actseq) begin
        if (reg_milk[12]) begin
            milk_total <= 4095;
        end
        else milk_total <= reg_milk;
    end
    else if (actseq == 0) begin
        if (ans_err_msg) begin
            milk_total <= milk_origin;
        end
        else begin
            if (reg_black_make[12] || reg_green_make[12] || reg_milk_make[12] || reg_pineapple_make[12]) begin
                milk_total <= milk_total;
            end
            else milk_total <= reg_milk_make;
        end
    end
    else milk_total <= milk_total;
end
// blacktea total ============ blacktea total //

// blacktea total ============ blacktea total //
assign reg_pineapple = pineapplejuice_origin + pineapplejuice_supply_data;
assign reg_pineapple_make = pineapplejuice_origin - pineapplejuice_supply_data;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        pineapplejuice_total <= 0;
    end
    else if (state == IDLE) begin
        pineapplejuice_total <= 0;
    end
    else if (actseq) begin
        if (reg_pineapple[12]) begin
            pineapplejuice_total <= 4095;
        end
        else pineapplejuice_total <= reg_pineapple;
    end
    else if (actseq == 0) begin
        if (ans_err_msg) begin
            pineapplejuice_total <= pineapplejuice_origin;
        end
        else begin
            if (reg_black_make[12] || reg_green_make[12] || reg_milk_make[12] || reg_pineapple_make[12]) begin
                pineapplejuice_total <= pineapplejuice_total;
            end
            else pineapplejuice_total <= reg_pineapple_make;
        end
    end
    else pineapplejuice_total <= pineapplejuice_total;
end
// blacktea total ============ blacktea total //

// supply =============================== supply //

// CHECK DRINK ====================== CHECK DRINK //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        check_date_day <= 0;
    end    
    else if (state == IDLE) begin
        check_date_day <= 0;
    end
    else check_date_day <= c_data_r[4:0];
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        check_date_mounth <= 0;
    end    
    else if (state == IDLE) begin
        check_date_mounth <= 0;
    end
    else check_date_mounth <= c_data_r[39:32];
end
// CHECK DRINK ====================== CHECK DRINK //

// MAKE DRINK ============================ MAKE DRINK //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        blacktea_used <= 0;
        greentea_used <= 0;
        milk_used <= 0;
        pineapplejuice_used <= 0;
    end    
    else if (state == IDLE) begin
        blacktea_used <= 0;
        greentea_used <= 0;
        milk_used <= 0;
        pineapplejuice_used <= 0;        
    end
    else if (state == MAKE_CHECK_ML) begin
        case (typeseq)
            0 : begin // 1 black tea
                if (sizeseq == 0) begin // 960
                blacktea_used <= 960;
                end
                else if (sizeseq == 1) begin // 720
                blacktea_used <= 720;
                end
                else if (sizeseq == 3) begin // 480
                blacktea_used <= 480;
                end
            end 
            1 : begin // 3 black tea 1 milk
                if (sizeseq == 0) begin // 720 240 
                blacktea_used <= 720;
                milk_used <= 240;
                end
                else if (sizeseq == 1) begin //540 180
                blacktea_used <= 540;
                milk_used <= 180;
                end
                else if (sizeseq == 3) begin // 360 120
                blacktea_used <= 360;
                milk_used <= 120;
                end
            end 
            2 : begin // 1 black tea 1 milk
                if (sizeseq == 0) begin // 480 480
                blacktea_used <= 480;
                milk_used <= 480; 
                end
                else if (sizeseq == 1) begin // 360 360 
                blacktea_used <= 360;
                milk_used <= 360;                    
                end
                else if (sizeseq == 3) begin // 240 240 
                blacktea_used <= 240;
                milk_used <= 240;
                end
            end 
            3 : begin // 1 green tea
                if (sizeseq == 0) begin // 960
                    greentea_used <= 960; 
                end
                else if (sizeseq == 1) begin //720
                    greentea_used <= 720;
                end
                else if (sizeseq == 3) begin // 480
                    greentea_used <= 480; 
                end
            end 
            4 : begin // 1 green tea 1 milk
                if (sizeseq == 0) begin // 480 480
                    greentea_used <= 480;
                    milk_used <= 480;
                end
                else if (sizeseq == 1) begin // 360 360 
                    greentea_used <= 360;
                    milk_used <= 360;
                end
                else if (sizeseq == 3) begin // 240 240 
                    greentea_used <= 240;
                    milk_used <= 240;
                end
            end 
            5 : begin // 1 pineapple juice 
                if (sizeseq == 0) begin // 960 
                    pineapplejuice_used <= 960;
                end
                else if (sizeseq == 1) begin // 720 
                    pineapplejuice_used <= 720;
                end
                else if (sizeseq == 3) begin //480 
                    pineapplejuice_used <= 480;
                end
            end 
            6 : begin // 1 black tea 1 pineapple tea 
                if (sizeseq == 0) begin // 480 480
                    blacktea_used <= 480;
                    pineapplejuice_used <= 480;
                end
                else if (sizeseq == 1) begin // 360 360 
                    blacktea_used <= 360;
                    pineapplejuice_used <= 360;
                end
                else if (sizeseq == 3) begin // 240 240 
                    blacktea_used <= 240;
                    pineapplejuice_used <= 240;                    
                end
            end 
            7 : begin // 2 black tea 1 milk 1 pineapple juice
                if (sizeseq == 0) begin // 480 240 240
                    blacktea_used <= 480;
                    milk_used <= 240;
                    pineapplejuice_used <= 240;
                end
                else if (sizeseq == 1) begin // 360 180 180
                    blacktea_used <= 360;
                    milk_used <= 180;
                    pineapplejuice_used <= 180;                    
                end
                else if (sizeseq == 3) begin // 240 120 120 
                    blacktea_used <= 240;
                    milk_used <= 120;
                    pineapplejuice_used <= 120;
                end
            end 
        endcase
    end
end
// MAKE DRINK ============================ MAKE DRINK //

// ALL ERROR MESSAGE ======================== ALL ERROR MESSAGE //
always_comb begin
    case(actseq)
        0 : begin
            if(dateseq.M > check_date_mounth) begin
                ans_err_msg = 2'b01;
            end
            else if (dateseq.M == check_date_mounth && dateseq.D > check_date_day) begin
                ans_err_msg = 2'b01;
            end
            else if(reg_black_make[12] || reg_green_make[12] || reg_milk_make[12] || reg_pineapple_make[12]) begin
                ans_err_msg = 2'b10;
            end
            else begin
                ans_err_msg = 2'b00;
            end
        end
        1 : begin
            if(reg_black[12] || reg_green[12] || reg_milk[12] || reg_pineapple[12]) begin
                ans_err_msg = 2'b11;
            end
            else begin
                ans_err_msg = 2'b00;
            end
        end
        2 : begin
            if(dateseq.M > check_date_mounth) begin
                ans_err_msg = 2'b01;
            end
            else if (dateseq.M == check_date_mounth && dateseq.D > check_date_day) begin
                ans_err_msg = 2'b01;
            end
            else begin
                ans_err_msg = 2'b00;
            end
        end
        default : ans_err_msg = 2'b00;
    endcase
end
// ALL ERROR MESSAGE ======================== ALL ERROR MESSAGE //

// output data ======================================== output data //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.out_valid <= 0;
    end
    else if (state == OUT) begin
        inf.out_valid <= 1;
    end
    else begin
        inf.out_valid <= 0;
    end 
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.err_msg <= 0;
    end
    else if (state == OUT) begin
        inf.err_msg <= ans_err_msg;
    end
    else begin
        inf.err_msg <= 0;
    end 
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.complete <= 0;
    end
    else if (state == OUT) begin
        if (!ans_err_msg) begin
            inf.complete <= 1;
        end
        else inf.complete <= 0;
    end
    else begin
        inf.complete <= 0;
    end 
end
// output data ======================================== output data //


endmodule
