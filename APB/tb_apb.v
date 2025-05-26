////////////////////////////////////////////////
//
// Name:   Sriniketh Sekar
// Design: APB Protocol Test_bench
// Date:   26/05/2025
//
///////////////////////////////////////////////
module tb_apb;

	parameter DATA = 32;
	parameter ADDR = 32;

	reg  			      pclk    ;//clock
	reg  			      presetn ;//Active low reset
	reg  [ADDR-1:0]	paddr   ;//address
	reg  			      pwrite  ;//write-HIGH(1)read-LOW(0)
	reg  [DATA-1:0]	pwdata  ;// write data, valid when prwite is 1
	reg  			      psel    ;//selection of the slave
	reg  			      penable ;//indication of the enable phase in the second cycle

	wire [DATA-1:0] prdata  ;//read data
	wire 			      pready  ;//indication of slave is ready    

	Slave #(.DATA(DATA), .ADDR(ADDR)) slave_dut(

		.pclk(pclk          ),
		.presetn(presetn    ),
		.paddr(paddr        ),
		.pwrite(pwrite      ),
		.pwdata(pwdata      ),
		.psel(psel          ),
		.penable(penable    ),
		.prdata(prdata      ),
		.pready(pready      )

);

	initial pclk = 0;
	always #5 pclk = ~pclk;

	initial begin

		$dumpfile("Waves.vcd");
		$dumpvars;

		//initial reset
		paddr = 0;
		pwrite = 0;
		pwdata = 0;
		psel =0;
		penable =0;
		presetn =0;

		#10 presetn =1; //deassert reset

		// Write transactions
		apb_write(32'h0A, 32'hFACE);
		apb_write(32'h0B, 32'hBEEF);
		apb_write(32'h0C, 32'hCAFE);
		apb_write(32'h0D, 32'hF00D);
		apb_write(32'h0E, 32'h1234);

	
		#10;

		// Read transactions
		apb_read(32'h0D);
		apb_read(32'h0E);
		apb_read(32'h0A);
		apb_read(32'h0B);
		apb_read(32'h0C);
		

		#50;
		$finish;
	end 

	//write task
	task apb_write(input [31:0] addr, input [31:0] data);
	begin
		@(posedge pclk);
		paddr   <= addr;
		pwdata  <= data;
		pwrite  <= 1;
		psel    <= 1;
		penable <= 0;

		@(posedge pclk); 
		penable <= 1;

		@(posedge pclk);
		while (!pready) @(posedge pclk);

		
		psel    <= 0;
		penable <= 0;
		pwrite  <= 0;

		$display("[WRITE] Addr = 0x%0h, Data = 0x%0h", addr, data);
	end
	endtask

	// APB Read Task
	task apb_read(input [31:0] addr);
	begin
		@(posedge pclk);
		paddr   <= addr;
		pwrite  <= 0;
		psel    <= 1;
		penable <= 0;

		@(posedge pclk);
		penable <= 1;

		@(posedge pclk);
		while (!pready) @(posedge pclk);

		$display("[READ] Addr = 0x%0h, Data = 0x%0h", addr, prdata);

		
		psel    <= 0;
		penable <= 0;
	end
	endtask


endmodule
