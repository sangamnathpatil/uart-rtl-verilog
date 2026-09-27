`timescale 1ns/1ps

module uart_tx_tb;

    //SIMULATION PARAMETRS
    parameter CLK_FREQ = 10_000_000;
    parameter BAUD_RATE = 1_000_000;
    parameter CLK_PERIOD = 100;
    parameter BIT_PERIOD = 1000;

    //INPUTS AND OUTPUTS

    reg start;
    reg clk;
    reg [7:0] data;
    reg reset;

    wire tx;
    wire busy;
    wire done;

    integer errors;
    integer i;


    //UUT 

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .start(start),
        .clk(clk),
        .data(data),
        .reset(reset),
        .tx(tx),
        .busy(busy),
        .done(done)
    );


    // CLOCK GENERATION 10MHz
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    //VCD WAVEFORMN 
    initial begin
    $dumpfile("uart_tx.vcd");
    $dumpvars(0, uart_tx_tb);
    end


    //TASK TO CHECK ONE UART BIT

    task check_bit;
        input expected;
        input integer bit_number;

            begin
                        //FOR FAILING
                if(tx !== expected) begin
                    $display ("FAIL : BIT %0d | EXPECTED = %b , GOT = %b | TIME : %0t" , bit_number, expected, tx, $time);
                    errors = errors + 1;
                end
                        //FOR PASSING
                else begin
                    $display ("PASS : BIT %0d | TX = %b | TIME %0t" , bit_number, tx, $time);
                end

            end
    endtask


    task send_byte;
        input [7:0]task_data;
            begin

                wait(busy == 1'b0);                                  //WAIT UNTIL TX IS IDLE(FREE)

                @(negedge clk);                                      //TO START FROM NEGATIVE EDGE
                data = task_data;
                start = 1'b1;

                @(negedge clk);
                start = 1'b0;

                $display("\n------------------------------");
                $display("TRANSMITTING DATA :%b", data);
                $display("--------------------------------");

                //CHECK BUSY SIGNAL
                if(busy !== 1'b1) begin
                    $display("FAIL : BUSY SHOULD BE HIGH");
                    errors = errors +1;
                end

                //CHECK START BIT 
                #(BIT_PERIOD/2);
                check_bit(1'b0,0);

                //CHECK 8 BITS
                for(i=0; i<8; i= i+1) begin
                    #BIT_PERIOD;
                    check_bit(data[i], i+1);
                end

                //CHECK STOP BIT
                #BIT_PERIOD;
                check_bit(1'b1,9);

                //CHECK BUSY DURING STOP BIT
                if(busy !== 1'b1) begin
                    $display("FAIL : BUSY LOW DURING STOP BIT");
                    errors = errors + 1;
                end

                //WAIT FOR COMPLETION
                @(posedge done);
                #1;

                if(busy !== 1'b0) begin
                    $display("FAIL : BUSY DID NOT CLEAR");
                    errors = errors + 1;
                end

                else begin
                    $display("PASS : BUSY CLEARED");
                end

                if (tx !== 1'b1) begin
                    $display("FAIL : TX DID NOT RETURN TO IDLE");
                    errors = errors + 1;
                end

                else begin
                    $display("TRANSMISSION COMPLETED : %h", data);
                end
            end
    endtask

    //MAIN TEST SEQUENCE

    initial begin
        reset = 1'b1;
        start = 1'b0;
        data = 8'h00;
        errors = 0;

        //APPLY RESET
        repeat(3) @(negedge clk);
        reset = 1'b0;

        //CHECK IDLE CONDITION

        #1;

        if (tx !== 1'b1 || busy !== 1'b0 || done !== 1'b0) begin
            $display ("FAIL : INCORRECT IDLE STATE");
            errors = errors + 1;
        end

        else begin 
            $display ("PASS : RESET AND IDLE STATE");
        end

        //TEST CASE 1 === ALTERNATE NUMBERS
        send_byte(8'hA5);

        //TEST CASE 2 === ALL ZEROS
        send_byte(8'h00);

        //TEST CASE 3 === ALL ONES
        send_byte(8'hFF);

        //TEST CASE 4 
        send_byte(8'h55);

        //TEST CASE 5
        send_byte(8'h3C);

        //FINAL RESULT
        #1000;

        $display ("\n-----------------------------");
        $display ("UART TX TEXT SUMMARY");
        $display ("-------------------------------");

        if (errors == 0)
            $display ("ALL TESTS PASSED");
        else
            $display("TEST FAILED : %0d errors", errors);

        $finish;
    end

    //SIMULATION TIMEOUT
    initial begin
        #100000;
        $display("ERROR: SIMULATION TIMEOUT");
        $finish;
    end

endmodule