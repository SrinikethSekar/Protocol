module Parity(
	input rst_n,    
	input [7:0] data_in, 
	input [1:0]parity_type,

	output reg parity_bit
	
);


localparam  ODD = 2'b00,
		  EVEN = 2'b01;

always@(*)begin
	
		if(!rst_n)begin 
			parity_bit = 1'b1;
			end

		else begin
			case(parity_type)
				
				

				ODD: parity_bit = (^data_in)?1'b0:1'b1;
	
				EVEN: parity_bit = (^data_in)?1'b1:1'b0;

				default: parity_bit = 1'b1;
				
			
			
			endcase 

			end
end
endmodule
