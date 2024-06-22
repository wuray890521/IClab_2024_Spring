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
module SORT_IP #(parameter IP_WIDTH = 3) (
    // Input signals
    IN_character, IN_weight,
    // Output signals
    OUT_character
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_WIDTH*4-1:0]  IN_character;
input [IP_WIDTH*5-1:0]  IN_weight;

output [IP_WIDTH*4-1:0] OUT_character;

reg [3:0]  input_charac[7:0];
reg [4:0] input_weight[7:0] ;

// wire [4:0] temp[7:0] ;
// wire [4:0] temp1[7:0] ;
// wire [4:0] temp2[7:0] ;
// wire [4:0] temp3[7:0] ;
// wire [4:0] temp4[7:0] ;
// wire [4:0] sol_w[7:0] ;
// wire [3:0] test[7:0] ;
// wire [3:0] test1[7:0];
// wire [3:0] test2[7:0];
// wire [3:0] test3[7:0];
// wire [3:0] test4[7:0];
// wire [3:0] sol_c[7:0];
// ===============================================================
// Design
// ===============================================================

genvar i;
generate 
	for (i = 0 ; i < 8 ; i  = i + 1) begin 
		if (i < IP_WIDTH) begin 
            always @(*) begin
                input_charac[i] = IN_character[(IP_WIDTH-i)*4-1 -: 4] ;
            end
            always @(*) begin
                input_weight[i] = IN_weight[(IP_WIDTH-i)*5-1 -: 5] ;
            end
		end
	end
endgenerate
// comparatorweight C1(.in_weight1(input_weight[0]), .in_weight2(input_weight[1]), .in_character1(input_charac[0]), .in_character2(input_charac[1]), .bigweight(temp[0]), .smallweight(temp[1]), .bigcharacter(test[0]), .smallcharacter(test[1]));
// comparatorweight C2(.in_weight1(input_weight[2]), .in_weight2(input_weight[3]), .in_character1(input_charac[2]), .in_character2(input_charac[3]), .bigweight(temp[2]), .smallweight(temp[3]), .bigcharacter(test[2]), .smallcharacter(test[3]));
// comparatorweight C3(.in_weight1(input_weight[4]), .in_weight2(input_weight[5]), .in_character1(input_charac[4]), .in_character2(input_charac[5]), .bigweight(temp[4]), .smallweight(temp[5]), .bigcharacter(test[4]), .smallcharacter(test[5]));
// comparatorweight C4(.in_weight1(input_weight[6]), .in_weight2(input_weight[7]), .in_character1(input_charac[6]), .in_character2(input_charac[7]), .bigweight(temp[6]), .smallweight(temp[7]), .bigcharacter(test[6]), .smallcharacter(test[7]));

// comparatorweight C5(.in_weight1(temp[0]), .in_weight2(temp[2]), .in_character1(test[0]), .in_character2(test[2]), .bigweight(temp1[0]), .smallweight(temp1[1]), .bigcharacter(test1[0]), .smallcharacter(test1[1]));
// comparatorweight C6(.in_weight1(temp[1]), .in_weight2(temp[3]), .in_character1(test[1]), .in_character2(test[3]), .bigweight(temp1[2]), .smallweight(temp1[3]), .bigcharacter(test1[2]), .smallcharacter(test1[3]));
// comparatorweight C7(.in_weight1(temp[4]), .in_weight2(temp[6]), .in_character1(test[4]), .in_character2(test[6]), .bigweight(temp1[4]), .smallweight(temp1[5]), .bigcharacter(test1[4]), .smallcharacter(test1[5]));
// comparatorweight C8(.in_weight1(temp[5]), .in_weight2(temp[7]), .in_character1(test[5]), .in_character2(test[7]), .bigweight(temp1[6]), .smallweight(temp1[7]), .bigcharacter(test1[6]), .smallcharacter(test1[7]));

// comparatorweight C9 (.in_weight1(temp1[0]), .in_weight2(temp1[4]), .in_character1(test1[0]), .in_character2(test1[4]), .bigweight(temp2[0]), .smallweight(temp2[1]), .bigcharacter(test2[0]), .smallcharacter(test2[1]));
// comparatorweight C10(.in_weight1(temp1[1]), .in_weight2(temp1[2]), .in_character1(test1[1]), .in_character2(test1[2]), .bigweight(temp2[2]), .smallweight(temp2[3]), .bigcharacter(test2[2]), .smallcharacter(test2[3]));
// comparatorweight C11(.in_weight1(temp1[5]), .in_weight2(temp1[6]), .in_character1(test1[5]), .in_character2(test1[6]), .bigweight(temp2[4]), .smallweight(temp2[5]), .bigcharacter(test2[4]), .smallcharacter(test2[5]));
// comparatorweight C12(.in_weight1(temp1[3]), .in_weight2(temp1[7]), .in_character1(test1[3]), .in_character2(test1[7]), .bigweight(temp2[6]), .smallweight(temp2[7]), .bigcharacter(test2[6]), .smallcharacter(test2[7]));

