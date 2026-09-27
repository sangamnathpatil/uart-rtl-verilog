module uart_tx #(

    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)
(
    input wire start,
    input wire reset,
    input wire [7:0] data,
    input wire clk,

    output reg tx,
    output reg busy,
    output reg done
);

    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE ;  // 50000000 / 9600 = 5208 

    // COUNTER STATE/////////////////////////////////////////////////////////////////////////////////////////OUR UART TX IS COUNTER BASED

    reg [31:0] baud_counter;                      // 32 BITS FOR 5208 CYCLES (CLOCK CYCLES)

    reg [3:0] bit_counter;                        // FOR 10 BITS(START , DATA(8) , STOP) , COUNTS UART BITS

    reg [9:0] shift_reg;                          // TO SHIFT 10 BITS (START , DATA(8) , STOP)

    // SEQUENTIAL LOGIC
    always @(posedge clk ) begin

        //RESET

        if (reset) begin

            tx    <= 1'b1;
            busy  <= 1'b0;
            done  <= 1'b0;

            baud_counter  <= 32'd0;
            bit_counter   <= 4'd0;
            shift_reg     <= 10'd0;
        end

        else begin

            done <= 1'b0;                       // DONE IS NORMALLY LOW

        // STARTING A NEW TRANSITION 
            if (start && !busy) begin

                // LOAD DATA
                shift_reg <= {1'b1, data, 1'b0};       // {STOP, DATA, START}

                busy         <= 1'b1;
                baud_counter <= 1'b0;
                bit_counter  <= 1'b0;

                //START BIT 
                tx   <=   1'b0;

            end
        //ONGOING TRANSMISSION
            else if (busy) begin

                //BAUD COUNTER

                if (baud_counter == BAUD_DIV - 1)begin                       //baud_counter == 5207

                    baud_counter <= 32'd0;                                   // baud counter == 0

                    shift_reg <= shift_reg >> 1;                             // RIGHT SHIFT

                    bit_counter <= bit_counter + 1'b1;                       // INCREMENT BY 1

                    tx <= shift_reg[1];                                      // OP NEXT BIT

                    //LAST BIT COMPLETED

                    if (bit_counter == 4'd9) begin

                        busy <= 1'b0;
                        done <= 1'b1;

                        tx <= 1'b1;                                          // UART IDLE STATE

                    end

                end

                else begin

                    baud_counter <= baud_counter +1'b1;

                end

            end

        end

    end

endmodule