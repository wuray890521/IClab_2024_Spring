module CAD(
    // input signals
    clk,
    rst_n,
    in_valid, 
    in_valid2,
    mode,
    matrix_size,
    matrix,
    matrix_idx,
    // output signals
    out_valid,
    out_value
    );

input [1:0] matrix_size;
input clk;
input [7:0] matrix;
input rst_n;
input [3:0] matrix_idx;
input in_valid2;

input mode;
input in_valid;

output reg out_valid;
output reg out_value;


//=======================================================
//                   Reg/Wire
//=======================================================
reg [3:0] state_cs, state_ns;
parameter IDLE = 0;
parameter LOAD = 1;
parameter LOAD2 = 2;
parameter INPUTMAX = 3;
parameter CAL = 4;
parameter CONVOLTUION = 5;
parameter CON2MAX = 6;
parameter MAXPOOLING = 7;
parameter DECONVOLUTION = 8;
parameter WAIT2 = 9;
parameter WAIT = 10;
parameter OUT = 11;

reg web;
reg [13:0] addres;
reg [7:0] reg_matrix;
reg [7:0] mem_out;
reg signed [7:0] img_mem_out;


reg web_kernal;
reg [8:0] addres_kernal;
reg [7:0] kernal_mem_out;
reg signed [7:0] kernal_mem_out_seq;

reg in_valid_d;
reg in_valid2_d;


reg [1:0] matrix_size_seq;
reg mode_seq;
reg [3:0] img_cal_seq;
reg [3:0] ker_cal_seq;

reg [14:0] cnt_state_1;
reg [6:0] cnt_img_x;
reg [6:0] cnt_img_y;
reg signed [7:0] img_matrix[39:0][39:0];

reg [2:0] cnt_ker_x;
reg [2:0] cnt_ker_y;
reg signed [7:0] ker_matrix[4:0][4:0];

reg [10:0] cnt_3;
reg flag_sram_ker_0;
reg flag_sram_ker;
reg flag_sram_img_0;
reg flag_sram_img;

// for kernal reset
integer i, j;
// for img reset
integer ii, jj;

// kernal calculation
reg signed [19:0] kernal;
reg signed [19:0] img;
reg signed [19:0] multi;
reg signed [19:0] add_a, add_b;
reg signed [19:0] convolution;

reg [5:0] cnt_state_5_x; // imgmatrix
reg [5:0] cnt_state_5_y; // imgmatrix 
reg [4:0] cnt_state_5; // 24 
reg [4:0] cnt_state_5_in_x;
reg [4:0] cnt_state_5_in_y;
reg [4:0] cnt_state_5_out_x;
reg [4:0] cnt_state_5_out_y;
reg [9:0] cnt_state_5to6;

// kernal calculation
integer k, l;

reg [1:0] cnt_state_7;
// reg [10:0] cnt_state_7;
reg cnt_state_7_x;
reg cnt_state_7_y;
reg [4:0] cnt_state_in_7_x;
reg [4:0] cnt_state_in_7_y;
// reg [10:0] cnt_state_in_7_x;
// reg [10:0] cnt_state_in_7_y;
reg signed [19:0] max_seq;
reg signed [19:0] compare_a;
reg signed [19:0] compare;

// integer kk;

reg [7:0] cnt_out;
reg [4:0] cnt_out_bit;
reg [4:0] cnt_out_value_bit;

reg [4:0] cnt_state_8;
reg [2:0] cnt_state_8_x;
reg [4:0] cnt_state_8_y;
reg [5:0] cnt_state_8_in_x;
reg [5:0] cnt_state_8_in_y;
reg [10:0] cnt_state_8to9;
reg [10:0] cnt_test;
reg signed [19:0] memout;

reg web_out;
reg [19:0] out_memout;
reg [19:0] reg_out_memout;
reg flag_out_0;
reg flag_out;

reg out_valid_prepare;

reg [9:0] addres_con;
reg web_con;
reg [19:0] max_input;
reg signed [19:0] max_input_seq;
reg flag_maxsram_0;
reg flag_maxsram;

//=======================================================
//                   Design
//=======================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_matrix <= 0;
    end
    else reg_matrix <= matrix;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_d <= 0;
    end
    else in_valid_d <= in_valid;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid2_d <= 0;
    end
    else in_valid2_d <= in_valid2;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        matrix_size_seq <= 0;
    end
    else if (in_valid && !in_valid_d) begin
        matrix_size_seq <= matrix_size;
    end
    else matrix_size_seq <= matrix_size_seq;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mode_seq <= 0;
    end
    else if (in_valid2 && !in_valid2_d) begin
        mode_seq <= mode;
    end
    else mode_seq <= mode_seq;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        img_cal_seq <= 0;
    end
    else if (in_valid2 && !in_valid2_d) begin
        img_cal_seq <= matrix_idx;
    end
    else img_cal_seq <= img_cal_seq;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ker_cal_seq <= 0;
    end
    else if (state_cs == OUT) begin
        ker_cal_seq <= 0;
    end
    else if (in_valid2 && in_valid2_d) begin
        ker_cal_seq <= matrix_idx;
    end
    else ker_cal_seq <= ker_cal_seq;
end

// ================= FSM ==================== //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state_cs <= IDLE;
    end
    else begin
        state_cs <= state_ns;
    end
