/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2024 Spring IC Design Laboratory 
Lab08: SystemVerilog Design and Verification 
File Name   : PATTERN.sv
Module Name : PATTERN
Release version : v1.0 (Release Date: Apr-2024)
Author : Jui-Huang Tsai (erictsai.ee12@nycu.edu.tw)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype_BEV.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter DRAM_p_w = "../00_TESTBED/DRAM/output_dram.dat";

//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];  

integer i, j, latency, total_latency, i_pat, t;
parameter PATNUM = 15000;

Date date;
logic [1:0] act_id;
logic [1:0] size;
// golden ans
logic golden_complete;
logic [1:0] golden_err_msg;
logic [7:0] boxid;
// golden input
logic [11:0] golden_black;
logic [11:0] golden_green;
logic [11:0] golden_milk;
logic [11:0] golden_pineapple;
logic [11:0] golden_month;
logic [11:0] golden_day;

logic [12:0] golden_black_supply;
logic [12:0] golden_green_supply;
logic [12:0] golden_milk_supply;
logic [12:0] golden_pineapple_supply;

logic [12:0] golden_black_used;
logic [12:0] golden_green_used;
logic [12:0] golden_milk_used;
logic [12:0] golden_pineapple_used;

logic [3:0] today_mouth;
logic [4:0] today_day;
// 
logic [5:0] out_lat;
// make drink 
parameter black_black_l = 960;
parameter black_black_m = 720;
parameter black_black_s = 480;

parameter milk_black_l = 720;
parameter milk_black_m = 540;
parameter milk_black_s = 360;
parameter milk_milk_l = 240;
parameter milk_milk_m = 180;
parameter milk_milk_s = 120;

parameter extra_milk_black_l = 480;
parameter extra_milk_black_m = 360;
parameter extra_milk_black_s = 240;
parameter extra_milk_milk_l  = 480;
parameter extra_milk_milk_m  = 360;
parameter extra_milk_milk_s  = 240;

parameter green_green_l = 960;
parameter green_green_m = 720;
parameter green_green_s = 480;

parameter greenmilk_green_l = 480;
parameter greenmilk_green_m = 360;
parameter greenmilk_green_s = 240;
parameter greenmilk_milk_l = 480;
parameter greenmilk_milk_m = 360;
parameter greenmilk_milk_s = 240;

parameter pine_pine_l = 960;
parameter pine_pine_m = 720;
parameter pine_pine_s = 480;

parameter superpine_black_l = 480;
parameter superpine_black_m = 360;
parameter superpine_black_s = 240;
parameter superpine_pine_l  = 480;
parameter superpine_pine_m  = 360;
parameter superpine_pine_s  = 240;

parameter superpinemilk_black_l = 480;
parameter superpinemilk_black_m = 360;
parameter superpinemilk_black_s = 240;
parameter superpinemilk_pine_l  = 240;
parameter superpinemilk_pine_m  = 180;
parameter superpinemilk_pine_s  = 120;
parameter superpinemilk_milk_l  = 240;
parameter superpinemilk_milk_m  = 180;
parameter superpinemilk_milk_s  = 120;

logic [2:0] type_make;

logic [11:0] black_supply;
logic [11:0] green_supply;
logic [11:0] milk_supply;
logic [11:0] pineapple_supply;

parameter OUT_NUM = 1;
//================================================================
// class random
//================================================================

/**
 * Class representing a random action.
 */


class random_act;
    randc Action act_id;
    constraint range{
        act_id inside{Make_drink, Supply, Check_Valid_Date};
    }
endclass

/**
 * Class representing a random box from 0 to 31.
 */

class random_box;
    randc logic [7:0] boxid;
    constraint range{
        boxid inside{[0:255]};
    }
endclass

/**
 * Class representing a random bev type.
 */
class random_bev;
    randc Bev_Type bev;
    constraint range{
        bev inside{ Black_Tea      	         ,
                    Milk_Tea	             ,
                    Extra_Milk_Tea           ,
                    Green_Tea 	             ,
                    Green_Milk_Tea           ,
                    Pineapple_Juice          ,
                    Super_Pineapple_Tea      ,
                    Super_Pineapple_Milk_Tea };
    }
