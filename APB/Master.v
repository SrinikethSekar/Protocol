////////////////////////////////////////////////
//
// Name:   Sriniketh Sekar
// Design: APB Protocol Master
// Date:   26/05/2025
//
///////////////////////////////////////////////

module Master #(parameter DATA = 32,ADDR =32)(
	input  wire    		     pclk   , // Clock
	input  wire  		       presetn, // Active-low reset
	input  wire 		       pready , // indication of slave is ready
	input  wire [DATA-1:0] prdata , // read data

	output reg  [ADDR-1:0] paddr  , //address bus
	output reg  		       pwrite , //write-HIGH(1)read-LOW(0)
	output reg  [DATA-1:0] pwdata , //write data, valid when prwite is 1
	output reg             psel   , //selection of the slave
	output reg  		       penable  //indication of the enable phase in the 2nd cycle

	);
	
	parameter IDLE   = 2'b00,
		        SETUP  = 2'b01, 
		        ACCESS = 2'b10;

    reg [DATA-1:0] data;
    reg [ADDR-1:0] addr;
    reg [1:0] state,next_state;
    reg start_transaction;

    //fsm next state logic
	always@(*)begin
		case(state)

			IDLE    : begin
						   if(start_transaction == 1)
						   	  next_state = SETUP;
						   else
						   	  next_state = IDLE;
					  end 

			SETUP   : begin
								next_state = ACCESS;
					  end 

			ACCESS  : begin
					       
					       	 if(pready == 1)
					       		next_state = IDLE;
					      	else
					       		next_state = ACCESS;
					  end 

			default : next_state = IDLE;
				       
		endcase
	end  

	//state transition logic
	always @(posedge pclk or negedge presetn) 
	begin
		if(!presetn)
			state <= IDLE;
		else
			state <= next_state;
	end

	// Data processing and output logic
	always@(*)
	begin

		paddr  = 32'b0;
		pwdata = 32'b0;
		pwrite = 0;
		psel   = 0;
		penable= 0;

		case(state)

			IDLE  : begin 
					      
					      psel    = 0;
					      penable = 0;
					     
				    end 

			SETUP : begin
					
					      psel    = 1;
					      penable = 0;
					      pwdata  = data;
					      paddr   = addr;
					      pwrite  = 1;
				    end

			ACCESS : begin
						  
					      psel    = 1;
					      penable = 1;
					      pwdata  = data;
					      paddr   = addr;
					      pwrite  = 1;

				    end

		endcase
	end 


endmodule
