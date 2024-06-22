// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on

module SNN(
	// Input signals
	clk,
	rst_n,
	cg_en,
	in_valid,
	img,
	ker,
	weight,

	// Output signals
	out_valid,
	out_data
);

input clk;
input rst_n;
input in_valid;
input cg_en;
input [7:0] img;
input [7:0] ker;
input [7:0] weight;

output reg out_valid;
output reg [9:0] out_data;

//==============================================//
//       parameter & integer declaration        //
//==============================================//


//==============================================//
//           reg & wire declaration             //
//==============================================//
// ======= FSM ======== //
reg [3:0] state_cs, state_ns;
parameter IDLE =  4'd0;
parameter LOAD =  4'd1;
parameter CON =   4'd2;
parameter MAXP =  4'd3;
parameter FULLY = 4'd4;
parameter NOR =   4'd5;
parameter WAIT =  4'd6;
parameter OUT =   4'd7;
// ======= FSM ======== //

// =========== input reg ======== //
integer i, j;
reg [7:0] reg_img;
reg [7:0] reg_ker;
reg [7:0] reg_weight;
reg in_valid_d;
reg [2:0] cnt_state_1_x;
reg [2:0] cnt_state_1_y;
reg [1:0] cnt_state_1_ker_x;
reg [1:0] cnt_state_1_ker_y;
reg flag_img;
reg [6:0] cnt_state_1;
reg [7:0] img_matrix1[5:0][5:0];
reg [7:0] img_matrix2[5:0][5:0];
reg [7:0] ker_matrix [2:0][2:0];
reg [7:0] wei_matrix [1:0][1:0];
// =========== input reg ======== //

// ========= convolution ========= //
reg [7:0] img_con_0;
reg [7:0] img_con_1;
reg [7:0] img_con_2;
reg [7:0] img_con_3;
reg [7:0] img_con_4;
reg [7:0] img_con_5;
reg [7:0] img_con_6;
reg [7:0] img_con_7;
reg [7:0] img_con_8;

reg [7:0] ker_con_0;
reg [7:0] ker_con_1;
reg [7:0] ker_con_2;
reg [7:0] ker_con_3;
reg [7:0] ker_con_4;
reg [7:0] ker_con_5;
reg [7:0] ker_con_6;
reg [7:0] ker_con_7;
reg [7:0] ker_con_8;

reg [15:0] mul_con_0;
reg [15:0] mul_con_1;
reg [15:0] mul_con_2;
reg [15:0] mul_con_3;
reg [15:0] mul_con_4;
reg [15:0] mul_con_5;
reg [15:0] mul_con_6;
reg [15:0] mul_con_7;
reg [15:0] mul_con_8;

reg [19:0] addr_1;
reg [19:0] addr_2;
reg [19:0] addr_3;
reg [21:0] convolution;

reg flar_state_2;

reg [11:0] scale;
reg [1:0] cnt_state_2_x;
reg [1:0] cnt_state_2_y;

reg [7:0] quantization;
reg [5:0] cnt_state_2;
reg flag_state_2_out;
reg flag_future;
reg [1:0] cnt_state_2_out_x;
reg [1:0] cnt_state_2_out_y;

reg [7:0] featuremap1[3:0][3:0];
reg [7:0] featuremap2[3:0][3:0];
// ========= convolution ========= //

// ============= maxpooling =========== //
reg cnt_state_3_x;
reg cnt_state_3_y;
reg [1:0] cnt_state_3_in_x;
reg [1:0] cnt_state_3_in_y;
reg flag_max;
reg flag_max_d;
reg [5:0] cnt_state_3;
reg [1:0] cnt_3;
reg [7:0] compare_a;
reg [7:0] max_seq;
reg [7:0] compare;
reg cnt_state_3_out_x;
reg cnt_state_3_out_y;
reg [7:0] max_matrix1[1:0][1:0];
reg [7:0] max_matrix2[1:0][1:0];
// ============= maxpooling =========== //

// ============ FULLY ================= //
reg [1:0] cnt_state_4;
reg [4:0] cnt_4;
reg cnt_state_4_in_x;
reg cnt_state_4_in_y;
reg cnt_state_4_weight_in_y;
reg flag_fully;
reg flag_fully_d;
reg [7:0] max_input;
reg [7:0] weight_input;
reg [15:0] multi_max;
reg [15:0] adder_max;
reg [19:0] fully;

reg [1:0] cnt_state_4_out;
reg [19:0] fullymatrix1[3:0];
reg [19:0] fullymatrix2[3:0];
reg flag_fully_out;
// ============ FULLY ================= //

// ================ l1 distance state_cs == NOR ============ //
reg [10:0] cnt_5 ;
reg [1:0] cnt_state_5;
reg [9:0] q1;
reg [9:0] q2;
reg [9:0] sub;
reg [9:0] addr_l1;
reg [9:0] out_temp;
// ================ l1 distance state_cs == NOR ============ //
reg [9:0] wait_out;
// ======================== CLOCK GATE =============== //
reg started;
reg flag_scale;
// ======================== CLOCK GATE =============== //
//==============================================//
//                  design                      //
//==============================================//
// =========== FSM ================== //
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
            state_cs <= IDLE;
    else
            state_cs <= state_ns;
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
            if (in_valid_d && !in_valid) begin
                state_ns = CON;
            end
            else state_ns = LOAD;
        end 
        CON : begin
            if (cnt_state_2 == 34) begin
                state_ns = MAXP;
            end
            else state_ns = CON;
        end
        MAXP : begin
            if (cnt_state_3 == 32) begin
                state_ns = FULLY;
            end
            else state_ns = MAXP;
        end
        FULLY : begin
            if (cnt_4 == 20) begin
                state_ns = NOR;
            end
            else state_ns = FULLY;
        end
        NOR : begin
            if (cnt_5 == 6) begin
                state_ns = OUT;
            end
            else state_ns = NOR;
        end
        OUT : begin
            state_ns = IDLE;
        end
        default: begin
            state_ns = state_cs;
        end
    endcase
