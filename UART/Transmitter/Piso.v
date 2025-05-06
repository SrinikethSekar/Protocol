module Piso (
	input rst_n,    
	input send,
	input [7:0]data_in , 
	input parity_bit,
	input baud_clk,

	output reg data_tx,
	output active_flag,
	output reg done_flag
);


localparam [1:0] IDLE  = 2'b00,
				 LOAD  = 2'b01, 
				 SHIFT = 2'b10,
				 DONE  = 2'b11;

reg [10:0] shift_reg;
reg [3:0] stop_count;
reg [1:0] state;

	//State Transition Logic

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

						DONE : if(send==0)
									state <= IDLE;
								else
								 	state <= DONE;


						default : state <= IDLE;
					endcase

				end

			    
		end


	//Frame Generation and Shifting Logic
	always@(posedge baud_clk or negedge rst_n)begin
		if(!rst_n)begin
			data_tx <= 1'b1; //Idle should be high in the UART TX
			shift_reg <= 11'b0;
			stop_count <= 4'b0;
			done_flag <= 1'b0;

		end
		else begin
			case (state)

				IDLE:begin
					data_tx <= 1'b1;
					done_flag <= 1'b0;
				end 

				LOAD: begin

					shift_reg <= {1'b1,parity_bit,data_in,1'b0};
					stop_count<= 4'b0; //reset the counter
					done_flag <= 1'b0;
				end

				SHIFT: begin

					data_tx <= shift_reg[0]; //LSB
					shift_reg <= {1'b0,shift_reg[10:1]}; //like after the above lsb send we are sending the remaining data one by one is [10:1] and the lsb 1'b0 is now inserted in the msb
					stop_count <= stop_count + 1;

				end 

				DONE: begin

					data_tx <= 1'b1;
					done_flag <= 1'b1;

				end

				default : begin
					data_tx <= 1'b1;
					done_flag <= 1'b0;
					end  
			
			endcase
		end 
	end 

	//Active flag logic

	assign active_flag = (state == SHIFT); //it is high during transmission


endmodule
