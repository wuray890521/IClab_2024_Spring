module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
                    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
                    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf,
                    
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 

);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;

reg          [31:0]                             araddr_ins;
reg signed   [31:0]                            araddr_data;
reg                                          arvalid_ins;
reg                                          arvalid_data;
wire rlast_ins;
wire rlast_data;
wire rvalid_ins;
wire rvalid_data;
reg  rready_ins;
reg  rready_data;
reg [DRAM_NUMBER * DATA_WIDTH-1:0] rdata_m_inf_seq;
// -----------------------------

//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;

reg [2:0]         op_code;
reg [3:0]         rs;
reg [3:0]         rt;
reg [3:0]         rd;
reg               func;
reg signed [4:0]  imm;
wire [12:0]        addr;

parameter offset = 16'h1000;
//###########################################
//
// Wrtie down your design below
//
//###########################################

//####################################################
//               reg & wire
//####################################################
// ============== FSM reg ================== //
reg [4:0] state_cs, state_ns;
parameter IDLE = 0;
parameter READINS = 1;
parameter READ   = 2;
parameter WAIT   = 3;
parameter EXE = 11;

parameter ADD_ins    = 4;
parameter SUB_ins    = 5;
parameter SET_ins    = 6;
parameter MUL_ins    = 14;

parameter LOAD_ins   = 7;
parameter LOAD_addr  = 12;

parameter STORE_ins  = 8;
parameter STORE_addr  = 15;

parameter BRANCH_ins = 9;
parameter BRANCH = 16;

parameter DETER_ins  = 10;
parameter DETER_ins_1  = 17;
parameter DETER_ins_2  = 18;
parameter DETER_ins_3  = 19;
parameter DETER_ins_4  = 20;
parameter DETER = 21;
parameter DETER_final = 22;

parameter FINAL = 13;
// ============== FSM reg ================== //
// =============== SRAM reg ================= //
reg [6:0] addres_ins;
reg [6:0] addres_ins_d;
// reg signed [7:0] addres_branch;
reg web_ins;
// =============== SRAM reg ================= //
// ================== INS reg ================== //
reg [15:0] ins_seq;
reg [15:0] ins;
reg [15:0] reg_ins;
// ================== INS reg ================== //
// dram write //
reg awvalid_data;
reg [31:0] awaddr_data;
reg signed [15:0] addr_data_0;
reg wvalid_data;
reg wlast;
reg signed [15:0] wdata;
reg bready;
// dram write //
// ============== LOAD_ins ========================= //
reg signed [15:0] rs_data;
// ============== LOAD_ins ========================= //
// ============== add / sub ins ==================== //
reg signed [15:0] cauculate1;
reg signed [15:0] cauculate2;
reg signed [15:0] cauculate;
reg [3:0] cnt_add_sub;
// ============== add / sub ins ==================== //
// ========== branch ========== //
reg signed [15:0] branch;
reg flag_branch;
// ========== branch ========== //
// ============== DETERMIN_INS ================= //
reg signed [4:0] coeff_a;
reg signed [9:0] coeff_b;
// reg signed [31:0] determin;

reg [10:0] cnt_det_cal;

reg [2:0] det_cal_x;
reg [2:0] det_cal_x_1;
reg [2:0] det_cal_x_2;

// reg [2:0] det_1_y;
// reg [2:0] det_2_y;
// reg [2:0] det_3_y;
// reg [2:0] det_4_y;

reg signed [68:0] determin1;
reg signed [68:0] determin1_sig;
reg signed [68:0] determin1_1;
reg signed [68:0] determin1_2;
reg signed [68:0] determin1_3;

reg signed [68:0] determin_out;

reg signed [68:0] determin_coe;

reg signed [68:0] determin_sol_m;

reg signed [68:0] determin_sol;

reg signed [100:0] temp;
reg signed [68:0] temp_sol;

reg signed [15:0] core_matrix [0:3][0:3];

integer i, j;
// ============== DETERMIN_INS ================= //
// ====================== current_pc_code ========= //
reg [15:0] cs_pc;
// ====================== current_pc_code ========= //
// ================= FSM ======================= //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) state_cs <= IDLE;
  else state_cs <= state_ns;
end

