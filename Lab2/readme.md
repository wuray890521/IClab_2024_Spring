# Lab02 Enigma Machine

[![hackmd-github-sync-badge](https://hackmd.io/NJ2VarpSRFe2j6o0HZBECw/badge)](https://hackmd.io/NJ2VarpSRFe2j6o0HZBECw)

Github : [**Lab02Github**](https://github.com/wuray890521/IClab/tree/main/Lab2)
# Description
# Topic of this week
# What codeing style I learn from this Lab?
在if 後的每個 if 都要有 else if 否則會出現Latch。在 combinational circuit 中非常重要。
```verilog=
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		sol_b <= 0 ;
	end
	else if (in_valid) begin 
		sol_b <= 0;
	end
	else if (state_cs == CAL && !reg_crypt_mode) begin
		sol_b <= reg_rotor_b[reg_rotor_a[reg_code_in]] ;
	end
	else begin 
		sol_b <= 0;
	end
end
```
Q1 : 為何下面的程式會有latch ?
```verilog=
always @(*) begin
	if (!rst_n || flag == 0) begin
		sol_a1 = 0;
	end
	else if (in_valid_2 && reg_crypt_mode == 0) begin
	for (q = 0; q < 64 ; q = q + 1) begin
		if (d_reg_rotor_a[q] == sol_b1 ) begin
			sol_a1 = q ;
		end
	end
	end
	else begin 
		sol_a1 = sol_a1;
	end
end
```
A1 : 正如剛剛所說的，使用for loop 只是單純的把電路 unroll 開但並沒有加入 else 因此會出現latch問題。解法如下，只要unroll開來並加入else即可解決。(所有的狀況都要寫到。)建議之後可以都使用 sequential circuit在本質上就不會發生latch。
```verilog=+
always @(*) begin
	if (!rst_n) begin
		sol_b1 = 0;
	end
	else if (in_valid) begin 
		sol_b1 = 0;
	end
	else if (state_cs == CAL && reg_crypt_mode == 0) begin
		if (d_reg_rotor_b[0] == (63 - sol_b)) sol_b1 = 0 ;
		else if (d_reg_rotor_b[1] == (63 - sol_b)) sol_b1 = 1 ;
		else if (d_reg_rotor_b[2] == (63 - sol_b)) sol_b1 = 2 ;
		else if (d_reg_rotor_b[3] == (63 - sol_b)) sol_b1 = 3 ;
		else if (d_reg_rotor_b[4] == (63 - sol_b)) sol_b1 = 4 ;
		else if (d_reg_rotor_b[5] == (63 - sol_b)) sol_b1 = 5 ;
		else if (d_reg_rotor_b[6] == (63 - sol_b)) sol_b1 = 6 ;
		else if (d_reg_rotor_b[7] == (63 - sol_b)) sol_b1 = 7 ;
		else if (d_reg_rotor_b[8] == (63 - sol_b)) sol_b1 = 8 ;
		else if (d_reg_rotor_b[9] == (63 - sol_b)) sol_b1 = 9 ;
		else if (d_reg_rotor_b[10] == (63 - sol_b)) sol_b1 = 10 ;
		else if (d_reg_rotor_b[11] == (63 - sol_b)) sol_b1 = 11 ;
		else if (d_reg_rotor_b[12] == (63 - sol_b)) sol_b1 = 12 ;
		else if (d_reg_rotor_b[13] == (63 - sol_b)) sol_b1 = 13 ;
		else if (d_reg_rotor_b[14] == (63 - sol_b)) sol_b1 = 14 ;
		else if (d_reg_rotor_b[15] == (63 - sol_b)) sol_b1 = 15 ;
		else if (d_reg_rotor_b[16] == (63 - sol_b)) sol_b1 = 16 ;
		else if (d_reg_rotor_b[17] == (63 - sol_b)) sol_b1 = 17 ;
		else if (d_reg_rotor_b[18] == (63 - sol_b)) sol_b1 = 18 ;
		else if (d_reg_rotor_b[19] == (63 - sol_b)) sol_b1 = 19 ;
		else if (d_reg_rotor_b[20] == (63 - sol_b)) sol_b1 = 20 ;
		else if (d_reg_rotor_b[21] == (63 - sol_b)) sol_b1 = 21 ;
		else if (d_reg_rotor_b[22] == (63 - sol_b)) sol_b1 = 22 ;
		else if (d_reg_rotor_b[23] == (63 - sol_b)) sol_b1 = 23 ;
		else if (d_reg_rotor_b[24] == (63 - sol_b)) sol_b1 = 24 ;
		else if (d_reg_rotor_b[25] == (63 - sol_b)) sol_b1 = 25 ;
		else if (d_reg_rotor_b[26] == (63 - sol_b)) sol_b1 = 26 ;
		else if (d_reg_rotor_b[27] == (63 - sol_b)) sol_b1 = 27 ;
		else if (d_reg_rotor_b[28] == (63 - sol_b)) sol_b1 = 28 ;
		else if (d_reg_rotor_b[29] == (63 - sol_b)) sol_b1 = 29 ;
		else if (d_reg_rotor_b[30] == (63 - sol_b)) sol_b1 = 30 ;
		else if (d_reg_rotor_b[31] == (63 - sol_b)) sol_b1 = 31 ;
		else if (d_reg_rotor_b[32] == (63 - sol_b)) sol_b1 = 32 ;
		else if (d_reg_rotor_b[33] == (63 - sol_b)) sol_b1 = 33 ;
		else if (d_reg_rotor_b[34] == (63 - sol_b)) sol_b1 = 34 ;
		else if (d_reg_rotor_b[35] == (63 - sol_b)) sol_b1 = 35 ;
		else if (d_reg_rotor_b[36] == (63 - sol_b)) sol_b1 = 36 ;
		else if (d_reg_rotor_b[37] == (63 - sol_b)) sol_b1 = 37 ;
		else if (d_reg_rotor_b[38] == (63 - sol_b)) sol_b1 = 38 ;
		else if (d_reg_rotor_b[39] == (63 - sol_b)) sol_b1 = 39 ;
		else if (d_reg_rotor_b[40] == (63 - sol_b)) sol_b1 = 40 ;
		else if (d_reg_rotor_b[41] == (63 - sol_b)) sol_b1 = 41 ;
		else if (d_reg_rotor_b[42] == (63 - sol_b)) sol_b1 = 42 ;
		else if (d_reg_rotor_b[43] == (63 - sol_b)) sol_b1 = 43 ;
		else if (d_reg_rotor_b[44] == (63 - sol_b)) sol_b1 = 44 ;
		else if (d_reg_rotor_b[45] == (63 - sol_b)) sol_b1 = 45 ;
		else if (d_reg_rotor_b[46] == (63 - sol_b)) sol_b1 = 46 ;
		else if (d_reg_rotor_b[47] == (63 - sol_b)) sol_b1 = 47 ;
		else if (d_reg_rotor_b[48] == (63 - sol_b)) sol_b1 = 48 ;
		else if (d_reg_rotor_b[49] == (63 - sol_b)) sol_b1 = 49 ;
		else if (d_reg_rotor_b[50] == (63 - sol_b)) sol_b1 = 50 ;
		else if (d_reg_rotor_b[51] == (63 - sol_b)) sol_b1 = 51 ;
		else if (d_reg_rotor_b[52] == (63 - sol_b)) sol_b1 = 52 ;
		else if (d_reg_rotor_b[53] == (63 - sol_b)) sol_b1 = 53 ;
		else if (d_reg_rotor_b[54] == (63 - sol_b)) sol_b1 = 54 ;
		else if (d_reg_rotor_b[55] == (63 - sol_b)) sol_b1 = 55 ;
		else if (d_reg_rotor_b[56] == (63 - sol_b)) sol_b1 = 56 ;
		else if (d_reg_rotor_b[57] == (63 - sol_b)) sol_b1 = 57 ;
		else if (d_reg_rotor_b[58] == (63 - sol_b)) sol_b1 = 58 ;
		else if (d_reg_rotor_b[59] == (63 - sol_b)) sol_b1 = 59 ;
		else if (d_reg_rotor_b[60] == (63 - sol_b)) sol_b1 = 60 ;
		else if (d_reg_rotor_b[61] == (63 - sol_b)) sol_b1 = 61 ;
		else if (d_reg_rotor_b[62] == (63 - sol_b)) sol_b1 = 62 ;
		else if (d_reg_rotor_b[63] == (63 - sol_b)) sol_b1 = 63 ;
		else sol_b1 = 0;
	end
	else sol_b1 = 0;
end
```
Q2 : out_valid 和 out_code 的條件要怎麼寫?
A2 : 如下所示，最大的原則是out_valid、out_code的訊號拉起來時間必須同時，為此我們要使用相同判斷式，而非使用out_valid控制out_code。同時建議 out_code 應使用序向電路。
```verilog=
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_code <= 0;
	end
	else if (reg_in_valid_2 == 0) begin
		out_code <= 0;
	end
	else if (cnt>=1 && reg_crypt_mode == 0) begin
		out_code <= sol_a1;
	end
	else if (cnt>=1 && reg_crypt_mode == 1) begin
		out_code <= sol_a1_d_ans;
	end
	else out_code <= 0;
end
```
```verilog=+
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_valid <= 0;
	end
	else if (reg_in_valid_2 == 0) begin
		out_valid <= 0;
	end
	else if (cnt>=1) begin
		out_valid <= 1;
	end
	else out_valid <= 0;
end
```
Q3 : 如何取出在第一個CLK才存在的值?
A3 : 如下所示。
```verilog=
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_d <= 0;
	end
	else begin
		in_valid_d <= in_valid;
	end
end
```
```verilog=+
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		reg_crypt_mode <= 0 ;
	end
	else if (in_valid && in_valid_d==0) begin
		reg_crypt_mode <= crypt_mode;
	end
	else reg_crypt_mode <= reg_crypt_mode ;
end
```
![waveform to Q3](https://hackmd.io/_uploads/Sy9jAmh66.png)

Q4 : 使用generate時須注意什麼，以及下列程式有甚麼錯誤?
```verilog=
genvar k ;
generate
for (k = 0 ; k < 64; k = k + 1) begin : loop_3
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			reg_rotor_a[k] <= 0;
		end
		else if (state_cs == LOAD) begin
			reg_rotor_a[k] <= rotor_a [k];
		end
		else if (state_cs == CAL) begin
			case (reg_crypt_mode)
				1'b0 : begin
					reg_rotor_a[(k + reg_rotor_a[code_in] [1:0] + 64) % 64] <= reg_rotor_a [k];
					d_reg_rotor_a [k] <= reg_rotor_a[k];
				end
				default: begin
					for (m = 0; m < 64 ; m = m + 1) begin
						if (reg_rotor_b[m] == (63 - reg_rotor_b[reg_rotor_a[code_in]])) begin
							sol_b1_d <= m ;
							reg_rotor_a[(k + m [1:0] + 64) % 64] <= reg_rotor_a [k];
							sol_r <= 7'd63 - reg_rotor_b[reg_rotor_a[code_in]];
						end
					end
					d_reg_rotor_a [k] <= reg_rotor_a[k];
				end
			endcase
		end
		else reg_rotor_a[k] <= reg_rotor_a[k];
	end
end
endgenerate
```
A4 : 以reg_rotor_a[k]為例在合成時會出現多重控制，修改方法如下，如果一定要使用generate時一定要確定reg_rotor_a[k]會不會被多重控制。
```verilog=+
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (k = 0 ; k < 64; k = k + 1) begin
			reg_rotor_a[k] <= 0;
		end
	end
	else if (state_cs == LOAD) begin
		for (k = 0 ; k < 64; k = k + 1) begin
			reg_rotor_a[k] <= rotor_a [k];
		end
	end
	else if (state_cs == CAL && reg_crypt_mode == 0) begin
		for (k = 0 ; k < 64; k = k + 1) begin
			reg_rotor_a[(k + reg_rotor_a[reg_code_in] [1:0] + 64) % 64] <= reg_rotor_a [k];
			d_reg_rotor_a [k] <= reg_rotor_a[k];
			d_d_reg_rotor_a [k] <= d_reg_rotor_a[k];
			end
		end
end
```
Q5 : FSM是否有更好的打法?
A5 : 實在有太多不明所以的地方直接放入優化版。最重要的部分是不建議在combinational circuit 應該直接說明我的state而非使用state_cs = state_ns，另外應該要在設計的最一開始就想好。
```verilog=
always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
                state_cs <= IDLE;
        else
                state_cs <= state_ns;
end
always@(*) begin
	case (state_cs)
		IDLE : begin
			if (in_valid) begin
				state_ns = LOAD ;
			end
			else begin
				state_ns = IDLE ;
			end
		end
		LOAD : begin
			if (in_valid_2) begin
				state_ns = CAL ;
			end
			else begin
				state_ns = LOAD ;
			end
		end
		CAL : begin
			if (in_valid) begin
				state_ns = LOAD;
			end
			else begin
				state_ns = CAL ;
			end
		end
		default: begin
			state_ns = IDLE ;
		end
	endcase
end 
```
# Experience
經過這次lab我學習到在開始寫code前必需搞清楚spec的要求，而非盲目的去寫code。
## Code Review
這次lab寫得過於倉促，沒有整體的規劃，導致到最後很像在湊出答案，而非有嚴謹邏輯。下次寫lab應該要先決定好 FSM 的配置，以及輸出訊號的設計。
之後所有的 Lab 應該要把所有 input 先接到 register 而非直接開始工作。
![image](https://hackmd.io/_uploads/r1tiacCTp.png)