endclass

/**
 * Class representing a random bev size L M S.
 */
class random_size;
    randc Bev_Size size;
    constraint range{
        size inside{ L ,
                     M ,
                     S  };
    }
endclass


//================================================================
// initial
//================================================================

// initial $readmemh(DRAM_p_r, golden_DRAM);
random_act  act_rand;
random_box  box_rand;
random_bev  bev_type_rand;
random_size bev_size_rand;
// check if 1000 pattern
initial begin 
    $readmemh(DRAM_p_r, golden_DRAM);
    act_rand = new();
    box_rand = new();
    bev_type_rand = new();
    bev_size_rand = new();

    golden_complete = 'b0;
    total_latency = 0;
    latency = 0;
	reset_signal_task;

    t = $urandom_range(0, 3);
    repeat(t) @(negedge clk);
    for(i_pat = 0; i_pat < PATNUM; i_pat = i_pat + 1) begin
		input_task;
    	latency = 0;
        check_ans_task;
        wait_out_valid_task;
		$display ("\033[0;38;5;219mPass Pattern NO. %d  latency = %d\033[m", i_pat, latency);
        repeat($urandom_range(0,3)) @(negedge clk);
	end
    $writememh(DRAM_p_w, golden_DRAM);
	pass_task;
end
// check if 1000 pattern

// check if reste == 0
initial begin
	forever@(posedge clk)begin
		if(inf.rst_n == 0)
          begin
		    @(negedge clk);
			if((inf.complete !== 0) || (inf.err_msg !== 0) || (inf.out_valid !== 0))
            begin
            $display ("--------------------------------------------------------------------------------------------");
            $display ("            FAIL! Output signal should be 0 after the reset signal is asserted              ");
            $display ("--------------------------------------------------------------------------------------------");
			  repeat(3) @(negedge clk);
              $finish;
			end
		  end
	end
end
// check if outvalid == 1 the ans is correct or not ========= 
initial begin
	forever@(posedge clk)begin
		if(inf.out_valid)begin
		    @(negedge clk);
			if((inf.complete !== golden_complete)||(inf.err_msg !== golden_err_msg))
            begin
            $display ("--------------------------------------------------------------------------------------------");
            $display ("                               FAIL! Incorrect Anwser                                       ");
            $display ("                               \033[0;38;5;219mWrong Answer\033[m                           ");
            $display ("--------------------------------------------------------------------------------------------");
            repeat(4) @(negedge clk);
            $finish;
			end
		end
	end
end
// check if outvalid == 1 the ans is correct or not ========= 

// reset signal task ============= reset signal task //
task reset_signal_task; 
  begin 
    inf.rst_n = 1;
    #(0.5);  inf.rst_n <= 0;
	inf.D 	       = 'bx;
    inf.sel_action_valid = 0;
    inf.type_valid = 0; 
    inf.size_valid = 0; 
    inf.date_valid = 0; 
    inf.box_no_valid = 0; 
    inf.box_sup_valid = 0;
	#(5);
    #(10);  inf.rst_n <= 1;
  end 
endtask
// reset signal task ============= reset signal task //

// input task ========================= input task //
task input_task;
    begin
    repeat(1) @(negedge clk);
    inf.sel_action_valid = 'b1;
    act_rand.randomize();
    inf.D = act_rand.act_id;
    @(negedge clk);

    inf.sel_action_valid = 'b0;
    inf.D = 'bx;
    repeat($urandom_range(0, 3)) @(negedge clk);
        if (act_rand.act_id == Make_drink) begin
            make_drink_task;
        end
        else if (act_rand.act_id == Supply) begin
            supply_task;
        end
        else if (act_rand.act_id == Check_Valid_Date) begin
            check_valid_day_task;
        end
    end
endtask
// input task ========================= input task //