always @(*) begin
    case (state_cs)
      IDLE : begin
        state_ns = READINS;
      end
      READINS : begin
        if (arready_m_inf[1] && arvalid_ins) begin
          state_ns = READ;
        end
        else state_ns = READINS;
      end
      READ : begin
        if (addres_ins == 127) begin
          state_ns = WAIT;
        end
        else state_ns = READ;
      end
      WAIT : begin
        if (addres_ins == addres_ins_d) begin
          state_ns = EXE;
        end
        else state_ns = WAIT;
      end
      EXE : begin
        if (op_code == 3'b010) begin
          state_ns = LOAD_ins;
        end
        else if (op_code == 3'b000) begin
          if (func == 1) begin
            state_ns = SUB_ins;
          end
          else state_ns = ADD_ins;
        end
        else if (op_code == 3'b001) begin
          if (func == 1) begin
            state_ns = MUL_ins;
          end
          else state_ns = SET_ins;
        end
        else if (op_code == 3'b011) begin
          state_ns = STORE_ins;
        end
        else if (op_code == 3'b100) begin
          state_ns = BRANCH_ins;
        end
        else if (op_code == 3'b111) begin
          state_ns = DETER_ins;
        end
        else state_ns = EXE;
      end
      LOAD_ins : begin
        if (arready_m_inf[0] == 1) begin
          state_ns = LOAD_addr;
        end
        else state_ns = LOAD_ins;
      end
      LOAD_addr : begin
        if (rlast_data == 1) begin
          state_ns = FINAL;
        end
        else state_ns = LOAD_addr;
      end
      ADD_ins : begin
        if (cnt_add_sub == 2) begin
          state_ns = FINAL;
        end
        else state_ns = ADD_ins;
      end
      SUB_ins : begin
        if (cnt_add_sub == 2) begin
          state_ns = FINAL;
        end
        else state_ns = SUB_ins;        
      end
      MUL_ins : begin
        if (cnt_add_sub == 2) begin
          state_ns = FINAL;
        end
        else state_ns = MUL_ins;           
      end
      SET_ins : begin
        if (cnt_add_sub == 2) begin
          state_ns = FINAL;
        end
        else state_ns = state_cs;
      end

      STORE_ins : begin
        if (awready_m_inf == 1 && awvalid_m_inf == 1) begin
          state_ns = STORE_addr;
        end
        else state_ns = STORE_ins;
      end
      STORE_addr : begin
        if (wlast_m_inf == 1 && wready_m_inf == 1) begin
          state_ns = FINAL;
        end
        else state_ns = STORE_addr;
      end
      BRANCH_ins : begin
        state_ns = BRANCH;
      end
      BRANCH : begin
        state_ns = FINAL;
      end
      DETER_ins : begin
        if (cnt_add_sub == 15) begin
          state_ns = DETER_ins_1;
        end
        else state_ns = state_cs;
      end
      DETER_ins_1 : begin
        if (cnt_det_cal == 9) begin
          state_ns = DETER_ins_2;
        end
        else state_ns = state_cs;
      end
      DETER_ins_2 : begin
        if (cnt_det_cal == 9) begin
          state_ns = DETER_ins_3;
        end
        else state_ns = state_cs;
      end
      DETER_ins_3 : begin
        if (cnt_det_cal == 9) begin
          state_ns = DETER_ins_4;
        end
        else state_ns = state_cs;
      end
      DETER_ins_4 : begin
        if (cnt_det_cal == 9) begin
          state_ns = DETER;
        end
        else state_ns = state_cs;
      end
      DETER : begin
        if (cnt_det_cal == 1) begin
          state_ns = DETER_final;
        end
        else state_ns = state_cs;
      end
      DETER_final : begin
        if (cnt_det_cal == 2) begin
          state_ns = FINAL;
        end
        else state_ns = state_cs;
      end
      FINAL : begin
        if (addres_ins == 127) begin
          state_ns = READINS;
        end
        else if (addres_ins == 127 && addres_ins_d >= 110) begin
          state_ns = READINS;
        end
        else if (flag_branch && addres_ins == 0) begin
          state_ns = READINS;
        end
        else state_ns = WAIT;
      end
      default: state_ns = state_cs;
    endcase
end
// ================= FSM ======================= //

// ====================== DRAM WRITE =================== //
assign awid_m_inf = 0;
assign awburst_m_inf = 4'b0101;
assign awsize_m_inf = 6'b001001;
assign awlen_m_inf = 14'b00_0000_0000_0000;
assign awvalid_m_inf = awvalid_data;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    awvalid_data <= 0;
  end
  else if (state_cs == STORE_ins && state_ns == STORE_ins) begin
    awvalid_data <= 1;
  end
  else awvalid_data <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    awaddr_data <= 32'h1000;
  end
  else if (state_cs == STORE_ins) begin
    awaddr_data <= addr_data_0 + offset;
  end
  else awaddr_data <= awaddr_data;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    wvalid_data <= 0;
  end
  else if (state_cs == STORE_addr || state_ns == STORE_addr) begin
    if (awvalid_m_inf && awready_m_inf) wvalid_data <= 1;
    else if (wready_m_inf) begin
      wvalid_data <= 0;
    end
    else wvalid_data <= wvalid_data;
  end
  else wvalid_data <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    wlast <= 0;
  end
  else if (state_cs == STORE_addr || state_ns == STORE_addr) begin
    if (awvalid_m_inf && awready_m_inf) wlast <= 1;
    else if (wready_m_inf) begin
      wlast <= 0;
    end
    else wlast <= wlast;
  end
  else wlast <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    wdata <= 0;
  end
  else if (state_cs == STORE_addr) begin
    case (rt)
      0 : wdata <= core_r0 ;
      1 : wdata <= core_r1 ;
      2 : wdata <= core_r2 ;
      3 : wdata <= core_r3 ;
      4 : wdata <= core_r4 ;
      5 : wdata <= core_r5 ;
      6 : wdata <= core_r6 ;
      7 : wdata <= core_r7 ;
      8 : wdata <= core_r8 ;
      9 : wdata <= core_r9 ;
      10: wdata <= core_r10;
      11: wdata <= core_r11;
      12: wdata <= core_r12;
      13: wdata <= core_r13;
      14: wdata <= core_r14;
      15: wdata <= core_r15;
      default: wdata <= 0;
    endcase
  end
  else wdata <= wdata;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    bready <= 0;
  end
  else if (awvalid_m_inf && awready_m_inf) bready <= 1;
  else if (bvalid_m_inf) begin
    bready <= 0;
  end
  else bready <= bready;
end

assign wdata_m_inf = wdata;
assign wlast_m_inf = wlast;
assign awaddr_m_inf = awaddr_data;
assign wvalid_m_inf = wvalid_data;
assign bready_m_inf = bready;
// ====================== DRAM WRITE =================== //

// =========================== DRAM READ INS ===================== //
assign arid_m_inf = 0;
assign arburst_m_inf = 4'b0101;
assign arsize_m_inf = 6'b001001;
assign arlen_m_inf = 14'b11_1111_1000_0000;

// arvalid_m_inf
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    arvalid_ins <= 0;
  end
  else if (state_cs == READINS && state_ns == READINS) begin
    arvalid_ins <= 1;
  end
  else arvalid_ins <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    arvalid_data <= 0;
  end
  else if (state_cs == LOAD_ins && state_ns == LOAD_ins) begin
    arvalid_data <= 1;
  end
  else arvalid_data <= 0;
end

assign arvalid_m_inf = {arvalid_ins, arvalid_data};
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    araddr_ins <= 16'h1000;
  end
  else if (state_cs == READINS) begin
    if (cs_pc > 16'h1f00) begin
      araddr_ins <= 16'h1f00;;
    end
    else araddr_ins <= cs_pc;
  end
  // else if (flag_branch) begin
  //   if (cs_pc > 16'h1f00) begin
  //     araddr_ins <= 16'h1f00;
  //   end
  //   else araddr_ins <= araddr_ins;
  // end
  else araddr_ins <= araddr_ins;
end


always @(*) begin
  addr_data_0 <= (rs_data + imm) <<< 1;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    araddr_data <= 0;
  end
  else if (state_cs == IDLE) begin
    araddr_data <= 32'h00001000;
  end
  else if (state_cs == LOAD_ins) begin
    araddr_data <= addr_data_0[11:0] + offset;
  end
  else araddr_data <= araddr_data;
end

assign araddr_m_inf = {araddr_ins, araddr_data};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rready_ins <= 0;
  end
  else if (state_ns == READ) begin
    if (rlast_m_inf[1]) begin
      rready_ins <= 0;
    end
    else rready_ins <= 1;
  end
  else rready_ins <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rready_data <= 0;
  end
  else if (state_ns == LOAD_addr) begin
    if (state_cs != LOAD_addr) rready_data <= 1;
    else if (rlast_data == 1) begin
      rready_data <= 0;
    end
    else rready_data <= rready_data;
  end
  else rready_data <= 0;
end
assign rready_m_inf = {rready_ins, rready_data};

assign rvalid_ins = rvalid_m_inf[1];
assign rvalid_data = rvalid_m_inf[0];
assign rlast_ins = rlast_m_inf[1];
assign rlast_data = rlast_m_inf[0];
// =========================== DRAM READ INS ===================== //
// =============================================
// SSSSSSSS  RRRRRRRRR      AAAA     MMM     MMM
// SS        RR     RRR    AA  AA    MMMMM  MMMM
// SSSSSSSS  RRRRRRRRR    AA    AA   MM  MMMM  M
//       SS  RR    RR    AAAAAAAAAA  MM   MM   M
// SSSSSSSS  RR     RRR AA        AA MM        M
// ======== INS SRAM ===========================
// ============ INS SRAM =============== //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    reg_ins <= 0;
  end
  else reg_ins <= ins;
end
// rs = cauculate1 
// rt = cauculate2
wire [4:0] imm_data;
assign imm_data = (imm[4]) ? -imm : imm;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    addres_ins <= 0;
  end
  else if (state_cs == READINS) begin
    addres_ins <= 0;
  end
  else if (state_cs == READ) begin
    if (web_ins) addres_ins <= addres_ins;
    else begin
      if (addres_ins < 127) begin
        addres_ins <= addres_ins + 1;
      end
      else if (addres_ins == 127) begin
        if (cs_pc > 16'h1f00) begin
          addres_ins <= cs_pc[7:0] >> 1;
        end
        else addres_ins <= 0;
      end
    end
      
  end
  else if (state_cs == FINAL) begin
    if (flag_branch) addres_ins <= addres_ins;
    else addres_ins <= addres_ins + 1;
  end
  else if (state_cs == BRANCH) begin
    if (branch == 0) begin
      if (imm[4] == 1) begin
        if (addres_ins + 1 - imm_data < 127) begin
            addres_ins <= addres_ins - imm_data + 1;
        end
        else addres_ins <= 0;
      end
      else begin
        if (addres_ins + 1 + imm_data < 127) begin
            addres_ins <= addres_ins + imm_data + 1;
        end
        else addres_ins <= 127;
      end
    end
    else addres_ins <= addres_ins;
  end
  else addres_ins <= addres_ins;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    addres_ins_d <= 0;
  end
  else begin
    addres_ins_d <= addres_ins;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    web_ins <= 1;
  end
  else if (rvalid_ins) begin
    web_ins <= 0;
  end
  else web_ins <= 1;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ins_seq <= 0;
  end
  else ins_seq <= rdata_m_inf[31:16];
end

always @(*) begin
  if (!rst_n) begin
    op_code = 0;
    rs 	    = 0;
    rt 	    = 0;
    rd 	    = 0;
    func    = 0;
    imm 	  = 0;
  end
  else begin
    op_code = reg_ins[15:13];
    rs 	    = reg_ins[12:9];
    rt 	    = reg_ins[8:5];
    rd 	    = reg_ins[4:1];
    func    = reg_ins[0];
    imm 	  = reg_ins[4:0];
  end
end
// ============ INS SRAM =============== //

// ==================== core ======================= //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r0 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 0) begin
      core_r0 <= rdata_m_inf[15:0];
    end
    else core_r0 <= core_r0;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 0) begin
      core_r0 <= cauculate;
    end
    else core_r0 <= core_r0;
  end
  else if (state_cs == DETER_final) begin
    core_r0 <= temp_sol;
  end
  else core_r0 <= core_r0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r1 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 1) begin
      core_r1 <= rdata_m_inf[15:0];
    end
    else core_r1 <= core_r1;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 1) begin
      core_r1 <= cauculate;
    end
    else core_r1 <= core_r1;
  end
  else core_r1 <= core_r1;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r2 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 2) begin
      core_r2 <= rdata_m_inf[15:0];
    end
    else core_r2 <= core_r2;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 2) begin
      core_r2 <= cauculate;
    end
    else core_r2 <= core_r2;
  end

  else core_r2 <= core_r2;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r3 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 3) begin
      core_r3 <= rdata_m_inf[15:0];
    end
    else core_r3 <= core_r3;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 3) begin
      core_r3 <= cauculate;
    end
    else core_r3 <= core_r3;
  end
  else core_r3 <= core_r3;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r4 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 4) begin
      core_r4 <= rdata_m_inf[15:0];
    end
    else core_r4 <= core_r4;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 4) begin
      core_r4 <= cauculate;
    end
    else core_r4 <= core_r4;
  end
  else core_r4 <= core_r4;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r5 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 5) begin
      core_r5 <= rdata_m_inf[15:0];
    end
    else core_r5 <= core_r5;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 5) begin
      core_r5 <= cauculate;
    end
    else core_r5 <= core_r5;
  end
  else core_r5 <= core_r5;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r6 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 6) begin
      core_r6 <= rdata_m_inf[15:0];
    end
    else core_r6 <= core_r6;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 6) begin
      core_r6 <= cauculate;
    end
    else core_r6 <= core_r6;
  end
  else core_r6 <= core_r6;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r7 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 7) begin
      core_r7 <= rdata_m_inf[15:0];
    end
    else core_r7 <= core_r7;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 7) begin
      core_r7 <= cauculate;
    end
    else core_r7 <= core_r7;
  end
  else core_r7 <= core_r7;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r8 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 8) begin
      core_r8 <= rdata_m_inf[15:0];
    end
    else core_r8 <= core_r8;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 8) begin
      core_r8 <= cauculate;
    end
    else core_r8 <= core_r8;
  end
  else core_r8 <= core_r8;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r9 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 9) begin
      core_r9 <= rdata_m_inf[15:0];
    end
    else core_r9 <= core_r9;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 9) begin
      core_r9 <= cauculate;
    end
    else core_r9 <= core_r9;
  end
  else core_r9 <= core_r9;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r10 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 10) begin
      core_r10 <= rdata_m_inf[15:0];
    end
    else core_r10 <= core_r10;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 10) begin
      core_r10 <= cauculate;
    end
    else core_r10 <= core_r10;
  end
  else core_r10 <= core_r10;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r11 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 11) begin
      core_r11 <= rdata_m_inf[15:0];
    end
    else core_r11 <= core_r11;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 11) begin
      core_r11 <= cauculate;
    end
    else core_r11 <= core_r11;
  end
  else core_r11 <= core_r11;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r12 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 12) begin
      core_r12 <= rdata_m_inf[15:0];
    end
    else core_r12 <= core_r12;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 12) begin
      core_r12 <= cauculate;
    end
    else core_r12 <= core_r12;
  end
  else core_r12 <= core_r12;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r13 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 13) begin
      core_r13 <= rdata_m_inf[15:0];
    end
    else core_r13 <= core_r13;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 13) begin
      core_r13 <= cauculate;
    end
    else core_r13 <= core_r13;
  end
  else core_r13 <= core_r13;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r14 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 14) begin
      core_r14 <= rdata_m_inf[15:0];
    end
    else core_r14 <= core_r14;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 14) begin
      core_r14 <= cauculate;
    end
    else core_r14 <= core_r14;
  end
  else core_r14 <= core_r14;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r15 <= 0;
  end
  else if (state_cs == LOAD_addr) begin
    if (rt == 15) begin
      core_r15 <= rdata_m_inf[15:0];
    end
    else core_r15 <= core_r15;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    if (rd == 15) begin
      core_r15 <= cauculate;
    end
    else core_r15 <= core_r15;
  end
  else core_r15 <= core_r15;
