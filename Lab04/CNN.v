module CNN(
    //Input Port
    clk,
    rst_n,
    in_valid,
    Img,
    Kernel,
	Weight,
    Opt,

    //Output Port
    out_valid,
    out
    );


//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;

input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] Img, Kernel, Weight;
input [1:0] Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;
// reg ------------------------------------------------------------------ reg //
reg in_valid_d;
reg [1:0] reg_opt;
reg [inst_sig_width+inst_exp_width:0] reg_Img, reg_Kernel, reg_Weight;
reg [inst_sig_width+inst_exp_width:0] Img1[0:3][0:3];
reg [inst_sig_width+inst_exp_width:0] Img2[0:3][0:3];
reg [inst_sig_width+inst_exp_width:0] Img3[0:3][0:3];
reg [inst_sig_width+inst_exp_width:0] Kernel1[0:2][0:2];
reg [inst_sig_width+inst_exp_width:0] Kernel2[0:2][0:2];
reg [inst_sig_width+inst_exp_width:0] Kernel3[0:2][0:2];
reg [inst_sig_width+inst_exp_width:0] reg_weight[0:1][0:1];

reg [inst_sig_width+inst_exp_width:0] padding1[0:5][0:5];
reg [inst_sig_width+inst_exp_width:0] padding2[0:5][0:5];
reg [inst_sig_width+inst_exp_width:0] padding3[0:5][0:5];

reg [inst_sig_width+inst_exp_width:0] featuremap1[0:3][0:3];
reg [inst_sig_width+inst_exp_width:0] featuremap2[0:3][0:3];
reg [inst_sig_width+inst_exp_width:0] featuremap3[0:3][0:3];
reg [inst_sig_width+inst_exp_width:0] featuremap[0:3][0:3];

reg [15:0] cnt;

reg [inst_sig_width+inst_exp_width:0] test1;
reg [inst_sig_width+inst_exp_width:0] test2;
reg [inst_sig_width+inst_exp_width:0] test3;
reg [inst_sig_width+inst_exp_width:0] test4;
reg [inst_sig_width+inst_exp_width:0] test5;
reg [inst_sig_width+inst_exp_width:0] test6;
reg [inst_sig_width+inst_exp_width:0] test7;
reg [inst_sig_width+inst_exp_width:0] test8;
reg [inst_sig_width+inst_exp_width:0] test9;

reg [inst_sig_width+inst_exp_width:0] test1_1;
reg [inst_sig_width+inst_exp_width:0] test1_2;
reg [inst_sig_width+inst_exp_width:0] test1_3;
reg [inst_sig_width+inst_exp_width:0] test1_4;
reg [inst_sig_width+inst_exp_width:0] test1_5;
reg [inst_sig_width+inst_exp_width:0] test1_6;
reg [inst_sig_width+inst_exp_width:0] test1_7;
reg [inst_sig_width+inst_exp_width:0] test1_8;
reg [inst_sig_width+inst_exp_width:0] test1_9;

reg [inst_sig_width+inst_exp_width:0] test2_1;
reg [inst_sig_width+inst_exp_width:0] test2_2;
reg [inst_sig_width+inst_exp_width:0] test2_3;
reg [inst_sig_width+inst_exp_width:0] test2_4;
reg [inst_sig_width+inst_exp_width:0] test2_5;
reg [inst_sig_width+inst_exp_width:0] test2_6;
reg [inst_sig_width+inst_exp_width:0] test2_7;
reg [inst_sig_width+inst_exp_width:0] test2_8;
reg [inst_sig_width+inst_exp_width:0] test2_9;
reg [inst_sig_width+inst_exp_width:0] test2_10;
reg [inst_sig_width+inst_exp_width:0] test2_11;
reg [inst_sig_width+inst_exp_width:0] test2_12;
reg [inst_sig_width+inst_exp_width:0] test2_13;

reg [inst_sig_width+inst_exp_width:0] test3_1;
reg [inst_sig_width+inst_exp_width:0] test3_2;
reg [inst_sig_width+inst_exp_width:0] test3_3;
reg [inst_sig_width+inst_exp_width:0] test3_4;
reg [inst_sig_width+inst_exp_width:0] test3_5;
reg [inst_sig_width+inst_exp_width:0] test3_6;
reg [inst_sig_width+inst_exp_width:0] test3_7;
reg [inst_sig_width+inst_exp_width:0] test3_8;
reg [inst_sig_width+inst_exp_width:0] test3_9;
reg [inst_sig_width+inst_exp_width:0] test3_10;
reg [inst_sig_width+inst_exp_width:0] test3_11;
reg [inst_sig_width+inst_exp_width:0] test3_12;
reg [inst_sig_width+inst_exp_width:0] test3_13;

reg [inst_sig_width+inst_exp_width:0] test4_1;
reg [inst_sig_width+inst_exp_width:0] test4_2;
reg [inst_sig_width+inst_exp_width:0] test4_3;

reg [inst_sig_width+inst_exp_width:0] feature;

reg [inst_sig_width+inst_exp_width:0] feature1;
reg [inst_sig_width+inst_exp_width:0] feature2;
reg [inst_sig_width+inst_exp_width:0] feature3;
reg [inst_sig_width+inst_exp_width:0] feature4;

wire [inst_sig_width+inst_exp_width:0] max0;
wire [inst_sig_width+inst_exp_width:0] max0_1;

reg [inst_sig_width+inst_exp_width:0] max;

reg [inst_sig_width+inst_exp_width:0] maxpooling[0:1][0:1];

reg [inst_sig_width+inst_exp_width:0] m_wmatrix[0:3];

reg [inst_sig_width+inst_exp_width:0] test;