end
always @(*) begin
    case (state_cs)
        IDLE : begin
            if (in_valid) begin
                state_ns = LOAD;
            end
            else if (in_valid2) begin
                state_ns = LOAD2;
            end
            else state_ns = IDLE;
        end
        LOAD : begin
            if (in_valid2) begin
                state_ns = LOAD2;
            end
            else state_ns = LOAD;
        end
        LOAD2 : begin
            if (!in_valid2 && in_valid2_d) begin
                state_ns = INPUTMAX;
            end
            else state_ns = LOAD2;
        end
        INPUTMAX : begin
            if (flag_sram_img && !flag_sram_img_0) begin
                state_ns = CAL;
            end
            else state_ns = INPUTMAX;
        end
        CAL : begin
            if (!mode_seq) begin
                state_ns = CONVOLTUION;
            end
            else state_ns = DECONVOLUTION;
        end
        CONVOLTUION : begin
            if (matrix_size_seq == 0) begin
                if (cnt_state_5to6 == 16 && cnt_state_5 == 24) begin
                    state_ns = WAIT;
                end
                else state_ns = CONVOLTUION;
            end
            else if (matrix_size_seq == 1) begin
                if (cnt_state_5to6 == 144 && cnt_state_5 == 24) begin
                    state_ns = WAIT;
                end
                else state_ns = CONVOLTUION;
            end
            else if (matrix_size_seq == 2) begin
                if (cnt_state_5to6 == 784 && cnt_state_5 == 24) begin
                    state_ns = WAIT;
                end
                else state_ns = CONVOLTUION;
            end
            else state_ns = CONVOLTUION;
        end
        WAIT : begin
            state_ns = MAXPOOLING;
        end
        MAXPOOLING : begin
            if (!flag_maxsram_0 && flag_maxsram) begin
                state_ns = WAIT2;
            end
            else state_ns = MAXPOOLING;
        end
        DECONVOLUTION : begin
            if (matrix_size_seq == 0) begin
                if (cnt_test == 143 && cnt_state_8 == 2) begin
                    state_ns = WAIT2;
                end
                else state_ns = DECONVOLUTION;
            end
            else if (matrix_size_seq == 1) begin
                if (cnt_test == 399 && cnt_state_8 == 2) begin
                    state_ns = WAIT2;
                end
                else state_ns = DECONVOLUTION;
            end
            else if (matrix_size_seq == 2) begin
                if (cnt_test == 1295 && cnt_state_8 == 2) begin
                    state_ns = WAIT2;
                end
                else state_ns = DECONVOLUTION;
            end
            else state_ns = DECONVOLUTION;
        end
        WAIT2 : begin
            state_ns = OUT;
        end
        OUT : begin
            if (!mode_seq) begin
                if (matrix_size_seq == 0) begin
                    if (cnt_out == 3 && cnt_out_bit == 19) begin
                        state_ns = IDLE;
                    end
                    else state_ns = OUT;
                end
                else if (matrix_size_seq == 1) begin
                    if (cnt_out == 35 && cnt_out_bit == 19) begin
                        state_ns = IDLE;
                    end
                    else state_ns = OUT;
                end
                else if (matrix_size_seq == 2) begin
                    if (cnt_out == 195  && cnt_out_bit == 19) begin
                        state_ns = IDLE;
                    end
                    else state_ns = OUT;
                end
                else state_ns = OUT;
            end
            else if (mode_seq == 1) begin
                if (flag_out_0 == 0 && flag_out == 1) begin
                    state_ns = IDLE;
                end
                else state_ns = OUT;
            end
            else state_ns = OUT;
        end
        default: state_ns = state_cs;
    endcase
end
// ================= FSM ==================== //

// =================== web for imgsram ============== //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_1 <= 0;
    end
    else if (state_cs == LOAD && in_valid) begin
        cnt_state_1 <= cnt_state_1 + 1;
    end
    else cnt_state_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        web <= 1;
    end
    else if (in_valid) begin
        if (matrix_size_seq == 0) begin
            if (cnt_state_1 >= 1023) begin
                web <= 1;
            end
            else web <= 0;
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_state_1 >= 4095) begin
                web <= 1;
            end
            else web <= 0;
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_state_1 >= 16383) begin
                web <= 1;
            end
            else web <= 0;
        end
        else web <= web;
    end
    else web <= 1;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addres <= 0;
    end
    else if (state_cs == LOAD && in_valid) begin
        addres <= addres + 1;
    end
    else if (state_cs == LOAD2) begin
        if (matrix_size_seq == 0) begin
            addres <= img_cal_seq << 6;
        end
        else if (matrix_size_seq == 1) begin
            addres <= img_cal_seq << 8;
        end
        else if (matrix_size_seq == 2) begin
            addres <= img_cal_seq << 10;
        end
    end
    else if (state_cs == INPUTMAX) begin
        addres <= addres + 1;
    end
    else addres <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        img_mem_out <= 0;
    end
    else if (state_cs == INPUTMAX) begin
        img_mem_out <= mem_out;
    end
    else img_mem_out <= img_mem_out;
end
// =================== web for imgsram ============== //

// =================== web for kersram ============== //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        web_kernal <= 1;
    end
    else if (in_valid) begin
        if (matrix_size_seq == 0) begin
            if (cnt_state_1 >= 1023) begin
                web_kernal <= 0;
            end
            else web_kernal <= 1;
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_state_1 >= 4095) begin
                web_kernal <= 0;
            end
            else web_kernal <= 1;
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_state_1 >= 16383) begin
                web_kernal <= 0;
            end
            else web_kernal <= 1;
        end
        else web_kernal <= web_kernal;
    end
    else web_kernal <= 1;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addres_kernal <= 0;
    end
    else if (in_valid) begin
        if (web) begin
            addres_kernal <= addres_kernal + 1;
        end
        else addres_kernal <= 0;
    end
    else if (state_cs == LOAD2) begin
        addres_kernal <= ker_cal_seq * 25;
    end
    else if (state_cs == INPUTMAX) begin
        if (addres_kernal == 399) begin
            addres_kernal <= 0;
        end
        else addres_kernal <= addres_kernal + 1;
    end
    else addres_kernal <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        kernal_mem_out_seq <= 0;
    end
    else if (state_cs == INPUTMAX) begin
        kernal_mem_out_seq <= kernal_mem_out;
    end
    else kernal_mem_out_seq <= 0;
