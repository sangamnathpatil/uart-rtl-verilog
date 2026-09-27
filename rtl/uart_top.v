module uart_top#(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire reset,

    //TX INTERFACE
    input wire [7:0] tx_data,
    input wire       tx_start,
    output wire      tx_busy,
    output wire      tx_done,

    //RX INTERFACE
    output wire [7:0] rx_data,
    output wire       rx_done       
);

    //INTERNAL UART CONNECTION --------   TX --> RX
    wire uart_line;


    ///////////////////////////////////////////////////////////////   UART TRANSMITTER   /////////////////////////////////////////////////////////////////////////


    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx_inst (
        .start(tx_start),
        .reset(reset),
        .data(tx_data),
        .clk(clk),

        .tx(uart_line),
        .busy(tx_busy),
        .done(tx_done)
    );


    //////////////////////////////////////////////////////////////   UART RECEIVER  //////////////////////////////////////////////////////////////////////////////


    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) rx_inst (
        .reset(reset),
        .clk(clk),
        .rx(uart_line),

        .data_out(rx_data),
        .busy(rx_busy),
        .done(rx_done)
    );

endmodule