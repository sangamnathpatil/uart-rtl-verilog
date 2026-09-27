`timescale 1ns/1ps

module uart_top_tb ;

    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 9600;

    reg clk;
    reg reset;
    
    reg [7:0] tx_data;
    reg tx_start;

    wire tx_busy;
    wire tx_done;

    wire [7:0] rx_data;
    wire rx_done;


    /////////////////////////////////////////////////////  UUT  ///////////////////////////////////////////////////////

    uart_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .clk      (clk),
        .reset    (reset),

        .tx_data  (tx_data),
        .tx_start (tx_start),

        .tx_busy  (tx_busy),
        .tx_done  (tx_done),

        .rx_data  (rx_data),
        .rx_done  (rx_done)
    );

    //////////////////////////////////////////////////// CLOCK /////////////////////////////////////////////////////////

    always #10 clk = ~clk;

    //////////////////////////////////////////////////// WAVEFORM /////////////////////////////////////////////////////////

    initial begin
        $dumpfile ("uart_top.vcd");
        $dumpvars (0, uart_top_tb);
    end

    //////////////////////////////////////////////////// MONITOR /////////////////////////////////////////////////////////

    initial begin
        $monitor(
            "Time=%0t | TX_DATA=%h | START=%b | TX=%b | BUSY=%b | TX_DONE=%b | RX_DATA=%h | RX_DONE=%b",
            $time, tx_data, tx_start, uut.uart_line, tx_busy, tx_done, rx_data, rx_done );
    end

    //////////////////////////////////////////////////// TEST /////////////////////////////////////////////////////////

    initial begin

        clk = 0;
        reset = 1;
        tx_data = 8'h00;
        tx_start = 0;

        //RESET 
        #100;
        reset = 0;

        //////////////////////////////////////////////////// FIRST BYTE /////////////////////////////////////////////////////

        #100;

        tx_data = 8'hA5;
        tx_start = 1;

        #20;
        tx_start = 0;

        wait(tx_done);               // WAIT FOR TRANSMISSION


        //////////////////////////////////////////////////// SECOND BYTE /////////////////////////////////////////////////////
        
        #100;

        tx_data = 8'h3C;
        tx_start = 1;

        #20;
        tx_start = 0;

        wait(tx_done);               // WAIT FOR TRANSMISSION


        //////////////////////////////////////////////////// THIRD BYTE /////////////////////////////////////////////////////

        #100;

        tx_data = 8'hF0;
        tx_start = 1;

        #20;
        tx_start = 0;

        wait(tx_done);               // WAIT FOR TRANSMISSION

        #1000;

        $finish;

    end

endmodule