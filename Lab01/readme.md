
4bit 比較器
```
module  four_bit_magnitude_comparator(output L,G,E,input[3:0]A,B);
    wire[3:0] x;
    assign  x[0] = ~(A[0]^B[0]),
            x[1] = ~(A[1]^B[1]),
            x[2] = ~(A[2]^B[2]),
            x[3] = ~(A[3]^B[3]),
            L = ~A[3]&B[3] | x[3]&~A[2]&B[2] |
            x[3]&x[2]&~A[1]&B[1] |      
            x[3]&x[2]&x[1]&~A[0]&B[0],
            G = A[3]&~B[3] | x[3]&A[2]&~B[2] | 
            x[3]&x[2]&A[1]&~B[1] | 
            x[3]&x[2]&x[1]&A[0]&~B[0],
            E = x[0]&x[1]&x[2]&x[3];
endmodule
```
在除掉特定的數字，且有一定的範圍下應該使用查表的case與法而非無腦的直接用 / 下去做除法。