end

// ==================== core ======================= //

// ============== LOAD_ins =============== //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rs_data <= 0;
  end
  else if (state_cs == EXE) begin
    case (rs) 
      0  : rs_data <=  core_r0;
      1  : rs_data <=  core_r1;
      2  : rs_data <=  core_r2;
      3  : rs_data <=  core_r3;
      4  : rs_data <=  core_r4;
      5  : rs_data <=  core_r5;
      6  : rs_data <=  core_r6;
      7  : rs_data <=  core_r7;
      8  : rs_data <=  core_r8;
      9  : rs_data <=  core_r9;
      10 : rs_data <= core_r10;
      11 : rs_data <= core_r11;
      12 : rs_data <= core_r12;
      13 : rs_data <= core_r13;
      14 : rs_data <= core_r14;
      15 : rs_data <= core_r15;
      default: rs_data <= rs_data;
    endcase
  end
  else rs_data <= rs_data;
end
// ============== LOAD_ins =============== //

// ==================== CAL ADD AND SUB ================ //
// rs - rt => cauculate1 - cauculate2 = cauculate
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cauculate1 <= 0;
  end
  else if (state_cs == EXE) begin
    case (rs) 
      0  : cauculate1 <=  core_r0;
      1  : cauculate1 <=  core_r1;
      2  : cauculate1 <=  core_r2;
      3  : cauculate1 <=  core_r3;
      4  : cauculate1 <=  core_r4;
      5  : cauculate1 <=  core_r5;
      6  : cauculate1 <=  core_r6;
      7  : cauculate1 <=  core_r7;
      8  : cauculate1 <=  core_r8;
      9  : cauculate1 <=  core_r9;
      10 : cauculate1 <= core_r10;
      11 : cauculate1 <= core_r11;
      12 : cauculate1 <= core_r12;
      13 : cauculate1 <= core_r13;
      14 : cauculate1 <= core_r14;
      15 : cauculate1 <= core_r15;
      default: cauculate1 <= cauculate1;
    endcase
  end
  else cauculate1 <= cauculate1;
