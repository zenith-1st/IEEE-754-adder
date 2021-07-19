module matrix_keypad(
input clk,
input [3:0] col_line, //col
output reg [3:0] row_line, //row
output reg [15:0]led,
//input [3:0] dispn,  // chossing 1 dispaly out of 4 possibilities
//input [6:0] disp);  // display 7 seg

reg [1:0] count  = 2'b00;


always@(posedge clk)
begin
count = count + 1;
end

always@(count)
begin
case(count)
2'b00: scan = 4'b0001;		//1st col
2'b01: scan = 4'b0010;		//2nd col
2'b10: scan = 4'b0100;		//3rd
2'b11: scan = 4'b1000;		//4th
defualt:scan = 4'b0001;
endcase
end


always@(scan,read)
begin
case(scan)
4'b0001:					//to check 1st column 4 prob(4-row)
case(read)
4'b0001: disp= 7'b1111110; //0
4'b0010: disp= 7'b1110011;	//4
4'b0100: disp= 7'b1111110; //8
4'b1000: disp= 7'b1001110;	//c
defaut: disp= 7'b0000000;
endcase

4'b0010:
case(read)
4'b0001: disp= 7'b0110000; //1
4'b0010: disp= 7'b1011011;	//5
4'b0100: disp= 7'b1111011; //9
4'b1000: disp= 7'b0111101;	//d
defaut: disp= 7'b0000000;
endcase

4'b0100:
case(read)
4'b0001: disp= 7'b1101101; //2
4'b0010: disp= 7'b1011111;	//6
4'b0100: disp= 7'b1110111; //A
4'b1000: disp= 7'b1001111;	//E
defaut: disp= 7'b0000000;
endcase

4'b0010:
case(read)
4'b0001: disp= 7'b1111001; //3
4'b0010: disp= 7'b1110000;	//7
4'b0100: disp= 7'b0011111; //b
4'b1000: disp= 7'b1000111;	//f
defaut: disp= 7'b0000000;
endcase

default: disp = 7'b0000000;

endcase
end

endmodule




