module bridge(input clk, INF.bridge_inf inf);
import usertype::*;
// OUTPUT SIGNAL ======================================================== OUTPUTSIGNAL//
// AR_VALID ==================== AR_VALID //
always_ff @(posedge clk or negedge inf.rst_n)begin
    if (!inf.rst_n) begin
        inf.AR_VALID <= 0;
    end
    else if (inf.C_in_valid == 1 && inf.C_r_wb == 1) begin
        inf.AR_VALID <= 1;
    end
    else if (inf.AR_READY == 1)begin
        inf.AR_VALID <= 0;
    end
end
// AR_VALID ==================== AR_VALID //

// AR_ADDR ===================== AR_ADDR //
always_ff @(posedge clk or negedge inf.rst_n)begin
    if (!inf.rst_n) begin
        inf.AR_ADDR <= 0;
    end
    else if (inf.C_r_wb == 1)begin
        inf.AR_ADDR <= {6'b100000, inf.C_addr, 3'b000};
    end
    else begin
        inf.AR_ADDR <= inf.AR_ADDR;
    end
end
// AR_ADDR ===================== AR_ADDR //

// R_READY ======================= R_READY //
always_ff @(posedge clk or negedge inf.rst_n)begin
    if (!inf.rst_n) begin
        inf.R_READY <= 0;
    end
    else if (inf.AR_READY == 1 && inf.AR_VALID == 1)begin
        inf.R_READY <= 1;
    end
    else if (inf.R_VALID == 1) begin
        inf.R_READY <= 0;
    end
    else begin
        inf.R_READY <= inf.R_READY;
    end
end
// R_READY ======================= R_READY //

// C_out_valid =============== C_out_valid //
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)begin 
        inf.C_out_valid <= 0;
    end
    else if(inf.R_VALID == 1) begin 
        inf.C_out_valid <= 1;
    end
    else if(inf.B_VALID) begin 
        inf.C_out_valid <= 1;
    end
    else inf.C_out_valid <= 0;
end
// C_out_valid =============== C_out_valid //

// C_data_r ================== C_data_r //
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)begin 
        inf.C_data_r <= 0;
    end
    else if(inf.R_VALID == 1) begin 
        inf.C_data_r <= inf.R_DATA;
    end
    else if(inf.B_VALID == 1) begin 
        inf.C_data_r <= inf.R_DATA;
    end
    else inf.C_data_r <= 0;
end
// C_data_r ================== C_data_r //

// AW_VALID ====================== AW_VALID //
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)begin 
        inf.AW_VALID <= 0;
    end
    else if(inf.C_in_valid == 1 && inf.C_r_wb == 0) begin 
        inf.AW_VALID <= 1;
    end
    else if(inf.AW_READY) begin 
        inf.AW_VALID <= 0;
    end
end
// AW_VALID ====================== AW_VALID //

//AW_ADDR ============== AW_ADDR //
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin 
        inf.AW_ADDR <= 0;
    end
    else if (inf.C_r_wb == 1) begin
        inf.AW_ADDR <= {6'b100000, inf.C_addr, 3'b000};
    end
    else inf.AW_ADDR <= inf.AW_ADDR;
end
//AW_ADDR ============== AW_ADDR //

// W_VALID ================= W_VALID //
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin 
        inf.W_VALID <= 0;
    end
    else if (inf.AW_VALID == 1 && inf.AW_READY == 1) begin
        inf.W_VALID <= 1;
    end
    else if (inf.W_READY == 1) begin
        inf.W_VALID <= 0;
    end
    else inf.W_VALID <= inf.W_VALID;
end
// W_VALID ================= W_VALID //

// W_DATA =================== W_DATA //
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin 
        inf.W_DATA <= 0;
    end
    else if (inf.AW_VALID == 1 && inf.AW_READY == 1) begin
        inf.W_DATA <= inf.C_data_w;
    end
    else if (inf.W_READY == 1) begin
        inf.W_DATA <= 0;
    end
    else inf.W_DATA <= inf.W_DATA;
end
// W_DATA =================== W_DATA //
// B_READY ===================== B_READY //
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin 
        inf.B_READY <= 0;
    end
    else if (inf.AW_VALID == 1 && inf.AW_READY == 1) begin
        inf.B_READY <= 1;
    end
    else if (inf.B_VALID == 1) begin
        inf.B_READY <= 0;
    end
    else inf.B_READY <= inf.B_READY;
end
// B_READY ===================== B_READY //
// OUTPUT SIGNAL ======================================================== OUTPUTSIGNAL//
endmodule