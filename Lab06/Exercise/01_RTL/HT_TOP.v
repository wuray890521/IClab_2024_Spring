//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : HT_TOP.v
//   	Module Name : HT_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "SORT_IP.v"
//synopsys translate_on

module HT_TOP(
    // Input signals
    clk,
	  rst_n,
	  in_valid,
    in_weight, 
	  out_mode,
    // Output signals
    out_valid, 
	  out_code
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid, out_mode;
input [2:0] in_weight;

output reg out_valid, out_code;

// ===============================================================
// Reg & Wire Declaration
// ===============================================================
reg r_out_mode;

reg [3:0] cnt;
// A:14 B:13 C:12 E:11 I:10 L:9 O:8 V:7
reg in_valid_d;
reg [4:0] reg_char [14:7];
reg [5:0] reg_weight   [0:15];
reg [6:0] reg_Huffman  [14:7];
reg [3:0] bit_width  [14:7];

integer i,j,k;
// ======================================================
//    STATE
// ======================================================
parameter IDLE       = 3'd0;
parameter S_INPUT    = 3'd1; 
parameter S_CAL      = 3'd2; 
parameter S_OUTPUT1  = 3'd3; 
parameter S_OUTPUT2  = 3'd4; 
parameter S_OUTPUT3  = 3'd5; 
parameter S_OUTPUT4  = 3'd6; 
parameter S_OUTPUT5  = 3'd7; 

reg [2:0] c_s,n_s;
// ======================================================
// Soft IP
// ======================================================
parameter  IP_WIDTH = 8;
wire [IP_WIDTH*4-1:0]  OUT_character_0;
reg  [IP_WIDTH*4-1:0]  IN_character_0;
reg  [IP_WIDTH*5-1:0]  IN_weight_0;

SORT_IP #(.IP_WIDTH(IP_WIDTH)) I_SORT_IP_0(.IN_character(IN_character_0), .IN_weight(IN_weight_0), .OUT_character(OUT_character_0)); 

always @(posedge clk or negedge rst_n) //IN_character_0
  begin
    if (~rst_n) begin
    IN_character_0 <= 0;
    end
    else if(in_valid) begin
      IN_character_0[31:28] <= 4'd14;
      IN_character_0[27:24] <= 4'd13;
      IN_character_0[23:20] <= 4'd12;
      IN_character_0[19:16] <= 4'd11;
      IN_character_0[15:12] <= 4'd10;
      IN_character_0[11:8]  <= 4'd9;
      IN_character_0[7:4]   <= 4'd8;
      IN_character_0[3:0]   <= 4'd7;            
    end
    else if(in_valid_d) begin
      IN_character_0[31:28] <= 4'd15;
      IN_character_0[27:24] <= OUT_character_0[31:28];
      IN_character_0[23:20] <= OUT_character_0[27:24];
      IN_character_0[19:16] <= OUT_character_0[23:20];
      IN_character_0[15:12] <= OUT_character_0[19:16];
      IN_character_0[11:8]  <= OUT_character_0[15:12];
      IN_character_0[7:4]   <= OUT_character_0[11:8] ;
      IN_character_0[3:0]   <= 4'd6;      
    end
    else if (c_s==S_CAL)begin
      case (cnt)
      0:begin
          IN_character_0 <= IN_character_0;           
        end
      1:begin
          IN_character_0[31:28] <= 4'd15;
          IN_character_0[27:24] <= 4'd15;
          IN_character_0[23:20] <= OUT_character_0[27:24];
          IN_character_0[19:16] <= OUT_character_0[23:20];
          IN_character_0[15:12] <= OUT_character_0[19:16];
          IN_character_0[11:8]  <= OUT_character_0[15:12];
          IN_character_0[7:4]   <= OUT_character_0[11:8] ;
          IN_character_0[3:0]   <= 4'd5;           
        end
      2:begin
          IN_character_0 <= IN_character_0;  
        end  
      3:begin
          IN_character_0[31:28] <= 4'd15;
          IN_character_0[27:24] <= 4'd15;
          IN_character_0[23:20] <= 4'd15;
          IN_character_0[19:16] <= OUT_character_0[23:20];
          IN_character_0[15:12] <= OUT_character_0[19:16];
          IN_character_0[11:8]  <= OUT_character_0[15:12];
          IN_character_0[7:4]   <= OUT_character_0[11:8] ;
          IN_character_0[3:0]   <= 4'd4;           
        end        
      4:begin
          IN_character_0 <= IN_character_0;  
        end  
      5:begin
          IN_character_0[31:28] <= 4'd15;
          IN_character_0[27:24] <= 4'd15;
          IN_character_0[23:20] <= 4'd15;
          IN_character_0[19:16] <= 4'd15;
          IN_character_0[15:12] <= OUT_character_0[19:16];
          IN_character_0[11:8]  <= OUT_character_0[15:12];
          IN_character_0[7:4]   <= OUT_character_0[11:8] ;
          IN_character_0[3:0]   <= 4'd3;           
        end   
      6:begin
          IN_character_0 <= IN_character_0;  
        end  
      7:begin
          IN_character_0[31:28] <= 4'd15;
          IN_character_0[27:24] <= 4'd15;
          IN_character_0[23:20] <= 4'd15;
          IN_character_0[19:16] <= 4'd15;
          IN_character_0[15:12] <= 4'd15;
          IN_character_0[11:8]  <= OUT_character_0[15:12];
          IN_character_0[7:4]   <= OUT_character_0[11:8] ;
          IN_character_0[3:0]   <= 4'd2;           
        end    
      8:begin
          IN_character_0 <= IN_character_0;  
        end  
      9:begin
          IN_character_0[31:28] <= 4'd15;
          IN_character_0[27:24] <= 4'd15;
          IN_character_0[23:20] <= 4'd15;
          IN_character_0[19:16] <= 4'd15;
          IN_character_0[15:12] <= 4'd15;
          IN_character_0[11:8]  <= 4'd15;
          IN_character_0[7:4]   <= OUT_character_0[11:8] ;
          IN_character_0[3:0]   <= 4'd1;           
        end          
      default:  IN_character_0 <= IN_character_0; 
      endcase
    end
  end
always @(posedge clk or negedge rst_n) // IN_weight_0
  begin
    if (~rst_n) IN_weight_0 <= 0; 
    else if (in_valid) begin
       case (cnt)
        0: IN_weight_0[39:35] <= in_weight;
        1: IN_weight_0[34:30] <= in_weight;
        2: IN_weight_0[29:25] <= in_weight;
        3: IN_weight_0[24:20] <= in_weight;
        4: IN_weight_0[19:15] <= in_weight;
        5: IN_weight_0[14:10] <= in_weight;
        6: IN_weight_0[9:5]   <= in_weight;
        7: IN_weight_0[4:0]   <= in_weight;
       endcase
    end
    else if (in_valid_d)begin
      IN_weight_0[39:35] <= 5'd31;
      IN_weight_0[34:30] <= reg_weight[OUT_character_0[31:28]];
      IN_weight_0[29:25] <= reg_weight[OUT_character_0[27:24]];
      IN_weight_0[24:20] <= reg_weight[OUT_character_0[23:20]];
      IN_weight_0[19:15] <= reg_weight[OUT_character_0[19:16]];
      IN_weight_0[14:10] <= reg_weight[OUT_character_0[15:12]];
      IN_weight_0[9:5]   <= reg_weight[OUT_character_0[11:8]] ;
      IN_weight_0[4:0]   <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]];   
    end
    else if (c_s==S_CAL)begin
      case (cnt)
      0:begin
          IN_weight_0 <= IN_weight_0;           
        end
      1:begin
          IN_weight_0[39:35] <= 5'd31;
          IN_weight_0[34:30] <= 5'd31;
          IN_weight_0[29:25] <= reg_weight[OUT_character_0[27:24]];
          IN_weight_0[24:20] <= reg_weight[OUT_character_0[23:20]];
          IN_weight_0[19:15] <= reg_weight[OUT_character_0[19:16]];
          IN_weight_0[14:10] <= reg_weight[OUT_character_0[15:12]];
          IN_weight_0[9:5]   <= reg_weight[OUT_character_0[11:8]] ;
          IN_weight_0[4:0]   <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]]; 
        end
      2:begin
          IN_weight_0 <= IN_weight_0;  
        end  
      3:begin
          IN_weight_0[39:35] <= 5'd31;
          IN_weight_0[34:30] <= 5'd31;
          IN_weight_0[29:25] <= 5'd31;
          IN_weight_0[24:20] <= reg_weight[OUT_character_0[23:20]];
          IN_weight_0[19:15] <= reg_weight[OUT_character_0[19:16]];
          IN_weight_0[14:10] <= reg_weight[OUT_character_0[15:12]];
          IN_weight_0[9:5]   <= reg_weight[OUT_character_0[11:8]] ;
          IN_weight_0[4:0]   <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]]; 
        end        
      4:begin
          IN_weight_0 <= IN_weight_0;  
        end  
      5:begin
          IN_weight_0[39:35] <= 5'd31;
          IN_weight_0[34:30] <= 5'd31;
          IN_weight_0[29:25] <= 5'd31;
          IN_weight_0[24:20] <= 5'd31;
          IN_weight_0[19:15] <= reg_weight[OUT_character_0[19:16]];
          IN_weight_0[14:10] <= reg_weight[OUT_character_0[15:12]];
          IN_weight_0[9:5]   <= reg_weight[OUT_character_0[11:8]] ;
          IN_weight_0[4:0]   <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]]; 
        end   
      6:begin
          IN_weight_0 <= IN_weight_0;  
        end  
      7:begin
          IN_weight_0[39:35] <= 5'd31;
          IN_weight_0[34:30] <= 5'd31;
          IN_weight_0[29:25] <= 5'd31;
          IN_weight_0[24:20] <= 5'd31;
          IN_weight_0[19:15] <= 5'd31;
          IN_weight_0[14:10] <= reg_weight[OUT_character_0[15:12]];
          IN_weight_0[9:5]   <= reg_weight[OUT_character_0[11:8]] ;
          IN_weight_0[4:0]   <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]]; 
        end    
      8:begin
          IN_weight_0 <= IN_weight_0;  
        end  
      9:begin
          IN_weight_0[39:35] <= 5'd31;
          IN_weight_0[34:30] <= 5'd31;
          IN_weight_0[29:25] <= 5'd31;
          IN_weight_0[24:20] <= 5'd31;
          IN_weight_0[19:15] <= 5'd31;
          IN_weight_0[14:10] <= 5'd31;
          IN_weight_0[9:5]   <= reg_weight[OUT_character_0[11:8]] ;
          IN_weight_0[4:0]   <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]]; 
        end          
      default:  IN_weight_0 <= IN_weight_0; 
      endcase
    end
  end