end
// =========== FSM ================== //
wire ctrl_start = started;
wire G_sleep_start = (cg_en && started)? ctrl_start : 1'b0;
wire G_clock_start;
GATED_OR instgor4( .CLOCK(clk), .SLEEP_CTRL(G_sleep_start), .RST_N(rst_n), .CLOCK_GATED(G_clock_start) );
// =============== clock gating =============== //
always @(posedge G_clock_start or negedge rst_n) begin
	if(!rst_n) started <= 0;
	else begin
		if(in_valid) started <= 1;	
	end
end
// =============== clock gating =============== //
wire ctrl_load = (cnt_state_1 < 73 && (state_cs == LOAD || state_cs == IDLE)) ? 1'b0 : 1'b1;
wire G_sleep_load = (cg_en && started)? ctrl_load : 1'b0;
wire G_clock_load;
GATED_OR GATED_load( .CLOCK(clk), .SLEEP_CTRL(G_sleep_load), .RST_N(rst_n), .CLOCK_GATED(G_clock_load) );

wire ctrl_load_kernal = (cnt_state_1 <= 8 && (state_cs == LOAD)) ? 1'b0 : 1'b1;
wire G_sleep_load_kernal = (cg_en && started)? ctrl_load_kernal : 1'b0;
wire G_clock_load_kernal;
GATED_OR GATED_kernal( .CLOCK(clk), .SLEEP_CTRL(G_sleep_load_kernal), .RST_N(rst_n), .CLOCK_GATED(G_clock_load_kernal) );

wire ctrl_load_weight = (cnt_state_1 <= 3 && (state_cs == LOAD)) ? 1'b0 : 1'b1;
wire G_sleep_load_weight = (cg_en && started)? ctrl_load_weight : 1'b0;
wire G_clock_load_weight;
GATED_OR GATED_weight( .CLOCK(clk), .SLEEP_CTRL(G_sleep_load_weight), .RST_N(rst_n), .CLOCK_GATED(G_clock_load_weight) );
// =========== input ============= //
always @(posedge G_clock_load or negedge rst_n) begin
	if (!rst_n) begin
		reg_img <= 0;
		reg_ker <= 0;
		reg_weight <= 0;
	end
	else begin
		reg_img <= img;
		reg_ker <= ker;
		reg_weight <= weight;
	end
end

