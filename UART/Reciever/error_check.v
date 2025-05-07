module error_check (
			input  rst_n, 
			input  received_flag, 
			input  [1:0]parity_type, 
			input  start_bit,
			input  stop_bit, 
			input  parity_bit, 
			input [7:0]	data_out, 

			output reg [2:0] error_flag

);

reg error_parity;
reg parity_flag;
reg start_flag;
reg stop_flag;

localparam ODD = 2'b01, 
		   EVEN = 2'b10;

always@(*)
begin
	case(parity_type)
			ODD:     error_parity = (^data_out)? 1'b0 : 1'b1;
    		EVEN:    error_parity = (^data_out)? 1'b1 : 1'b0;
    		default: error_parity = 1'b1;
    endcase 
 end 

always@(*)begin
	parity_flag = (error_parity ^ parity_bit);
	start_flag  = (start_bit == 0);  
    stop_flag   = (stop_bit == 1); 
end 

always @(*) begin
    if (rst_n && received_flag)
        error_flag = {stop_flag, start_flag, parity_flag};
    else
        error_flag = 3'b000;
end


endmodule