end
// ========= BRANCH_ins ========== //
always @(*) begin
  branch = cauculate1 - cauculate2;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    flag_branch <= 0;
  end
  else if (state_cs == BRANCH_ins || state_cs == BRANCH) begin
    if (branch == 0) flag_branch <= 1;
    else flag_branch <= 0;
  end
  else flag_branch <= 0;
end
// ========= BRANCH_ins ========== //

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cauculate2 <= 0;
  end
  else if (state_cs == EXE) begin
    case (rt) 
      0  : cauculate2 <=  core_r0;
      1  : cauculate2 <=  core_r1;
      2  : cauculate2 <=  core_r2;
      3  : cauculate2 <=  core_r3;
      4  : cauculate2 <=  core_r4;
      5  : cauculate2 <=  core_r5;
      6  : cauculate2 <=  core_r6;
      7  : cauculate2 <=  core_r7;
      8  : cauculate2 <=  core_r8;
      9  : cauculate2 <=  core_r9;
      10 : cauculate2 <= core_r10;
      11 : cauculate2 <= core_r11;
      12 : cauculate2 <= core_r12;
      13 : cauculate2 <= core_r13;
      14 : cauculate2 <= core_r14;
      15 : cauculate2 <= core_r15;
      default: cauculate2 <= cauculate2;
    endcase
  end
  else cauculate2 <= cauculate2;
