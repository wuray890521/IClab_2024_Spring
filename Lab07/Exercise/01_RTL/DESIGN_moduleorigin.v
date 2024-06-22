module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
	in_matrix_A,
    in_matrix_B,
    out_idle,
    handshake_sready,
    handshake_din,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

	fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    out_matrix,

    flag_clk1_to_fifo,
    flag_fifo_to_clk1
);
input clk;
input rst_n;
input in_valid;
input [3:0] in_matrix_A;
input [3:0] in_matrix_B;
input out_idle;
output reg handshake_sready;
output reg [7:0] handshake_din;
// You can use the the custom flag ports for your design
input  flag_handshake_to_clk1;
output flag_clk1_to_handshake;

input fifo_empty;
input [7:0] fifo_rdata;
output reg fifo_rinc;
output reg out_valid;
output reg [7:0] out_matrix;
// You can use the the custom flag ports for your design
output flag_clk1_to_fifo;
input flag_fifo_to_clk1;


// =================================================================================
// ================                   reg                                     ======
// =================================================================================
reg in_valid_d;
reg [15:0] cnt ;
reg [3:0] matrix_a[15:0];
reg [3:0] matrix_b[15:0];
reg [3:0] matrix[31:0];
reg flag;

reg [3:0] reg_in_matrix_A;
reg [3:0] reg_in_matrix_B;
reg flag_handshake_to_clk1_d;
reg [7:0] fifo_rdata_d;
reg [10:0] cnt_flag;


reg [6:0] state_cs, state_ns;
parameter IDLE = 7'd0;
parameter LOAD = 7'd1;
parameter OUTHAND  = 7'd2;
parameter OUTFIFO  = 7'd3;
parameter WAIT  = 7'd4;
parameter OUT  = 7'd5;

reg flag_fifo_to_clk1_d;
reg [15:0] cnt_fifo;

reg [7:0] sol_matrix[255:0];
// make the delay in_valid ------------ make the delay in_valid //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_d <= 0;
    end
    else in_valid_d <= in_valid;
end
// make the delay in_valid ------------ make the delay in_valid //

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_fifo_to_clk1_d <= 0;
    end
    else flag_fifo_to_clk1_d <= flag_fifo_to_clk1;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fifo_rdata_d <= 0;
    end
    else fifo_rdata_d <= fifo_rdata;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_fifo <= 0;
    end
    else if (state_cs == OUTFIFO && flag_fifo_to_clk1_d) begin
        cnt_fifo <= cnt_fifo + 1;
    end
    else if (state_cs == IDLE) begin
        cnt_fifo <= 0;
    end
    else cnt_fifo <= cnt_fifo;
end
// =========================================== //
// ====              FSM               ======= //
// =========================================== //
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
            if (!in_valid) begin
                state_ns = OUTHAND;
            end
            else state_ns = LOAD;
        end
        OUTHAND : begin
            if (fifo_rinc) begin
                state_ns = OUTFIFO;
            end
            else state_ns = OUTHAND;
        end
        OUTFIFO : begin
            if (cnt_fifo == 256) begin
                state_ns = WAIT;
            end
            else state_ns = OUTFIFO;
        end
        WAIT : begin
            state_ns = OUT;
        end
        OUT : begin
            if (cnt == 255) begin
                state_ns = IDLE;
            end
            else state_ns = OUT;
        end
        default: state_ns = state_cs;
    endcase
end
// counter ========================================= counter //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end
    else if (state_cs == IDLE) begin
        cnt <= 0;
    end
    else if (state_cs == LOAD) begin
        if (in_valid_d && !in_valid) begin
            cnt <= 0;
        end
        else cnt <= cnt + 1;
    end
    else if (state_cs == OUTHAND) begin
        cnt <= 0;
    end
    else if (state_cs == OUTFIFO) begin
        if (flag_fifo_to_clk1 == 1)cnt <= cnt + 1;
        else cnt <= cnt;
    end
    else if (state_cs == WAIT) begin
        cnt <= 0;
    end
    else if (state_cs == OUT) begin
        cnt <= cnt + 1;
    end
    else cnt <= cnt;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_flag <= 0;
    end
    else if (state_cs == IDLE) begin
        cnt_flag <= 0;
    end
    // else if (handshake_sready == 1 && out_idle == 1) begin
    //     cnt_flag <= cnt_flag + 1;
    // end
    else if (flag_handshake_to_clk1 == 0 && flag_handshake_to_clk1_d == 1) begin
        cnt_flag <= cnt_flag + 1;
    end
    else cnt_flag <= cnt_flag;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_in_matrix_A <= 0;
    end
    else if (in_valid || in_valid_d) begin
        reg_in_matrix_A <= in_matrix_A;
    end
    else reg_in_matrix_A <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_in_matrix_B <= 0;
    end
    else if (in_valid || in_valid_d) begin
        reg_in_matrix_B <= in_matrix_B;
    end
    else reg_in_matrix_B <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_handshake_to_clk1_d <= 0;
    end
    else flag_handshake_to_clk1_d <= flag_handshake_to_clk1;
