module uart_top_rx(
    input clk,
    input rst_n,
    input data_tx,
    input [1:0] baud_rate,
    input [1:0] parity_type,

    output [7:0] data_out,
    output [2:0] error_flag,
    output done_flag,
    output active_flag
);

    wire baud_clk;
    wire [10:0] data_parll;
    wire receive_flag;
    wire start_bit, stop_bit, parity_bit;

   
    baud_generator u_baud_gen (
        .clk(clk),
        .rst_n(rst_n),
        .baud_rate(baud_rate),
        .baud_clk(baud_clk)
    );

    
    Sipo u_sipo (
        .rst_n(rst_n),
        .data_tx(data_tx),
        .baud_clk(baud_clk),
        .data_parll(data_parll),
        .receive_flag(receive_flag),
        .active_flag(active_flag)
    );

   
    Deframe u_deframe (
        .rst_n(rst_n),
        .receive_flag(receive_flag),
        .data_parll(data_parll),
        .parity_bit(parity_bit),
        .start_bit(start_bit),
        .stop_bit(stop_bit),
        .done_flag(done_flag),
        .data_out(data_out)
    );

   
    error_check u_error_check (
        .rst_n(rst_n),
        .received_flag(receive_flag),
        .parity_type(parity_type),
        .start_bit(start_bit),
        .stop_bit(stop_bit),
        .parity_bit(parity_bit),
        .data_out(data_out),
        .error_flag(error_flag)
    );


endmodule