end
// =========== SUB_ins =============== //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cauculate <= 0;
  end
  else if (state_cs == SUB_ins) begin
    cauculate <= cauculate1 - cauculate2;
  end
  else if (state_cs == ADD_ins) begin
    cauculate <= cauculate1 + cauculate2;
  end
  else if (state_cs == MUL_ins) begin
    cauculate <= cauculate1 * cauculate2;
  end
  else if (state_cs == SET_ins) begin
    cauculate <= (cauculate1 < cauculate2) ? 1 : 0;
  end
  else cauculate <= cauculate;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cnt_add_sub <= 0;
  end
  else if (state_cs == ADD_ins || state_cs == SUB_ins || state_cs == MUL_ins || state_cs == SET_ins) begin
    cnt_add_sub <= cnt_add_sub + 1;
  end
  else if (state_cs == DETER_ins) begin
    if (cnt_add_sub == 15) cnt_add_sub <= 0;
    else cnt_add_sub <= cnt_add_sub + 1;
  end
  else cnt_add_sub <= 0;
end
// ====================== DETER_ins =============== //
always @(*) begin
  if (!rst_n) begin
    coeff_a = 0;
    coeff_b = 0;
  end
  else begin
    coeff_a = reg_ins[12:9];
    coeff_b = reg_ins[8:0];
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for ( i = 0; i < 4 ; i = i + 1 ) begin
      for ( j = 0; j < 4 ; j = j + 1 ) begin
        core_matrix[i][j] <= 0;
      end
    end
  end
  else if (state_cs == DETER_ins) begin
    case (cnt_add_sub) 
      0  : core_matrix[0][0] <=  core_r0;
      1  : core_matrix[0][1] <=  core_r1;
      2  : core_matrix[0][2] <=  core_r2;
      3  : core_matrix[0][3] <=  core_r3;
      4  : core_matrix[1][0] <=  core_r4;
      5  : core_matrix[1][1] <=  core_r5;
      6  : core_matrix[1][2] <=  core_r6;
      7  : core_matrix[1][3] <=  core_r7;
      8  : core_matrix[2][0] <=  core_r8;
      9  : core_matrix[2][1] <=  core_r9;
      10 : core_matrix[2][2] <= core_r10;
      11 : core_matrix[2][3] <= core_r11;
      12 : core_matrix[3][0] <= core_r12;
      13 : core_matrix[3][1] <= core_r13;
      14 : core_matrix[3][2] <= core_r14;
      15 : core_matrix[3][3] <= core_r15;
      default: begin
        core_matrix[0][0] <= core_matrix[0][0];
        core_matrix[0][1] <= core_matrix[0][1];
        core_matrix[0][2] <= core_matrix[0][2];
        core_matrix[0][3] <= core_matrix[0][3];
        core_matrix[1][0] <= core_matrix[1][0];
        core_matrix[1][1] <= core_matrix[1][1];
        core_matrix[1][2] <= core_matrix[1][2];
        core_matrix[1][3] <= core_matrix[1][3];
        core_matrix[2][0] <= core_matrix[2][0];
        core_matrix[2][1] <= core_matrix[2][1];
        core_matrix[2][2] <= core_matrix[2][2];
        core_matrix[2][3] <= core_matrix[2][3];
        core_matrix[3][0] <= core_matrix[3][0];
        core_matrix[3][1] <= core_matrix[3][1];
        core_matrix[3][2] <= core_matrix[3][2];
        core_matrix[3][3] <= core_matrix[3][3];
      end
    endcase
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cnt_det_cal <= 0;
  end
  else if (state_cs == DETER_ins_1 || state_cs == DETER_ins_2 || state_cs == DETER_ins_3 || state_cs == DETER_ins_4) begin
    if (cnt_det_cal == 9) cnt_det_cal <= 0;
    else cnt_det_cal <= cnt_det_cal + 1;
  end
  else if (state_cs == DETER) begin
    if (cnt_det_cal == 1) cnt_det_cal <= 0;
    else cnt_det_cal <= cnt_det_cal + 1;
  end
  else if (state_cs == DETER_final) begin
    cnt_det_cal <= cnt_det_cal + 1;
  end
  else cnt_det_cal <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    det_cal_x <= 0;
  end
  else if (state_cs == DETER_ins_1 || state_cs == DETER_ins_2 || state_cs == DETER_ins_3 || state_cs == DETER_ins_4) begin
    case (cnt_det_cal)
      0 : det_cal_x <= 1;
      1 : det_cal_x <= 2;
      2 : det_cal_x <= 3;
      3 : det_cal_x <= 3;
      4 : det_cal_x <= 2;
      5 : det_cal_x <= 1;
      default: det_cal_x <= det_cal_x;
    endcase
  end
  else det_cal_x <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    det_cal_x_1 <= 0;
  end
  else if (state_cs == DETER_ins_1 || state_cs == DETER_ins_2 || state_cs == DETER_ins_3 || state_cs == DETER_ins_4) begin
    case (cnt_det_cal)
      0 : det_cal_x_1 <= 2;
      1 : det_cal_x_1 <= 3;
      2 : det_cal_x_1 <= 1;
      3 : det_cal_x_1 <= 2;
      4 : det_cal_x_1 <= 1;
      5 : det_cal_x_1 <= 3;
      default: det_cal_x_1 <= det_cal_x_1;
    endcase
  end
  else det_cal_x_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    det_cal_x_2 <= 0;
  end
  else if (state_cs == DETER_ins_1 || state_cs == DETER_ins_2 || state_cs == DETER_ins_3 || state_cs == DETER_ins_4) begin
    case (cnt_det_cal)
      0 : det_cal_x_2 <= 3;
      1 : det_cal_x_2 <= 1;
      2 : det_cal_x_2 <= 2;
      3 : det_cal_x_2 <= 1;
      4 : det_cal_x_2 <= 3;
      5 : det_cal_x_2 <= 2;
      default: det_cal_x_2 <= det_cal_x_2;
    endcase
  end
  else det_cal_x_2 <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    determin1_1 <= 0;
  end
  else if (state_cs == DETER_ins_1) begin
    determin1_1 <= core_matrix[1][det_cal_x];
  end
  else if (state_cs == DETER_ins_2) begin
    determin1_1 <= core_matrix[0][det_cal_x];
  end
  else if (state_cs == DETER_ins_3) begin
    determin1_1 <= core_matrix[0][det_cal_x];
  end
  else if (state_cs == DETER_ins_4) begin
    determin1_1 <= core_matrix[0][det_cal_x];
  end
  else determin1_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    determin1_2 <= 0;
  end
  else if (state_cs == DETER_ins_1) begin
    determin1_2 <= core_matrix[2][det_cal_x_1];
  end
  else if (state_cs == DETER_ins_2) begin
    determin1_2 <= core_matrix[2][det_cal_x_1];
  end
  else if (state_cs == DETER_ins_3) begin
    determin1_2 <= core_matrix[1][det_cal_x_1];
  end
  else if (state_cs == DETER_ins_4) begin
    determin1_2 <= core_matrix[1][det_cal_x_1];
  end
  else determin1_2 <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    determin1_3 <= 0;
  end
  else if (state_cs == DETER_ins_1) begin
    determin1_3 <= core_matrix[3][det_cal_x_2];
  end
  else if (state_cs == DETER_ins_2) begin
    determin1_3 <= core_matrix[3][det_cal_x_2];
  end
  else if (state_cs == DETER_ins_3) begin
    determin1_3 <= core_matrix[3][det_cal_x_2];
  end
  else if (state_cs == DETER_ins_4) begin
    determin1_3 <= core_matrix[2][det_cal_x_2];
  end
  else determin1_3 <= 0;
