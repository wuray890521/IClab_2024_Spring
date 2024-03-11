# Lab01 Code Calculator
Github : [**Lab01Github**](https://github.com/wuray890521/IClab/tree/main/Lab1)
# Description
# Topic of this week
# What codeing style I learn from this Lab?
Q1 : 在使用submodule時要注意什麼?
A1 : 輸出，輸入訊號的型別以及在submodule與連接出電路的腳位 signed 、 bits 必須一致，如下所示。
```verilog=
reg  signed [9:0] regn0, regn1, regn2, regn3, regn4;
wire signed [9:0] a, b, c, d, e;

AD N1 (.inp1(regn0), .inp2(-normal), .outp(a));
AD N2 (.inp1(regn1), .inp2(-normal), .outp(b));
AD N3 (.inp1(regn2), .inp2(-normal), .outp(c));
AD N4 (.inp1(regn3), .inp2(-normal), .outp(d));
AD N5 (.inp1(regn4), .inp2(-normal), .outp(e));

module AD (inp1, inp2, outp);
    input wire signed [9:0] inp1, inp2;
    output wire signed [9:0] outp;
    assign outp = inp1 + inp2;
endmodule
```
Q2 : 有號數，無號數要如何定義?
A2 : 如下所示。
```verilog=
reg  signed [9:0] reg_in_n [4:0];
reg  signed [9:0] tmp;
wire signed [9:0] a, b, c, d, e;
```
# Experience
在使用verilog時建議使用硬體語言去思考而非使用軟體語言。
以排序為例 : 
bubble sorting :
```verilog=
always @(*) begin
  reg_in_n[0] = {4'b0,in_n0} ;
  reg_in_n[1] = {4'b0,in_n1} ;
  reg_in_n[2] = {4'b0,in_n2} ;
  reg_in_n[3] = {4'b0,in_n3} ;
  reg_in_n[4] = {4'b0,in_n4} ;
  for(i = 0; i < 4; i = i + 1) begin
      for(j = 0; j < 4; j = j + 1) begin
          if( reg_in_n[j] < reg_in_n[j+1]) begin
              tmp = reg_in_n [j];
              reg_in_n[j] = reg_in_n[j+1];
              reg_in_n[j+1] = tmp;
          end
      end
  end
end
```
hardware sort algorithm : 
```verilog=
CM C1 (.inp5(reg_in_n [0]), .inp6(reg_in_n [1]), .outpbig(a1), .outpsmall(a2));
CM C2 (.inp5(reg_in_n [2]), .inp6(reg_in_n [3]), .outpbig(a3), .outpsmall(a4));
CM C3 (.inp5(a1), .inp6(a3), .outpbig(b1), .outpsmall(b2));
CM C4 (.inp5(a2), .inp6(a4), .outpbig(b3), .outpsmall(b4));
CM C5 (.inp5(b2), .inp6(b3), .outpbig(l1), .outpsmall(l2));
assign reg_in_n[0] = {4'b0,in_n0} ;
assign reg_in_n[1] = {4'b0,in_n1} ;
assign reg_in_n[2] = {4'b0,in_n2} ;
assign reg_in_n[3] = {4'b0,in_n3} ;
assign reg_in_n[4] = {4'b0,in_n4} ;
always @(*) begin
  if (reg_in_n [4] < b4) begin
    s0 = b1;
    s1 = l1;
    s2 = l2;
    s3 = b4;
    s4 = reg_in_n [4];
  end
  else if (reg_in_n [4] < l2) begin
    s0 = b1;
    s1 = l1;
    s2 = l2;
    s3 = reg_in_n [4];
    s4 = b4;
  end
  else if (reg_in_n [4] < l1) begin
    s0 = b1;
    s1 = l1;
    s2 = reg_in_n [4];
    s3 = l2;
    s4 = b4;
  end
  else if (reg_in_n [4] < b1) begin
    s0 = b1;
    s1 = reg_in_n [4];
    s2 = l1;
    s3 = l2;
    s4 = b4;
  end
  else begin
    s0 = reg_in_n [4];
    s1 = b1;
    s2 = l1;
    s3 = l2;
    s4 = b4;
  end
end
```
兩者在比較器的使用數量上就會有極大的差異。