// ===============================================================
//                current state
// ===============================================================
always @(posedge clk or negedge rst_n)
  begin
      if (!rst_n)
          c_s <= IDLE;
      else
          c_s <= n_s;
  end
// ===============================================================
//                   next state
// ===============================================================
always @(*)
  begin
      case (c_s)
          IDLE:
            begin
                if (in_valid)
                    n_s = S_INPUT;
                else
                    n_s = IDLE;
            end
          S_INPUT:
            begin
                if (in_valid==0)
                    n_s = S_CAL;
                else
                    n_s = S_INPUT;
            end
          S_CAL:
            begin
                if (cnt==10)
                    n_s = S_OUTPUT1;
                else
                    n_s = S_CAL;
            end
          S_OUTPUT1:  
                if (bit_width[10]==1)
                    n_s = S_OUTPUT2;
                else
                    n_s = S_OUTPUT1;
          S_OUTPUT2:  
                if (r_out_mode==1 & bit_width[12]==1)
                    n_s = S_OUTPUT3;
                else if(r_out_mode==0 & bit_width[9]==1)    
                    n_s = S_OUTPUT3;
                else
                    n_s = S_OUTPUT2;
          S_OUTPUT3:  
                if (r_out_mode==1 & bit_width[9]==1)
                    n_s = S_OUTPUT4;
                else if(r_out_mode==0 & bit_width[8]==1)    
                    n_s = S_OUTPUT4;
                else
                    n_s = S_OUTPUT3;                                                  
          S_OUTPUT4:  
                if (r_out_mode==1 & bit_width[14]==1)
                    n_s = S_OUTPUT5;
                else if(r_out_mode==0 & bit_width[7]==1)    
                    n_s = S_OUTPUT5;
                else
                    n_s = S_OUTPUT4;
          S_OUTPUT5:  
                if (r_out_mode==1 & bit_width[13]==1)
                    n_s = IDLE;
                else if(r_out_mode==0 & bit_width[11]==1)    
                    n_s = IDLE;
                else
                    n_s = S_OUTPUT5;                    
          default:
              n_s = IDLE;
      endcase
  end
