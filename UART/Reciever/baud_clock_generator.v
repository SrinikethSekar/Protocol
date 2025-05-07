module baud_generator(
    input clk,  // clock
    input rst_n, // reset
    input [1:0] baud_rate,
    output reg baud_clk // selecting the baud rate
);
    
    reg [13:0] baud_div;
    reg [13:0] ticks;
    


    always @(*) begin
        case (baud_rate)
            2'b00: baud_div = 14'd1302 ;  //19200
            2'b01: baud_div = 14'd653  ;  //2400
            2'b10: baud_div = 14'd326  ;  //4800
            2'b11: baud_div = 14'd163  ;  //9600
            default: baud_div = 14'd163;  //9600
        endcase 
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_clk <= 0;
             ticks<= 14'd0;
        end else begin
            if (ticks >= baud_div) begin
                ticks <= 14'd0;
                baud_clk <= ~baud_clk;  
            end else begin
                ticks <= ticks + 1'd1;
                baud_clk <= ~baud_clk;
            end
        end
    end
endmodule
