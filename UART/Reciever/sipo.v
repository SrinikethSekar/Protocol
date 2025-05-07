module Sipo (
    input rst_n,
    input data_tx,
    input baud_clk, 

    output reg [10:0] data_parll,
    output reg receive_flag, 
    output reg active_flag 
);

localparam [1:0] IDLE = 2'b00,
                 START = 2'b01,
                 RECEIVE = 2'b10,
                 DONE = 2'b11;

reg [10:0] shift_reg;
reg [3:0] bit_count;
reg [3:0] stop_count;
reg [1:0] state;

always @(posedge baud_clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        stop_count <= 0;
    end
    else begin
        case (state)

            IDLE: begin
                if (data_tx == 1'b0) begin
                    state <= START;
                    stop_count <= 0;
                end else begin
                    state <= IDLE;
                end
            end

            START: begin
                if (stop_count == 4'd6) begin  // Wait for middle of start bit
                    state <= RECEIVE;
                    stop_count <= 0;
                end else begin
                    stop_count <= stop_count + 1;
                    state <= START;
                end
            end

            RECEIVE: begin
                if (bit_count == 4'd10) begin // Received all bits (1 start + 8 data + 1 stop)
                    state <= DONE;
                end else begin
                    state <= RECEIVE;
                end
            end

            DONE: begin
                state <= IDLE;  // Return to IDLE
            end

            default: state <= IDLE;

        endcase
    end  
end

always @(posedge baud_clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_reg <= 0;
        bit_count <= 0;
        data_parll <= 0;
        active_flag <= 0;
        receive_flag <= 0;
    end
    else begin
        case (state)

            IDLE: begin
                shift_reg <= 0;
                bit_count <= 0;
                stop_count <= 0;
                active_flag <= 0;
                receive_flag <= 0;
            end

            START: begin
                active_flag <= 1;
                receive_flag <= 0;
            end

            RECEIVE: begin
   				active_flag <= 1;
    				if (stop_count == 4'd1) begin
        				shift_reg <= {shift_reg[9:0], data_tx}; // LSB first
        				bit_count <= bit_count + 1;
        				stop_count <= 0;
    				end else begin
        				stop_count <= stop_count + 1;
    				end
				end

            DONE: begin
                data_parll <= shift_reg;
                receive_flag <= 1;
                active_flag <= 0;
                bit_count <= 0;  // <- Important fix
            end

            default: begin
                active_flag <= 0;
                receive_flag <= 0;
            end

        endcase
    end
end

endmodule
