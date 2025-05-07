module Deframe (

	input rst_n, 
	input receive_flag,
	input [10:0] data_parll, 

	output reg parity_bit,
	output reg start_bit,
	output reg stop_bit, 
	output reg done_flag,
	output reg [7:0]data_out
);


always@(*)

begin

	start_bit     = data_parll[0];
	stop_bit      = data_parll[10];
	done_flag     = receive_flag;
	data_out[7:0] = data_parll[8:1];
    parity_bit    = data_parll[9];

end 

endmodule
