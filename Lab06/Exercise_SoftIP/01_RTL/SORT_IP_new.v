
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : SORT_IP.v
//   	Module Name : SORT_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module SORT_IP #(parameter IP_WIDTH = 8) (
    // Input signals
    IN_character, IN_weight,
    // Output signals
    OUT_character
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_WIDTH*4-1:0]  IN_character; //8x4 =32
input [IP_WIDTH*5-1:0]  IN_weight;    //39:0

output [IP_WIDTH*4-1:0] OUT_character; //8x4 =32
// ===============================================================
// wire & reg
// ===============================================================
reg [3:0] input_charac [0:7] ;
reg [4:0] input_weight [0:7] ;
integer k,l;
// ===============================================================
// case 
// ===============================================================
genvar i, j ;
generate 
	for (i = 0 ; i < 8 ; i  = i + 1) begin 
		always@(*)begin
		if (i < IP_WIDTH) begin 
			 input_charac[i] = IN_character[(IP_WIDTH-i)*4-1 -: 4] ;
			 input_weight[i] = IN_weight[(IP_WIDTH-i)*5-1 -: 5] ;
		end
		else begin 
			input_charac[i] = 0 ;
		    input_weight[i] = 0 ;

		end
		end
	end
endgenerate

reg [4:0] temp_weight;
reg [3:0] temp_char;
reg [4:0] array_weight [0:7];
reg [3:0] array_charac [0:7];
always@(*)begin
array_weight[0] = input_weight[0];
array_weight[1] = input_weight[1];
array_weight[2] = input_weight[2];
array_weight[3] = input_weight[3];
array_weight[4] = input_weight[4];
array_weight[5] = input_weight[5];
array_weight[6] = input_weight[6];
array_weight[7] = input_weight[7];

array_charac[0] = input_charac[0];
array_charac[1] = input_charac[1];
array_charac[2] = input_charac[2];
array_charac[3] = input_charac[3];
array_charac[4] = input_charac[4];
array_charac[5] = input_charac[5];
array_charac[6] = input_charac[6];
array_charac[7] = input_charac[7];

for (k = 9; k > 1; k = k - 1) begin
	for (l = 0 ; l < k; l = l + 1) begin
			if (array_weight[l] < array_weight[l + 1])begin
			  temp_weight = array_weight[l];
			  temp_char = array_charac[l];
			  array_charac[l] = array_charac[l+1];
			  array_weight[l] = array_weight[l + 1];	
			  array_weight[l + 1] = temp_weight;
			  array_charac[l+1] = temp_char;
			end
		end
	end 
end
 
generate 
	for (i = 0 ; i < IP_WIDTH ; i  = i + 1) begin 
		assign OUT_character[(IP_WIDTH-i)*4-1 -: 4] = array_charac[i] ;
	end
endgenerate




endmodule