end
// handshake_sready ========================= handshake_sready //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        handshake_sready <= 0;
    end
    else if (state_cs == OUTHAND && cnt_flag < 33) begin
        handshake_sready <= 1;
    end
    else handshake_sready <= 0;
end
// handshake_sready ========================= handshake_sready //

// handshake_din ================================== handshake_din //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        handshake_din <= 0;
    end
    else if (state_cs == OUTHAND && cnt_flag < 33) handshake_din <= matrix[cnt_flag];
    else handshake_din <= 0;
end
// handshake_din ================================== handshake_din //

// input matrix for A =========== input matrix for A //
genvar ii;
generate
    for (ii = 0; ii < 16 ; ii = ii + 1 ) begin : input_matrixa
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                matrix[ii] <= 0;
            end
            else if (in_valid_d && cnt == ii) begin
                matrix[ii] <= reg_in_matrix_A;
            end
            else matrix[ii] <= matrix[ii];
        end
    end
endgenerate
// input matrix for A =========== input matrix for A //

// input matrix for B =========== input matrix for B //
genvar i;
generate
    for (i = 16; i < 32 ; i = i + 1 ) begin : input_matrixb
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                matrix[i] <= 0;
            end
            else if (in_valid_d && cnt == i[3:0]) begin
                matrix[i] <= reg_in_matrix_B;
            end
            else matrix[i] <= matrix[i];
        end
    end
endgenerate
// input matrix for B =========== input matrix for B //

// solution matrix =================== solution matrix //
genvar j;
generate
    for (j = 0; j < 256 ; j = j + 1 ) begin : solutionmatrixloop
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                sol_matrix[j] <= 0;
            end
            else if (state_cs == IDLE) begin
                sol_matrix[j] <= 0;
            end
            else if (cnt_fifo == j) begin
                sol_matrix[j] <= fifo_rdata_d; 
            end
            else sol_matrix[j] <= sol_matrix[j];
        end
    end
endgenerate
// solution matrix =================== solution matrix //

// out_valid ============================= out_valid //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (state_cs == OUT) begin
        out_valid <= 1;
    end
    else if (state_cs == IDLE) begin
        out_valid <= 0;
    end
    else out_valid <= out_valid;
end
// out_valid ============================= out_valid //

// out_matrix ============================ out_matrix//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_matrix <= 0;
    end
    else if (state_cs == OUT) begin
        out_matrix <= sol_matrix[cnt];
    end

    else out_matrix <= 0;
end
// out_matrix ============================ out_matrix//

// fifo_rinc ==================================================== fifo_rinc //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fifo_rinc <= 0;
    end
    else if(!fifo_empty) begin
        fifo_rinc <= 1;
    end
    else begin
        fifo_rinc <= 0;
    end
end
// fifo_rinc ==================================================== fifo_rinc //
endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    in_matrix,
    out_valid,
    out_matrix,
    busy,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [7:0] in_matrix;
output reg out_valid;
output reg [7:0] out_matrix;
output reg busy;

// You can use the the custom flag ports for your design
input  flag_handshake_to_clk2;
output flag_clk2_to_handshake;

input  flag_fifo_to_clk2;
output flag_clk2_to_fifo;
reg [7:0] in_matrix_d;

reg [10:0] cnt_mul;
reg in_valid_d;
reg [10:0] cnt_in;
reg [7:0] matrix_a[15:0];
reg [7:0] matrix_b[15:0];
reg [7:0] sol_matrix[255:0];

reg fifo_full_d;
reg [1:0] state_cs, state_ns;
parameter IDLE = 0;
parameter LOAD = 1;
parameter CAL  = 2;
parameter OUTFIFO  = 3;
// counter matrix multiplication ======== counter matrix multiplication //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_mul <= 0;
    end
    else if (state_cs == IDLE) begin
        cnt_mul <= 0;
    end
    else if (state_cs == CAL) begin
        if (cnt_mul == 255) begin
            cnt_mul <= 0;
        end
        else cnt_mul <= cnt_mul + 1;
    end
    else if (state_cs == OUTFIFO && !fifo_full) begin
        if (out_valid == 0 && cnt_mul==0) begin
            cnt_mul <= cnt_mul +1;
        end
        else if (fifo_full || out_valid == 0) begin
            cnt_mul <= cnt_mul;
        end
        else cnt_mul <= cnt_mul + 1;
    end
    else cnt_mul <= cnt_mul;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_in <= 0;
    end
    else if (state_cs == IDLE) begin
        cnt_in <= 0;
    end
    else if (!in_valid && in_valid_d) begin
        cnt_in <= cnt_in + 1;
    end
    else cnt_in <= cnt_in;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_matrix_d <= 0;
    end
    else in_matrix_d <= in_matrix;