end
// =================== web for kersram ============== //

// ============= state_cs == LOAD2 =============== //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_sram_img_0 <= 0;
    end
    else if (state_cs == INPUTMAX) begin
        if (matrix_size_seq == 0) begin
            if (cnt_3[6]) begin
                flag_sram_img_0 <= 0;
            end
            else flag_sram_img_0<= 1;
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_3[8]) begin
                flag_sram_img_0 <= 0;
            end
            else flag_sram_img_0<= 1;
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_3[10]) begin
                flag_sram_img_0 <= 0;
            end
            else flag_sram_img_0<= 1;
        end
    end
    else flag_sram_img_0 <= flag_sram_img_0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_sram_img <= 0;
    end
    else flag_sram_img <= flag_sram_img_0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_img_x <= 0;
    end
    else if (state_cs == LOAD2) begin
        if (mode_seq)cnt_img_x <= 4;
        else cnt_img_x <= 0;
    end
    else if (state_cs == INPUTMAX) begin
        if (flag_sram_img) begin
            if (mode_seq == 0) begin
                if (matrix_size_seq == 0) begin
                    if (cnt_img_x == 7) begin
                        cnt_img_x <= 0;
                    end
                    else cnt_img_x <= cnt_img_x + 1;
                end
                else if (matrix_size_seq == 1) begin
                    if (cnt_img_x == 15) begin
                        cnt_img_x <= 0;
                    end
                    else cnt_img_x <= cnt_img_x + 1;
                end
                else if (matrix_size_seq == 2) begin
                    if (cnt_img_x == 31) begin
                        cnt_img_x <= 0;
                    end
                    else cnt_img_x <= cnt_img_x + 1;
                end  
            end
            else begin
                if (matrix_size_seq == 0) begin
                    if (matrix_size_seq == 0) begin
                        if (cnt_img_x == 11) begin
                            cnt_img_x <= 4;
                        end
                        else cnt_img_x <= cnt_img_x + 1;
                    end
                end
                else if (matrix_size_seq == 1) begin
                    if (cnt_img_x == 19) begin
                        cnt_img_x <= 4;
                    end
                    else cnt_img_x <= cnt_img_x + 1;
                end
                else if (matrix_size_seq == 2) begin
                    if (cnt_img_x == 35) begin
                        cnt_img_x <= 4;
                    end
                    else cnt_img_x <= cnt_img_x + 1;                    
                end
            end
        end
        else cnt_img_x <= cnt_img_x;
    end
    else cnt_img_x <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_img_y <= 0;
    end
    else if (state_cs == LOAD2) begin
        if (mode_seq)cnt_img_y <= 4;
        else cnt_img_y <= 0;
    end
    else if (state_cs == INPUTMAX) begin
        if (flag_sram_img) begin
            if (mode_seq == 0) begin
                if (matrix_size_seq == 0) begin
                    if (cnt_img_x == 7) begin
                        cnt_img_y <= cnt_img_y + 1;
                    end
                    else cnt_img_y <= cnt_img_y;
                end
                else if (matrix_size_seq == 1) begin
                    if (cnt_img_x == 15) begin
                        cnt_img_y <= cnt_img_y + 1;
                    end
                    else cnt_img_y <= cnt_img_y;
                end
                else if (matrix_size_seq == 2)   begin
                    if (cnt_img_x == 31) begin
                        cnt_img_y <= cnt_img_y + 1;
                    end
                    else cnt_img_y <= cnt_img_y;
                end  
            end
            else begin
                if (matrix_size_seq == 0) begin
                    if (cnt_img_x == 11) begin
                        cnt_img_y <= cnt_img_y + 1;
                    end
                    else cnt_img_y <= cnt_img_y;
                end
                else if (matrix_size_seq == 1) begin
                    if (cnt_img_x == 19) begin
                        cnt_img_y <= cnt_img_y + 1;
                    end
                    else cnt_img_y <= cnt_img_y;                   
                end
                else if (matrix_size_seq == 2) begin
                    if (cnt_img_x == 35) begin
                        cnt_img_y <= cnt_img_y + 1;
                    end
                    else cnt_img_y <= cnt_img_y;
                end
            end 
        end
        else cnt_img_y <= cnt_img_y;    
    end
    else cnt_img_y <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (ii = 0; ii < 40 ; ii = ii + 1) begin
            for (jj = 0; jj < 40 ; jj = jj + 1) begin
                img_matrix[ii][jj] <= 0;
            end
        end
    end
    else if (state_cs == LOAD2) begin
        for (ii = 0; ii < 40 ; ii = ii + 1) begin
            for (jj = 0; jj < 40 ; jj = jj + 1) begin
                img_matrix[ii][jj] <= 0;
            end
        end
    end
    else if (state_cs == INPUTMAX) begin
        img_matrix[cnt_img_y][cnt_img_x] <= img_mem_out;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_ker_x <= 0;
    end
    else if (state_cs == LOAD2) begin
        if (mode_seq == 0) begin
            cnt_ker_x <= 0;
        end
        else cnt_ker_x <= 4;
    end
    else if (state_cs == INPUTMAX) begin
        if (flag_sram_ker) begin
            if (mode_seq == 0) begin
                if (cnt_ker_x == 4) begin
                    cnt_ker_x <= 0;
                end
                else cnt_ker_x <= cnt_ker_x + 1; 
            end
            else begin
                if (cnt_ker_x == 0) begin
                    cnt_ker_x <= 4;
                end
                else cnt_ker_x <= cnt_ker_x - 1;                 
            end
        end
        else cnt_ker_x <= cnt_ker_x;
    end
    else cnt_ker_x <= cnt_ker_x;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_ker_y <= 0;
    end
    else if (state_cs == OUT) begin
        cnt_ker_y <= 0;
    end
    else if (state_cs == LOAD2) begin
        if (mode_seq == 0)cnt_ker_y <= 0;
        else cnt_ker_y <= 4;
    end
    else if (state_cs == INPUTMAX && flag_sram_ker) begin
        if (mode_seq == 0) begin
            if (cnt_ker_x[2]) begin
                cnt_ker_y <= cnt_ker_y + 1;
            end
            else if (cnt_ker_y[2] && cnt_ker_x[2]) begin
                cnt_ker_y <= 0;
            end
            else cnt_ker_y <= cnt_ker_y;
        end
        else begin
            if (cnt_ker_x == 0) begin
                cnt_ker_y <= cnt_ker_y - 1;
            end
            else cnt_ker_y <= cnt_ker_y;
        end
    end
    else cnt_ker_y <= cnt_ker_y;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1) begin
            for (j = 0; j < 5 ; j = j + 1) begin
                ker_matrix[i][j] <= 0;
            end
        end
    end
    else if (state_cs == LOAD2) begin
        for (i = 0; i < 5 ; i = i + 1) begin
            for (j = 0; j < 5 ; j = j + 1) begin
                ker_matrix[i][j] <= 0;
            end
        end
    end
    else if (state_cs == INPUTMAX) begin
        ker_matrix[cnt_ker_y][cnt_ker_x] <= kernal_mem_out_seq;
    end
