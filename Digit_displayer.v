module Digit_displayer(digit, s, pnl, btn1, lighter, btn2, clk);
	input [3:0] digit; //свичи для ввода числа
	input clk; //50 Мгц клок
	output wire [7:0] s; //Крайняя правая цифра
	output wire [7:0] pnl; //правая LED панель
	wire [7:0] first_d; //Самая левая цифра
	wire [7:0] second_d; //Вторая слева цифра
	wire [7:0] third_d; // Предпоследняя цифра цифра
	wire [7:0] fourth_d; //Последняя цифра
	wire [7:0] res1; //Первая выводимая цифра
	wire [7:0] res2; //Вторая выводимая цифра
	wire [7:0] res3; //Третья выводимая цифра
	wire [7:0] res4; //Четверая выводимая цифра
	wire [7:0] cosres1;
	wire [7:0] cosres2;
	wire [7:0] cosres3;
	wire [7:0] cosres4;
	wire [7:0] sinres1;
	wire [7:0] sinres2;
	wire [7:0] sinres3;
	wire [7:0] sinres4;
	digit_enter(digit, fourth_d); //Ввод правой крайней цифры
	wire clock_for_panel;
	wire [2:0] rcounter;
	Slow_Clock_100kHz(clk, clock_for_panel); //Замедляем клок до 1 мГц для отображения цифр
	Refresh_Counter(clock_for_panel, rcounter); //Счётчик для отображения цифр
	Anode_Control(rcounter, pnl); //Поочерёдное (практически одновременное) отображение цифр
	input btn1;
	output wire [3:0] lighter; //4 светодиода в крестике
	input btn2;
	display_changer(btn1, clk, lighter); //смена выводимой триг. функции
	new_button(btn2, clk, first_d, second_d, third_d, fourth_d); //ввести цифру следующего разряда
	wire [13:0] deg;
	wire [7:0] thousands;
	wire [7:0] hundreds;
	wire [7:0] tens;
	wire [7:0] units;
	BTD_translator(first_d, thousands);
	BTD_translator(second_d, hundreds);
	BTD_translator(third_d, tens);
	BTD_translator(fourth_d, units);
	summator(thousands, hundreds, tens, units, deg); //Суммируем цифры и переводим в одно число, обозначающее градусы
	reg [7:0] tmps; //Поочерёдно выводит цифры на дисплее
	reg [7:0] sk1;
	reg [7:0] sk2;
	reg [7:0] sk3;
	reg [7:0] sk4;
	assign res1 = sk1;
	assign res2 = sk2;
	assign res3 = sk3;
	assign res4 = sk4;
	assign s = tmps;
	sine(deg, sinres1, sinres2, sinres3, sinres4);
	cosine(deg, cosres1, cosres2, cosres3, cosres4);
	always @(lighter)
	begin
		case (lighter)
		4'b0111: begin
			sk1 = sinres1;
			sk2 = sinres2;
			sk3 = sinres3;
			sk4 = sinres4;
			end
		4'b1011: begin
			sk1 = cosres1;
			sk2 = cosres2;
			sk3 = cosres3;
			sk4 = cosres4;
			end
		4'b1101: begin
			sk1 = sinres1;
			sk2 = sinres2;
			sk3 = sinres3;
			sk4 = sinres4;
			end
		4'b1110: begin
			sk1 = cosres1;
			sk2 = cosres2;
			sk3 = cosres3;
			sk4 = cosres4;
			end
		default: begin
			sk1 = sinres1;
			sk2 = sinres2;
			sk3 = sinres3;
			sk4 = sinres4;
			end
		endcase
	end
	
	always @ (pnl)
	begin
		case (pnl)
		8'b01111111: tmps = res1;
		8'b10111111: tmps = res2;
		8'b11011111: tmps = res3;
		8'b11101111: tmps = res4;
		8'b11110111: tmps = first_d;
		8'b11111011: tmps = second_d;
		8'b11111101: tmps = third_d;
		8'b11111110: tmps = fourth_d;
		endcase
	end
	
endmodule

module digit_enter(digit, s);
	input [3:0] digit; //4 свича
	output wire [7:0] s; //7 сегментов
	reg[7:0] segments;
	assign s = segments;
	always @(digit)
	begin
		case (digit)
			4'b1111: segments = 8'b10000001; //0
			4'b1110: segments = 8'b11001111; //1
			4'b1101: segments = 8'b10010010; //2
			4'b1100: segments = 8'b10000110; //3
			4'b1011: segments = 8'b11001100; //4
			4'b1010: segments = 8'b10100100; //5
			4'b1001: segments = 8'b10100000; //6
			4'b1000: segments = 8'b10001111; //7
			4'b0111: segments = 8'b10000000; //8
			4'b0110: segments = 8'b10000100; //9
			default: segments = 8'b11111110; //-
		endcase
	end
endmodule

module Refresh_Counter(refresh_clk, refresh_counter);
	input refresh_clk;
	output reg [2:0] refresh_counter = 3'b000;
	always @(posedge refresh_clk) refresh_counter <= refresh_counter + 3'b001;
endmodule

module Anode_Control(refresh_counter, anode); //включение LED панели для отображения цифр (Pin 128, 129, 132, 133)
	input [2:0] refresh_counter;
	output reg [7:0] anode;
	always @(refresh_counter)
	begin
		case (refresh_counter)
		3'b000: anode = 8'b11111110;
		3'b001: anode = 8'b11111101;
		3'b010: anode = 8'b11111011;
		3'b011: anode = 8'b11110111;
		3'b100: anode = 8'b11101111;
		3'b101: anode = 8'b11011111;
		3'b110: anode = 8'b10111111;
		3'b111: anode = 8'b01111111;
		endcase
	end
endmodule 
	
module BTD_translator(bin_digit, dec_output);
	input [7:0] bin_digit;
	output reg [13:0] dec_output;
	always @(bin_digit)
	begin
	case (bin_digit)
		8'b10000001: dec_output = 14'b00000000000000; //лучше бы заменить всё на числа в двоичной СС
		8'b11001111: dec_output = 14'b00000000000001;
		8'b10010010: dec_output = 14'b00000000000010;
		8'b10000110: dec_output = 14'b00000000000011;
		8'b11001100: dec_output = 14'b00000000000100;
		8'b10100100: dec_output = 14'b00000000000101;
		8'b10100000: dec_output = 14'b00000000000110;
		8'b10001111: dec_output = 14'b00000000000111;
		8'b10000000: dec_output = 14'b00000000001000;
		8'b10000100: dec_output = 14'b00000000001001;
		default: dec_output = 14'b00000000000000;
	endcase
	end
endmodule	
module summator(thousands, hundreds, tens, units, final_number);
	input [13:0] thousands;
	input [13:0] hundreds;
	input [13:0] tens;
	input [13:0] units;
	output wire [13:0] final_number;
	assign final_number = (thousands * 14'b00001111101000 + hundreds * 14'b00000001100100 + tens * 14'b00000000001010 + units) % 14'b00000101101000;
endmodule




	
	
	
	
	
	
	
	
	
	
	
	
	
	