end



always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    determin1 <= 0;
  end
  else if (state_cs == DETER_ins_1 || state_cs == DETER_ins_2 || state_cs == DETER_ins_3 || state_cs == DETER_ins_4) begin
    determin1 <= determin1_1 * determin1_2 * determin1_3;
  end
  else determin1 <= determin1;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    determin1_sig <= 0;
  end
  else if (state_cs == DETER_ins_1 || state_cs == DETER_ins_2 || state_cs == DETER_ins_3 || state_cs == DETER_ins_4) begin
    if (cnt_det_cal == 2) begin
      determin1_sig <= 0;
    end
    else if (cnt_det_cal <= 5) begin
      determin1_sig <= determin1_sig + determin1;
    end
    else determin1_sig <= determin1_sig - determin1;
  end
  else determin1_sig <= determin1_sig;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    determin_out <= 0;
  end
  else if (state_cs == DETER_ins_1) begin
    if (cnt_det_cal == 9) begin
      determin_out <= determin1_sig;
    end
    else determin_out <= determin_out;
  end
  else if (state_cs == DETER_ins_2) begin
    if (cnt_det_cal == 9) begin
      determin_out <= -determin1_sig;
    end
    else determin_out <= determin_out;
  end
  else if (state_cs == DETER_ins_3) begin
    if (cnt_det_cal == 9) begin
      determin_out <= determin1_sig;
    end
    else determin_out <= determin_out;
  end
  else if (state_cs == DETER_ins_4) begin
    if (cnt_det_cal == 9) begin
      determin_out <= -determin1_sig;
    end
    else determin_out <= determin_out;
  end
  else determin_out <= determin_out;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    determin_coe <= 0;
  end
  else if (state_cs == DETER_ins_1) begin
    if (cnt_det_cal == 9) begin
      determin_coe <= core_r0;
    end
    else determin_coe <= determin_coe;
  end
  else if (state_cs == DETER_ins_2) begin
    if (cnt_det_cal == 9) begin
      determin_coe <= core_r4;
    end
    else determin_coe <= determin_coe;
  end
  else if (state_cs == DETER_ins_3) begin
    if (cnt_det_cal == 9) begin
      determin_coe <= core_r8;
    end
    else determin_coe <= determin_coe;
  end
  else if (state_cs == DETER_ins_4) begin
    if (cnt_det_cal == 9) begin
      determin_coe <= core_r12;
    end
    else determin_coe <= determin_coe;
  end
  else determin_coe <= determin_coe;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    determin_sol_m <= 0;
  end
  else if (state_cs == DETER_ins_1) begin
    determin_sol_m <= 0;
  end
  else determin_sol_m <= determin_out * determin_coe;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    determin_sol <= 0;
  end
  else if (state_cs == DETER_ins) begin
    determin_sol <= 0;
  end
  else if (cnt_det_cal == 0 && (state_cs == DETER_ins_2 || state_cs == DETER_ins_3 || state_cs == DETER_ins_4 || state_cs == DETER)) determin_sol <= determin_sol + determin_sol_m;
  else if (state_cs == DETER && cnt_det_cal == 1) begin
    determin_sol <= determin_sol + determin_sol_m;
  end
  else if (state_cs == FINAL) begin
    determin_sol <= 0;
  end
  else determin_sol <= determin_sol;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    temp <= 0;
  end
  else if (state_cs == DETER_final) begin
    temp <= (determin_sol >>> (coeff_a * 2)) + coeff_b;
  end
  else temp <= temp;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    temp_sol <= 0;
  end
  else if (state_cs == DETER_final) begin
    if (temp > 32767) begin
      temp_sol <= 32767;
    end
    else if (temp < -32768) begin
      temp_sol <= -32768;
    end
    else temp_sol <= temp;
  end
  else temp_sol <= temp_sol;