end
// ============= state_cs == LOAD2 =============== //

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_3 <= 0;
    end
    else if (state_cs == INPUTMAX) begin
        cnt_3 <= cnt_3 + 1;
    end
    else cnt_3 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_sram_ker_0 <= 0;
    end
    else if (state_cs == INPUTMAX) begin
        if (cnt_3 >= 25) begin
            flag_sram_ker_0 <= 0;
        end
        else flag_sram_ker_0 <= 1;
    end
    else flag_sram_ker_0 <= flag_sram_ker_0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_sram_ker <= 0;
    end
    else begin
        flag_sram_ker <= flag_sram_ker_0;
    end
end

// ================== CAL ================= //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_5to6 <= 0;
    end
    else if (state_cs == CONVOLTUION) begin
        if (cnt_state_5 == 24) begin
            cnt_state_5to6 <= cnt_state_5to6 + 1;
        end
        else cnt_state_5to6 <= cnt_state_5to6;
    end
    else cnt_state_5to6 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_5_x <= 0;
    end
    else if (state_cs == CONVOLTUION) begin
        if (cnt_state_5_x[2]) begin
            cnt_state_5_x <= 0;
        end
        else cnt_state_5_x <= cnt_state_5_x + 1;
    end
    else cnt_state_5_x <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_5_y <= 0;
    end
    else if (state_cs == CONVOLTUION) begin
        if (cnt_state_5 == 24) begin
            cnt_state_5_y <= 0;
        end
        else if (cnt_state_5_x[2]) begin
            cnt_state_5_y <= cnt_state_5_y + 1;
        end
        else cnt_state_5_y <= cnt_state_5_y;    
    end
    else cnt_state_5_y <= 0;
end



always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        kernal <= 0;
    end
    else if (state_cs == CONVOLTUION) begin
        kernal <= ker_matrix[cnt_state_5_y][cnt_state_5_x];
    end
    else if (state_cs == DECONVOLUTION) begin
        kernal <= ker_matrix[cnt_state_8_y][cnt_state_8_x];
    end
    else kernal <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        img <= 0;
    end
    else if (state_cs == CONVOLTUION) begin
        img <= img_matrix[cnt_state_5_y + cnt_state_5_in_y][cnt_state_5_x + cnt_state_5_in_x];
    end
    else if (state_cs == DECONVOLUTION) begin
        img <= img_matrix[cnt_state_8_y + cnt_state_8_in_y][cnt_state_8_x + cnt_state_8_in_x];
    end
    else img <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_5 <= 0;
    end
    else if (state_cs == CONVOLTUION) begin
        if (cnt_state_5 == 24) begin
            cnt_state_5 <= 0;
        end
        else cnt_state_5 <= cnt_state_5 + 1;
    end
    else cnt_state_5 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_5_in_x <= 0;
    end
    else if (state_cs == CONVOLTUION) begin
        if (matrix_size_seq == 0) begin
            if (cnt_state_5 == 24) begin
                if (cnt_state_5_in_x == 3) cnt_state_5_in_x <= 0;
                else cnt_state_5_in_x <= cnt_state_5_in_x + 1;
            end
            else cnt_state_5_in_x <= cnt_state_5_in_x;
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_state_5 == 24) begin
                if (cnt_state_5_in_x == 11) cnt_state_5_in_x <= 0;
                else cnt_state_5_in_x <= cnt_state_5_in_x + 1;
            end
            else cnt_state_5_in_x <= cnt_state_5_in_x;
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_state_5 == 24) begin
                if (cnt_state_5_in_x == 27) cnt_state_5_in_x <= 0;
                else cnt_state_5_in_x <= cnt_state_5_in_x + 1;
            end
            else cnt_state_5_in_x <= cnt_state_5_in_x;
        end
    end
    else cnt_state_5_in_x <= 0;

