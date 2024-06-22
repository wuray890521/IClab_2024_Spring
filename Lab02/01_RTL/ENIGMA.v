 module ENIGMA(
	// Input Ports
	clk, 
	rst_n, 
	in_valid, 
	in_valid_2, 
	crypt_mode, 
	code_in, 

	// Output Ports
	out_code, 
	out_valid
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;              // clock input
input rst_n;            // asynchronous reset (active low)
input in_valid;         // code_in valid signal for rotor (level sensitive). 0/1: inactive/active
input in_valid_2;       // code_in valid signal for code  (level sensitive). 0/1: inactive/active
input crypt_mode;       // 0: encrypt; 1:decrypt; only valid for 1 cycle when in_valid is active

input [6-1:0] code_in;	// When in_valid   is active, then code_in is input of rotors. 
						// When in_valid_2 is active, then code_in is input of code words.
							
output reg out_valid;       	// 0: out_code is not valid; 1: out_code is valid
output reg [6-1:0] out_code;	// encrypted/decrypted code word

// ===============================================================
// Design
// ===============================================================

reg [9:0] cnt;
reg reg_in_valid_2;
// fsm state
reg [1:0] state_cs, state_ns;
parameter IDLE = 2'd0; //IDLE
parameter LOAD = 2'd1; // LOAD
parameter CAL = 2'd2; // ENCRYPTION OR DECRYPTION
// sotre data
reg [5:0] rotor_a [63:0];
reg [5:0] rotor_b [63:0];
reg reg_crypt_mode;
// store code_in
reg [5:0] reg_code_in;

reg [5:0] reg_rotor_a [63:0];
reg [5:0] d_reg_rotor_a [63:0];
reg [5:0] d_d_reg_rotor_a [63:0];
reg [5:0] de_reg_rotor_a [63:0];

reg [5:0] d_reg_rotor_b [63:0];
reg [5:0] reg_rotor_b [63:0];
reg [2:0] mode;
//sol for all 
reg [5:0] sol_a ;
reg [5:0] sol_a_d ;
reg [5:0] sol_a1;
reg [5:0] sol_b ;
reg [5:0] sol_b_d;
reg [5:0] sol_b1;
reg [5:0] sol_b1_d;
reg [5:0] sol_b_inv;
reg [5:0] sol_a1_d;
reg [5:0] sol_r;
reg [5:0] sol_a1_d_ans;

reg flag_1;
reg in_valid_d;
// reg flag1;
// forloop
integer m, q, k, b;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		reg_code_in <= 0;
		reg_in_valid_2 <= 0;
	end
	else begin 
		reg_code_in <= code_in ;
		reg_in_valid_2 <= in_valid_2;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_d <= 0;
	end
	else begin
		in_valid_d <= in_valid;
	end
end
// always @(posedge clk or negedge rst_n) begin
// 	if (!rst_n) begin
// 		flag1 <= 0;
// 	end
// 	else if (cnt >= 63 && in_valid == 1) begin
// 		flag1 <= 1;
// 	end
// 	else flag1 <= 0;
// end
//stroe crypt_data 
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		reg_crypt_mode <= 0 ;
	end
	else if (in_valid && in_valid_d==0) begin
		reg_crypt_mode <= crypt_mode;
	end
	else reg_crypt_mode <= reg_crypt_mode ;
end
// FSM
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
// FSM
//counter
always @(posedge clk or negedge rst_n) //cnt
begin
    if(!rst_n) begin
    	cnt <= 0;		
	end
	else if (in_valid == 0 && state_cs == LOAD) begin
		cnt <= 0;
	end
	else if (in_valid_2 == 0 && state_ns == 2) begin
		cnt <= 0;
	end
    else if(state_cs == LOAD) begin
    	cnt <= cnt + 1;  	
	end
	else if (in_valid_2) begin
		cnt <= cnt + 1;
	end
end
// counter
// input data to rotor table a
genvar j ;
generate
for (j = 0; j < 64; j = j + 1) begin : loop_1
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			rotor_a[j] <= 0;
		end
		else if (in_valid == 1 && cnt == j) begin
			rotor_a[j] <= reg_code_in;
		end
		else rotor_a[j] <= rotor_a[j];
	end
end
endgenerate

// input data to rotr table b
genvar i ;
generate
for (i = 0 ; i < 64; i = i + 1) begin : loop_2
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			rotor_b[i] <= 0;
		end
		else if (cnt == 128) begin
			rotor_b[i] <= 0;
		end
		else if (state_cs == LOAD && cnt == i + 64) begin
			rotor_b[i] <= reg_code_in;
		end
		else rotor_b[i] <= rotor_b[i];
	end
end
endgenerate
// put data in reflector
// shit the data from rotor_a to reg_rotor_a by the rules in spec. rotorA in e-state
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

// shit the data from rotor_a to reg_rotor_a by the rules in spec. rotorA in d-state
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (k = 0 ; k < 64; k = k + 1) begin
			de_reg_rotor_a[k] <= 0;
		end
	end
	else if (state_cs == LOAD) begin
		for (k = 0 ; k < 64; k = k + 1) begin
			de_reg_rotor_a[k] <= rotor_a [k];
		end
	end
	else if (state_cs == CAL && reg_crypt_mode == 1) begin
		for (k = 0 ; k < 64; k = k + 1) begin
			de_reg_rotor_a[(k + sol_b1_d[1:0] + 64) % 64] <= de_reg_rotor_a [k];
			end
		end
end


genvar l ;
generate
for (l = 0 ; l < 8; l = l + 1) begin : loop_4
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			reg_rotor_b [0 + 8 * l] <=  0 ;
			reg_rotor_b [1 + 8 * l] <=  0 ;
			reg_rotor_b [2 + 8 * l] <=  0 ;
			reg_rotor_b [3 + 8 * l] <=  0 ;
			reg_rotor_b [4 + 8 * l] <=  0 ;
			reg_rotor_b [5 + 8 * l] <=  0 ;
			reg_rotor_b [6 + 8 * l] <=  0 ;
			reg_rotor_b [7 + 8 * l] <=  0 ;
		end
		else if (state_cs == LOAD) begin
			reg_rotor_b [0 + 8 * l] <=  rotor_b [0 + 8 * l] ;
			reg_rotor_b [1 + 8 * l] <=  rotor_b [1 + 8 * l] ;
			reg_rotor_b [2 + 8 * l] <=  rotor_b [2 + 8 * l] ;
			reg_rotor_b [3 + 8 * l] <=  rotor_b [3 + 8 * l] ;
			reg_rotor_b [4 + 8 * l] <=  rotor_b [4 + 8 * l] ;
			reg_rotor_b [5 + 8 * l] <=  rotor_b [5 + 8 * l] ;
			reg_rotor_b [6 + 8 * l] <=  rotor_b [6 + 8 * l] ;
			reg_rotor_b [7 + 8 * l] <=  rotor_b [7 + 8 * l] ;
		end
		else if (state_cs == CAL) begin
			case (reg_crypt_mode)
				1'b0: begin 			
				case (reg_rotor_b[reg_rotor_a[reg_code_in]][2:0])
				3'b001 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
				end 
				3'b010 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
				end 
				3'b011 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
				end
				3'b100 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
				end 
				3'b101 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
				end 
				3'b110 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;	
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
				end 
				3'b111 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
				end 
				default: begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
				end
				endcase
				end
				default: begin 
				case ((7'd63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]]) % 8)
				3'b001 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
				end 
				3'b010 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
				end 
				3'b011 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
				end
				3'b100 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
				end 
				3'b101 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
				end 
				3'b110 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;	
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
				end 
				3'b111 : begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
				end 
				default: begin
					reg_rotor_b [0 + 8 * l] <= reg_rotor_b [0 + 8 * l] ;
					reg_rotor_b [1 + 8 * l] <= reg_rotor_b [1 + 8 * l] ;
					reg_rotor_b [2 + 8 * l] <= reg_rotor_b [2 + 8 * l] ;
					reg_rotor_b [3 + 8 * l] <= reg_rotor_b [3 + 8 * l] ;
					reg_rotor_b [4 + 8 * l] <= reg_rotor_b [4 + 8 * l] ;
					reg_rotor_b [5 + 8 * l] <= reg_rotor_b [5 + 8 * l] ;
					reg_rotor_b [6 + 8 * l] <= reg_rotor_b [6 + 8 * l] ;
					reg_rotor_b [7 + 8 * l] <= reg_rotor_b [7 + 8 * l] ;
				end
				endcase
				end
			endcase
			d_reg_rotor_b [0 + 8 * l] <= reg_rotor_b [0 + 8 * l];
			d_reg_rotor_b [1 + 8 * l] <= reg_rotor_b [1 + 8 * l];
			d_reg_rotor_b [2 + 8 * l] <= reg_rotor_b [2 + 8 * l];
			d_reg_rotor_b [3 + 8 * l] <= reg_rotor_b [3 + 8 * l];
			d_reg_rotor_b [4 + 8 * l] <= reg_rotor_b [4 + 8 * l];
			d_reg_rotor_b [5 + 8 * l] <= reg_rotor_b [5 + 8 * l];
			d_reg_rotor_b [6 + 8 * l] <= reg_rotor_b [6 + 8 * l];
			d_reg_rotor_b [7 + 8 * l] <= reg_rotor_b [7 + 8 * l];
		end
	end
end
endgenerate


// read the ans of step 1
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		sol_a <= 0 ;
	end
	else if (in_valid) begin 
		sol_a <= 0;
	end
	else if (state_cs == CAL && reg_crypt_mode == 0) begin
		sol_a <= reg_rotor_a[reg_code_in] ;
	end
	else begin 
		sol_a <= 0;
	end
end

// solution to step 2
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

// solution to step 4
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

always @(*) begin
	if (!rst_n) begin
		sol_b1_d = 0;
	end
	else if (in_valid) begin 
		sol_b1_d = 0;
	end
	else if (state_cs == CAL && reg_crypt_mode == 1) begin
		// for (b = 0; b < 64 ; b = b + 1) begin
			if (reg_rotor_b[0] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 0 ;
			else if (reg_rotor_b[1] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 1 ;
			else if (reg_rotor_b[2] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 2 ;
			else if (reg_rotor_b[3] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 3 ;
			else if (reg_rotor_b[4] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 4 ;
			else if (reg_rotor_b[5] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 5 ;
			else if (reg_rotor_b[6] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 6 ;
			else if (reg_rotor_b[7] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 7 ;
			else if (reg_rotor_b[8] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 8 ;
			else if (reg_rotor_b[9] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 9 ;
			else if (reg_rotor_b[10] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 10 ;
			else if (reg_rotor_b[11] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 11 ;
			else if (reg_rotor_b[12] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 12 ;
			else if (reg_rotor_b[13] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 13 ;
			else if (reg_rotor_b[14] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 14 ;
			else if (reg_rotor_b[15] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 15 ;
			else if (reg_rotor_b[16] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 16 ;
			else if (reg_rotor_b[17] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 17 ;
			else if (reg_rotor_b[18] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 18 ;
			else if (reg_rotor_b[19] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 19 ;
			else if (reg_rotor_b[20] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 20 ;
			else if (reg_rotor_b[21] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 21 ;
			else if (reg_rotor_b[22] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 22 ;
			else if (reg_rotor_b[23] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 23 ;
			else if (reg_rotor_b[24] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 24 ;
			else if (reg_rotor_b[25] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 25 ;
			else if (reg_rotor_b[26] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 26 ;
			else if (reg_rotor_b[27] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 27 ;
			else if (reg_rotor_b[28] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 28 ;
			else if (reg_rotor_b[29] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 29 ;
			else if (reg_rotor_b[30] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 30 ;
			else if (reg_rotor_b[31] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 31 ;
			else if (reg_rotor_b[32] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 32 ;
			else if (reg_rotor_b[33] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 33 ;
			else if (reg_rotor_b[34] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 34 ;
			else if (reg_rotor_b[35] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 35 ;
			else if (reg_rotor_b[36] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 36 ;
			else if (reg_rotor_b[37] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 37 ;
			else if (reg_rotor_b[38] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 38 ;
			else if (reg_rotor_b[39] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 39 ;
			else if (reg_rotor_b[40] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 40 ;
			else if (reg_rotor_b[41] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 41 ;
			else if (reg_rotor_b[42] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 42 ;
			else if (reg_rotor_b[43] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 43 ;
			else if (reg_rotor_b[44] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 44 ;
			else if (reg_rotor_b[45] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 45 ;
			else if (reg_rotor_b[46] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 46 ;
			else if (reg_rotor_b[47] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 47 ;
			else if (reg_rotor_b[48] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 48 ;
			else if (reg_rotor_b[49] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 49 ;
			else if (reg_rotor_b[50] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 50 ;
			else if (reg_rotor_b[51] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 51 ;
			else if (reg_rotor_b[52] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 52 ;
			else if (reg_rotor_b[53] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 53 ;
			else if (reg_rotor_b[54] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 54 ;
			else if (reg_rotor_b[55] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 55 ;
			else if (reg_rotor_b[56] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 56 ;
			else if (reg_rotor_b[57] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 57 ;
			else if (reg_rotor_b[58] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 58 ;
			else if (reg_rotor_b[59] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 59 ;
			else if (reg_rotor_b[60] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 60 ;
			else if (reg_rotor_b[61] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 61 ;
			else if (reg_rotor_b[62] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 62 ;
			else if (reg_rotor_b[63] == (63 - reg_rotor_b[de_reg_rotor_a[reg_code_in]])) sol_b1_d = 63 ;
			else sol_b1_d = 0;
	end
	else sol_b1_d = 0;
end



always @(*) begin
	if (!rst_n) begin
		sol_a1 = 0;
	end
	else if (state_cs == LOAD) begin
		sol_a1 = 0;
	end
	else if (state_cs == CAL && reg_crypt_mode == 0) begin
		// for (q = 0; q < 64 ; q = q + 1) begin
		// 	if (d_reg_rotor_a[q] == sol_b1 ) begin
		// 		sol_a1 = q ;
		// 	end
		// end
		if (d_reg_rotor_a[0] == sol_b1 ) sol_a1 = 0 ;
		else if (d_reg_rotor_a[1] == sol_b1 ) sol_a1 = 1 ;   
		else if (d_reg_rotor_a[2] == sol_b1 ) sol_a1 = 2 ;
		else if (d_reg_rotor_a[3] == sol_b1 ) sol_a1 = 3 ;      
		else if (d_reg_rotor_a[4] == sol_b1 ) sol_a1 = 4 ;     
		else if (d_reg_rotor_a[5] == sol_b1 ) sol_a1 = 5 ;  
		else if (d_reg_rotor_a[6] == sol_b1 ) sol_a1 = 6 ;         
		else if (d_reg_rotor_a[7] == sol_b1 ) sol_a1 = 7 ;   
		else if (d_reg_rotor_a[8] == sol_b1 ) sol_a1 = 8 ;     
		else if (d_reg_rotor_a[9] == sol_b1 ) sol_a1 = 9 ;     
		else if (d_reg_rotor_a[10] == sol_b1 ) sol_a1 = 10 ;  
		else if (d_reg_rotor_a[11] == sol_b1 ) sol_a1 = 11 ;   
		else if (d_reg_rotor_a[12] == sol_b1 ) sol_a1 = 12 ;
		else if (d_reg_rotor_a[13] == sol_b1 ) sol_a1 = 13 ;      
		else if (d_reg_rotor_a[14] == sol_b1 ) sol_a1 = 14 ;     
		else if (d_reg_rotor_a[15] == sol_b1 ) sol_a1 = 15 ;  
		else if (d_reg_rotor_a[16] == sol_b1 ) sol_a1 = 16 ;         
		else if (d_reg_rotor_a[17] == sol_b1 ) sol_a1 = 17 ;   
		else if (d_reg_rotor_a[18] == sol_b1 ) sol_a1 = 18 ;     
		else if (d_reg_rotor_a[19] == sol_b1 ) sol_a1 = 19 ;
		else if (d_reg_rotor_a[20] == sol_b1 ) sol_a1 = 20 ;  
		else if (d_reg_rotor_a[21] == sol_b1 ) sol_a1 = 21 ;   
		else if (d_reg_rotor_a[22] == sol_b1 ) sol_a1 = 22 ;
		else if (d_reg_rotor_a[23] == sol_b1 ) sol_a1 = 23 ;      
		else if (d_reg_rotor_a[24] == sol_b1 ) sol_a1 = 24 ;     
		else if (d_reg_rotor_a[25] == sol_b1 ) sol_a1 = 25 ;  
		else if (d_reg_rotor_a[26] == sol_b1 ) sol_a1 = 26 ;         
		else if (d_reg_rotor_a[27] == sol_b1 ) sol_a1 = 27 ;   
		else if (d_reg_rotor_a[28] == sol_b1 ) sol_a1 = 28 ;     
		else if (d_reg_rotor_a[29] == sol_b1 ) sol_a1 = 29 ;
		else if (d_reg_rotor_a[30] == sol_b1 ) sol_a1 = 30 ;  
		else if (d_reg_rotor_a[31] == sol_b1 ) sol_a1 = 31 ;   
		else if (d_reg_rotor_a[32] == sol_b1 ) sol_a1 = 32 ;
		else if (d_reg_rotor_a[33] == sol_b1 ) sol_a1 = 33 ;      
		else if (d_reg_rotor_a[34] == sol_b1 ) sol_a1 = 34 ;     
		else if (d_reg_rotor_a[35] == sol_b1 ) sol_a1 = 35 ;  
		else if (d_reg_rotor_a[36] == sol_b1 ) sol_a1 = 36 ;         
		else if (d_reg_rotor_a[37] == sol_b1 ) sol_a1 = 37 ;   
		else if (d_reg_rotor_a[38] == sol_b1 ) sol_a1 = 38 ;     
		else if (d_reg_rotor_a[39] == sol_b1 ) sol_a1 = 39 ;
		else if (d_reg_rotor_a[40] == sol_b1 ) sol_a1 = 40 ;  
		else if (d_reg_rotor_a[41] == sol_b1 ) sol_a1 = 41 ;   
		else if (d_reg_rotor_a[42] == sol_b1 ) sol_a1 = 42 ;
		else if (d_reg_rotor_a[43] == sol_b1 ) sol_a1 = 43 ;      
		else if (d_reg_rotor_a[44] == sol_b1 ) sol_a1 = 44 ;     
		else if (d_reg_rotor_a[45] == sol_b1 ) sol_a1 = 45 ;  
		else if (d_reg_rotor_a[46] == sol_b1 ) sol_a1 = 46 ;         
		else if (d_reg_rotor_a[47] == sol_b1 ) sol_a1 = 47 ;   
		else if (d_reg_rotor_a[48] == sol_b1 ) sol_a1 = 48 ;     
		else if (d_reg_rotor_a[49] == sol_b1 ) sol_a1 = 49 ;
		else if (d_reg_rotor_a[50] == sol_b1 ) sol_a1 = 50 ;  
		else if (d_reg_rotor_a[51] == sol_b1 ) sol_a1 = 51 ;   
		else if (d_reg_rotor_a[52] == sol_b1 ) sol_a1 = 52 ;
		else if (d_reg_rotor_a[53] == sol_b1 ) sol_a1 = 53 ;      
		else if (d_reg_rotor_a[54] == sol_b1 ) sol_a1 = 54 ;     
		else if (d_reg_rotor_a[55] == sol_b1 ) sol_a1 = 55 ;  
		else if (d_reg_rotor_a[56] == sol_b1 ) sol_a1 = 56 ;         
		else if (d_reg_rotor_a[57] == sol_b1 ) sol_a1 = 57 ;   
		else if (d_reg_rotor_a[58] == sol_b1 ) sol_a1 = 58 ;     
		else if (d_reg_rotor_a[59] == sol_b1 ) sol_a1 = 59 ;
		else if (d_reg_rotor_a[60] == sol_b1 ) sol_a1 = 60 ;
		else if (d_reg_rotor_a[61] == sol_b1 ) sol_a1 = 61 ;
		else if (d_reg_rotor_a[62] == sol_b1 ) sol_a1 = 62 ;
		else if (d_reg_rotor_a[63] == sol_b1 ) sol_a1 = 63 ;
		else sol_a1 = 0 ;
	end
	else begin 
		sol_a1 = 0;
	end
end

// always @(*) begin
// 	if (!rst_n) begin
// 		sol_a1_d = 0;
// 	end
// 	else if (state_cs == LOAD) begin
// 		sol_a1_d = 0;
// 	end
// 	else if (state_cs == CAL && reg_crypt_mode == 1) begin
// 	for (q = 0; q < 64 ; q = q + 1) begin
// 		if (de_reg_rotor_a[q] == sol_b1_d ) begin
// 			sol_a1_d = q ;
// 		end

// 	end
	
// 	end
// 	else begin 
// 		sol_a1_d = 0;
// 	end
// end


always @(*) begin
	if (!rst_n) begin
		sol_a1_d = 0;
	end
	else if (state_cs == LOAD) begin
		sol_a1_d = 0;
	end
	// de_reg_rotor_a[0] == sol_b1_d

	// else if (state_cs == CAL && reg_crypt_mode == 1) begin
	// for (q = 0; q < 64 ; q = q + 1) begin
		// if (de_reg_rotor_a[0] == sol_b1_d ) begin
	else if (state_cs == CAL && reg_crypt_mode == 1) begin
		if (de_reg_rotor_a[0] == sol_b1_d) begin
			sol_a1_d = 0 ;
		end
		else if (de_reg_rotor_a[1] == sol_b1_d ) begin
			sol_a1_d = 1 ;
		end
		else if (de_reg_rotor_a[2] == sol_b1_d ) begin
			sol_a1_d = 2 ;
		end
		else if (de_reg_rotor_a[3] == sol_b1_d ) begin
			sol_a1_d = 3 ;
		end
		else if (de_reg_rotor_a[4] == sol_b1_d ) begin
			sol_a1_d = 4 ;
		end
		else if (de_reg_rotor_a[5] == sol_b1_d ) begin
			sol_a1_d = 5 ;
		end
		else if (de_reg_rotor_a[6] == sol_b1_d ) begin
			sol_a1_d = 6 ;
		end
		else if (de_reg_rotor_a[7] == sol_b1_d ) begin
			sol_a1_d = 7 ;
		end
		else if (de_reg_rotor_a[8] == sol_b1_d ) begin
			sol_a1_d = 8 ;
		end
		else if (de_reg_rotor_a[9] == sol_b1_d ) begin
			sol_a1_d = 9 ;
		end
		else if (de_reg_rotor_a[10] == sol_b1_d ) begin
			sol_a1_d = 10 ;
		end
		else if (de_reg_rotor_a[11] == sol_b1_d ) begin
			sol_a1_d = 11 ;
		end
		else if (de_reg_rotor_a[12] == sol_b1_d ) begin
			sol_a1_d = 12 ;
		end
		else if (de_reg_rotor_a[13] == sol_b1_d ) begin
			sol_a1_d = 13 ;
		end
		else if (de_reg_rotor_a[14] == sol_b1_d ) begin
			sol_a1_d = 14 ;
		end
		else if (de_reg_rotor_a[15] == sol_b1_d ) begin
			sol_a1_d = 15 ;
		end
		else if (de_reg_rotor_a[16] == sol_b1_d ) begin
			sol_a1_d = 16 ;
		end
		else if (de_reg_rotor_a[17] == sol_b1_d ) begin
			sol_a1_d = 17 ;
		end
		else if (de_reg_rotor_a[18] == sol_b1_d ) begin
			sol_a1_d = 18 ;
		end
		else if (de_reg_rotor_a[19] == sol_b1_d ) begin
			sol_a1_d = 19 ;
		end
		else if (de_reg_rotor_a[20] == sol_b1_d ) begin
			sol_a1_d = 20 ;
		end
		else if (de_reg_rotor_a[21] == sol_b1_d ) begin
			sol_a1_d = 21 ;
		end
		else if (de_reg_rotor_a[22] == sol_b1_d ) begin
			sol_a1_d = 22 ;
		end
		else if (de_reg_rotor_a[23] == sol_b1_d ) begin
			sol_a1_d = 23 ;
		end
		else if (de_reg_rotor_a[24] == sol_b1_d ) begin
			sol_a1_d = 24 ;
		end
		else if (de_reg_rotor_a[25] == sol_b1_d ) begin
			sol_a1_d = 25 ;
		end
		else if (de_reg_rotor_a[26] == sol_b1_d ) begin
			sol_a1_d = 26 ;
		end
		else if (de_reg_rotor_a[27] == sol_b1_d ) begin
			sol_a1_d = 27 ;
		end
		else if (de_reg_rotor_a[28] == sol_b1_d ) begin
			sol_a1_d = 28 ;
		end
		else if (de_reg_rotor_a[29] == sol_b1_d ) begin
			sol_a1_d = 29 ;
		end
		else if (de_reg_rotor_a[30] == sol_b1_d ) begin
			sol_a1_d = 30 ;
		end
		else if (de_reg_rotor_a[31] == sol_b1_d ) begin
			sol_a1_d = 31 ;
		end
		else if (de_reg_rotor_a[32] == sol_b1_d ) begin
			sol_a1_d = 32 ;
		end
		else if (de_reg_rotor_a[33] == sol_b1_d ) begin
			sol_a1_d = 33 ;
		end
		else if (de_reg_rotor_a[34] == sol_b1_d ) begin
			sol_a1_d = 34 ;
		end
		else if (de_reg_rotor_a[35] == sol_b1_d ) begin
			sol_a1_d = 35 ;
		end
		else if (de_reg_rotor_a[36] == sol_b1_d ) begin
			sol_a1_d = 36 ;
		end
		else if (de_reg_rotor_a[37] == sol_b1_d ) begin
			sol_a1_d = 37 ;
		end
		else if (de_reg_rotor_a[38] == sol_b1_d ) begin
			sol_a1_d = 38 ;
		end
		else if (de_reg_rotor_a[39] == sol_b1_d ) begin
			sol_a1_d = 39 ;
		end
		else if (de_reg_rotor_a[40] == sol_b1_d ) begin
			sol_a1_d = 40 ;
		end
		else if (de_reg_rotor_a[41] == sol_b1_d ) begin
			sol_a1_d = 41 ;
		end
		else if (de_reg_rotor_a[42] == sol_b1_d ) begin
			sol_a1_d = 42 ;
		end
		else if (de_reg_rotor_a[43] == sol_b1_d ) begin
			sol_a1_d = 43 ;
		end
		else if (de_reg_rotor_a[44] == sol_b1_d ) begin
			sol_a1_d = 44 ;
		end
		else if (de_reg_rotor_a[45] == sol_b1_d ) begin
			sol_a1_d = 45 ;
		end
		else if (de_reg_rotor_a[46] == sol_b1_d ) begin
			sol_a1_d = 46 ;
		end
		else if (de_reg_rotor_a[47] == sol_b1_d ) begin
			sol_a1_d = 47 ;
		end
		else if (de_reg_rotor_a[48] == sol_b1_d ) begin
			sol_a1_d = 48 ;
		end
		else if (de_reg_rotor_a[49] == sol_b1_d ) begin
			sol_a1_d = 49 ;
		end
		else if (de_reg_rotor_a[50] == sol_b1_d ) begin
			sol_a1_d = 50 ;
		end
		else if (de_reg_rotor_a[51] == sol_b1_d ) begin
			sol_a1_d = 51 ;
		end
		else if (de_reg_rotor_a[52] == sol_b1_d ) begin
			sol_a1_d = 52 ;
		end
		else if (de_reg_rotor_a[53] == sol_b1_d ) begin
			sol_a1_d = 53 ;
		end
		else if (de_reg_rotor_a[54] == sol_b1_d ) begin
			sol_a1_d = 54 ;
		end
		else if (de_reg_rotor_a[55] == sol_b1_d ) begin
			sol_a1_d = 55 ;
		end
		else if (de_reg_rotor_a[56] == sol_b1_d ) begin
			sol_a1_d = 56 ;
		end
		else if (de_reg_rotor_a[57] == sol_b1_d ) begin
			sol_a1_d = 57 ;
		end
		else if (de_reg_rotor_a[58] == sol_b1_d ) begin
			sol_a1_d = 58 ;
		end
		else if (de_reg_rotor_a[59] == sol_b1_d ) begin
			sol_a1_d = 59 ;
		end
		else if (de_reg_rotor_a[60] == sol_b1_d ) begin
			sol_a1_d = 60 ;
		end
		else if (de_reg_rotor_a[61] == sol_b1_d ) begin
			sol_a1_d = 61 ;
		end
		else if (de_reg_rotor_a[62] == sol_b1_d ) begin
			sol_a1_d = 62 ;
		end
		else if (de_reg_rotor_a[63] == sol_b1_d ) begin
			sol_a1_d = 63 ;
		end
		else begin 
			sol_a1_d = 0;
		end
	end
	else begin 
		sol_a1_d = 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		sol_a1_d_ans <= 0;
	end
	else if (state_cs == 2 && reg_crypt_mode == 0) begin
		sol_a1_d_ans <= sol_a1;
	end
	else if (state_cs == 2 && reg_crypt_mode == 1) begin
		sol_a1_d_ans <= sol_a1_d;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_code <= 0;
	end
	else if (reg_in_valid_2 == 0) begin
		out_code <= 0;
	end
	// else if (flag_1) begin
	// 	out_code <= sol_a1;
	// end
	else if (cnt>=1 && reg_crypt_mode == 0) begin
		out_code <= sol_a1;
	end
	else if (cnt>=1 && reg_crypt_mode == 1) begin
		out_code <= sol_a1_d_ans;
	end
	// else if (state_cs == 2) begin
	// 	if (reg_crypt_mode) 
	// 	begin
	// 		out_code <= sol_a1_d;
	// 	end
	// 	else begin
	// 		out_code <= 0;
	// 	end
	// end

	// else if (out_valid && reg_crypt_mode == 0) begin
	// 	out_code = sol_a1_d_ans;
	// end
	// else if (out_valid && reg_crypt_mode == 1) begin
	// 	out_code = sol_a1_d_ans;
	// end
	else out_code <= 0;
end

// output

// out_valid
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
	// else if (state_cs == 2) begin
	// 	if (reg_crypt_mode) //decry 
	// 	  out_valid <= 1;
	// 	else // encrypt
	// 	out_valid <= 0;
	// end
	else out_valid <= 0;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		flag_1 <= 0;
	else if (state_cs==2 )
	flag_1 <= 1;	
	else 
	flag_1 <= 0;
end
endmodule
