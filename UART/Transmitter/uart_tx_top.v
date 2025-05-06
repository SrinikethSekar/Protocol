module uart_top_tx (
	input clk,    
	input rst_n, 
	input send,
	input [7:0] data_in, 
	input [1:0]parity_type,
	input [1:0]baud_rate,

	output data_tx,
	output active_flag,
	output done_flag

	);

wire parity_bit;
wire baud_clk;


Piso uut1(.rst_n(rst_n),
		  .send(send),
		  .data_in(data_in),
		  .parity_bit(parity_bit),
		  .baud_clk(baud_clk),
		  .data_tx(data_tx),
		  .active_flag(active_flag),
		  .done_flag(done_flag));

baud_generator uut2(.clk(clk),
					.rst_n(rst_n), 
					.baud_rate(baud_rate), 
					.baud_clk(baud_clk));


Parity uut3(.rst_n(rst_n),
			.data_in(data_in), 
			.parity_type(parity_type),
			.parity_bit(parity_bit));

		
endmodule