end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_5_in_y <= 0;
    end
    else if (state_cs == CONVOLTUION) begin
        if (matrix_size_seq == 0) begin
            if (cnt_state_5_in_x == 3 && cnt_state_5 == 24) begin
                cnt_state_5_in_y <= cnt_state_5_in_y + 1;
            end
            else cnt_state_5_in_y <= cnt_state_5_in_y;
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_state_5_in_x == 11 && cnt_state_5 == 24) begin
                cnt_state_5_in_y <= cnt_state_5_in_y + 1;
            end
            else cnt_state_5_in_y <= cnt_state_5_in_y;
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_state_5_in_x == 27 && cnt_state_5 == 24) begin
                cnt_state_5_in_y <= cnt_state_5_in_y + 1;
            end
            else cnt_state_5_in_y <= cnt_state_5_in_y;
        end
    end
    else cnt_state_5_in_y <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_5_out_x <= 0;
    end
    else if (state_cs == CONVOLTUION && cnt_state_5to6 != 0) begin
        if (matrix_size_seq == 0) begin
            if (cnt_state_5_x == 2 && cnt_state_5_y == 0) begin
                if (cnt_state_5_out_x == 3) begin
                    cnt_state_5_out_x <= 0;
                end
                else cnt_state_5_out_x <= cnt_state_5_out_x + 1;    
            end
            else cnt_state_5_out_x <= cnt_state_5_out_x; 
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_state_5_x == 2 && cnt_state_5_y == 0) begin
                if (cnt_state_5_out_x == 11) begin
                    cnt_state_5_out_x <= 0;
                end
                else cnt_state_5_out_x <= cnt_state_5_out_x + 1;    
            end
            else cnt_state_5_out_x <= cnt_state_5_out_x; 
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_state_5_x == 2 && cnt_state_5_y == 0) begin
                if (cnt_state_5_out_x == 27) begin
                    cnt_state_5_out_x <= 0;
                end
                else cnt_state_5_out_x <= cnt_state_5_out_x + 1;    
            end
            else cnt_state_5_out_x <= cnt_state_5_out_x; 
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_5_out_y <= 0;
    end
    else if (state_cs == CONVOLTUION && cnt_state_5to6 != 0) begin
        if (matrix_size_seq == 0) begin
            if (cnt_state_5_x == 2 && cnt_state_5_y == 0) begin
                if (cnt_state_5_out_x == 3) begin
                    cnt_state_5_out_y <= cnt_state_5_out_y + 1; 
                end
                else cnt_state_5_out_y <= cnt_state_5_out_y;    
            end
            else cnt_state_5_out_y <= cnt_state_5_out_y;
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_state_5_x == 2 && cnt_state_5_y == 0) begin
                if (cnt_state_5_out_x == 11) begin
                    cnt_state_5_out_y <= cnt_state_5_out_y + 1; 
                end
                else cnt_state_5_out_y <= cnt_state_5_out_y;    
            end
            else cnt_state_5_out_y <= cnt_state_5_out_y;
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_state_5_x == 2 && cnt_state_5_y == 0) begin
                if (cnt_state_5_out_x == 27) begin
                    cnt_state_5_out_y <= cnt_state_5_out_y + 1; 
                end
                else cnt_state_5_out_y <= cnt_state_5_out_y;    
            end
            else cnt_state_5_out_y <= cnt_state_5_out_y;
        end

    end
    else cnt_state_5_out_y <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        add_a <= 0;
        add_b <= 0;
    end
    else if (state_cs == CONVOLTUION) begin
        add_a <= convolution;
        add_b <= multi;
    end
    else if (state_cs == DECONVOLUTION) begin
        add_a <= convolution;
        add_b <= multi;
    end
    else begin
        add_a <= 0;
        add_b <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        convolution <= 0;
    end
    else if (state_cs == CONVOLTUION && state_ns == CONVOLTUION ) begin
        if (cnt_state_5_x == 2 && cnt_state_5_y == 0) begin
            convolution <= add_b;    
        end
        else convolution <= convolution + add_b;
    end
    else if (state_cs == DECONVOLUTION && state_ns == DECONVOLUTION ) begin
        if (cnt_state_8_x == 2 && cnt_state_8_y == 0) begin
            convolution <= add_b;    
        end
        else convolution <= convolution + add_b;
    end
    else convolution <= 0;
end

always @(*) begin
    multi = kernal * img;
end

wire [4:0] cnt_x;
wire [4:0] cnt_y;
assign cnt_x = cnt_state_in_7_x + cnt_state_7_x;
assign cnt_y = cnt_state_in_7_y + cnt_state_7_y;

always @(*) begin
    if (!rst_n) begin
        addres_con = 0;
    end
    else if (state_cs == CONVOLTUION) begin
        addres_con = {cnt_state_5_out_y, cnt_state_5_out_x};
    end
    else if (state_cs == WAIT) begin
        addres_con = 0;
    end
    else if (state_cs == MAXPOOLING) begin
        addres_con = {(cnt_y), (cnt_x)};
    end
    else addres_con = 0;
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        web_con <= 1;
    end
    else if (state_cs == CONVOLTUION && state_ns == CONVOLTUION) begin
        web_con <= 0;
    end
    else web_con <= 1;
end
// ================== CAL ================= //

// ==================== MAXPOLLING==========//
reg [10:0] cnt_7;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_7 <= 0;
    end
    else if (state_cs == MAXPOOLING) begin
        cnt_7 <= cnt_7 + 1;
    end
    else cnt_7 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_maxsram_0 <= 0;
    end
    else if (state_cs == MAXPOOLING) begin
        if (matrix_size_seq == 0) begin
            if (cnt_7 >= 16) begin
                flag_maxsram_0 <= 0;
            end
            else flag_maxsram_0 <= 1;
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_7 >= 144) begin
                flag_maxsram_0 <= 0;
            end
            else flag_maxsram_0 <= 1;
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_7 >= 784) begin
                flag_maxsram_0 <= 0;
            end
            else flag_maxsram_0 <= 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_maxsram <= 0;
    end
    else flag_maxsram <= flag_maxsram_0;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        max_input_seq <= 0;
    end
    else max_input_seq <= max_input;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_7 <= 0;
    end
    else if (state_cs == OUT) begin
        cnt_state_7 <= 0;
    end
    else if (state_cs == MAXPOOLING) begin
        if (cnt_state_7 == 3) begin
            cnt_state_7 <= 0;
        end
        else cnt_state_7 <= cnt_state_7 + 1;
    end
