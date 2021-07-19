/* in Half precision FPA, 1bit = Sign bit,
								  5 bit = exp , 
								  10 bit = fraction/mentessa 
*/

module FPADD (CLK, St, done, ovf, unf, FPinput, FPsum);
input CLK;
input St;			//sw
output reg done;
output reg ovf;	//to check overflow 
output reg unf;	//to check underflow
input[15:0] FPinput;
output[15:0] FPsum;

reg[12:0] F1;	//fraction of in1(10+2) 2 more bit to check overflow condition 
reg[12:0] F2;	//fraction of in2(10+2)
reg[4:0] E1;	//exp of in1
reg[4:0] E2;	//exp of in2
reg S1;  		//in1 sign bit
reg S2;			//in2 sign bit
wire FV;
wire FU;
wire[14:0] F1comp;	//gaurd bit
wire[14:0] F2comp;
wire[14:0] Addout;	//f1comp+f2comp
wire[14:0] Fsum;
reg[2:0] State;      //stages

initial
begin
State = 0;
done = 0;
ovf = 0;
unf = 0;
S1 = 0;
S2 = 0;
F1 = 0;
F2 = 0;
E1 = 0;
E2 = 0;
end

assign F1comp = (S1) ? ~({2'b00, F1}) + 1 : {2'b00, F1} ; //if sign bit 1 then comp
assign F2comp = (S2 == 1'b1) ? ~({2'b00, F2}) + 1 : {2'b00, F2} ;	//if sign bit 1 then comp
assign Addout = F1comp + F2comp ;
assign Fsum = ((Addout[14]) == 1'b0) ? Addout : ~Addout + 1 ;
assign FV = Fsum[14] ^ Fsum[13] ; 	//to find overflow
assign FU = ~F1[12] ;					//underflow
assign FPsum = {S1, E1, F1[11:2]} ;  



always @(posedge CLK)
begin

	case (State)
	0 : 								//for input 1
		begin
		if (St == 1'b1)
		begin
		E1 <= FPinput[14:10] ; 	//exp (5 bit)
		S1 <= FPinput[15] ;		//sign
		F1[12:0] <= {FPinput[9:0], 2'b00} ;
		if (FPinput == 0)  //?
		begin
		F1[12] <= 1'b0 ; // to generate UF
		end
		else
		begin
		F1[12] <= 1'b1 ;
		end
		done <= 1'b0 ;
		ovf <= 1'b0 ;
		unf <= 1'b0 ;
		State <= 1 ;
		end
		end
		
	1 :												//for input 2
		begin
		E2 <= FPinput[14:10] ;
		S2 <= FPinput[15] ;
		F2[12:0] <= {FPinput[9:0], 2'b00} ;
		if (FPinput == 0)
		begin
		F2[12] <= 1'b0 ;
		end
		else
		begin
		F2[12] <= 1'b1 ;
		end
		State <= 2 ;
		end
	2 :										//to check exp condition
		begin
		if (F1 == 0 | F2 == 0)			//if both frcn are zero => stage 3
		begin
		State <= 3 ;						
		end
		else
		begin
		if (E1 == E2)						//if both have same exp value => stage 3
		begin
		State <= 3 ;
		end
		else if (E1 < E2)					//make them equal by right shift 
		begin
		F1 <= {1'b0, F1[12:1]} ;		//righr shift? if yes then why they concider only fractn
		E1 <= E1 + 1 ;
		end
		else
		begin
		F2 <= {1'b0, F2[12:1]} ;
		E2 <= E2 + 1 ;
		end
		end
		end
	3 :								//if (F1 == 0 | F2 == 0) elif e1=e2	
		begin
		S1 <= Addout[14] ;   	//????? comp1 and com2 ni last bit  is sign:????
		if (FV == 1'b0)
		begin
		F1 <= Fsum[12:0] ;      //underflow		
		end
		else
		begin
		F1 <= Fsum[13:1] ;     //stage 4 for overflow right shift
		E1 <= E1 + 1 ;
		end
		State <= 4 ;
		end
	4 :							//if state 3 is overflow then how f1 can equal to 0?????
		begin
		if (F1 == 0)			//just check if frcn is zero or not
		begin
		E1 <= 5'b00000 ;
		State <= 6 ;
		end
		else
		begin
		State <= 5 ;
		end
		end
	5 :
		begin
		if (E1 == 0)		//underflow 
		begin
		unf <= 1'b1 ;
		State <= 6 ;
		end
		else if (FU == 1'b0)
		begin
		State <= 6 ;
		end
		else
		begin
		F1 <= {F1[11:0], 1'b0} ;   //normalize
		E1 <= E1 - 1 ;					// left shift
		end
		end
	6 :
		begin
		if (E1 == 31)			//exp is 5 bit so max is 2^5
		begin
		ovf <= 1'b1 ;
		end
		done <= 1'b1 ;
		State <= 0 ;
		end
		endcase
	end
endmodule