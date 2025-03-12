module Piso; (
	input rst_n,    
	input send,
	input [7:0]data_in , 
	input parity_bit,
	input baud_clk,

	output data_tx,
	output active_flag,
	output done_flag
);


localparam [1:0] IDLE  = 2'b00,
				 LOAD  = 2'b01, 
				 SHIFT = 2'b10,
				 DONE  = 2'b11;


reg [10:0] stop_count;
reg [1:0] state, next_state;

	always@(posedge baud_clk or negedge rst_n)
		
		begin
			
			if(!rst_n)
				state <= IDLE;
			
			else
				begin
					case(state)

						IDLE :  if(send)
									state <= LOAD;
								else
									state <= IDLE;


						LOAD : state <= SHIFT;


						SHIFT : if(stop_count==4'd11)
									state <= DONE;
								else
									state<=SHIFT;

						DONE : if(!send)
									state <= IDLE;
								else
								 	state <= DONE;


						default : state <= IDLE;

				end

			    
		end 

endmodule