end

reg [1:0] cnt_flag_7;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_flag_7 <= 0;
    end
    else if (state_cs == MAXPOOLING && flag_maxsram) begin
        if (cnt_flag_7 == 3) cnt_flag_7 <= 0;
        else cnt_flag_7 <= cnt_flag_7 + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_7_x <= 0;
    end
    else if (state_cs == MAXPOOLING) begin
        cnt_state_7_x <= cnt_state_7_x + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_7_y <= 0;
    end
    else if (state_cs == OUT) begin
        cnt_state_7_y <= 0;
    end
    else if (state_cs == MAXPOOLING) begin
        if (cnt_state_7[0] == 1) begin
            cnt_state_7_y <= cnt_state_7_y + 1;
        end
        else cnt_state_7_y <= cnt_state_7_y;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_in_7_x <= 0;
    end
    else if (state_cs == OUT) begin
        cnt_state_in_7_x <= 0;
    end
    else if (state_cs == MAXPOOLING) begin
        if (matrix_size_seq == 0) begin
            if (cnt_state_7 == 3) begin
                if (cnt_state_in_7_x == 2) begin
                    cnt_state_in_7_x <= 0;
                end
                else cnt_state_in_7_x <= cnt_state_in_7_x + 2;
            end
            else cnt_state_in_7_x <= cnt_state_in_7_x;
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_state_7 == 3) begin
                if (cnt_state_in_7_x == 10) begin
                    cnt_state_in_7_x <= 0;
                end
                else cnt_state_in_7_x <= cnt_state_in_7_x + 2;
            end
            else cnt_state_in_7_x <= cnt_state_in_7_x;
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_state_7 == 3) begin
                if (cnt_state_in_7_x == 26) begin
                    cnt_state_in_7_x <= 0;
                end
                else cnt_state_in_7_x <= cnt_state_in_7_x + 2;
            end
            else cnt_state_in_7_x <= cnt_state_in_7_x;
        end
    end
    else cnt_state_in_7_x <= cnt_state_in_7_x;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_in_7_y <= 0;
    end
    else if (state_cs == OUT) begin
        cnt_state_in_7_y <= 0;
    end
    else if (state_cs == MAXPOOLING) begin
        if (matrix_size_seq == 0) begin
            if (cnt_state_7 == 3 && cnt_state_in_7_x == 2) begin
                cnt_state_in_7_y <= cnt_state_in_7_y + 2;
            end
            else cnt_state_in_7_y <= cnt_state_in_7_y;
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_state_7 == 3 && cnt_state_in_7_x == 10) begin
                cnt_state_in_7_y <= cnt_state_in_7_y + 2;
            end
            else cnt_state_in_7_y <= cnt_state_in_7_y;
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_state_7 == 3 && cnt_state_in_7_x == 26) begin
                cnt_state_in_7_y <= cnt_state_in_7_y + 2;
            end
            else cnt_state_in_7_y <= cnt_state_in_7_y;
        end
    end
    else cnt_state_in_7_y <= cnt_state_in_7_y;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        compare_a <= 0;
    end
    else if (state_cs == MAXPOOLING && flag_maxsram) begin
        if (cnt_flag_7 == 3) begin
            compare_a <= 20'b10000000000000000000;
        end
        else compare_a <= compare;
    end
end

always @(*) begin
    if (!rst_n) begin
        compare = 0;
    end
    else if (state_cs == MAXPOOLING && flag_maxsram) begin
        if (compare_a > max_input_seq) begin
            compare = compare_a;
        end
        else compare = max_input_seq;
    end
    else compare = 0;
end
// ==================== MAXPOLLING==========//

// =============== deconvolution ============= //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_test <= 0;
    end
    else if (state_cs == DECONVOLUTION && cnt_state_8to9 != 0 && state_ns == DECONVOLUTION) begin
        if (cnt_state_8_x == 2 && cnt_state_8_y == 0) begin
            cnt_test <= cnt_test + 1;
        end
        else cnt_test <= cnt_test;
    end
    else if (state_cs == MAXPOOLING) begin
        if (cnt_flag_7 == 3) begin
            cnt_test <= cnt_test + 1;
        end
        else cnt_test <= cnt_test;
    end
    else if (state_cs == WAIT2) begin
        cnt_test <= 0;
    end
    else if (state_cs == OUT) begin
        if (cnt_out_bit == 19) begin
            cnt_test <= cnt_test + 1;
        end
        else cnt_test <= cnt_test;
    end
    else cnt_test <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_8 <= 0;
    end
    else if (state_cs == DECONVOLUTION) begin
        if (cnt_state_8 == 24) cnt_state_8 <= 0;
        else cnt_state_8 <= cnt_state_8 + 1;
    end
    else cnt_state_8 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_8_x <= 0;
    end
    else if (state_cs == DECONVOLUTION) begin
        if (cnt_state_8_x == 4) begin
            cnt_state_8_x <= 0;
        end
        else cnt_state_8_x <= cnt_state_8_x + 1;
    end
    else cnt_state_8_x <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_8_y <= 0;
    end
    else if (state_cs == DECONVOLUTION) begin
        if (cnt_state_8 == 24) begin
            cnt_state_8_y <= 0;
        end
        else if (cnt_state_8_x == 4) begin
            cnt_state_8_y <= cnt_state_8_y + 1;
        end
        else cnt_state_8_y <= cnt_state_8_y;
    end
    else cnt_state_8_y <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_8_in_x <= 0;
    end
    else if (state_cs == DECONVOLUTION) begin
        if (matrix_size_seq ==0) begin
            if (cnt_state_8 == 24) begin
                if (cnt_state_8_in_x == 11) cnt_state_8_in_x <= 0;
                else cnt_state_8_in_x <= cnt_state_8_in_x + 1;
            end
            else cnt_state_8_in_x <= cnt_state_8_in_x;
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_state_8 == 24) begin
                if (cnt_state_8_in_x == 19) cnt_state_8_in_x <= 0;
                else cnt_state_8_in_x <= cnt_state_8_in_x + 1;
            end
            else cnt_state_8_in_x <= cnt_state_8_in_x;
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_state_8 == 24) begin
                if (cnt_state_8_in_x == 35) cnt_state_8_in_x <= 0;
                else cnt_state_8_in_x <= cnt_state_8_in_x + 1;
            end
            else cnt_state_8_in_x <= cnt_state_8_in_x;
        end
    end
    else cnt_state_8_in_x <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_8_in_y <= 0;
    end
    else if (state_cs == DECONVOLUTION) begin
        if (matrix_size_seq == 0) begin
            if (cnt_state_8_in_x == 11 && cnt_state_8 == 24) begin
                cnt_state_8_in_y <= cnt_state_8_in_y + 1;
            end
            else cnt_state_8_in_y <= cnt_state_8_in_y;
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_state_8_in_x == 19 && cnt_state_8 == 24) begin
                cnt_state_8_in_y <= cnt_state_8_in_y + 1;
            end
            else cnt_state_8_in_y <= cnt_state_8_in_y;
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_state_8_in_x == 35 && cnt_state_8 == 24) begin
                cnt_state_8_in_y <= cnt_state_8_in_y + 1;
            end
            else cnt_state_8_in_y <= cnt_state_8_in_y;
        end
    end
    else cnt_state_8_in_y <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_state_8to9 <= 0;
    end
    else if (state_cs == DECONVOLUTION) begin
        if (cnt_state_8 == 24) begin
            cnt_state_8to9 <= cnt_state_8to9 + 1;
        end
        else cnt_state_8to9 <= cnt_state_8to9;
    end
    else cnt_state_8to9 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        web_out <= 1;
    end
    else if (state_cs == DECONVOLUTION && state_ns == DECONVOLUTION) begin
        web_out <= 0;
    end
    else if (state_cs == MAXPOOLING && state_ns == MAXPOOLING) begin
        web_out <= 0;
    end
    else web_out <= 1;
