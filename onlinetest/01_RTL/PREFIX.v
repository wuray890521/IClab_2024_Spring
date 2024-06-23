module PREFIX (
    // input port
    clk,
    rst_n,
    in_valid,
    opt,
    in_data,
    // output port
    out_valid,
    out
);
// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;
input rst_n;
input in_valid;
input opt;
input [4:0] in_data;
output reg out_valid;
output reg signed [94:0] out;

// ===============================================================
// Reg & Wire Declaration
// ===============================================================
reg [4:0] reg_in_data;
reg in_valid_d;
reg reg_opt;
reg flag;
reg [94:0] regforOUT;


reg signed [40:0] input_arr [18:0];
reg [1:0] oprater_arr [18:0];
reg [5:0] location_arr[8:0];
reg [4:0] in_data_arr[18:0];
reg [4:0] reg_DATA [18:0] ;
reg [4:0] stack [8:0];
reg [4:0] RPE  [18:0];

reg [10:0] cnt;
reg [8:0] cnt_cal;
reg [3:0] cnt_op;

integer i, j, k ,l;


// ======================================================
//    STATE
// ======================================================
reg [5:0] state_cs, state_ns;
parameter IDLE = 6'd0;
parameter LOAD = 6'd1;
parameter CAL_0= 6'd2;
parameter CAL_1= 6'd3;
parameter OUT = 6'd4;

// ========= DELAY ======================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_d <= 0;
    end
    else in_valid_d <= in_valid;
end

// ===============================================================
//                current state
// ===============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state_cs <= IDLE;
    end
    else state_cs <= state_ns;
end
// ===============================================================
//                   next state
// ===============================================================
always @(*) begin
    case (state_cs)
        IDLE : begin
            if (in_valid | in_valid_d) begin
                state_ns = LOAD;
            end
            else state_ns = IDLE;
        end 
        LOAD : begin
            if (!in_valid && reg_opt == 0) begin
                state_ns = CAL_0;
            end
            else if (!in_valid && reg_opt == 1) begin
                state_ns = CAL_1;
            end
            else state_ns = LOAD;
        end
        CAL_0 : begin
            if (oprater_arr[0] == 1 && 
                oprater_arr[1] == 2 &&
                oprater_arr[2] == 2 &&
                oprater_arr[3] == 2 &&
                oprater_arr[4] == 2 &&
                oprater_arr[5] == 2 &&
                oprater_arr[6] == 2 &&
                oprater_arr[7] == 2 &&
                oprater_arr[8] == 2 &&
                oprater_arr[9] == 2 &&
                oprater_arr[10] == 2 && 
                oprater_arr[11] == 2 &&
                oprater_arr[12] == 2 &&
                oprater_arr[13] == 2 &&
                oprater_arr[14] == 2 &&
                oprater_arr[15] == 2 &&
                oprater_arr[16] == 2 &&
                oprater_arr[17] == 2 &&
                oprater_arr[18] == 2 ) begin
                    state_ns = OUT;
            end
            else state_ns = CAL_0;
        end
        CAL_1 : begin
            if (cnt_cal == 30) begin
                state_ns = OUT;
            end
            else state_ns = CAL_1;
        end
        OUT : begin
            state_ns = IDLE;
        end
        default : begin
            state_ns = IDLE;
        end
    endcase
end
// ===============================================================
//       Counter
// ===============================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end
    else if (state_cs == LOAD) begin
        if (!in_valid) begin
            cnt <= 0;
        end
        else cnt <= cnt + 1;
    end
    else if (state_cs == CAL_0) begin
        if (cnt == 2) begin
            cnt <= 1;
        end
        else cnt <= cnt + 1;
    end
    else if (state_cs == CAL_1) begin
        cnt <= 0;
    end

    else if (state_cs == IDLE) begin
        cnt <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_op <= 0;
    end
    else if (state_cs == LOAD) begin
        if (reg_in_data[4]) cnt_op <= cnt_op + 1;
        else cnt_op <= cnt_op;
    end
    else cnt_op <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_cal <= 0;
    end
    else if (state_cs == CAL_0) begin
        if (cnt == 0) begin
            cnt_cal <= 0;
        end
        else if(cnt==1)
           cnt_cal <= cnt_cal + 1;
    end
    else if(state_cs == CAL_1) begin
        if(flag) cnt_cal <= cnt_cal;
        else begin
          if(reg_DATA[cnt_cal]==16 || reg_DATA[cnt_cal]==17)begin
            if(stack[0]==18 || stack[0]==19)  cnt_cal <= cnt_cal;
            else cnt_cal <= cnt_cal + 1;    
          end
          else begin
            cnt_cal <= cnt_cal + 1;  
          end        
        end
    end
    else cnt_cal <= 0;