// ===============================================================
//       Counter
// ===============================================================
always @(posedge clk or negedge rst_n) begin // cnt
  if (!rst_n)          cnt <= 0;
  else if (in_valid)   cnt <= cnt + 1;
  else if (c_s==S_CAL & cnt==10)  cnt <= 0;
  // else if (c_s==S_CAL)  cnt <= cnt + 1;
  // else if (c_s==S_OUTPUT5)  cnt <= 0;
  else                 cnt <= 0;
end

// ===============================================================
// Design
// ===============================================================
always @(posedge clk or negedge rst_n) begin // in_valid_d
  if (!rst_n) in_valid_d <= 0;
  else        in_valid_d <= in_valid;  
end
always @(posedge clk or negedge rst_n) begin // r_out_mode
  if (!rst_n)                        r_out_mode <= 0;
  else if (in_valid & in_valid_d==0) r_out_mode <= out_mode;
  else                               r_out_mode <= r_out_mode;
end

always @(posedge clk or negedge rst_n) begin // A=7 B=6 C=5 E=4 I=3 L=2 O=1 V=0, total 8 characters
    if (~rst_n) begin
      for (i=0;i<16;i=i+1) begin
        reg_weight[i] <= 0;
      end   
    end
    else if (in_valid) begin
       case (cnt)
        0: reg_weight[14] <= in_weight;
        1: reg_weight[13] <= in_weight;
        2: reg_weight[12] <= in_weight;
        3: reg_weight[11] <= in_weight;
        4: reg_weight[10] <= in_weight;
        5: reg_weight[9]  <= in_weight;
        6: reg_weight[8]  <= in_weight;
        7: reg_weight[7]  <= in_weight;
        default: begin
          for (i=1;i<16;i=i+1) begin
            reg_weight[i] <= 0;
          end 
        end
       endcase
    end
    else if (in_valid_d) begin
      reg_weight[6] <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]];
    end
    else if (c_s==S_CAL) begin
      case (cnt)
      0: reg_weight[5] <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]];
      2: reg_weight[4] <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]];
      4: reg_weight[3] <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]];
      6: reg_weight[2] <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]];
      8: reg_weight[1] <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]];
     10: reg_weight[0] <= reg_weight[OUT_character_0[7:4]] + reg_weight[OUT_character_0[3:0]];
        default: begin
          for (i=1;i<16;i=i+1) begin
            reg_weight[i] <= reg_weight[i];
          end 
        end  
      endcase
    end
  end