end

always @(*) begin
    if (!rst_n) begin
        memout = 0;
    end
    else if (state_cs == DECONVOLUTION) begin
        memout = convolution;
    end
    else if (state_cs == MAXPOOLING) begin
        memout = compare;
    end
    else memout = 0;
end
// =============== deconvolution ============= //

// ============ output ================= //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_out_memout <= 0;
    end
    else reg_out_memout <= out_memout;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_out_value_bit <= 0;
    end
    else if (state_cs == LOAD2) begin
        cnt_out_value_bit <= 0;
    end
    else if (state_cs == OUT && flag_out) begin
        if (cnt_out_value_bit == 19) begin
            cnt_out_value_bit <= 0;
        end
        else cnt_out_value_bit <= cnt_out_value_bit + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_out_bit <= 0;
    end
    else if (state_cs == LOAD2) begin
        cnt_out_bit <= 0;
    end
    else if (state_cs == OUT) begin
        if (cnt_out_bit == 19) begin
            cnt_out_bit <= 0;
        end
        else cnt_out_bit <= cnt_out_bit + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_out <= 0;
    end
    else if (state_cs == OUT) begin
        if (cnt_out_bit == 19) begin
            cnt_out <= cnt_out +  1;
        end
        else cnt_out <= cnt_out;
    end
    else cnt_out <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_out_0 <= 0;
    end
    else if (state_cs == IDLE) begin
        flag_out_0 <= 0;
    end
    else if (state_cs == OUT) begin
        if (matrix_size_seq == 0) begin
            if (cnt_test >= 144) begin
                flag_out_0 <= 0;
            end
            else flag_out_0 <= 1;
        end
        else if (matrix_size_seq == 1) begin
            if (cnt_test >= 400) begin
                flag_out_0 <= 0;
            end
            else flag_out_0 <= 1;
        end
        else if (matrix_size_seq == 2) begin
            if (cnt_test >= 1296) begin
                flag_out_0 <= 0;
            end
            else flag_out_0 <= 1;
        end

    end
    else flag_out_0 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_out <= 0;
    end
    else flag_out <= flag_out_0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else out_valid <= flag_out;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_value <= 0;
    end
    else if (flag_out) begin
        out_value <= reg_out_memout[cnt_out_value_bit];
    end
    else out_value <= 0;
end
// ============ output ================= //

