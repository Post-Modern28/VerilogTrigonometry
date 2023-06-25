module new_button(btn2, clknew, d1, d2, d3, d4); //Вводим новую цифру и сдвигаем всё влево
	input btn2;
	input clknew;
	output reg [7:0] d1;
	output reg [7:0] d2;
	output reg [7:0] d3;
	input [7:0] d4;
	wire stable_signal;
	debouncer(btn2, clknew, stable_signal);
	//reg [1:0] counter = 2'b00;
	always @(posedge stable_signal)
	begin
		if (d4 != 8'b00000001 && d4 != 8'b11111110)
		begin
		d1 = d2;
		d2 = d3;
		d3 = d4;
		if (d1 == 8'b10000001)
		begin
			d1 = 8'b11111111;
			if (d2 == 8'b10000001)
			begin
				d2 = 8'b11111111;
				if (d3 == 8'b10000001)
				begin
					d3 = 8'b11111111;
				end
			end
		end
		end
	end
endmodule