always @(posedge clk or negedge rst_n) //reg_char
begin
  if (!rst_n)begin
    for(k=7;k<15;k=k+1)begin
      reg_char[k] <= 0;
    end
  end
  else if(in_valid) begin
      reg_char[ 7] <=  7;     
      reg_char[ 8] <=  8;     
      reg_char[ 9] <=  9;     
      reg_char[10] <= 10;     
      reg_char[11] <= 11;     
      reg_char[12] <= 12;     
      reg_char[13] <= 13;     
      reg_char[14] <= 14;     
  end
  else if(in_valid==0 & in_valid_d==1)begin
    for (k=7;k<15;k=k+1)begin
        if (OUT_character_0[7:4]==reg_char[k] || OUT_character_0[3:0]==reg_char[k]) 
          reg_char[k] <= 6; 
    end
  end
  else if (c_s==S_CAL)begin
    case(cnt)
    0:begin
      for(k=7;k<15;k=k+1)begin
        if(reg_char[k]==OUT_character_0[7:4] || reg_char[k]==OUT_character_0[3:0])
          reg_char[k] <= 5;
      end      
    end
    2:begin
      for(k=7;k<15;k=k+1)begin
        if(reg_char[k]==OUT_character_0[7:4] || reg_char[k]==OUT_character_0[3:0])
          reg_char[k] <= 4;
      end      
    end
    4:begin
      for(k=7;k<15;k=k+1)begin
        if(reg_char[k]==OUT_character_0[7:4] || reg_char[k]==OUT_character_0[3:0])
          reg_char[k] <= 3;
      end      
    end
    6:begin
      for(k=7;k<15;k=k+1)begin
        if(reg_char[k]==OUT_character_0[7:4] || reg_char[k]==OUT_character_0[3:0])
          reg_char[k] <= 2;
      end      
    end
    8:begin
      for(k=7;k<15;k=k+1)begin
        if(reg_char[k]==OUT_character_0[7:4] || reg_char[k]==OUT_character_0[3:0])
          reg_char[k] <= 1;
      end      
    end
  10:begin
      for(k=7;k<15;k=k+1)begin
        if(reg_char[k]==OUT_character_0[7:4] || reg_char[k]==OUT_character_0[3:0])
          reg_char[k] <= 0;
      end      
    end                    
    default:begin
      for(k=7;k<15;k=k+1)begin
        reg_char[k] <= reg_char[k];
      end
    end
    endcase
  end