// comparatorweight C13(.in_weight1(temp2[0]), .in_weight2(temp2[1]), .in_character1(test2[0]), .in_character2(test2[1]), .bigweight(temp3[0]), .smallweight(temp3[1]), .bigcharacter(test3[0]), .smallcharacter(test3[1]));
// comparatorweight C14(.in_weight1(temp2[2]), .in_weight2(temp2[4]), .in_character1(test2[2]), .in_character2(test2[4]), .bigweight(temp3[4]), .smallweight(temp3[5]), .bigcharacter(test3[4]), .smallcharacter(test3[5]));
// comparatorweight C15(.in_weight1(temp2[3]), .in_weight2(temp2[5]), .in_character1(test2[3]), .in_character2(test2[5]), .bigweight(temp3[2]), .smallweight(temp3[3]), .bigcharacter(test3[2]), .smallcharacter(test3[3]));
// comparatorweight C16(.in_weight1(temp2[6]), .in_weight2(temp2[7]), .in_character1(test2[6]), .in_character2(test2[7]), .bigweight(temp3[6]), .smallweight(temp3[7]), .bigcharacter(test3[6]), .smallcharacter(test3[7]));

// comparatorweight C17(.in_weight1(temp3[1]), .in_weight2(temp3[2]), .in_character1(test3[1]), .in_character2(test3[2]), .bigweight(temp4[1]), .smallweight(temp4[2]), .bigcharacter(test4[1]), .smallcharacter(test4[2]));
// comparatorweight C18(.in_weight1(temp3[5]), .in_weight2(temp3[6]), .in_character1(test3[5]), .in_character2(test3[6]), .bigweight(temp4[5]), .smallweight(temp4[6]), .bigcharacter(test4[5]), .smallcharacter(test4[6]));
// comparatorweight C19(.in_weight1(temp3[0]), .in_weight2(temp3[3]), .in_character1(test3[0]), .in_character2(test3[3]), .bigweight(temp4[0]), .smallweight(temp4[3]), .bigcharacter(test4[0]), .smallcharacter(test4[3]));
// comparatorweight C20(.in_weight1(temp3[4]), .in_weight2(temp3[7]), .in_character1(test3[4]), .in_character2(test3[7]), .bigweight(temp4[4]), .smallweight(temp4[7]), .bigcharacter(test4[4]), .smallcharacter(test4[7]));

// comparatorweight C21(.in_weight1(temp4[0]), .in_weight2(temp4[7]), .in_character1(test4[0]), .in_character2(test4[7]), .bigweight(sol_w[0]), .smallweight(sol_w[7]), .bigcharacter(sol_c[0]), .smallcharacter(sol_c[7]));
// comparatorweight C22(.in_weight1(temp4[1]), .in_weight2(temp4[4]), .in_character1(test4[1]), .in_character2(test4[4]), .bigweight(sol_w[1]), .smallweight(sol_w[2]), .bigcharacter(sol_c[1]), .smallcharacter(sol_c[2]));
// comparatorweight C23(.in_weight1(temp4[2]), .in_weight2(temp4[5]), .in_character1(test4[2]), .in_character2(test4[5]), .bigweight(sol_w[3]), .smallweight(sol_w[4]), .bigcharacter(sol_c[3]), .smallcharacter(sol_c[4]));
// comparatorweight C24(.in_weight1(temp4[3]), .in_weight2(temp4[6]), .in_character1(test4[3]), .in_character2(test4[6]), .bigweight(sol_w[5]), .smallweight(sol_w[6]), .bigcharacter(sol_c[5]), .smallcharacter(sol_c[6]));

integer x,y; 
reg [4:0] temp;
reg [3:0] temp_char;
reg [4:0] array [0:7];
reg [3:0] array_char [0:7];
always@(*)begin
// array[0] = input_weight[0];
// array[1] = input_weight[1];
// array[2] = input_weight[2];
// array[3] = input_weight[3];
// array[4] = input_weight[4];
// array[5] = input_weight[5];
// array[6] = input_weight[6];
// array[7] = input_weight[7];

// array_char[0] = input_char[0];
// array_char[1] = input_char[1];
// array_char[2] = input_char[2];
// array_char[3] = input_char[3];
// array_char[4] = input_char[4];
// array_char[5] = input_char[5];
// array_char[6] = input_char[6];
// array_char[7] = input_char[7];

for (x = 9; x > 1; x = x - 1) begin
	for (y = 0 ; y < x; y = y + 1) begin
			if (array[y] < array[y + 1])begin
			  temp = input_weight[y];
			  temp_char = input_charc[y];
			  input_weight[y] = input_weight[y + 1];
			  input_charc[y] = input_charc[y+1];
			  input_weight[y + 1] = temp;
			  input_char[y+1] = temp_char;
			end
		end
	end 
end

generate 
	for (i = 0 ; i < IP_WIDTH ; i  = i + 1) begin 
		assign OUT_character[(IP_WIDTH-i)*4-1 -: 4] = input_charc[i] ;
	end
endgenerate
endmodule

module comparatorweight (
    in_weight1,
    in_weight2,
    in_character1,
    in_character2,

    bigweight,
    smallweight, 
    bigcharacter,
    smallcharacter
);
    input [4:0]in_weight1;
    input [4:0]in_weight2;   
    input [3:0]in_character1;
    input [3:0]in_character2;   
    output reg [4:0]bigweight, smallweight; 
    output reg [3:0]bigcharacter, smallcharacter; 

always @(*) begin
    if (in_weight1 > in_weight2 | ((in_weight1 == in_weight2) && (in_character1 > in_character2))) begin
        bigweight = in_weight1;
        smallweight = in_weight2;
        bigcharacter = in_character1;
        smallcharacter = in_character2;
    end
    else begin
        bigweight = in_weight2;
        smallweight = in_weight1;
        bigcharacter = in_character2;
        smallcharacter = in_character1;
    end
end

endmodule