end


// ===============================================================
// Design
// ===============================================================
// ========= REG_INPUT =========================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_in_data <= 0;
    end
    else if (in_valid | in_valid_d) begin
        reg_in_data <= in_data;
    end
    else reg_in_data <= reg_in_data;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_opt <= 0;
    end
    else if (in_valid && !in_valid_d) begin
        reg_opt <= opt;
    end
    else reg_opt <= reg_opt;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 19 ; i = i + 1 ) begin
           reg_DATA[i] <= 0; 
        end
    end
    else if (in_valid_d) begin
        reg_DATA[0] <= reg_in_data;
        for (i = 0; i < 18 ; i = i + 1 ) begin
           reg_DATA[i+1] <= reg_DATA[i]; 
        end
    end
    else begin
        for (i = 0; i < 19 ; i = i + 1 ) begin
           reg_DATA[i] <= reg_DATA[i]; 
        end      
    end    
end
// ============= ARR ==============================
always @(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        for (i = 0; i < 20 ; i = i + 1 ) begin
           input_arr[i] <= 0; 
        end
    end
    else if (in_valid_d && reg_opt == 0) begin
        input_arr[cnt] <= reg_in_data[3:0];
    end
    else if (in_valid_d && reg_opt == 1) begin
        input_arr[18 - cnt] <= reg_in_data[3:0];
    end
    else if (state_cs == IDLE)begin
        for (i = 0; i < 20 ; i = i + 1 ) begin
           input_arr[i] <= 0; 
        end
    end
    else if (state_cs == CAL_0) begin
        if(cnt[0]==0)begin
            case (input_arr[location_arr[8 - cnt_cal]])
                0 : input_arr [location_arr[8 - cnt_cal]] <= input_arr[location_arr[8 - cnt_cal] + 1] + input_arr [location_arr[8 - cnt_cal] + 2];
                1 : input_arr [location_arr[8 - cnt_cal]] <= input_arr[location_arr[8 - cnt_cal] + 1] - input_arr [location_arr[8 - cnt_cal] + 2];
                2 : input_arr [location_arr[8 - cnt_cal]] <= input_arr[location_arr[8 - cnt_cal] + 1] * input_arr [location_arr[8 - cnt_cal] + 2];
                3 : input_arr [location_arr[8 - cnt_cal]] <= input_arr[location_arr[8 - cnt_cal] + 1] / input_arr [location_arr[8 - cnt_cal] + 2];
            endcase
        end
        else if (cnt==1)begin
            for(j=1;j<17;j=j+1)begin    
                input_arr[location_arr[8 - cnt_cal] + j]   <= input_arr[location_arr[8 - cnt_cal] + j + 2];
            end 
            input_arr[17] <= input_arr[location_arr[8 - cnt_cal] + 1]; 
            input_arr[18] <= input_arr[location_arr[8 - cnt_cal] + 2];
        end
    end
end

always @(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        for (i = 0; i < 20 ; i = i + 1 ) begin
           oprater_arr[i] <= 0; 
        end
    end
    else if (in_valid_d) begin
        oprater_arr[cnt] <= !reg_in_data[4];
    end
    else if (state_cs == IDLE)begin
        for (i = 0; i < 20 ; i = i + 1 ) begin
           oprater_arr[i] <= 0; 
        end
    end
    else if (state_cs == CAL_0) begin
        if(cnt[0]==0)begin
            oprater_arr[location_arr[8 - cnt_cal]] <= 1;
            oprater_arr[location_arr[8 - cnt_cal] + 1] <= 2;
            oprater_arr[location_arr[8 - cnt_cal] + 2] <= 2;
        end
        else if (cnt==1)begin
            for(j=1;j<17;j=j+1)begin    
                oprater_arr[location_arr[8 - cnt_cal] + j] <= oprater_arr[location_arr[8 - cnt_cal] + j + 2];
            end 
            oprater_arr[17] <= 2;
            oprater_arr[18] <= 2;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 9 ; i = i + 1) begin
            location_arr[i] <= 0;
        end
    end
    else if (state_cs == LOAD && reg_in_data[4] == 1) begin
        location_arr[cnt_op] <= cnt;
    end
    else if (state_cs == IDLE) begin
        for (i = 0; i < 9 ; i = i + 1) begin
            location_arr[i] <= 0;
        end
    end
    else begin
        for (i = 0; i < 9 ; i = i + 1) begin
            location_arr[i] <= location_arr[i];
        end
    end
end

// ======= OPT = 1 ===================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (l = 0; l < 9 ; l = l + 1) begin
            stack[l] <= 0;
        end
        flag <= 0;
    end
    else if (state_cs==IDLE) begin
        for (l = 0; l < 9 ; l = l + 1) begin
            stack[l] <= 0;
        end
        flag <= 0;
    end    
    else if(state_cs==CAL_1 && flag)begin
      if(stack[0]==18 || stack[0]==19)begin
          for (l = 0; l < 8 ; l = l + 1) begin
            stack[l] <= stack[l+1];
          end   
        flag <= flag;    
      end
      else begin
        for (l = 0; l < 9 ; l = l + 1) begin
          stack[l] <= stack[l];
        end           
        flag <= 0;
      end
    end    
    else if(state_cs==CAL_1)begin
      if (cnt_cal >19)begin
        if(stack[0]!=0)begin
            for (l = 0; l < 8 ; l = l + 1) begin
              stack[l] <= stack[l+1];
            end          
            stack[8] <= 0;
        end
        else begin
            for (l = 0; l < 8 ; l = l + 1) begin
              stack[l+1] <= stack[l];
            end 
        end
      end
      else if(reg_DATA[cnt_cal]>15)begin //means it's operator
        if(reg_DATA[cnt_cal]==18 || reg_DATA[cnt_cal]==19)begin
          stack[0] <= reg_DATA[cnt_cal];
          for (l = 0; l < 8 ; l = l + 1) begin
            stack[l+1] <= stack[l];
          end               
        end
        else begin
          if(stack[0]==18 || stack[0]==19)begin
            flag <= 1;
          end
          else begin
            stack[0] <= reg_DATA[cnt_cal];
            for (l = 0; l < 8 ; l = l + 1) begin
              stack[l+1] <= stack[l];
            end     
          end
        end
      end
    end
    else begin
        for (l = 0; l < 9 ; l = l + 1) begin
          stack[l] <= stack[l];
        end     
    end
end

always @(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        for (l = 0; l < 19 ; l = l + 1 ) begin
           RPE[l] <= 0; 
        end
    end
    else if (state_cs==IDLE) begin
        for (l = 0; l < 19 ; l = l + 1 ) begin
           RPE[l] <= 0; 
        end
    end    
    else if(state_cs==CAL_1)begin
      if (cnt_cal>19)begin
        if(stack[0]!=0)begin
           RPE[0] <= stack[0];
           for (l = 0; l < 18 ; l = l + 1 ) begin
              RPE[l+1] <= RPE[l];  
           end            
        end
        else begin
            for (l = 0; l < 19 ; l = l + 1 ) begin
               RPE[l] <= RPE[l];  
            end       
        end        
      end
      else if(reg_DATA[cnt_cal]<=15)begin //means it's operand
        RPE[0] <= reg_DATA[cnt_cal];
        for (l = 0; l < 18 ; l = l + 1 ) begin
           RPE[l+1] <= RPE[l];  
        end
      end
      else if(flag)begin
        if(stack[0]==18 || stack[0]==19)begin
          RPE[0] <= stack[0];
          for (l = 0; l < 18 ; l = l + 1 ) begin
             RPE[l+1] <= RPE[l];  
          end 
        end
        else begin
            for (l = 0; l < 19 ; l = l + 1 ) begin
               RPE[l] <= RPE[l];  
            end       
        end        
      end
      else begin
          for (l = 0; l < 19 ; l = l + 1 ) begin
             RPE[l] <= RPE[l];  
          end       
      end
    end
end

// ===============================================================
//     OUTPUT
// ===============================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (state_cs == OUT && reg_opt == 0) begin
        out_valid <= 1;
    end
    else if (state_cs == OUT && reg_opt == 1) begin
        out_valid <= 1;
    end
    else if (state_cs == IDLE) begin
        out_valid <= 0;
    end
    else out_valid <= out_valid;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out <= 0;
    end
    else if (state_cs == OUT && !reg_opt) begin
        out <= input_arr[0];
    end
    else if (state_cs == OUT && reg_opt == 1) begin
        // out <= {RPE[0],RPE[1],RPE[2],RPE[3],RPE[4],RPE[5],RPE[6],RPE[7],RPE[8],RPE[9],RPE[10],RPE[11],RPE[12],RPE[13],RPE[14],RPE[15],RPE[16],RPE[17],RPE[18]};
        out <= regforOUT;
    end
    else if (state_cs == IDLE) begin
        out <= 0;
    end
    else out <= out;
end

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) regforOUT <= 0;
    else  regforOUT <= {RPE[18],RPE[17],RPE[16],RPE[15],RPE[14],RPE[13],RPE[12],RPE[11],RPE[10],RPE[9],RPE[8],RPE[7],RPE[6],RPE[5],RPE[4],RPE[3],RPE[2],RPE[1],RPE[0]};
  end
endmodule
