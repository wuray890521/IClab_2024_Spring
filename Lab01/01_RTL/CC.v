

//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2024 Spring
//   Lab01 Exercise		: Code Calculator
//   Author     		  : Jhan-Yi LIAO
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CC.v
//   Module Name : CC
//   Release version : V1.0 (Release Date: 2024-02)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################


module CC(
  // Input signals
    opt,
    in_n0, in_n1, in_n2, in_n3, in_n4,  
  // Output signals
    out_n
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input wire [3:0] in_n0, in_n1, in_n2, in_n3, in_n4;
input wire [2:0] opt;
output reg [9:0] out_n;         					

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment
wire signed [9:0] reg_in_n [4:0];
reg  signed [9:0] tmp;

wire signed [9:0] a1, a2, a3, a4;
wire signed [9:0] b1, b2, b3, b4;
wire signed [9:0] l1, l2;
reg signed [9:0] s0, s1, s2, s3, s4;

wire signed [9:0] a, b, c, d, e;


reg  signed [9:0] n0, n1, n2, n3, n4;
reg  signed [9:0] regn0, regn1, regn2, regn3, regn4;

wire signed [9:0] n0_1, n2_3, no_4;
wire signed [9:0] n3_3;
wire signed [9:0] n0_4;


wire signed [9:0] normal;
wire signed [9:0] normal1;
 
reg  signed [9:0] avg;
wire signed [9:0] avg1;
 
integer i, j;
//================================================================
//    DESIGN
//================================================================
CM C1 (.inp5(reg_in_n [0]), .inp6(reg_in_n [1]), .outpbig(a1), .outpsmall(a2));
CM C2 (.inp5(reg_in_n [2]), .inp6(reg_in_n [3]), .outpbig(a3), .outpsmall(a4));

CM C3 (.inp5(a1), .inp6(a3), .outpbig(b1), .outpsmall(b2));
CM C4 (.inp5(a2), .inp6(a4), .outpbig(b3), .outpsmall(b4));

CM C5 (.inp5(b2), .inp6(b3), .outpbig(l1), .outpsmall(l2));
//DO NORMALIZATION
AD N1 (.inp1(regn0), .inp2(-normal), .outp(a));
AD N2 (.inp1(regn1), .inp2(-normal), .outp(b));
AD N3 (.inp1(regn2), .inp2(-normal), .outp(c));
AD N4 (.inp1(regn3), .inp2(-normal), .outp(d));
AD N5 (.inp1(regn4), .inp2(-normal), .outp(e));
// calculation
//n3*3
AD U6 (.inp1(n3 <<< 1), .inp2(n3), .outp(n3_3));
MU M1 (.inp3(n0), .inp4(n4), .outp1(n0_4));
// put data in reg
assign reg_in_n[0] = {4'b0,in_n0} ;
assign reg_in_n[1] = {4'b0,in_n1} ;
assign reg_in_n[2] = {4'b0,in_n2} ;
assign reg_in_n[3] = {4'b0,in_n3} ;
assign reg_in_n[4] = {4'b0,in_n4} ;
// sort
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
  case (opt[1])
  1'b1 : begin
    regn0 = s0 ;
    regn1 = s1 ;
    regn2 = s2 ;
    regn3 = s3 ;
    regn4 = s4 ;
  end
  default : begin
    regn0 = s4 ;
    regn1 = s3 ;
    regn2 = s2 ;
    regn3 = s1 ;
    regn4 = s0 ;
  end
  endcase
end
// normalization
// calculate normalize number
AD U1 (.inp1(regn0), .inp2(regn4), .outp(normal1));
assign normal = (normal1)/2;
always @(*) begin
  case (opt[0])
  1'b1 : begin
    n0 = a;
    n1 = b;
    n2 = c;
    n3 = d;
    n4 = e;
  end
  
  default : begin
    n0 = regn0;
    n1 = regn1;
    n2 = regn2;
    n3 = regn3;
    n4 = regn4;
  end
  endcase
end
//OUT PUT THE ANS.
always @(*) begin
avg = (n0 + n1 + n2 + n3 + n4)/5;
  case(opt[2])
    1'b1: begin
      out_n = ((n3_3) > (n0_4)) ? ((n3_3) - (n0_4)) : (-((n3_3) - (n0_4)));
    end
    default: begin
      out_n = (n0 + (n1 * n2) + (avg * n3))/3;
    end
  endcase
end
// --------------------------------------------------
// write your design here
// --------------------------------------------------
endmodule
// sub module to adder
module AD (inp1, inp2, outp);
  input wire signed [9:0] inp1, inp2;
  output wire signed [9:0] outp;
  
  assign outp = inp1 + inp2;
endmodule
// sub module to multi
module MU (inp3, inp4, outp1);
  input wire signed [9:0] inp3, inp4;
  output wire signed [9:0] outp1;
  
  assign outp1 = inp3 * inp4;
endmodule
// sub module to compare
module CM (inp5, inp6, outpbig, outpsmall);
  input  wire signed [9:0] inp5, inp6;
  output wire signed [9:0] outpbig, outpsmall;

  assign outpbig = (inp5 > inp6) ? inp5 : inp6 ;
  assign outpsmall = (inp5 > inp6) ? inp6 : inp5 ;
endmodule