// make drink task ============ make drink task //
task make_drink_task ;
    begin
        inf.type_valid = 'b1;
        bev_type_rand.randomize();
        inf.D = bev_type_rand.bev;
        @(negedge clk);
        inf.type_valid = 'b0;
        inf.D = 'bx;
        repeat(1) @(negedge clk);
        
        inf.size_valid = 'b1;
        bev_size_rand.randomize();
        // size = bev_size_rand.randomize();
        inf.D = bev_size_rand.size;
        @(negedge clk);
        inf.size_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);    
        
        date.M = $urandom_range(1, 12);
        if (date.M == 1) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 3) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 5) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 7) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 8) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 10) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 12) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 4) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 6) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 9) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 11) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 2) begin
            date.D = $urandom_range(1,28);
        end

        today_mouth = date.M;
        today_day = date.D;
        inf.date_valid = 1;
        inf.D = date;
        @(negedge clk);
        inf.date_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);


        inf.box_no_valid = 'b1;
        box_rand.randomize();
        inf.D = box_rand.boxid;
        @(negedge clk);
        inf.box_no_valid = 'b0;
        inf.D = 'bx;
    end
endtask
// make drink task ============ make drink task //

// supply_task ============ supply_task //
task supply_task ;
    begin
        // date 
        date.M = $urandom_range(1, 12);
        if (date.M == 1) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 3) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 5) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 7) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 8) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 10) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 12) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 4) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 6) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 9) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 11) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 2) begin
            date.D = $urandom_range(1,28);
        end
        today_mouth = date.M;
        today_day = date.D;
        inf.date_valid = 1;
        inf.D = date;
        @(negedge clk);
        inf.date_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);

        // box_no_valid
        inf.box_no_valid = 'b1;
        box_rand.randomize();
        inf.D = box_rand.boxid;
        @(negedge clk);
        inf.box_no_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);

        // box_sup_valid
        // black tea
        inf.box_sup_valid = 'b1;
        black_supply = $urandom_range(0, 4095);
        inf.D = black_supply;
        @(negedge clk);
        inf.box_sup_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);
        // green tea 
        inf.box_sup_valid = 'b1;
        green_supply = $urandom_range(0, 4095);
        inf.D = green_supply;
        @(negedge clk);
        inf.box_sup_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);
        // milk
        inf.box_sup_valid = 'b1;
        milk_supply = $urandom_range(0, 4095);
        inf.D = milk_supply;
        @(negedge clk);
        inf.box_sup_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);
        // pineapple 
        inf.box_sup_valid = 'b1;
        pineapple_supply = $urandom_range(0, 4095);
        inf.D = pineapple_supply;
        @(negedge clk);
        inf.box_sup_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);
    end
endtask
// supply_task ============ supply_task //
// check_valid_day_task ============ check_valid_day_task //
task check_valid_day_task ;
    begin
        // date 
        date.M = 12;
        if (date.M == 1) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 3) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 5) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 7) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 8) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 10) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 12) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 4) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 6) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 9) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 11) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 2) begin
            date.D = $urandom_range(1,28);
        end
        today_mouth = date.M;
        today_day = date.D;
        inf.date_valid = 1;
        inf.D = date;
        @(negedge clk);
        inf.date_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);

        // box_no_valid
        inf.box_no_valid = 'b1;
        box_rand.randomize();
        inf.D = box_rand.boxid;
        @(negedge clk);
        inf.box_no_valid = 'b0;
        inf.D = 'bx;

    end
endtask