//=======================================================
//                    SRAM
//=======================================================   
MEMORY_SUMA180_16384X8X1BM8 imgsram(.A0(addres[0]),
                            .A1(addres[1]),
                            .A2(addres[2]),
                            .A3(addres[3]),
                            .A4(addres[4]),
                            .A5(addres[5]),
                            .A6(addres[6]),
                            .A7(addres[7]),
                            .A8(addres[8]),
                            .A9(addres[9]),
                            .A10(addres[10]),
                            .A11(addres[11]),
                            .A12(addres[12]),
                            .A13(addres[13]),
                            .DO0(mem_out[0]),
                            .DO1(mem_out[1]),
                            .DO2(mem_out[2]),
                            .DO3(mem_out[3]),
                            .DO4(mem_out[4]),
                            .DO5(mem_out[5]),
                            .DO6(mem_out[6]),
                            .DO7(mem_out[7]),
                            .DI0(reg_matrix[0]),
                            .DI1(reg_matrix[1]),
                            .DI2(reg_matrix[2]),
                            .DI3(reg_matrix[3]),
                            .DI4(reg_matrix[4]),
                            .DI5(reg_matrix[5]),
                            .DI6(reg_matrix[6]),
                            .DI7(reg_matrix[7]),
                            .CK (clk),
                            .WEB(web),
                            .OE (1'b1), 
                            .CS (1'b1));

MEMORY_SUMA180_448X8X1BM4 kernalsram (  .A0 (addres_kernal[0]),
                                .A1 (addres_kernal[1]),
                                .A2 (addres_kernal[2]),
                                .A3 (addres_kernal[3]),
                                .A4 (addres_kernal[4]),
                                .A5 (addres_kernal[5]),
                                .A6 (addres_kernal[6]),
                                .A7 (addres_kernal[7]),
                                .A8 (addres_kernal[8]),
                                .DO0(kernal_mem_out[0]),
                                .DO1(kernal_mem_out[1]),
                                .DO2(kernal_mem_out[2]),
                                .DO3(kernal_mem_out[3]),
                                .DO4(kernal_mem_out[4]),
                                .DO5(kernal_mem_out[5]),
                                .DO6(kernal_mem_out[6]),
                                .DO7(kernal_mem_out[7]),
                                .DI0(reg_matrix[0]),
                                .DI1(reg_matrix[1]),
                                .DI2(reg_matrix[2]),
                                .DI3(reg_matrix[3]),
                                .DI4(reg_matrix[4]),
                                .DI5(reg_matrix[5]),
                                .DI6(reg_matrix[6]),
                                .DI7(reg_matrix[7]),
                                .CK (clk),
                                .WEB(web_kernal),
                                .OE (1'b1),
                                .CS (1'b1));

MEMORY_SUMA180_1344X20X1BM4 outputsram(.A0 (cnt_test[0]),
                                .A1 (cnt_test[1]),
                                .A2 (cnt_test[2]),
                                .A3 (cnt_test[3]),
                                .A4 (cnt_test[4]),
                                .A5 (cnt_test[5]),
                                .A6 (cnt_test[6]),
                                .A7 (cnt_test[7]),
                                .A8 (cnt_test[8]),
                                .A9 (cnt_test[9]),
                                .A10(cnt_test[10]),

                                .DO0 (out_memout[0]),
                                .DO1 (out_memout[1]),
                                .DO2 (out_memout[2]),
                                .DO3 (out_memout[3]),
                                .DO4 (out_memout[4]),
                                .DO5 (out_memout[5]),
                                .DO6 (out_memout[6]),
                                .DO7 (out_memout[7]),
                                .DO8 (out_memout[8]),
                                .DO9 (out_memout[9]),
                                .DO10(out_memout[10]),
                                .DO11(out_memout[11]),
                                .DO12(out_memout[12]),
                                .DO13(out_memout[13]),
                                .DO14(out_memout[14]),
                                .DO15(out_memout[15]),
                                .DO16(out_memout[16]),
                                .DO17(out_memout[17]),
                                .DO18(out_memout[18]),
                                .DO19(out_memout[19]),

                                .DI0 (memout[0]),
                                .DI1 (memout[1]),
                                .DI2 (memout[2]),
                                .DI3 (memout[3]),
                                .DI4 (memout[4]),
                                .DI5 (memout[5]),
                                .DI6 (memout[6]),
                                .DI7 (memout[7]),
                                .DI8 (memout[8]),
                                .DI9 (memout[9]),
                                .DI10(memout[10]),
                                .DI11(memout[11]),
                                .DI12(memout[12]),
                                .DI13(memout[13]),
                                .DI14(memout[14]),
                                .DI15(memout[15]),
                                .DI16(memout[16]),
                                .DI17(memout[17]),
                                .DI18(memout[18]),
                                .DI19(memout[19]),

                                .CK (clk),
                                .WEB(web_out),
                                .OE (1'b1), 
                                .CS (1'b1));

MEMORY_SUMA180_1024X20X1BM2  consram   (.A0  (addres_con[0]),
                                 .A1  (addres_con[1]),
                                 .A2  (addres_con[2]),
                                 .A3  (addres_con[3]),
                                 .A4  (addres_con[4]),
                                 .A5  (addres_con[5]),
                                 .A6  (addres_con[6]),
                                 .A7  (addres_con[7]),
                                 .A8  (addres_con[8]),
                                 .A9  (addres_con[9]),

                                 .DO0 (max_input[0]),
                                 .DO1 (max_input[1]),
                                 .DO2 (max_input[2]),
                                 .DO3 (max_input[3]),
                                 .DO4 (max_input[4]),
                                 .DO5 (max_input[5]),
                                 .DO6 (max_input[6]),
                                 .DO7 (max_input[7]),
                                 .DO8 (max_input[8]),
                                 .DO9 (max_input[9]),
                                 .DO10(max_input[10]),
                                 .DO11(max_input[11]),
                                 .DO12(max_input[12]),
                                 .DO13(max_input[13]),
                                 .DO14(max_input[14]),
                                 .DO15(max_input[15]),
                                 .DO16(max_input[16]),
                                 .DO17(max_input[17]),
                                 .DO18(max_input[18]),
                                 .DO19(max_input[19]),

                                 .DI0 (convolution[0]),
                                 .DI1 (convolution[1]),
                                 .DI2 (convolution[2]),
                                 .DI3 (convolution[3]),
                                 .DI4 (convolution[4]),
                                 .DI5 (convolution[5]),
                                 .DI6 (convolution[6]),
                                 .DI7 (convolution[7]),
                                 .DI8 (convolution[8]),
                                 .DI9 (convolution[9]),
                                 .DI10(convolution[10]),
                                 .DI11(convolution[11]),
                                 .DI12(convolution[12]),
                                 .DI13(convolution[13]),
                                 .DI14(convolution[14]),
                                 .DI15(convolution[15]),
                                 .DI16(convolution[16]),
                                 .DI17(convolution[17]),
                                 .DI18(convolution[18]),
                                 .DI19(convolution[19]),
                                 .CK (clk) ,
                                 .WEB(web_con) ,
                                 .OE (1'b1) ,
                                 .CS (1'b1) );
endmodule   