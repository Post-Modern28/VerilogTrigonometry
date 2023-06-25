module debouncer(pb, clk_in, out_1); //Штука для обработки дребезга контактов
	input pb, clk_in;
	output out_1;
	wire clk_out;
	wire q1, q2, q2_bar, tmp;
	Slow_Clock_4Hz cl1(clk_in, clk_out);
	D_flip_flop d1(clk_out, pb, q1);
	//assign tmp = pb & q1;
	D_flip_flop d2(clk_out, q1, q2);
	
	assign q2_bar = ~q2;
	assign out_1 = q1 & q2_bar;
endmodule



module D_flip_flop(clk, d, q, qbar);
	input clk, d;
	output reg q;
	output reg qbar;
	always @(posedge clk)
	begin
		q = d;
		qbar = ~q;
	end
endmodule
			
module Slow_Clock_4Hz(clk_in, clk_out);
	input clk_in;
	output clk_out;
	reg [30:0] count = 0;
	reg clk_out;
	always @(posedge clk_in)
	begin
		count = count + 1;
		if (count >= 500_000)
		begin
			count = 0;
			clk_out = ~clk_out;
		end
	end
endmodule

module Slow_Clock_100kHz(clk_in, clk_out);
	input clk_in;
	output clk_out;
	reg [30:0] count = 0;
	reg clk_out;
	always @(posedge clk_in)
	begin
		count = count + 1;
		if (count >= 1_000)
		begin
			count = 0;
			clk_out = ~clk_out;
		end
	end
endmodule	