wire [inst_sig_width+inst_exp_width:0] min0;
wire [inst_sig_width+inst_exp_width:0] min1;
wire [inst_sig_width+inst_exp_width:0] min;

reg [inst_sig_width+inst_exp_width:0] sub_in;
reg [inst_sig_width+inst_exp_width:0] sub_out;
reg [inst_sig_width+inst_exp_width:0] sub_out1;

reg [inst_sig_width+inst_exp_width:0] div_in1;
reg [inst_sig_width+inst_exp_width:0] div_in2;

reg [inst_sig_width+inst_exp_width:0] ln_in;
reg [inst_sig_width+inst_exp_width:0] ln_out;

reg [inst_sig_width+inst_exp_width:0] div_out1;

reg [inst_sig_width+inst_exp_width:0] normalization[0:3];

reg [inst_sig_width+inst_exp_width:0] ans[0:3];

reg [inst_sig_width+inst_exp_width:0] exp_in_1;
reg [inst_sig_width+inst_exp_width:0] exp_out_1;
reg [inst_sig_width+inst_exp_width:0] exp_in_2;
reg [inst_sig_width+inst_exp_width:0] exp_out_2;

reg [3:0] state_cs;
reg [3:0] state_ns;

reg flag;
reg maxflag;
reg flag1;
reg flag0;
reg flag0_1;
reg minflag;

parameter flotingpoint1 = 32'b00111111100000000000000000000000;
parameter flotingpointnegtive1 = 32'b10111111100000000000000000000000;
parameter IDLE = 4'd0;
parameter LOAD = 4'd1;
parameter CON = 4'd2;
parameter MAXP = 4'd3;
parameter FULLY = 4'd4;
parameter NOR = 4'd5;
parameter OUT = 6;

// parameter ------------------------------------------------------ parameter //
integer i, j;
integer k, l;
// adder ------------------------------------------------------------ adder //
DW_fp_sum3 #(23,8,1)   S1( .a(test3_1),.b(test3_2),.c(test3_3),.z(test3_10),.rnd(3'b000) );
DW_fp_sum3 #(23,8,1)   S2( .a(test3_4),.b(test3_5),.c(test3_6),.z(test3_11),.rnd(3'b000) );
DW_fp_sum3 #(23,8,1)   S3( .a(test3_7),.b(test3_8),.c(test3_9),.z(test3_12),.rnd(3'b000) );

