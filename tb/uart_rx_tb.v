`timescale 1ns/1ps

module uart_rx_tb ;


    //////////////  CLOCK PARAMETERS  ////////////////////
    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 9600;


    ///////////////  TESTBENCH SIGNALS  /////////////////
    reg clk;
    reg reset;
    reg rx;

    wire [7:0] data_out;
    wire busy;
    wire done;


    /////////////  UUT  ////////////////////
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_out),
        .busy(busy),
        .done(done)
    );


    // CLOCK GENERATION
    always #10 clk = ~clk;


    //UART BIT TIME
    localparam BIT_TIME = 1000000000 / BAUD_RATE ;


    //TASK TO TRANSMIT ONE UART BYTE (8 BITS)
    task send_byte;
        input [7:0] tx_data;
        integer i;

        begin

            ////////////////////////  START BIT  //////////////////////////////// 
            rx = 1'b0;
            #(BIT_TIME);

            ///////////////////////  8 DATA BITS ---- LSB FIRST  ///////////////
            for ( i = 0 ; i < 8 ; i = i + 1 ) begin
                rx = tx_data [i] ;
                #(BIT_TIME);
            end
            
            ////////////////////// STOP BIT  ///////////////////////////////////
            rx = 1'b1 ;
            #(BIT_TIME);

        end

    endtask
    

    //TEST SEQUENCE 
    initial begin 

        //CREATE WAVEFORM
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, uart_rx_tb);

        $monitor("Time=%0t | RX=%b | DATA=%h | DONE=%b", $time, rx, data_out, done);


        //INITIALIZE
        clk = 1'b0;
        reset = 1'b1;
        rx = 1'b1;                                    /////////UART IDLE STATE

        //RESET
        #100
        reset = 1'b0;

        //WAIT BEFORE TRANSMISSION
        #(BIT_TIME);

        //SEND FIRST BYTE
        send_byte(8'h55);
        #(BIT_TIME * 2);

        //SEND SECOND BYTE
        send_byte(8'hA5);
        #(BIT_TIME * 2);

        //SEND THIRD BYTE
        send_byte(8'h3C);
        #(BIT_TIME * 2);

        $finish;

    end

endmodule