end
always @(posedge clk or negedge rst_n) //reg_Huffman and bit_width
  begin
    if (!rst_n)begin
      for (j=7;j<15;j=j+1)begin
        reg_Huffman[j] <= 0;
        bit_width [j]  <= 0;
      end
    end
    else if (c_s==IDLE)begin
      for (j=7;j<15;j=j+1)begin
        reg_Huffman[j] <= 0;
        bit_width [j]  <= 0;
      end
    end
    else if (in_valid_d & in_valid==0) begin
      for (j=7;j<15;j=j+1)begin
        if (reg_char[j] == OUT_character_0[7:4]) begin
          reg_Huffman[j][0] <= 0;
          bit_width [j] <= 1;
        end
        else if (reg_char[j] == OUT_character_0[3:0])  begin
          reg_Huffman[j][0] <= 1;
          bit_width [j] <= 1;
        end
      end
    end 
    else if (c_s==S_CAL) begin
      case (cnt) 
        0:begin
            for (j=7;j<15;j=j+1)begin
              if (reg_char[j] == OUT_character_0[7:4]) begin
                  reg_Huffman[j][bit_width[j]] <= 0;
                  bit_width [j] <= bit_width [j]+1;
              end
              else if (reg_char[j] == OUT_character_0[3:0])  begin
                reg_Huffman[j][bit_width[j]] <= 1;
                bit_width [j] <= bit_width[j]+1;
              end          
            end
          end  
        2:begin
            for (j=7;j<15;j=j+1)begin
              if (reg_char[j] == OUT_character_0[7:4]) begin
                  reg_Huffman[j][bit_width [j]] <= 0;
                  bit_width [j] <= bit_width [j]+1;
              end
              else if (reg_char[j] == OUT_character_0[3:0])  begin
                reg_Huffman[j][bit_width [j]] <= 1;
                bit_width [j] <= bit_width [j]+1;
              end          
            end
          end
        4:begin
            for (j=7;j<15;j=j+1)begin
              if (reg_char[j] == OUT_character_0[7:4]) begin
                  reg_Huffman[j][bit_width [j]] <= 0;
                  bit_width [j] <= bit_width [j]+1;
              end
              else if (reg_char[j] == OUT_character_0[3:0])  begin
                reg_Huffman[j][bit_width [j]] <= 1;
                bit_width [j] <= bit_width [j]+1;
              end          
            end
          end  
        6:begin
            for (j=7;j<15;j=j+1)begin
              if (reg_char[j] == OUT_character_0[7:4]) begin
                  reg_Huffman[j][bit_width [j]] <= 0;
                  bit_width [j] <= bit_width [j]+1;
              end
              else if (reg_char[j] == OUT_character_0[3:0])  begin
                reg_Huffman[j][bit_width [j]] <= 1;
                bit_width [j] <= bit_width [j]+1;
              end          
            end
          end  
       8:begin
            for (j=7;j<15;j=j+1)begin
              if (reg_char[j] == OUT_character_0[7:4]) begin
                  reg_Huffman[j][bit_width [j]] <= 0;
                  bit_width [j] <= bit_width [j]+1;
              end
              else if (reg_char[j] == OUT_character_0[3:0])  begin
                reg_Huffman[j][bit_width [j]] <= 1;
                bit_width [j] <= bit_width [j]+1;
              end          
            end
          end  
      10:begin
            for (j=7;j<15;j=j+1)begin
              if (reg_char[j] == OUT_character_0[7:4]) begin
                  reg_Huffman[j][bit_width [j]] <= 0;
                  bit_width [j] <= bit_width [j]+1;
              end
              else if (reg_char[j] == OUT_character_0[3:0])  begin
                reg_Huffman[j][bit_width [j]] <= 1;
                bit_width [j] <= bit_width [j]+1;
              end          
            end
          end                                                                                      
       default:begin
           for (j=7;j<15;j=j+1)begin
             reg_Huffman[j] <= reg_Huffman[j];
             bit_width [j]  <= bit_width [j] ;
           end
         end                                                  
      endcase
    end
    else if(c_s==S_OUTPUT1)begin
      bit_width[10] <= bit_width[10]-1;
    end
    else if(c_s==S_OUTPUT2)begin
      if(r_out_mode)  bit_width[12] <= bit_width[12]-1;
      else            bit_width[9] <= bit_width[9]-1;
    end
    else if(c_s==S_OUTPUT3)begin
      if(r_out_mode)  bit_width[9] <= bit_width[9]-1;
      else            bit_width[8] <= bit_width[8]-1;
    end
    else if(c_s==S_OUTPUT4)begin
      if(r_out_mode)  bit_width[14] <= bit_width[14]-1;
      else            bit_width[7] <= bit_width[7]-1;
    end
    else if(c_s==S_OUTPUT5)begin
      if(r_out_mode)  bit_width[13] <= bit_width[13]-1;
      else            bit_width[11] <= bit_width[11]-1;
    end            
  end

