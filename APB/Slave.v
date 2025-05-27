////////////////////////////////////////////////
//
// Name:   Sriniketh Sekar
// Design: APB Protocol Slave
// Date:   26/05/2025
//
///////////////////////////////////////////////
module Slave #(parameter DATA = 32,ADDR =32)(
	input wire             pclk    ,//clock
	input wire             presetn ,//Active low reset
	input wire  [ADDR-1:0] paddr   ,//address
	input wire             pwrite  ,//write-HIGH(1)read-LOW(0)
	input wire  [DATA-1:0] pwdata  ,// write data, valid when prwite is 1
	input wire             psel    ,//selection of the slave
	input wire             penable ,//indication of the enable phase in the second cycle

	output reg  [DATA-1:0] prdata  ,//read data
	output reg   	       pready   //indication of slave is ready    

);

    parameter IDLE   = 2'b00,
	      SETUP  = 2'b01, 
	      ACCESS = 2'b10;

    reg [1:0] state,next_state;
    reg [DATA-1:0]mem[0:255];

    //fsm next state logic
	always@(*)begin
		case(state)

			IDLE   : begin
						if(psel == 1 && penable == 0)
							next_state = SETUP;
						else
							next_state = IDLE;
					 end 

			SETUP  : begin
						if(psel == 1 && penable == 1)
							next_state = ACCESS;
						else
							next_state = SETUP;
					 end 

			ACCESS : begin
							next_state = IDLE ;
					 end

			default: next_state = IDLE;
		
		endcase // state
	
	end  

	//state transition logic
	always @(posedge pclk or negedge presetn) begin  
		if(!presetn) begin
			 state <= IDLE;
		end else begin
			 state <= next_state;
		end
	end

	// Data processing and output logic
	always@(posedge pclk or negedge presetn)
	begin
		if(!presetn) begin

			prdata <= 0;
			pready <= 0;
		end 
		else
			begin
			case(state)

				IDLE  : begin 
						      
						      pready <= 0;
						      prdata <= 0;
						     
					    end 

				SETUP : begin
						
						      pready <= 0;
					    end

				ACCESS : begin
							  
						      pready <= 1;

						      if(pwrite)
						      	mem[paddr] <= pwdata ;    //write operation
						      else
						      	prdata     <= mem[paddr]; //read operation

					    end

				default: pready <= 0;

		    endcase
		    end 
	end 

	
endmodule
