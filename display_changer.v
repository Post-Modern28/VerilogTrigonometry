module display_changer(btn1, clknew, lighter); //смена тригонометрической функции
	input btn1;
	input clknew;
	reg [1:0] counter = 2'b00;
	output wire [3:0] lighter;
	wire stable_signal;
	debouncer(btn1, clknew, stable_signal);
	reg [3:0] position;
	assign lighter = position;
	always @(posedge stable_signal)
	begin
		counter = counter + 2'b01;
		case (counter)
			2'b00: position = 4'b1110;
			2'b01: position = 4'b1101;
			2'b10: position = 4'b1011;
			2'b11: position = 4'b0111;
		endcase 
	end
endmodule