DW_fp_sum3 #(23,8,1)   S4( .a(test4_1),.b(test4_2),.c(test4_3),.z(test3_13),.rnd(3'b000) );
// sub --------------------------------------------------------------------------------- sub //
DW_fp_sub #(23, 8, 1)  sub1 ( .a(max), .b(min), .rnd(3'b000), .z(sub_out) );
DW_fp_sub #(23, 8, 1)  sub2 ( .a(sub_in), .b(min), .rnd(3'b000), .z(sub_out1) );
// div -------------------------------------------------------------------------------------- div //
DW_fp_div #(23, 8, 1, 1) div1 ( .a(div_in1), .b(div_in2), .rnd(3'b000), .z(div_out1) );
// Multiplier ------------------------------------------------------- Multiplier //
DW_fp_mult #(23,8,1)    mult0 ( .a(test1),.b(test1_1),.rnd(3'b000),.z(test2_1) );
DW_fp_mult #(23,8,1)    mult1 ( .a(test2),.b(test1_2),.rnd(3'b000),.z(test2_2) );
DW_fp_mult #(23,8,1)    mult2 ( .a(test3),.b(test1_3),.rnd(3'b000),.z(test2_3) );
DW_fp_mult #(23,8,1)    mult3 ( .a(test4),.b(test1_4),.rnd(3'b000),.z(test2_4) );
DW_fp_mult #(23,8,1)    mult4 ( .a(test5),.b(test1_5),.rnd(3'b000),.z(test2_5) );
DW_fp_mult #(23,8,1)    mult5 ( .a(test6),.b(test1_6),.rnd(3'b000),.z(test2_6) );
DW_fp_mult #(23,8,1)    mult6 ( .a(test7),.b(test1_7),.rnd(3'b000),.z(test2_7) );
DW_fp_mult #(23,8,1)    mult7 ( .a(test8),.b(test1_8),.rnd(3'b000),.z(test2_8) );
DW_fp_mult #(23,8,1)    mult8 ( .a(test9),.b(test1_9),.rnd(3'b000),.z(test2_9) );
// comparator -------------------------------------------------------- comparator //
DW_fp_cmp#(inst_sig_width,inst_exp_width,inst_ieee_compliance) 
    C0_1 (.a(feature1), .b(feature2), .agtb(flag0), .zctr(1'd0));
DW_fp_cmp#(inst_sig_width,inst_exp_width,inst_ieee_compliance) 
    C0_2 (.a(feature3), .b(feature4), .agtb(flag0_1), .zctr(1'd0));
DW_fp_cmp#(inst_sig_width,inst_exp_width,inst_ieee_compliance) 
    C0_3 (.a(max0), .b(max0_1), .agtb(maxflag), .zctr(1'd0));
// Exponential ----------------------------------------------------  Exponential //
DW_fp_exp #(23, 8, 1, 1) exp1( .a(exp_in_1), .z(exp_out_1) );
// log ---------------------------------------------------------------- log //
DW_fp_ln #(23, 8, 1, 1) ln1( .a(ln_in), .z(ln_out) );
// cnt ------------------------------------------------------------------ cnt //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end
    else if (in_valid) begin
        cnt <= cnt + 1;
    end
    else if (state_cs == CON) begin
        if (cnt == 50) begin
            cnt <= 0;
        end
        else cnt <= cnt + 1;
    end
    else if (state_cs == MAXP) begin
        if (cnt == 21) begin
            cnt <= 0;
        end
        else cnt <= cnt + 1;
    end
    else if (state_cs == FULLY) begin
        if (cnt == 5) begin
            cnt <= 0;
        end
        else cnt <= cnt + 1;
    end
    else if (state_cs == NOR) begin
        if (cnt == 17) begin
            cnt <= 0;
        end
        else cnt <= cnt + 1;
    end
    else if (state_cs == OUT) begin
        if (cnt == 5) begin
            cnt <= 0;
        end
        else cnt <= cnt + 1;
    end
    else cnt <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_Img <= 0;
        reg_Kernel <= 0;
        reg_Weight <= 0; 
    end
    else begin
        reg_Img <= Img;
        reg_Kernel <= Kernel;
        reg_Weight <= Weight; 
    end
end
// FSM ------------------------------------------------------------------ FSM //
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
            if (in_valid_d == 0) begin
                state_ns = CON;
            end
            else state_ns = LOAD;
        end 
        CON : begin
            if (cnt == 50) begin
                state_ns = MAXP;
            end
            else state_ns = CON;
        end
        MAXP : begin
            if (cnt == 21) begin
                state_ns = FULLY;
            end
            else state_ns = MAXP;
        end
        FULLY : begin
            if (cnt == 5) begin
                state_ns = NOR;
            end
            else state_ns = FULLY;
        end
        NOR : begin
            if (cnt == 17) begin
                state_ns = OUT;
            end
            else state_ns = NOR;
        end
        OUT : begin
            if (cnt == 5) begin
                state_ns = IDLE;
            end
            else state_ns = OUT;
        end
        default: begin
            state_ns = IDLE;
        end
    endcase
end
// input Opt ------------------------------------------------------ input Opt //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_d <= 0;
    end
    else in_valid_d <= in_valid;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_opt <= 0;
    end
    else if (in_valid == 1 && in_valid_d == 0) begin
        reg_opt <= Opt;
    end
    else reg_opt <= reg_opt;
end
// input Img1 ---------------------------------------------------- input Img1 //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 4; i > 0 ; i = i - 1) begin
            for (j = 4; j > 0 ; j = j - 1) begin
                Img1 [i][j] <= 0;
            end
        end
    end
    else if (in_valid == 1 && cnt < 17) begin
        Img1[3][3] <= reg_Img;
        for (i = 0; i < 4 ; i = i + 1) begin
            for (j = 0; j < 4 ; j = j + 1) begin
                Img1[i][j-1] <= Img1[i][j];
                Img1[j-1][3] <= Img1[j][0];
            end
        end
    end
    else if (cnt > 16)begin
        for (i = 0; i < 4 ; i = i + 1) begin
            for (j = 0; j < 4 ; j = j + 1) begin
                Img1[i][j] <= Img1[i][j];
            end
        end
    end
end
// input Img2 ---------------------------------------------------- input Img2 //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag <= 0;
    end
    else if (in_valid && cnt >= 16) begin
        flag <= 1;
    end
    else if (in_valid == 0) begin
        flag <= 0;
    end
    else flag <= flag;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 4; i > 0 ; i = i - 1) begin
            for (j = 4; j > 0 ; j = j - 1) begin
                Img2 [i][j] <= 0;
            end
        end
    end
    else if (flag == 1 && flag1 == 0) begin
        Img2[3][3] <= reg_Img;
        for (i = 0; i < 4 ; i = i + 1) begin
            for (j = 0; j < 4 ; j = j + 1) begin
                Img2[i][j-1] <= Img2[i][j];
                Img2[j-1][3] <= Img2[j][0];
            end
        end
    end
    else if (flag1 == 1)begin
        for (i = 0; i < 4 ; i = i + 1) begin
            for (j = 0; j < 4 ; j = j + 1) begin
                Img2[i][j] <= Img2[i][j];
            end
        end
    end
end
// input Img3 ---------------------------------------------------- input Img3 //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag1 <= 0;
    end
    else if (in_valid && cnt >= 32) begin
        flag1 <= 1;
    end
    else if (in_valid == 0) begin
        flag1 <= 0;
    end
    else flag1 <= flag1;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 4; i > 0 ; i = i - 1) begin
            for (j = 4; j > 0 ; j = j - 1) begin
                Img3 [i][j] <= 0;
            end
        end
    end
    else if (in_valid_d == 1 && flag1 == 1) begin
        Img3[3][3] <= reg_Img;
        for (i = 0; i < 4 ; i = i + 1) begin
            for (j = 0; j < 4 ; j = j + 1) begin
                Img3[i][j-1] <= Img3[i][j];
                Img3[j-1][3] <= Img3[j][0];
            end
        end
    end
    else if (cnt == 48)begin
        for (i = 0; i < 4 ; i = i + 1) begin
            for (j = 0; j < 4 ; j = j + 1) begin
                Img3[i][j] <= Img3[i][j];
            end
        end
    end
end
// input kernel1 ---------------------------------------------------- input kernel1 //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 3; i > 0 ; i = i - 1) begin
            for (j = 3; j > 0 ; j = j - 1) begin
                Kernel1 [i][j] <= 0;
            end
        end
    end
    else if (in_valid == 1 && cnt < 10) begin
        Kernel1[2][2] <= reg_Kernel;
        for (i = 0; i < 3 ; i = i + 1) begin
            for (j = 0; j < 3 ; j = j + 1) begin
                Kernel1[i][j-1] <= Kernel1[i][j];
                Kernel1[j-1][2] <= Kernel1[j][0];
            end
        end
    end
    else if (cnt > 9)begin
        for (i = 0; i < 3 ; i = i + 1) begin
            for (j = 0; j < 3 ; j = j + 1) begin
                Kernel1[i][j] <= Kernel1[i][j];
            end
        end
    end
end
// input kernel2 ---------------------------------------------------- input kernel2 //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 3; i > 0 ; i = i - 1) begin
            for (j = 3; j > 0 ; j = j - 1) begin
                Kernel2 [i][j] <= 0;
            end
        end
    end
    else if (in_valid == 1 && cnt > 9 && cnt < 19) begin
        Kernel2[2][2] <= reg_Kernel;
        for (i = 0; i < 3 ; i = i + 1) begin
            for (j = 0; j < 3 ; j = j + 1) begin
                Kernel2[i][j-1] <= Kernel2[i][j];
                Kernel2[j-1][2] <= Kernel2[j][0];
            end
        end
    end
    else if (cnt > 18)begin
        for (i = 0; i < 3 ; i = i + 1) begin
            for (j = 0; j < 3 ; j = j + 1) begin
                Kernel2[i][j] <= Kernel2[i][j];
            end
        end
    end
end
// input kernel3 ---------------------------------------------------- input kernel3 //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 3; i > 0 ; i = i - 1) begin
            for (j = 3; j > 0 ; j = j - 1) begin
                Kernel3 [i][j] <= 0;
            end
        end
    end
    else if (in_valid == 1 && cnt > 18 && cnt < 28) begin
        Kernel3[2][2] <= reg_Kernel;
        for (i = 0; i < 3 ; i = i + 1) begin
            for (j = 0; j < 3 ; j = j + 1) begin
                Kernel3[i][j-1] <= Kernel3[i][j];
                Kernel3[j-1][2] <= Kernel3[j][0];
            end
        end
    end
    else if (cnt > 27)begin
        for (i = 0; i < 3 ; i = i + 1) begin
            for (j = 0; j < 3 ; j = j + 1) begin
                Kernel3[i][j] <= Kernel3[i][j];
            end
        end
    end
end
// input weight ---------------------------------------------------- input weight //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 2 ; i = i + 1 ) begin
            for (j = 0; j < 2 ; j = j + 1 ) begin
                reg_weight [i][j] <= 0;
            end
        end
    end
    else if (in_valid && cnt < 5) begin
        reg_weight[1][1] <= reg_Weight;
        for (i = 0; i < 2 ; i = i + 1 ) begin
            for (j = 0; j < 2 ; j = j + 1 ) begin
                reg_weight[i][j-1] <= reg_weight[i][j];
                reg_weight[j-1][1] <= reg_weight[j][0];
            end
        end
    end
    else if (cnt == 5) begin
        for (i = 0; i < 2 ; i = i + 1 ) begin
            for (j = 0; j < 2 ; j = j + 1 ) begin
                reg_weight [i][j] <= reg_weight[i][j];
            end
        end
    end
end
// padding1 --------------------------------padding1 //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 6 ; i = i + 1) begin
            for (j = 0; j < 6 ; j = j + 1) begin
                padding1 [i][j] <= 0;
            end
        end
    end
    else if (reg_opt[1] == 1 && flag == 1) begin
        for (j = 0; j < 4 ; j = j + 1) begin
            padding1 [0][j + 1] <= Img1[0][j];
        end
        for (i = 0; i < 4 ; i = i + 1) begin
            padding1 [5][i + 1] <= Img1[3][i];
        end
        for (k = 0; k < 4 ; k = k + 1) begin
            padding1 [k + 1][0] <= Img1[k][0];
        end
        for (l = 0; l < 4 ; l = l + 1) begin
            padding1 [l + 1][5] <= Img1[l][3];
        end
        padding1 [0][0] <= Img1[0][0];
        padding1 [0][5] <= Img1[0][3];
        padding1 [5][0] <= Img1[3][0];
        padding1 [5][5] <= Img1[3][3];
        for (i = 1; i < 5 ; i = i + 1) begin
            for (j = 1; j < 5 ; j = j + 1) begin
                padding1 [i][j] <= Img1[i - 1][j - 1];
            end
        end
    end
    else if (reg_opt[1] == 0 && flag) begin
        for (i = 1; i < 5 ; i = i + 1) begin
            for (j = 1; j < 5 ; j = j + 1) begin
                padding1 [i][j] <= Img1[i - 1][j - 1];
            end
        end
    end
    else if (state_cs == 0) begin
        for (i = 0; i < 6 ; i = i + 1) begin
            for (j = 0; j < 6 ; j = j + 1) begin
                padding1 [i][j] <= 0;
            end
        end
    end
    else begin
        for (i = 1; i < 5 ; i = i + 1) begin
            for (j = 1; j < 5 ; j = j + 1) begin
                padding1 [i][j] <= padding1[i][j];
            end
        end
    end
end
// padding2 -------------------------------- padding2 //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 6 ; i = i + 1) begin
            for (j = 0; j < 6 ; j = j + 1) begin
                padding2 [i][j] <= 0;
            end
        end
    end
    else if (reg_opt[1] == 1 && flag1 == 1) begin
        for (j = 0; j < 4 ; j = j + 1) begin
            padding2 [0][j + 1] <= Img2[0][j];
        end
        for (i = 0; i < 4 ; i = i + 1) begin
            padding2 [5][i + 1] <= Img2[3][i];
        end
        for (k = 0; k < 4 ; k = k + 1) begin
            padding2 [k + 1][0] <= Img2[k][0];
        end
        for (l = 0; l < 4 ; l = l + 1) begin
            padding2 [l + 1][5] <= Img2[l][3];
        end
        padding2 [0][0] <= Img2[0][0];
        padding2 [0][5] <= Img2[0][3];
        padding2 [5][0] <= Img2[3][0];
        padding2 [5][5] <= Img2[3][3];
        for (i = 1; i < 5 ; i = i + 1) begin
            for (j = 1; j < 5 ; j = j + 1) begin
                padding2 [i][j] <= Img2[i - 1][j - 1];
            end
        end
    end
    else if (reg_opt[1] == 0 && flag1 == 1) begin
        for (i = 1; i < 5 ; i = i + 1) begin
            for (j = 1; j < 5 ; j = j + 1) begin
                padding2 [i][j] <= Img2[i - 1][j - 1];
            end
        end
    end
    else if (state_cs == 0) begin
        for (i = 0; i < 6 ; i = i + 1) begin
            for (j = 0; j < 6 ; j = j + 1) begin
                padding2 [i][j] <= 0;
            end
        end
    end
    else begin
        for (i = 1; i < 5 ; i = i + 1) begin
            for (j = 1; j < 5 ; j = j + 1) begin
                padding2 [i][j] <= padding2[i][j];
            end
        end
    end
end
//padding3 -------------------------------- padding3 //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 6 ; i = i + 1) begin
            for (j = 0; j < 6 ; j = j + 1) begin
                padding3 [i][j] <= 0;
            end
        end
    end
    else if (reg_opt[1] == 1 && state_ns == CON) begin
        for (j = 0; j < 4 ; j = j + 1) begin
            padding3 [0][j + 1] <= Img3[0][j];
        end
        for (i = 0; i < 4 ; i = i + 1) begin
            padding3 [5][i + 1] <= Img3[3][i];
        end
        for (k = 0; k < 4 ; k = k + 1) begin
            padding3 [k + 1][0] <= Img3[k][0];
        end
        for (l = 0; l < 4 ; l = l + 1) begin
            padding3 [l + 1][5] <= Img3[l][3];
        end
        padding3 [0][0] <= Img3[0][0];
        padding3 [0][5] <= Img3[0][3];
        padding3 [5][0] <= Img3[3][0];
        padding3 [5][5] <= Img3[3][3];
        for (i = 1; i < 5 ; i = i + 1) begin
            for (j = 1; j < 5 ; j = j + 1) begin  
                padding3 [i][j] <= Img3[i - 1][j - 1];
            end
        end
    end
    else if (reg_opt[1] == 0 && state_ns == CON) begin
        for (i = 1; i < 5 ; i = i + 1) begin
            for (j = 1; j < 5 ; j = j + 1) begin
                padding3 [i][j] <= Img3[i - 1][j - 1];
            end
        end
    end
    else if (state_cs == 0) begin
        for (i = 0; i < 6 ; i = i + 1) begin
            for (j = 0; j < 6 ; j = j + 1) begin
                padding3 [i][j] <= 0;
            end
        end
    end
    else begin
        for (i = 1; i < 5 ; i = i + 1) begin
            for (j = 1; j < 5 ; j = j + 1) begin
                padding3 [i][j] <= padding3[i][j];
            end
        end
    end
end
// // Convolution1-multi -------------------------------- Convolution1-multi //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        test1 <= 0;
        test2 <= 0;
        test3 <= 0;
        test4 <= 0;
        test5 <= 0;
        test6 <= 0;
        test7 <= 0;
        test8 <= 0;
        test9 <= 0;
    end
    else if (state_cs == CON && (cnt >> 4) == 0) begin
        test1 <= padding1[0 + (cnt >> 2)] [0 + (cnt[1:0])];
        test2 <= padding1[0 + (cnt >> 2)] [1 + (cnt[1:0])];
        test3 <= padding1[0 + (cnt >> 2)] [2 + (cnt[1:0])];
        test4 <= padding1[1 + (cnt >> 2)] [0 + (cnt[1:0])];
        test5 <= padding1[1 + (cnt >> 2)] [1 + (cnt[1:0])];
        test6 <= padding1[1 + (cnt >> 2)] [2 + (cnt[1:0])];
        test7 <= padding1[2 + (cnt >> 2)] [0 + (cnt[1:0])];
        test8 <= padding1[2 + (cnt >> 2)] [1 + (cnt[1:0])];
        test9 <= padding1[2 + (cnt >> 2)] [2 + (cnt[1:0])]; 
    end
    else if (state_cs == CON && (cnt >> 4) == 1 ) begin
        test1 <= padding2[0 + ((cnt - 16) >> 2)] [0 + (cnt[1:0])];
        test2 <= padding2[0 + ((cnt - 16) >> 2)] [1 + (cnt[1:0])];
        test3 <= padding2[0 + ((cnt - 16) >> 2)] [2 + (cnt[1:0])];
        test4 <= padding2[1 + ((cnt - 16) >> 2)] [0 + (cnt[1:0])];
        test5 <= padding2[1 + ((cnt - 16) >> 2)] [1 + (cnt[1:0])];
        test6 <= padding2[1 + ((cnt - 16) >> 2)] [2 + (cnt[1:0])];
        test7 <= padding2[2 + ((cnt - 16) >> 2)] [0 + (cnt[1:0])];
        test8 <= padding2[2 + ((cnt - 16) >> 2)] [1 + (cnt[1:0])];
        test9 <= padding2[2 + ((cnt - 16) >> 2)] [2 + (cnt[1:0])]; 
    end
    else if (state_cs == CON && (cnt >> 4) == 2 ) begin
        test1 <= padding3[0 + ((cnt - 32) >> 2)] [0 + (cnt[1:0])];
        test2 <= padding3[0 + ((cnt - 32) >> 2)] [1 + (cnt[1:0])];
        test3 <= padding3[0 + ((cnt - 32) >> 2)] [2 + (cnt[1:0])];
        test4 <= padding3[1 + ((cnt - 32) >> 2)] [0 + (cnt[1:0])];
        test5 <= padding3[1 + ((cnt - 32) >> 2)] [1 + (cnt[1:0])];
        test6 <= padding3[1 + ((cnt - 32) >> 2)] [2 + (cnt[1:0])];
        test7 <= padding3[2 + ((cnt - 32) >> 2)] [0 + (cnt[1:0])];
        test8 <= padding3[2 + ((cnt - 32) >> 2)] [1 + (cnt[1:0])];
        test9 <= padding3[2 + ((cnt - 32) >> 2)] [2 + (cnt[1:0])]; 
    end
    else if (state_cs == 4 && cnt < 4) begin
        test1 <= maxpooling[0 + (cnt / 2)][0];
        test2 <= maxpooling[0 + (cnt / 2)][1];
        test3 <= 0;
        test4 <= 0;
        test5 <= 0;
        test6 <= 0;
        test7 <= 0;
        test8 <= 0;
        test9 <= 0; 
    end
    else if (state_cs == 5 && cnt > 9 && cnt < 14 && reg_opt == 1) begin
        test1 <= exp_out_1;
    end
    else  begin
        test1 <= 0;
        test2 <= 0;
        test3 <= 0;
        test4 <= 0;
        test5 <= 0;
        test6 <= 0;
        test7 <= 0;
        test8 <= 0;
        test9 <= 0; 
    end
end
// KERNAL ------------------------------ KERNAL //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        test1_1 <= 0;
        test1_2 <= 0;
        test1_3 <= 0;
        test1_4 <= 0;
        test1_5 <= 0;
        test1_6 <= 0;
        test1_7 <= 0;
        test1_8 <= 0;
        test1_9 <= 0;
    end
    else if (state_cs == CON && (cnt / 16) == 0) begin
        test1_1 <= Kernel1[0][0];
        test1_2 <= Kernel1[0][1];
        test1_3 <= Kernel1[0][2];
        test1_4 <= Kernel1[1][0];
        test1_5 <= Kernel1[1][1];
        test1_6 <= Kernel1[1][2];
        test1_7 <= Kernel1[2][0];
        test1_8 <= Kernel1[2][1];
        test1_9 <= Kernel1[2][2]; 
    end
    else if (state_cs == CON && (cnt / 16) == 1 ) begin
        test1_1 <= Kernel2[0][0];
        test1_2 <= Kernel2[0][1];
        test1_3 <= Kernel2[0][2];
        test1_4 <= Kernel2[1][0];
        test1_5 <= Kernel2[1][1];
        test1_6 <= Kernel2[1][2];
        test1_7 <= Kernel2[2][0];
        test1_8 <= Kernel2[2][1];
        test1_9 <= Kernel2[2][2]; 
    end
    else if (state_cs == CON && (cnt / 16) == 2 ) begin
        test1_1 <= Kernel3[0][0];
        test1_2 <= Kernel3[0][1];
        test1_3 <= Kernel3[0][2];
        test1_4 <= Kernel3[1][0];
        test1_5 <= Kernel3[1][1];
        test1_6 <= Kernel3[1][2];
        test1_7 <= Kernel3[2][0];
        test1_8 <= Kernel3[2][1];
        test1_9 <= Kernel3[2][2];   
    end
    else if (state_cs == 4 && cnt < 4) begin
        test1_1 <= reg_weight[0][(cnt[0])];
        test1_2 <= reg_weight[1][(cnt[0])];
        test1_3 <= 0;
        test1_4 <= 0;
        test1_5 <= 0;
        test1_6 <= 0;
        test1_7 <= 0;
        test1_8 <= 0;
        test1_9 <= 0; 
    end
    else if (state_cs == 5 && cnt > 9 && cnt < 14 && reg_opt == 1) begin
        test1_1 <= exp_out_1;
    end
    else  begin
        test1_1 <= 0;
        test1_2 <= 0;
        test1_3 <= 0;
        test1_4 <= 0;
        test1_5 <= 0;
        test1_6 <= 0;
        test1_7 <= 0;
        test1_8 <= 0;
        test1_9 <= 0; 
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        test3_1 <= 0;
        test3_2 <= 0;
        test3_3 <= 0;
        test3_4 <= 0;
        test3_5 <= 0;
        test3_6 <= 0;
        test3_7 <= 0;
        test3_8 <= 0;
        test3_9 <= 0;
    end
    else if (state_cs == 2) begin
        test3_1  <= test2_1 ;
        test3_2  <= test2_2 ;
        test3_3  <= test2_3 ;
        test3_4  <= test2_4 ;
        test3_5  <= test2_5 ;
        test3_6  <= test2_6 ;
        test3_7  <= test2_7 ;
        test3_8  <= test2_8 ;
        test3_9  <= test2_9 ;
    end
    else if (state_cs == 4) begin
        test3_1  <= test2_1 ;
        test3_2  <= test2_2 ;
        test3_3  <= test2_3 ;
        test3_4  <= test2_4 ;
        test3_5  <= test2_5 ;
        test3_6  <= test2_6 ;
        test3_7  <= test2_7 ;
        test3_8  <= test2_8 ;
        test3_9  <= test2_9 ;
    end
    else if (state_cs == 5 && cnt > 10 && cnt < 15 && reg_opt == 1) begin
        test3_1  <= test2_1 ;
        test3_2  <= flotingpointnegtive1 ;
        test3_3  <= 0 ;
        test3_4  <= 0 ;
        test3_5  <= 0 ;
        test3_6  <= 0 ;
        test3_7  <= 0 ;
        test3_8  <= 0 ;
        test3_9  <= 0 ;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        test4_1 <= 0;
        test4_2 <= 0;
        test4_3 <= 0;
    end
    else if (state_cs == 2) begin
        test4_1 <= test3_10;
        test4_2 <= test3_11;
        test4_3 <= test3_12;
    end
    else if (state_cs == 3 && cnt < 16) begin
        test4_1 <= featuremap1[cnt >> 2] [cnt[1:0]];
        test4_2 <= featuremap2[cnt >> 2] [cnt[1:0]];
        test4_3 <= featuremap3[cnt >> 2] [cnt[1:0]];
    end
    else if (state_cs == 5 && cnt > 9 && cnt < 14 && reg_opt == 2) begin
        test4_1 <= exp_out_1;
        test4_2 <= flotingpoint1;
        test4_3 <= 0;
    end
    else if (state_cs == 5 && cnt > 10 && cnt < 15 && reg_opt == 1) begin
        test4_1 <= test2_1;
        test4_2 <= flotingpoint1;
        test4_3 <= 0;
    end
    else if (state_cs == 5 && cnt > 9 && cnt < 14 && reg_opt == 3) begin
        test4_1 <= exp_out_1;
        test4_2 <= flotingpoint1;
        test4_3 <= 0;
    end
    else begin
        test4_1 <= 0;
        test4_2 <= 0;
        test4_3 <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 6 ; i = i + 1) begin
            for (j = 0; j < 6 ; j = j + 1) begin
                featuremap1 [i][j] <= 0;
            end
        end
    end
    else if (state_cs == CON && ((cnt - 3) / 16) == 0) begin
        featuremap1 [3][3] <= test3_13;
        for (i = 0; i < 4 ; i = i + 1) begin
            for (j = 0; j < 4 ; j = j + 1) begin
                featuremap1[i][j-1] <= featuremap1[i][j];
                featuremap1[j-1][3] <= featuremap1[j][0];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 6 ; i = i + 1) begin
            for (j = 0; j < 6 ; j = j + 1) begin
                featuremap2 [i][j] <= 0;
            end
        end
    end
    else if (state_cs == CON && ((cnt - 3) / 16) == 1) begin
        featuremap2 [3][3] <= test3_13;
        for (i = 0; i < 4 ; i = i + 1) begin
            for (j = 0; j < 4 ; j = j + 1) begin
                featuremap2[i][j-1] <= featuremap2[i][j];
                featuremap2[j-1][3] <= featuremap2[j][0];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 6 ; i = i + 1) begin
            for (j = 0; j < 6 ; j = j + 1) begin
                featuremap3 [i][j] <= 0;
            end
        end
    end
    else if (state_cs == CON && ((cnt - 3) / 16) == 2) begin
        featuremap3 [3][3] <= test3_13;
        for (i = 0; i < 4 ; i = i + 1) begin
            for (j = 0; j < 4 ; j = j + 1) begin
                featuremap3[i][j-1] <= featuremap3[i][j];
                featuremap3[j-1][3] <= featuremap3[j][0];
            end
        end
    end
end
//feature -------------------------------- feature //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 4 ; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                featuremap[i][j] <= 0;
            end
        end
    end
    else if (state_cs == 3 && cnt < 17) begin
        featuremap[3][3] <= test3_13;
        for (i = 0; i < 4 ; i = i + 1) begin
            for (j = 0; j < 4 ; j = j + 1) begin
                featuremap[i][j-1] <= featuremap[i][j];
                featuremap[j-1][3] <= featuremap[j][0];
            end
        end
    end
end

//feature maxpooling -------------------------------- feature maxpooling //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        feature1 <= 0;
    end
    else if (state_cs == MAXP && cnt > 16) begin
        feature1 <= featuremap[0 + (2 * ((cnt - 17) / 2))][0 + (2 * ((cnt - 17) % 2))];
    end
    else if (state_cs == 5 && cnt == 0) begin
        feature1 <= m_wmatrix[0];
    end
    else if (state_cs == 5 && cnt == 1) begin
        feature1 <= max0;
    end
    else feature1 <= feature1;
end
//feature maxpooling -------------------------------- feature maxpooling //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        feature2 <= 0;
    end
    else if (state_cs == MAXP && cnt > 16) begin
        feature2 <= featuremap[0 + (2 * ((cnt - 17) / 2))][1 + (2 * ((cnt - 17) % 2))];
    end
    else if (state_cs == 5 && cnt == 0) begin
        feature2 <= m_wmatrix[1];
    end
    else if (state_cs == 5 && cnt == 1) begin
        feature2 <= max0_1;
    end
    else feature2 <= feature2;
end
//feature maxpooling -------------------------------- feature maxpooling //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        feature3 <= 0;
    end
    else if (state_cs == MAXP && cnt > 16) begin
        feature3 <= featuremap[1 + (2 * ((cnt - 17) / 2))][0 + (2 * ((cnt - 17) % 2))];
    end
    else if (state_cs == 5 && cnt == 0) begin
        feature3 <= m_wmatrix[2];
    end
    else if (state_cs == 5 && cnt == 1) begin
        feature3 <= min0;
    end
    else feature3 <= feature3;
end
//feature maxpooling -------------------------------- feature maxpooling //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        feature4 <= 0;
    end
    else if (state_cs == MAXP && cnt > 16) begin
        feature4 <= featuremap[1 + (2 * ((cnt - 17) / 2))][1 + (2 * ((cnt - 17) % 2))];
    end
    else if (state_cs == 5 && cnt == 0) begin
        feature4 <= m_wmatrix[3];
    end
    else if (state_cs == 5 && cnt == 1) begin
        feature4 <= min1;
    end
    else feature4 <= feature4;
end
//feature comparator -------------------------------- feature comparator //
assign max0 = flag0==1 ? feature1 : feature2;
assign max0_1 = flag0_1==1 ? feature3 : feature4;
// assign max = maxflag==1 ? feature1 : feature2;
always @(*) begin
    if (!rst_n) begin
        max = 0;
    end
    else if (state_cs == 3) begin
        max = maxflag==1 ? max0 : max0_1;
    end
    else if (state_cs == 5) begin
        max = flag0==1 ? feature1 : feature2;
    end
    else max = 0;
end

// store max data ----------------------------------------------------- store max data //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 2 ; i = i + 1) begin
            for (j = 0; j < 2; j = j + 1) begin
                maxpooling[i][j] <= 0;
            end
        end
    end
    else if (state_cs == MAXP && cnt > 16) begin
        maxpooling[1][1] <= max;
        for (i = 0; i < 2 ; i = i + 1) begin
            for (j = 0; j < 2 ; j = j + 1) begin
                maxpooling[i][j-1] <= maxpooling[i][j];
                maxpooling[j-1][1] <= maxpooling[j][0];
            end
        end
    end
    else begin
        for (i = 0; i < 2 ; i = i + 1) begin
            for (j = 0; j < 2; j = j + 1) begin
                maxpooling[i][j] <= maxpooling[i][j];
            end
        end
    end
end
// m_wmatrix ------------------------------ m_wmatrix //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (j = 0; j < 4 ; j = j + 1) begin
            m_wmatrix[j] <= 0;
        end
    end
    else if (state_cs == FULLY && cnt <= 5) begin
        m_wmatrix[3] <= test3_10;
        for (j = 3; j > 0 ; j = j - 1) begin
            m_wmatrix[j - 1] <= m_wmatrix[j];
        end
    end
    else begin
        for (j = 0; j < 4 ; j = j + 1) begin
            m_wmatrix[j] <= m_wmatrix[j];
        end
    end
end
assign min0 = flag0==0 ? feature1 : feature2;
assign min1 = flag0_1==0 ? feature3 : feature4;
assign min  = flag0_1==0 ? feature3 : feature4;
////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sub_in <= 0;
    end
    else if (state_cs == 5 && cnt > 1 && cnt < 6) begin
        sub_in <= m_wmatrix[cnt - 2];
    end
    else sub_in <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div_in1 <= 0;
    end
    else if (state_cs == 5 && cnt > 2 && cnt < 7) begin
        div_in1 <= sub_out1;
    end
    else if (state_cs == 5 && cnt > 9 && cnt < 15 && reg_opt == 2) begin
        div_in1 <= test4_1;
    end
    else if (state_cs == 5 && cnt > 11 && cnt < 16 && reg_opt == 1) begin
        div_in1 <= test3_10;
    end
    else div_in1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div_in2 <= 0;
    end
    else if (state_cs == 5 && cnt > 2 && cnt < 7) begin
        div_in2 <= sub_out;
    end
    else if (state_cs == 5 && cnt > 9 && cnt < 15 && reg_opt == 2) begin
        div_in2 <= test3_13;
    end
    else if (state_cs == 5 && cnt > 11 && cnt < 16 && reg_opt == 1) begin
        div_in2 <= test3_13;
    end
    else div_in2 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        exp_in_1 <= 0;
    end
    else if (state_cs == 5 && cnt > 8 && cnt < 13) begin
        exp_in_1 <= normalization[cnt - 9];
    end
    else exp_in_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        exp_in_2 <= 0;
    end
    else if (state_cs == 5 && cnt > 8 && cnt < 13) begin
        exp_in_2 <= normalization[cnt - 9];
    end
    else exp_in_2 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 3 ; i = i + 1) begin
            normalization[i] <= 0;
        end
    end
    else if (state_cs == 5 && cnt > 3 && cnt < 8) begin
        normalization[cnt - 4] <= div_out1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ln_in <= 0;
    end
    else if (state_cs == 5 && cnt > 9 && cnt < 16 && reg_opt == 3) begin
        ln_in <= test3_13;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ans[0] <= 0;
        ans[1] <= 0;
        ans[2] <= 0;
        ans[3] <= 0;
    end
    else if (state_cs == 5 && cnt > 3 && cnt < 8 && reg_opt == 0) begin
        ans[3] <= div_out1;
        for (i = 3; i > 0 ; i = i - 1) begin
            ans[i - 1] <= ans[i];
        end
    end 
    else if (state_cs == 5 && cnt > 12 && cnt < 17 && reg_opt == 1) begin
        ans[3] <= div_out1;
        for (i = 3; i > 0 ; i = i - 1) begin
            ans[i - 1] <= ans[i];
        end
    end 
    else if (state_cs == 5 && cnt > 10 && cnt < 16 && reg_opt == 2) begin
        ans[3] <= div_out1;
        for (i = 3; i > 0 ; i = i - 1) begin
            ans[i - 1] <= ans[i];
        end
    end 
    else if (state_cs == 5 && cnt > 10 && cnt < 16 && reg_opt == 3) begin
        ans[3] <= ln_out;
        for (i = 3; i > 0 ; i = i - 1) begin
            ans[i - 1] <= ans[i];
        end
    end 
end

// out_valid reset ------------------------------------------ out_valid reset //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (state_cs == OUT && cnt < 4) begin
        out_valid <= 1;
    end
    else out_valid <= 0;
end
// out reset ----------------------------------------------------- out reset //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out <= 0;
    end
    else if (state_cs == OUT && cnt < 4) begin
        case (cnt)
            0 : out <= ans[0];
            1 : out <= ans[1];
            2 : out <= ans[2];
            3 : out <= ans[3]; 
            default: out <= 0;
        endcase
    end
    else out <= 0;
end

endmodule