end
// =========================================== //
// ====              FSM               ======= //
// =========================================== //
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
            if (cnt_in == 33) begin
                state_ns = CAL;
            end
            else state_ns = LOAD;
        end
        CAL : begin
            if (cnt_mul == 255) begin
                state_ns = OUTFIFO;
            end
            else state_ns = CAL;
        end
        OUTFIFO : begin
            if (cnt_mul == 257) begin
                state_ns = IDLE;
            end
            else state_ns = OUTFIFO;
        end
        default: state_ns = state_cs;
    endcase
end
// =========================================== //
// ====              FSM               ======= //
// =========================================== //

// counter matrix multiplication ======== counter matrix multiplication //
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_d <= 0;
    end
    else in_valid_d <= in_valid;
end
// counter matrix multiplication ======== counter matrix multiplication //

// input matrix a =================== input matrix a //
genvar ii;
generate
    for (ii = 0; ii < 16 ; ii = ii + 1 ) begin : input_matrixa
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                matrix_a[ii] <= 0;
            end
            // else if (state_cs == IDLE) begin
            //     matrix_a[ii] <= 0;
            // end
            else if (in_valid && cnt_in == ii) begin
                matrix_a[ii] <= {4'b0000,in_matrix};
            end
            else matrix_a[ii] <= matrix_a[ii];
        end
    end
endgenerate
// input matrix a =================== input matrix a //

// input matrix b ======================= input matrix b //
genvar i;
generate
    for (i = 16; i < 32 ; i = i + 1 ) begin : input_matrixb
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                matrix_b[i[3:0]] <= 0;
            end
            else if (state_cs == IDLE) begin
                matrix_b[i[3:0]] <= 0;
            end
            else if (in_valid && cnt_in == i) begin
                matrix_b[i[3:0]] <= {4'b0000,in_matrix};
            end
            else matrix_b[i[3:0]] <= matrix_b[i[3:0]];
        end
    end
endgenerate
// input matrix b ======================= input matrix b //

// culculate sol_matrix ======================== culculate sol_matrix //
genvar j;
generate
    for (j = 0; j < 256 ; j = j + 1 ) begin : cauculationloop
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                sol_matrix[j] <= 0;
            end
            else if (state_cs == IDLE) begin
                sol_matrix[j] <= 0;
            end
            else if (state_cs == CAL && cnt_mul == j) begin
                sol_matrix[j] <= matrix_a[j >> 4] * matrix_b[j[3:0]]; 
            end
            else sol_matrix[j] <= sol_matrix[j];
        end
    end
endgenerate
// culculate sol_matrix ======================== culculate sol_matrix //



// out_matrix ================================================ out_matrix //
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) fifo_full_d <= 0;
  else  fifo_full_d <= fifo_full;
    
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_matrix <= 0;
    end
    else if (state_cs == OUTFIFO && !fifo_full) begin
        if (fifo_full == 1) begin
            out_matrix <= out_matrix;
        end
        else if(fifo_full_d) begin
            out_matrix <= out_matrix;    
        end
        else out_matrix <= sol_matrix[cnt_mul];
    end
    
    // else if (state_cs == OUTFIFO && !fifo_full) begin
        // if (fifo_full == 1 || out_valid == 0) begin
            // out_matrix <= out_matrix;
    //    end
        // else out_matrix <= sol_matrix[cnt_mul];
    // end
    // else if (state_cs == OUTFIFO) begin
    //     if (flag_fifo_to_clk2 == 0) begin
    //         out_matrix <= out_matrix;
    //     end
    //     else out_matrix <= sol_matrix[cnt_mul];
    // end
    // else if (state_cs == OUTFIFO) begin
    //     if (fifo_full) begin
    //         out_matrix <= out_matrix;
    //     end
    //     else out_matrix <= sol_matrix[cnt_mul];
    // end
end
// out_matrix ================================================ out_matrix //

// FIFO control signal =================== FIFO control signal //
// .wclk (clk2)
// .rclk (clk1)
// .rst_n (rst_n)
// .winc (out_matrix_valid_clk2)
// .wdata (out_matrix_clk2)
// .wfull (fifo_full)
// .rinc (fifo_rinc)
// .rdata (fifo_rdata)
// .rempty (fifo_empty)

// .flag_fifo_to_clk2(flag_fifo_to_clk2)
// .flag_clk2_to_fifo(flag_clk2_to_fifo)

// .flag_fifo_to_clk1(flag_fifo_to_clk1)
// .flag_clk1_to_fifo(flag_clk1_to_fifo)
// out_valid ============================================== out_valid //
// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         out_valid <= 0;
//     end
//     // else if (state_cs == OUTFIFO && !fifo_full) begin
//     //     out_valid <= 1;
//     // end
//     else out_valid <= 0;
// end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (state_cs == OUTFIFO && !fifo_full) begin
        out_valid <= 1;
    end
    else out_valid <= 0;
end
// out_valid ============================================== out_valid //

// busy ===================================================== busy //
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        busy <= 0;
    end
    else if (state_cs == OUTFIFO) begin
        busy <= 1;
    end 
    else begin
        busy <= 0;
    end
end

// busy ===================================================== busy //



// FIFO control signal =================== FIFO control signal //
endmodule