// check_valid_day_task ============ check_valid_day_task //
task wait_out_valid_task;
    begin
    while(inf.out_valid !== 1'b1) begin
        latency = latency + 1;
        if(latency == 1000) begin
            $display("*************************************************************************");
            $display("                           fail pattern: %d                           ", i_pat);
            $display("             The execution latency is limited in 1000 cycle              ");
            $display("*************************************************************************");
            $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
    end
endtask
// check ans task =============== check ans task //
task check_ans_task ;
    begin
        golden_black     = {golden_DRAM[65536 + 7 + (box_rand.boxid << 3)], golden_DRAM[65536 + 6 + (box_rand.boxid << 3)][7:4]};
        golden_green     = {golden_DRAM[65536 + 6 + (box_rand.boxid << 3)][3:0], golden_DRAM[65536 + 5 + (box_rand.boxid << 3)]};
        golden_milk      = {golden_DRAM[65536 + 3 + (box_rand.boxid << 3)], golden_DRAM[65536 + 2 + (box_rand.boxid << 3)][7:4]};
        golden_pineapple = {golden_DRAM[65536 + 2 + (box_rand.boxid << 3)][3:0], golden_DRAM[65536 + 1 + (box_rand.boxid << 3)]};
        golden_month     = {golden_DRAM[65536 + 4 + (box_rand.boxid << 3)]};
        golden_day       = {golden_DRAM[65536 +     (box_rand.boxid << 3)]};
    end
    if (act_rand.act_id == Make_drink) begin
        check_day_make_drink_task;
        repeat(1) @(negedge clk);
        check_ans_make_drink_task;
        if (golden_err_msg == 2'b00) begin
            check_inf_make_drink_task;
        end

    end
    else if (act_rand.act_id == Supply) begin
        check_ans_supply_task;
    end
    else if (act_rand.act_id == Check_Valid_Date) begin
        check_ans_cvd_task;
    end
endtask

task check_day_make_drink_task;
    begin
        if ((today_mouth > golden_month) || (today_mouth == golden_month && today_day > golden_day)) begin
            golden_err_msg = 2'b01;
            golden_complete = 'b0;
        end
        else begin 
            golden_err_msg = 2'b00;
            golden_complete = 'b1;
        end
    end
endtask

task check_ans_make_drink_task;
    begin
        if (golden_err_msg == 2'b00) begin
            case (bev_type_rand.bev)
                0 : begin
                    if (bev_size_rand.size == 0) begin
                        golden_black_used = golden_black - black_black_l;
                        golden_milk_used = golden_milk;
                        golden_green_used = golden_green;
                        golden_pineapple_used = golden_pineapple;
                    end
                    else if (bev_size_rand.size == 1) begin
                        golden_black_used = golden_black - black_black_m;
                        golden_milk_used = golden_milk;
                        golden_green_used = golden_green;
                        golden_pineapple_used = golden_pineapple;
                    end
                    else if (bev_size_rand.size == 3) begin
                        golden_black_used = golden_black - black_black_s;
                        golden_milk_used = golden_milk;
                        golden_green_used = golden_green;
                        golden_pineapple_used = golden_pineapple;
                    end
                end  
                1 : begin
                    if (bev_size_rand.size == 0) begin
                        golden_black_used = golden_black - milk_black_l;
                        golden_milk_used = golden_milk - milk_milk_l;
                        golden_green_used = golden_green;
                        golden_pineapple_used = golden_pineapple;
                    end
                    else if (bev_size_rand.size == 1) begin
                        golden_black_used = golden_black - milk_black_m;
                        golden_milk_used = golden_milk - milk_milk_m;
                        golden_green_used = golden_green;
                        golden_pineapple_used = golden_pineapple;
                    end
                    else if (bev_size_rand.size == 3) begin
                        golden_black_used = golden_black - milk_black_s;
                        golden_milk_used = golden_milk - milk_milk_s;
                        golden_green_used = golden_green;
                        golden_pineapple_used = golden_pineapple;
                    end
                end  
                2 : begin
                    if (bev_size_rand.size == 0) begin
                        golden_black_used = golden_black - extra_milk_black_l;
                        golden_milk_used = golden_milk - extra_milk_milk_l;
                        golden_green_used = golden_green;
                        golden_pineapple_used = golden_pineapple;
                    end
                    else if (bev_size_rand.size == 1) begin
                        golden_black_used = golden_black - extra_milk_black_m;
                        golden_milk_used = golden_milk - extra_milk_milk_m;
                        golden_green_used = golden_green;
                        golden_pineapple_used = golden_pineapple;
                    end
                    else if (bev_size_rand.size == 3) begin
                        golden_black_used = golden_black - extra_milk_black_s;
                        golden_milk_used = golden_milk - extra_milk_milk_s;
                        golden_green_used = golden_green;
                        golden_pineapple_used = golden_pineapple;
                    end
                end  
                3 : begin
                    if (bev_size_rand.size == 0) begin
                        golden_green_used = golden_green - green_green_l;
                        golden_black_used = golden_black;
                        golden_milk_used = golden_milk;
                        golden_pineapple_used = golden_pineapple;
                    end
                    else if (bev_size_rand.size == 1) begin
                        golden_green_used = golden_green - green_green_m;
                        golden_black_used = golden_black;
                        golden_milk_used = golden_milk;
                        golden_pineapple_used = golden_pineapple;
                    end
                    else if (bev_size_rand.size == 3) begin
                        golden_green_used = golden_green - green_green_s;
                        golden_black_used = golden_black;
                        golden_milk_used = golden_milk;
                        golden_pineapple_used = golden_pineapple;
                    end
                end  
                4 : begin
                    if (bev_size_rand.size == 0) begin
                        golden_green_used = golden_green - greenmilk_green_l;
                        golden_milk_used = golden_milk - greenmilk_milk_l;
                        golden_black_used = golden_black;
                        golden_pineapple_used = golden_pineapple;
                    end
                    else if (bev_size_rand.size == 1) begin
                        golden_green_used = golden_green - greenmilk_green_m;
                        golden_milk_used = golden_milk - greenmilk_milk_m;
                        golden_black_used = golden_black;   
                        golden_pineapple_used = golden_pineapple;
                    end
                    else if (bev_size_rand.size == 3) begin
                        golden_green_used = golden_green - greenmilk_green_s;
                        golden_milk_used = golden_milk - greenmilk_milk_s;
                        golden_black_used = golden_black;
                        golden_pineapple_used = golden_pineapple;
                    end
                end  
                5 : begin
                    if (bev_size_rand.size == 0) begin
                        golden_pineapple_used = golden_pineapple - pine_pine_l;
                        golden_green_used = golden_green;
                        golden_milk_used = golden_milk;
                        golden_black_used = golden_black;
                    end
                    else if (bev_size_rand.size == 1) begin
                        golden_pineapple_used = golden_pineapple - pine_pine_m;
                        golden_green_used = golden_green;
                        golden_milk_used = golden_milk;
                        golden_black_used = golden_black;
                    end
                    else if (bev_size_rand.size == 3) begin
                        golden_pineapple_used = golden_pineapple - pine_pine_s;
                        golden_green_used = golden_green;
                        golden_milk_used = golden_milk;
                        golden_black_used = golden_black;
                    end
                end  
                6 : begin
                    if (bev_size_rand.size == 0) begin
                        golden_black_used = golden_black - superpine_black_l;
                        golden_pineapple_used = golden_pineapple - superpine_pine_l;
                        golden_green_used = golden_green;
                        golden_milk_used = golden_milk;
                    end
                    else if (bev_size_rand.size == 1) begin
                        golden_black_used = golden_black - superpine_black_m;
                        golden_pineapple_used = golden_pineapple - superpine_pine_m;
                        golden_green_used = golden_green;
                        golden_milk_used = golden_milk;
                    end
                    else if (bev_size_rand.size == 3) begin
                        golden_black_used = golden_black - superpine_black_s;
                        golden_pineapple_used = golden_pineapple - superpine_pine_s;
                        golden_green_used = golden_green;
                        golden_milk_used = golden_milk;
                    end
                end  
                7 : begin
                    if (bev_size_rand.size == 0) begin
                        golden_black_used = golden_black - superpinemilk_black_l;
                        golden_milk_used = golden_milk - superpinemilk_milk_l;
                        golden_pineapple_used = golden_pineapple - superpinemilk_pine_l;
                        golden_green_used = golden_green;                    
                    end
                    else if (bev_size_rand.size == 1) begin
                        golden_black_used = golden_black - superpinemilk_black_m;
                        golden_milk_used = golden_milk - superpinemilk_milk_m;
                        golden_pineapple_used = golden_pineapple - superpinemilk_pine_m;
                        golden_green_used = golden_green;                    
                    end
                    else if (bev_size_rand.size == 3) begin
                        golden_black_used = golden_black - superpinemilk_black_s;
                        golden_milk_used = golden_milk - superpinemilk_milk_s;
                        golden_pineapple_used = golden_pineapple - superpinemilk_pine_s;
                        golden_green_used = golden_green;                    
                    end
                end  
            endcase 
                @(negedge clk);
                golden_DRAM[65536 + 7 + (8 * box_rand.boxid)]      = golden_black_used[11:4];
                golden_DRAM[65536 + 6 + (8 * box_rand.boxid)][7:4] = golden_black_used[3:0];

                golden_DRAM[65536 + 6 + (8 * box_rand.boxid)][3:0] = golden_green_used[11:8];
                golden_DRAM[65536 + 5 + (8 * box_rand.boxid)]      = golden_green_used[7:0];

                golden_DRAM[65536 + 3 + (8 * box_rand.boxid)]      = golden_milk_used[11:4];
                golden_DRAM[65536 + 2 + (8 * box_rand.boxid)][7:4] = golden_milk_used[3:0];

                golden_DRAM[65536 + 2 + (8 * box_rand.boxid)][3:0] = golden_pineapple_used[11:8];
                golden_DRAM[65536 + 1 + (8 * box_rand.boxid)]      = golden_pineapple_used[7:0];
        end
        else if (golden_err_msg == 2'b01) begin
            golden_black_used = golden_black;
            golden_milk_used = golden_milk;
            golden_pineapple_used = golden_pineapple;
            golden_green_used = golden_green; 

            golden_DRAM[65536 + 7 + (8 * box_rand.boxid)]      = golden_black_used[11:4];
            golden_DRAM[65536 + 6 + (8 * box_rand.boxid)][7:4] = golden_black_used[3:0];

            golden_DRAM[65536 + 6 + (8 * box_rand.boxid)][3:0] = golden_green_used[11:8];
            golden_DRAM[65536 + 5 + (8 * box_rand.boxid)]      = golden_green_used[7:0];

            golden_DRAM[65536 + 3 + (8 * box_rand.boxid)]      = golden_milk_used[11:4];
            golden_DRAM[65536 + 2 + (8 * box_rand.boxid)][7:4] = golden_milk_used[3:0];

            golden_DRAM[65536 + 2 + (8 * box_rand.boxid)][3:0] = golden_pineapple_used[11:8];
            golden_DRAM[65536 + 1 + (8 * box_rand.boxid)]      = golden_pineapple_used[7:0];
        end
    end
endtask 

task check_inf_make_drink_task;
    begin
        if (golden_black_used[12] || golden_green_used[12] || golden_milk_used[12] || golden_pineapple_used[12]) begin
            golden_err_msg = 2'b10;
            golden_complete = 'b0;
        end
        else begin 
            golden_err_msg = 2'b00;
            golden_complete = 'b1;
        end
        if (golden_err_msg == 2'b10) begin
            golden_black_used = golden_black;
            golden_milk_used = golden_milk;
            golden_pineapple_used = golden_pineapple;
            golden_green_used = golden_green; 

            golden_DRAM[65536 + 7 + (8 * box_rand.boxid)]      = golden_black_used[11:4];
            golden_DRAM[65536 + 6 + (8 * box_rand.boxid)][7:4] = golden_black_used[3:0];

            golden_DRAM[65536 + 6 + (8 * box_rand.boxid)][3:0] = golden_green_used[11:8];
            golden_DRAM[65536 + 5 + (8 * box_rand.boxid)]      = golden_green_used[7:0];

            golden_DRAM[65536 + 3 + (8 * box_rand.boxid)]      = golden_milk_used[11:4];
            golden_DRAM[65536 + 2 + (8 * box_rand.boxid)][7:4] = golden_milk_used[3:0];

            golden_DRAM[65536 + 2 + (8 * box_rand.boxid)][3:0] = golden_pineapple_used[11:8];
            golden_DRAM[65536 + 1 + (8 * box_rand.boxid)]      = golden_pineapple_used[7:0];
        end
    end
endtask


task check_ans_supply_task;
    begin
        golden_black_supply     = golden_black     + black_supply;
        golden_green_supply     = golden_green     + green_supply;
        golden_milk_supply      = golden_milk      + milk_supply;
        golden_pineapple_supply = golden_pineapple + pineapple_supply;
        if (golden_black_supply[12] || golden_green_supply[12] || golden_milk_supply[12] || golden_pineapple_supply[12]) begin
            golden_err_msg = 2'b11;
            golden_complete = 'b0;
        end
        else begin
            golden_err_msg = 2'b00;
            golden_complete = 'b1;
        end

        golden_DRAM[65536 + 4 + (8 * box_rand.boxid)] = today_mouth;
        golden_DRAM[65536 + 0 + (8 * box_rand.boxid)] = today_day;
        if (golden_black_supply[12]) begin
            golden_DRAM[65536 + 7 + (8 * box_rand.boxid)]      = 8'b1111_1111;
            golden_DRAM[65536 + 6 + (8 * box_rand.boxid)][7:4] = 4'b1111;
        end
        else begin
            golden_DRAM[65536 + 7 + (8 * box_rand.boxid)]      = golden_black_supply[11:4];
            golden_DRAM[65536 + 6 + (8 * box_rand.boxid)][7:4] = golden_black_supply[3:0];
        end
        if (golden_green_supply[12]) begin
            golden_DRAM[65536 + 6 + (8 * box_rand.boxid)][3:0] = 4'b1111;
            golden_DRAM[65536 + 5 + (8 * box_rand.boxid)]      = 8'b1111_1111;
        end
        else begin
            golden_DRAM[65536 + 6 + (8 * box_rand.boxid)][3:0] = golden_green_supply[11:8];
            golden_DRAM[65536 + 5 + (8 * box_rand.boxid)]      = golden_green_supply[7:0];
        end
        if (golden_milk_supply[12]) begin
            golden_DRAM[65536 + 3 + (8 * box_rand.boxid)]      = 8'b1111_1111;
            golden_DRAM[65536 + 2 + (8 * box_rand.boxid)][7:4] = 4'b1111;
        end
        else begin
            golden_DRAM[65536 + 3 + (8 * box_rand.boxid)]      = golden_milk_supply[11:4];
            golden_DRAM[65536 + 2 + (8 * box_rand.boxid)][7:4] = golden_milk_supply[3:0];
        end
        if (golden_pineapple_supply[12]) begin
            golden_DRAM[65536 + 2 + (8 * box_rand.boxid)][3:0] = 4'b1111;
            golden_DRAM[65536 + 1 + (8 * box_rand.boxid)]      = 8'b1111_1111;
        end
        else begin
            golden_DRAM[65536 + 2 + (8 * box_rand.boxid)][3:0] = golden_pineapple_supply[11:8];
            golden_DRAM[65536 + 1 + (8 * box_rand.boxid)]      = golden_pineapple_supply[7:0];
        end
    end
endtask

task check_ans_cvd_task ;
    begin
        if ((today_mouth > golden_month) || (today_mouth == golden_month && today_day > golden_day)) begin
            golden_err_msg = 2'b01;
            golden_complete = 'b0;
        end
        else begin
            golden_err_msg = 2'b00;
            golden_complete = 'b1;
        end
    end
endtask

// check ans task =============== check ans task //
// check_task ============ check_task //    
initial begin
    out_lat = 0;
    while (inf.out_valid === 1) begin
        if (out_lat == OUT_NUM) begin
            $display ("--------------------------------------------------------------------------------------------");
            $display ("                               FAIL! out_valid should one cycle                             ");
            $display ("--------------------------------------------------------------------------------------------");
            repeat(5) @(negedge clk);
            $finish;
        end
        out_lat = out_lat + 1;
        @(negedge clk);
    end
end
// check_task ============ check_task //

// pass task ========================== pass task //
task pass_task; begin	
    $display("********************************************************************");
    $display("                        \033[0;38;5;219mCongratulations!\033[m      ");
    $display("                 \033[0;38;5;219mYou have passed all patterns!\033[m");
    $display("********************************************************************");
    $finish;
    repeat (5) @(negedge clk);
    $finish;
    end 
endtask
// pass task ========================== pass task //
endprogram