always @(posedge G_clock_load or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_d <= 0;
	end
	else in_valid_d <= in_valid;
end

// ================ clock gating in load ========== //
always @(posedge G_clock_load or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_1 <= 0;
	end
	else if (state_cs == IDLE) begin
		cnt_state_1 <= 0;
	end
	else cnt_state_1 <= cnt_state_1 + 1;
end

always @(posedge G_clock_load or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_1_x <= 0;
	end
	else if (state_cs == IDLE) begin
		cnt_state_1_x <= 0;
	end
	else begin
		if (cnt_state_1_x == 5) cnt_state_1_x <= 0;
		else cnt_state_1_x <= cnt_state_1_x + 1;
	end
end

always @(posedge G_clock_load or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_1_y <= 0;
	end
	else if (state_cs == IDLE) begin
		cnt_state_1_y <= 0;
	end
	else begin
		if (cnt_state_1_x == 5) begin 
			if (cnt_state_1_y == 5) cnt_state_1_y <= 0;
			else cnt_state_1_y <= cnt_state_1_y + 1;
		end
		else cnt_state_1_y <= cnt_state_1_y;
	end
end
// ================ clock gating in load ========== //

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		flag_img <= 0;
	end
	else if (cg_en == 0) begin
		if (state_cs == LOAD) begin
			if (cnt_state_1_x == 5 && cnt_state_1_y == 5) begin
				flag_img <= 1;
			end
			else flag_img <= flag_img;
		end
		else if (state_cs == IDLE) begin
			flag_img <= 0;
		end
		else  flag_img <= flag_img + 1;
	end
	else if (cg_en == 1) begin
		if (state_cs == LOAD) begin
			if (cnt_state_1_x == 5 && cnt_state_1_y == 5) begin
				flag_img <= 1;
			end
			else flag_img <= flag_img;
		end
		else flag_img <= 0;
	end
	// else if (state_cs == LOAD) begin
	// 	if (cnt_state_1_x == 5 && cnt_state_1_y == 5) begin
	// 		flag_img <= 1;
	// 	end
	// 	else flag_img <= flag_img;
	// end
	else flag_img <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 6 ; i = i + 1) begin
            for (j = 0; j < 6 ; j = j + 1) begin
                img_matrix1 [i][j] <= 0;
            end
        end
    end
    else if (state_cs == LOAD) begin
		if (!flag_img) begin
			img_matrix1[cnt_state_1_y][cnt_state_1_x] <= reg_img;
		end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 6 ; i = i + 1) begin
            for (j = 0; j < 6 ; j = j + 1) begin
                img_matrix2 [i][j] <= 0;
            end
        end
    end
    else if (state_cs == LOAD) begin
		if (flag_img) begin
			img_matrix2[cnt_state_1_y][cnt_state_1_x] <= reg_img;
		end
    end
end




always @(posedge G_clock_load_weight or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 2 ; i = i + 1 ) begin
            for (j = 0; j < 2 ; j = j + 1 ) begin
                wei_matrix [i][j] <= 0;
            end
        end
    end
    else if (state_cs == LOAD) begin
		case (cnt_state_1)
			0 :  wei_matrix[0][0] <= reg_weight;
			1 :  wei_matrix[0][1] <= reg_weight;
			2 :  wei_matrix[1][0] <= reg_weight;
			3 :  wei_matrix[1][1] <= reg_weight;
			default : begin
				wei_matrix[0][0] <= wei_matrix[0][0];
				wei_matrix[0][1] <= wei_matrix[0][1];
				wei_matrix[1][0] <= wei_matrix[1][0];
				wei_matrix[1][1] <= wei_matrix[1][1];
			end
		endcase
    end
    else if (cnt_state_1 == 4) begin
        for (i = 0; i < 2 ; i = i + 1 ) begin
            for (j = 0; j < 2 ; j = j + 1 ) begin
                wei_matrix [i][j] <= wei_matrix[i][j];
            end
        end
    end
end

always @(posedge G_clock_load_kernal or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_1_ker_y <= 0;
	end
	else if (state_cs == IDLE) begin
		cnt_state_1_ker_y <= 0;
	end
	else begin
		if (cnt_state_1_ker_x[1]) begin
			if (cnt_state_1_ker_y[1]) cnt_state_1_ker_y <= 0;
			else cnt_state_1_ker_y <= cnt_state_1_ker_y + 1;
		end
		else cnt_state_1_ker_y <= cnt_state_1_ker_y;
	end
end

always @(posedge G_clock_load_kernal or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_1_ker_x <= 0;
	end
	else if (state_cs == IDLE) begin
		cnt_state_1_ker_x <= 0;
	end
	else begin
		if (cnt_state_1_ker_x[1]) cnt_state_1_ker_x <= 0;
		else cnt_state_1_ker_x <= cnt_state_1_ker_x + 1;
	end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 3 ; i = i + 1 ) begin
            for (j = 0; j < 3 ; j = j + 1 ) begin
                ker_matrix [i][j] <= 0;
            end
        end
    end
    else if (state_cs == LOAD && cnt_state_1 < 9) begin
        ker_matrix[cnt_state_1_ker_y][cnt_state_1_ker_x] <= reg_ker;
    end
end

// =========== input ============= //
wire ctrl_con = (state_cs == CON || state_cs == OUT) ? 1'b0 : 1'b1;
wire G_sleep_con = (cg_en && started)? ctrl_con : 1'b0;
wire G_clock_con;
GATED_OR con_GATE( .CLOCK(clk), .SLEEP_CTRL(G_sleep_con), .RST_N(rst_n), .CLOCK_GATED(G_clock_con) );

wire ctrl_con_out = ((state_cs == CON && cnt_state_2 > 2) || state_cs == OUT) ? 1'b0 : 1'b1;
wire G_sleep_con_out = (cg_en && started)? ctrl_con_out: 1'b0;
wire G_clock_con_out;
GATED_OR con_out_GATE( .CLOCK(clk), .SLEEP_CTRL(G_sleep_con_out), .RST_N(rst_n), .CLOCK_GATED(G_clock_con_out) );
// ============ CONVOLUTION =========== //
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		scale <= 0;
	end
	else if (cg_en == 0) begin
		if (state_cs == CON) begin
			scale <= 12'd2295;
		end
		else if (state_cs == FULLY) begin
			scale <= 12'd510;
		end
		else scale <= scale;
	end
	else scale <= 0;
	// if (state_cs == CON) begin
	// 	scale <= 12'd2295;
	// end
	// else if (state_cs == FULLY) begin
	// 	scale <= 12'd510;
	// end
	// else scale <= scale;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		flag_scale <= 0;
	end
	else if (state_cs == 2) begin
		flag_scale <= 1;
	end
	else if (state_cs == 4) begin
		flag_scale <= 1;
	end
	else flag_scale <= 0;
end

always @(posedge G_clock_con or negedge rst_n) begin
	if (!rst_n) begin
		img_con_0 <= 0;
		img_con_1 <= 0;
		img_con_2 <= 0;
		img_con_3 <= 0;
		img_con_4 <= 0;
		img_con_5 <= 0;
		img_con_6 <= 0;
		img_con_7 <= 0;
		img_con_8 <= 0;
	end
	else if (state_cs == CON) begin
		if (!flar_state_2) begin
			img_con_0 <= img_matrix1[0 + cnt_state_2_y][0 + cnt_state_2_x];
			img_con_1 <= img_matrix1[0 + cnt_state_2_y][1 + cnt_state_2_x];
			img_con_2 <= img_matrix1[0 + cnt_state_2_y][2 + cnt_state_2_x];
			img_con_3 <= img_matrix1[1 + cnt_state_2_y][0 + cnt_state_2_x];
			img_con_4 <= img_matrix1[1 + cnt_state_2_y][1 + cnt_state_2_x];
			img_con_5 <= img_matrix1[1 + cnt_state_2_y][2 + cnt_state_2_x];
			img_con_6 <= img_matrix1[2 + cnt_state_2_y][0 + cnt_state_2_x];
			img_con_7 <= img_matrix1[2 + cnt_state_2_y][1 + cnt_state_2_x];
			img_con_8 <= img_matrix1[2 + cnt_state_2_y][2 + cnt_state_2_x];
		end
		else begin
			img_con_0 <= img_matrix2[0 + cnt_state_2_y][0 + cnt_state_2_x];
			img_con_1 <= img_matrix2[0 + cnt_state_2_y][1 + cnt_state_2_x];
			img_con_2 <= img_matrix2[0 + cnt_state_2_y][2 + cnt_state_2_x];
			img_con_3 <= img_matrix2[1 + cnt_state_2_y][0 + cnt_state_2_x];
			img_con_4 <= img_matrix2[1 + cnt_state_2_y][1 + cnt_state_2_x];
			img_con_5 <= img_matrix2[1 + cnt_state_2_y][2 + cnt_state_2_x];
			img_con_6 <= img_matrix2[2 + cnt_state_2_y][0 + cnt_state_2_x];
			img_con_7 <= img_matrix2[2 + cnt_state_2_y][1 + cnt_state_2_x];
			img_con_8 <= img_matrix2[2 + cnt_state_2_y][2 + cnt_state_2_x];
		end
	end
end

always @(posedge G_clock_con or negedge rst_n) begin
	if (!rst_n) begin
		ker_con_0 <= 0;
		ker_con_1 <= 0;
		ker_con_2 <= 0;
		ker_con_3 <= 0;
		ker_con_4 <= 0;
		ker_con_5 <= 0;
		ker_con_6 <= 0;
		ker_con_7 <= 0;
		ker_con_8 <= 0;
	end
	else if (state_cs == CON) begin
		ker_con_0 <= ker_matrix[0][0];
		ker_con_1 <= ker_matrix[0][1];
		ker_con_2 <= ker_matrix[0][2];
		ker_con_3 <= ker_matrix[1][0];
		ker_con_4 <= ker_matrix[1][1];
		ker_con_5 <= ker_matrix[1][2];
		ker_con_6 <= ker_matrix[2][0];
		ker_con_7 <= ker_matrix[2][1];
		ker_con_8 <= ker_matrix[2][2];
	end
end
 
always @(posedge G_clock_con or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_2_x <= 0;
	end
	else if (state_cs == CON) begin
		if (cnt_state_2_x == 3) cnt_state_2_x <= 0;
		else cnt_state_2_x <= cnt_state_2_x + 1;
	end
	else cnt_state_2_x <= 0;
end

always @(posedge G_clock_con or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_2_y <= 0;
	end
	else if (state_cs == CON) begin
		if (cnt_state_2_x == 3) begin
			if (cnt_state_2_y == 3) begin
				cnt_state_2_y <= 0;
			end
			else cnt_state_2_y <= cnt_state_2_y + 1;
		end
		else cnt_state_2_y <= cnt_state_2_y;
	end
	else cnt_state_2_y <= 0;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		flar_state_2 <= 0;
	end
	else if (state_cs == CON) begin
		if (cnt_state_2_x == 3 && cnt_state_2_y == 3) begin
			flar_state_2 <= 1;
		end
		else flar_state_2 <= flar_state_2;
	end
	else flar_state_2 <= 0;
end

always @(*) begin
	mul_con_0 = img_con_0 * ker_con_0;
	mul_con_1 = img_con_1 * ker_con_1;
	mul_con_2 = img_con_2 * ker_con_2;
	mul_con_3 = img_con_3 * ker_con_3;
	mul_con_4 = img_con_4 * ker_con_4;
	mul_con_5 = img_con_5 * ker_con_5;
	mul_con_6 = img_con_6 * ker_con_6;
	mul_con_7 = img_con_7 * ker_con_7;
	mul_con_8 = img_con_8 * ker_con_8;
end

always @(*) begin
	addr_1 = mul_con_0 + mul_con_1 + mul_con_2;
	addr_2 = mul_con_4 + mul_con_5 + mul_con_3;
	addr_3 = mul_con_7 + mul_con_8 + mul_con_6;
end

always @(posedge G_clock_con or negedge rst_n) begin
	if (!rst_n) begin
		convolution <= 0;
	end
	else if (state_cs == CON) begin
		convolution <= addr_1 + addr_2 + addr_3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		quantization <= 0;
	end
	else if (cg_en == 0) begin
		if (state_cs == CON) quantization <= convolution / scale;
		else if (state_cs == FULLY) quantization <= fully / scale;
	end
	else if (cg_en == 1) begin
		if (state_cs == CON) quantization <= convolution / 12'd2295;
		else if (state_cs == FULLY) quantization <= fully / 12'd510;		
	end
	else quantization <= 0;
end

always @(posedge G_clock_con or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_2 <= 0;
	end
	else if (state_cs == CON) begin
		cnt_state_2 <= cnt_state_2 + 1;
	end
	else cnt_state_2 <= 0;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		flag_state_2_out <= 0;
	end
	else if (cg_en == 0) begin
		if (state_cs == CON) begin
			if (cnt_state_2 < 2) begin
				flag_state_2_out <= 0;
			end
			else flag_state_2_out <= 1;
		end
		else flag_state_2_out <= 0;
	end
	else if (cg_en == 1) begin
		flag_state_2_out <= 0;
	end
end

always @(posedge G_clock_con_out or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_2_out_x <= 0;
	end
	else if (cg_en == 1) begin
		if (state_cs == CON) begin
			if (cnt_state_2_out_x == 3) cnt_state_2_out_x <= 0;
			else cnt_state_2_out_x <= cnt_state_2_out_x + 1;
		end
	end
	else if (cg_en == 0) begin
		if (state_cs == CON) begin
			if (flag_state_2_out) begin
				if (cnt_state_2_out_x == 3) begin
					cnt_state_2_out_x <= 0;
				end
				else cnt_state_2_out_x <= cnt_state_2_out_x + 1;
			end
			else cnt_state_2_out_x <= 0;
		end	
	end
end

always @(posedge G_clock_con_out or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_2_out_y <= 0;
	end
	else if (cg_en == 1) begin
		if (state_cs == CON) begin
			if (cnt_state_2_out_x == 3) cnt_state_2_out_y <= cnt_state_2_out_y + 1;
			else cnt_state_2_out_y <= cnt_state_2_out_y;
		end
	end
	else if (cg_en == 0) begin
		if (state_cs == CON) begin
			if (flag_state_2_out) begin
				if (cnt_state_2_out_x == 3) begin
					cnt_state_2_out_y <= cnt_state_2_out_y + 1;
				end
				else cnt_state_2_out_y <= cnt_state_2_out_y;
			end
			else cnt_state_2_out_y <= 0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		flag_future <= 0;
	end
	else if (state_cs == CON) begin
		if (cnt_state_2_out_x == 3 && cnt_state_2_out_y == 3) begin
			flag_future <= 1;
		end
		else flag_future <= flag_future;
	end
	else flag_future <= 0;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
        for (i = 0; i < 4 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
            	featuremap1[i][j] <= 0;
            end
        end
	end
	else if (state_cs == CON) begin
		if (!flag_future) begin
			featuremap1[cnt_state_2_out_y][cnt_state_2_out_x] <= quantization;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
        for (i = 0; i < 4 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
            	featuremap2[i][j] <= 0;
            end
        end
	end
	else if (state_cs == CON) begin
		if (flag_future) begin
			featuremap2[cnt_state_2_out_y][cnt_state_2_out_x] <= quantization;
		end
	end
end
// ============ CONVOLUTION =========== //
wire ctrl_max = (state_cs == MAXP || state_cs == OUT) ? 1'b0 : 1'b1;
wire G_sleep_max = (cg_en && started)? ctrl_max : 1'b0;
wire G_clock_max;
GATED_OR max_GATE( .CLOCK(clk), .SLEEP_CTRL(G_sleep_max), .RST_N(rst_n), .CLOCK_GATED(G_clock_max));

wire ctrl_max_in = ((state_cs == MAXP && cnt_state_3_x &&cnt_state_3_y) || state_cs == OUT) ? 1'b0 : 1'b1;
wire G_sleep_max_in = (cg_en && started)? ctrl_max_in : 1'b0;
wire G_clock_max_in;
GATED_OR max_in_GATE( .CLOCK(clk), .SLEEP_CTRL(G_sleep_max_in), .RST_N(rst_n), .CLOCK_GATED(G_clock_max_in));

wire ctrl_max_out = ((state_cs == MAXP && cnt_state_3 != 0 && !cnt_3) || state_cs == OUT) ? 1'b0 : 1'b1;
wire G_sleep_max_out = (cg_en && started)? ctrl_max_out : 1'b0;
wire G_clock_max_out;
GATED_OR max_out_GATE( .CLOCK(clk), .SLEEP_CTRL(G_sleep_max_out), .RST_N(rst_n), .CLOCK_GATED(G_clock_max_out));
// ============= MAXPOOLING ============= //
always @(posedge G_clock_max or negedge rst_n) begin
	if (!rst_n) begin
		cnt_3 <= 0;
	end
	else if (cg_en == 0) begin
		if (cnt_state_2 == 34) begin
			cnt_3 <= 0;
		end
		else cnt_3 <= cnt_3 + 1;
	end
	else if (cg_en == 1) begin
		if (state_cs == MAXP) begin
			cnt_3 <= cnt_3 + 1;
		end
		else cnt_3 <= 0;
	end
	else cnt_3 <= 0;
end

always @(posedge G_clock_max or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_3 <= 0;
	end
	else if (cg_en == 0) begin
		if (cnt_state_2 == 34) begin
			cnt_state_3 <= 0;
		end
		else cnt_state_3 <= cnt_state_3 + 1;
	end
	else if (cg_en == 1) begin
		if (state_cs == MAXP) begin
			cnt_state_3 <= cnt_state_3 + 1;
		end
		else cnt_state_3 <= 0;
	end
	else cnt_state_3 <= 0;
end

always @(posedge G_clock_max or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_3_x <= 0;
	end
	else if (cg_en == 0) begin
		if (cnt_state_2 == 34) begin
			cnt_state_3_x <= 0;
		end
		else cnt_state_3_x <= cnt_state_3_x + 1;
	end
	else if (cg_en == 1) begin
		if (state_cs == MAXP) begin
			cnt_state_3_x <= cnt_state_3_x + 1;
		end
		else cnt_state_3_x <= 0;
	end
	else cnt_state_3_x <= 0;
end

always @(posedge G_clock_max or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_3_y <= 0;
	end
	else if (cg_en == 0) begin
		if (cnt_state_2 == 34) begin
			cnt_state_3_y <= 0;
		end
		else begin
			if (cnt_state_3_x) cnt_state_3_y <= cnt_state_3_y + 1;
			else cnt_state_3_y <= cnt_state_3_y;
		end
	end
	else if (cg_en == 1) begin
		if (state_cs == MAXP) begin
			if (cnt_state_3_x) cnt_state_3_y <= cnt_state_3_y + 1;
			else cnt_state_3_y <= cnt_state_3_y;
		end
		else cnt_state_3_y <= 0;
	end
	else cnt_state_3_y <= 0;
end

always @(posedge G_clock_max_in or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_3_in_x <= 0;
	end
	else if (cg_en == 0) begin
		if (cnt_state_2 == 34) begin
			cnt_state_3_in_x <= 0;
		end
		else begin
			if (cnt_state_3_x &&cnt_state_3_y) begin
				cnt_state_3_in_x <= cnt_state_3_in_x + 2;
			end
			else cnt_state_3_in_x <= cnt_state_3_in_x;
		end
	end
	else if (cg_en == 1) begin
		if (state_cs == MAXP) begin
			if (cnt_state_3_x &&cnt_state_3_y) begin
				cnt_state_3_in_x <= cnt_state_3_in_x + 2;
			end
			else cnt_state_3_in_x <= cnt_state_3_in_x;
		end
		else cnt_state_3_in_x <= 0;
	end
	else cnt_state_3_in_x <= 0;
end

always @(posedge G_clock_max_in or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_3_in_y <= 0;
	end
	else if (state_cs == MAXP) begin
		if (cnt_state_3_x &&cnt_state_3_y) begin
			if (cnt_state_3_in_x)cnt_state_3_in_y <= cnt_state_3_in_y + 2;
			else cnt_state_3_in_y <= cnt_state_3_in_y;
		end
		else cnt_state_3_in_y <= cnt_state_3_in_y;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		flag_max <= 0;
	end
	else if (state_cs == MAXP) begin
		if (cnt_state_3 == 15) begin
			flag_max <= 1;
		end
		else flag_max <= flag_max;
	end
	else flag_max <= 0;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		flag_max_d <= 0;
	end
	else flag_max_d <= flag_max;
end
always @(posedge G_clock_max or negedge rst_n) begin
	if (!rst_n) begin
		compare_a <= 0;
	end
	else if (state_cs == MAXP) begin
		if (!flag_max) begin
			compare_a <= featuremap1[cnt_state_3_y + cnt_state_3_in_y][cnt_state_3_x + cnt_state_3_in_x];
		end
		else compare_a <= featuremap2[cnt_state_3_y + cnt_state_3_in_y][cnt_state_3_x + cnt_state_3_in_x];
	end
end

always @(posedge G_clock_max or negedge rst_n) begin
	if (!rst_n) begin
		compare <= 0;
	end
	else if (state_cs == MAXP) begin
		if (cnt_3 == 0) begin
			compare <= 0;
		end
		else compare <= max_seq;
	end
	else compare <= max_seq;
end

always @(*) begin
	if (!rst_n) begin
		max_seq = 0;
	end
	else if (state_cs == MAXP) begin
		if (compare_a > compare) begin
			max_seq = compare_a;
		end
		else max_seq = compare;
	end
	else max_seq = 0;
end

always @(posedge G_clock_max_out or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_3_out_x <= 0;
	end
	else if (state_cs == MAXP) begin
		if (cnt_state_3 != 0) begin
			if (!cnt_3) begin
				cnt_state_3_out_x <= cnt_state_3_out_x + 1;
			end
			else cnt_state_3_out_x <= cnt_state_3_out_x;
		end
		else cnt_state_3_out_x <= 0;
	end
end

always @(posedge G_clock_max_out or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_3_out_y <= 0;
	end
	else if (state_cs == MAXP) begin
		if (cnt_state_3 != 0) begin
			if (!cnt_3 && cnt_state_3_out_x) begin
				cnt_state_3_out_y <= cnt_state_3_out_y + 1;
			end
			else cnt_state_3_out_y <= cnt_state_3_out_y;
		end
		else cnt_state_3_out_y <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
        for (i = 0; i < 2 ; i = i + 1 ) begin
            for (j = 0; j < 2 ; j = j + 1 ) begin
                max_matrix1[i][j] <= 0;
            end
        end
	end
	else if (state_cs == MAXP) begin
		if (!flag_max_d) begin
			if (cnt_3 == 3) begin
				max_matrix1[cnt_state_3_out_y][cnt_state_3_out_x] <= max_seq;
			end
			else max_matrix1[cnt_state_3_out_y][cnt_state_3_out_x] <= max_seq;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
        for (i = 0; i < 2 ; i = i + 1 ) begin
            for (j = 0; j < 2 ; j = j + 1 ) begin
                max_matrix2[i][j] <= 0;
            end
        end
	end
	else if (state_cs == MAXP) begin
		if (flag_max_d) begin
			if (cnt_3 == 3) begin
				max_matrix2[cnt_state_3_out_y][cnt_state_3_out_x] <= max_seq;
			end
			else max_matrix2[cnt_state_3_out_y][cnt_state_3_out_x] <= max_seq;
		end
	end
end
// ============= MAXPOOLING ============= //
wire ctrl_fully = (state_cs == FULLY || state_cs == OUT) ? 1'b0 : 1'b1;
wire G_sleep_fully = (cg_en && started)? ctrl_fully : 1'b0;
wire G_clock_fully;
GATED_OR fully_GATE( .CLOCK(clk), .SLEEP_CTRL(G_sleep_fully), .RST_N(rst_n), .CLOCK_GATED(G_clock_fully));

wire ctrl_fully_out = ((state_cs == FULLY && flag_fully_out && cnt_state_4[0] == 0) || state_cs == OUT) ? 1'b0 : 1'b1;
wire G_sleep_fully_out = (cg_en && started)? ctrl_fully_out : 1'b0;
wire G_clock_fully_out;
GATED_OR fully_out_GATE( .CLOCK(clk), .SLEEP_CTRL(G_sleep_fully_out), .RST_N(rst_n), .CLOCK_GATED(G_clock_fully_out));
// =========== fully =========== //
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		flag_fully_d <= 0;
	end
	else if (state_cs == FULLY) begin
		flag_fully_d <= flag_fully;
	end
end

always @(posedge G_clock_fully or negedge rst_n) begin
	if (!rst_n) begin
		cnt_4 <= 0;
	end
	else if (cg_en == 0) begin
		if (cnt_state_3 == 32) begin
			cnt_4 <= 0;
		end
		else cnt_4 <= cnt_4 + 1;
	end
	else if (cg_en == 1) begin
		if (state_cs == FULLY) begin
			cnt_4 <= cnt_4 + 1;
		end
		else cnt_4 <= 0;
	end
	else cnt_4 <= 0;
end

always @(posedge G_clock_fully or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_4 <= 0;
	end
	else if (cg_en == 0) begin
		if (cnt_state_3 == 32) begin
			cnt_state_4 <= 0;
		end
		else cnt_state_4 <= cnt_state_4 + 1;
	end
	else if (cg_en == 1) begin
		if (state_cs == FULLY) begin
			cnt_state_4 <= cnt_state_4 + 1;
		end
		else cnt_state_4 <= 0;
	end
	else cnt_state_4 <= 0;
end

always @(posedge G_clock_fully or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_4_in_x <= 0;
	end
	else if (cg_en == 0) begin
		if (cnt_state_3 == 32) begin
			cnt_state_4_in_x <= 0;
		end
		else cnt_state_4_in_x <= cnt_state_4_in_x + 1;
	end
	else if (cg_en == 1) begin
		if (state_cs == FULLY) begin
			cnt_state_4_in_x <= cnt_state_4_in_x + 1;
		end
		else cnt_state_4_in_x <= 0;
	end
	else cnt_state_4_in_x <= 0;
 end

always @(posedge G_clock_fully or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_4_in_y <= 0;
	end
	else if (cg_en == 0) begin
		if (cnt_state_3 == 32) begin
			cnt_state_4_in_y <= 0;
		end
		else begin 
			if (cnt_state_4 == 3) begin
				cnt_state_4_in_y <= cnt_state_4_in_y + 1;
			end
			else cnt_state_4_in_y <= cnt_state_4_in_y;
		end
	end
	else if (cg_en == 1) begin
		if (state_cs == FULLY) begin
			if (cnt_state_4 == 3) begin
				cnt_state_4_in_y <= cnt_state_4_in_y + 1;
			end
			else cnt_state_4_in_y <= cnt_state_4_in_y;
		end
		else cnt_state_4_in_y <= 0;
	end
	else cnt_state_4_in_y <= 0;
end

always @(posedge G_clock_fully or negedge rst_n) begin
	if (!rst_n) begin
		flag_fully <= 0;
	end
	else if (state_cs == FULLY) begin
		if (cnt_state_4_in_x && cnt_state_4_in_y && cnt_state_4 == 3) begin
			flag_fully <= 1;
		end
		else flag_fully <= flag_fully;
	end
	else flag_fully <= 0;
end
always @(posedge G_clock_fully or negedge rst_n) begin
	if (!rst_n) begin
		max_input <= 0;
	end
	else if (state_cs == FULLY) begin
		if (!flag_fully) max_input <= max_matrix1[cnt_state_4_in_y][cnt_state_4_in_x];
		else max_input <= max_matrix2[cnt_state_4_in_y][cnt_state_4_in_x];
	end
end

always @(posedge G_clock_fully or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_4_weight_in_y <= 0;
	end
	else if (cg_en == 0) begin
		if (cnt_state_3 == 32) begin
			cnt_state_4_weight_in_y <= 0;
		end
		else begin 
			if (cnt_state_4[0]) cnt_state_4_weight_in_y <= cnt_state_4_weight_in_y + 1;
			else cnt_state_4_weight_in_y <= cnt_state_4_weight_in_y;
		end
	end
	else if (cg_en == 1) begin
		if (state_cs == FULLY) begin
			if (cnt_state_4[0]) cnt_state_4_weight_in_y <= cnt_state_4_weight_in_y + 1;
			else cnt_state_4_weight_in_y <= cnt_state_4_weight_in_y;
		end
		else cnt_state_4_weight_in_y <= 0;
	end
	else cnt_state_4_weight_in_y <= 0;
end

always @(posedge G_clock_fully or negedge rst_n) begin
	if (!rst_n) begin
		weight_input <= 0;
	end
	else if (state_cs == FULLY) begin
		weight_input <= wei_matrix[cnt_state_4_in_x][cnt_state_4_weight_in_y];
	end
end

always @(posedge G_clock_fully or negedge rst_n) begin
	if (!rst_n) begin
		multi_max <= 0;
	end
	else if (state_cs == FULLY) begin
		multi_max <= max_input * weight_input;
	end
end

always @(posedge G_clock_fully or negedge rst_n) begin
	if (!rst_n) begin
		adder_max <= 0;
	end
	else if (state_cs == FULLY) begin
		if (cnt_state_4[0]) begin
			adder_max <= 0;
		end
		else adder_max <= multi_max;
	end
end

always @(*) begin
	fully = adder_max + multi_max;
end


always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		flag_fully_out <= 0;
	end
	else if (state_cs == FULLY) begin
		if (cnt_4[1]) begin
			flag_fully_out <= 1;
		end
		else flag_fully_out <= flag_fully_out;
	end
	else if (state_cs == OUT)flag_fully_out <= 0;
end

always @(posedge G_clock_fully_out or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_4_out <= 0;
	end
	else if (state_cs == FULLY) begin
		if (flag_fully_out) begin
			if (!cnt_state_4[0]) begin
				cnt_state_4_out <= cnt_state_4_out + 1;
			end
			else cnt_state_4_out <= cnt_state_4_out;
		end
		else cnt_state_4_out <= 0;
	end
	else if (state_cs == OUT) begin
		cnt_state_4_out <= 0;
	end	
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 4 ; i = i + 1 ) begin
			fullymatrix1[i] <= 0;
		end
	end
	else if (state_cs == FULLY) begin
		if (cnt_4 <= 10) begin
			fullymatrix1[cnt_state_4_out] <= quantization;
		end
		else fullymatrix1[cnt_state_4_out] <= fullymatrix1[cnt_state_4_out];
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 4 ; i = i + 1 ) begin
			fullymatrix2[i] <= 0;
		end
	end
	else if (state_cs == FULLY) begin
		if (cnt_4 >= 10) begin
			fullymatrix2[cnt_state_4_out] <= quantization;
		end
		else fullymatrix2[cnt_state_4_out] <= fullymatrix2[cnt_state_4_out];
	end
end
// =========== fully =========== //
wire ctrl_l1 = (state_cs == NOR || state_cs == OUT) ? 1'b0 : 1'b1;
wire G_sleep_l1 = (cg_en && started)? ctrl_l1 : 1'b0;
wire G_clock_l1;
GATED_OR l1_GATE( .CLOCK(clk), .SLEEP_CTRL(G_sleep_l1), .RST_N(rst_n), .CLOCK_GATED(G_clock_l1));
// ==================== li distance ============== //
always @(posedge G_clock_l1 or negedge rst_n) begin
	if (!rst_n) begin
		cnt_5 <= 0;
	end
	else if (state_cs == NOR) begin
		cnt_5 <= cnt_5 + 1;
	end
	else cnt_5 <= 0;
end

always @(posedge G_clock_l1 or negedge rst_n) begin
	if (!rst_n) begin
		cnt_state_5 <= 0;
	end
	else if (state_cs == NOR) begin
		cnt_state_5 <= cnt_state_5 + 1;
	end
	else cnt_state_5 <= 0;
end

always @(posedge G_clock_l1 or negedge rst_n) begin
	if (!rst_n) begin
		q1 <= 0;
	end
	else if (cnt_4 == 20) begin
		q1 <= 0;
	end
	else if (state_cs == NOR) begin
		q1 <= fullymatrix1[cnt_state_5];
	end
end

always @(posedge G_clock_l1 or negedge rst_n) begin
	if (!rst_n) begin
		q2 <= 0;
	end
	else if (state_cs == NOR) begin
		q2 <= fullymatrix2[cnt_state_5];
	end
end

always @(posedge G_clock_l1 or negedge rst_n) begin
	if (!rst_n) begin
		sub <= 0;
	end
	else if (state_cs == NOR) begin
		if (q1 > q2) begin
			sub <= q1 - q2;
		end
		else sub <= q2 - q1;
	end
end

always @(posedge G_clock_l1 or negedge rst_n) begin
	if (!rst_n) begin
		addr_l1 <= 0;
	end
	else if (state_cs == NOR) begin
		if (cnt_5 == 1) begin
			addr_l1 <= 0;
		end
		else addr_l1 <= addr_l1 + sub;
	end
	else addr_l1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_temp <= 0;
	end
	else if (state_cs == NOR && state_ns == NOR) begin
		out_temp <= addr_l1 + sub;
	end
	// else if (cnt_5 == 6) begin
	// 	out_temp <= out_temp;
	// end
	else out_temp <= 0;
end
// ==================== li distance ============== //
wire ctrl_out = ((state_cs == NOR && cnt_5 >= 5) || state_cs == OUT || state_cs == IDLE) ? 1'b0 : 1'b1;
wire G_sleep_out = (cg_en && started)? ctrl_out : 1'b0;
wire G_clock_out;
GATED_OR out_GATE( .CLOCK(clk), .SLEEP_CTRL(G_sleep_out), .RST_N(rst_n), .CLOCK_GATED(G_clock_out));

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		wait_out <= 0;
	end
	else if (cnt_5 == 6) begin
		// wait_out <= out_temp;
		if (out_temp < 16) begin
			wait_out <= 0;
		end
		else wait_out <= out_temp;
	end
	else wait_out <= 0;
end
// ========== output ============ //

// wire ctrl_out = ((state_cs == NOR && cnt_5 >= 5) || state_cs == OUT || state_cs == IDLE) ? 1'b0 : 1'b1;
// wire G_sleep_out = (cg_en && started)? ctrl_out : 1'b0;
// wire G_clock_out;
// GATED_OR out_GATE( .CLOCK(clk), .SLEEP_CTRL(G_sleep_out), .RST_N(rst_n), .CLOCK_GATED(G_clock_out));

always @(posedge G_clock_out or negedge rst_n) begin
	if (!rst_n) begin
		out_valid <= 1'b0;
	end
	else if (state_cs == OUT) begin
		out_valid <= 1'b1;
	end
	else out_valid <= 1'b0;
end

always @(posedge G_clock_out or negedge rst_n) begin
	if (!rst_n) begin
		out_data <= 0;
	end
	else if (state_cs == OUT) begin
		// if (out_temp < 16) begin
		// 	out_data <= 0;
		// end
		// else out_data <= out_temp;
		out_data <= wait_out;
	end
	else out_data <= 0;
end
// ========== output ============ //


endmodule