end
// ====================== DETER_ins =============== //

// ===================== cs_pc ===================== //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cs_pc <= 16'h1000;
  end
  else if (state_cs == BRANCH) begin
    if (branch == 0 && flag_branch) begin
      if (imm[4] == 1) begin
        cs_pc <= cs_pc - (imm_data * 2) + 2;
      end
      else cs_pc <= cs_pc + (imm_data * 2) + 2;
    end
    else cs_pc <= cs_pc;
  end
  else if (state_cs == FINAL) begin
    if (flag_branch) cs_pc <= cs_pc;
    else cs_pc <= cs_pc + 2;
  end
  else cs_pc <= cs_pc;
end
// ===================== cs_pc ===================== //

// ================== output ================== //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) IO_stall <= 1;
  else if (state_cs == FINAL) begin
    IO_stall <= 0;
  end
  // else if (state_cs == READ && state_ns != READ) begin
  //   IO_stall <= 0;
  // end
  else IO_stall <= 1;
end
// ================== output ================== //

// ============ INS SRAM ================= //
SRAM_128X16X1BM2 inssram( .A0(addres_ins[0]),
                          .A1(addres_ins[1]),
                          .A2(addres_ins[2]),
                          .A3(addres_ins[3]),
                          .A4(addres_ins[4]),
                          .A5(addres_ins[5]),
                          .A6(addres_ins[6]),

                          .DO0 (ins[0]),
                          .DO1 (ins[1]),
                          .DO2 (ins[2]),
                          .DO3 (ins[3]),
                          .DO4 (ins[4]),
                          .DO5 (ins[5]),
                          .DO6 (ins[6]),
                          .DO7 (ins[7]),
                          .DO8 (ins[8]),
                          .DO9 (ins[9]),
                          .DO10(ins[10]),
                          .DO11(ins[11]),
                          .DO12(ins[12]),
                          .DO13(ins[13]),
                          .DO14(ins[14]),
                          .DO15(ins[15]),

                          .DI0 (ins_seq[0]),
                          .DI1 (ins_seq[1]),
                          .DI2 (ins_seq[2]),
                          .DI3 (ins_seq[3]),
                          .DI4 (ins_seq[4]),
                          .DI5 (ins_seq[5]),
                          .DI6 (ins_seq[6]),
                          .DI7 (ins_seq[7]),
                          .DI8 (ins_seq[8]),
                          .DI9 (ins_seq[9]),
                          .DI10(ins_seq[10]),
                          .DI11(ins_seq[11]),
                          .DI12(ins_seq[12]),
                          .DI13(ins_seq[13]),
                          .DI14(ins_seq[14]),
                          .DI15(ins_seq[15]),

                          .CK(clk),
                          .WEB(web_ins),
                          .OE(1'b1), 
                          .CS(1'b1));
// ============ INS SRAM ================= //


endmodule



