always @(posedge clk or negedge rst_n) 
  begin
    if (~rst_n)   out_code <= 0;  
    else begin
      case(r_out_mode)
      0:begin
        if(c_s==S_OUTPUT1)begin
          out_code <= reg_Huffman[10][bit_width[10]-1];
        end
        else if(c_s==S_OUTPUT2)begin
          out_code <= reg_Huffman[9][bit_width[9]-1];        
        end   
        else if(c_s==S_OUTPUT3)begin
          out_code <= reg_Huffman[8][bit_width[8]-1];          
        end  
        else if(c_s==S_OUTPUT4)begin
          out_code <= reg_Huffman[7][bit_width[7]-1];
        end  
        else if(c_s==S_OUTPUT5)begin
          out_code <= reg_Huffman[11][bit_width[11]-1];
        end          
        else out_code <= 0;                     
      end
      1:begin
        if(c_s==S_OUTPUT1)begin
          out_code <= reg_Huffman[10][bit_width[10]-1];
        end
        else if(c_s==S_OUTPUT2)begin
          out_code <= reg_Huffman[12][bit_width[12]-1];        
        end   
        else if(c_s==S_OUTPUT3)begin
          out_code <= reg_Huffman[9][bit_width[9]-1];          
        end  
        else if(c_s==S_OUTPUT4)begin
          out_code <= reg_Huffman[14][bit_width[14]-1];
        end  
        else if(c_s==S_OUTPUT5)begin
          out_code <= reg_Huffman[13][bit_width[13]-1];
        end          
        else out_code <= 0;    
      end
      default: out_code <= 0;
      endcase
    end
  end
always @(posedge clk or negedge rst_n) 
  begin
    if (~rst_n)               out_valid <= 0;
    else if(c_s==S_OUTPUT1)   out_valid <= 1;
    else if(c_s==IDLE)        out_valid <= 0;
    else                      out_valid <= out_valid;
  end
endmodule