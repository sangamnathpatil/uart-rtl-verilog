module uart_rx #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input wire reset,
    input wire clk,
    input wire rx,

    output reg [7:0]data_out,
    output reg busy,
    output reg done
);

    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;
    localparam HALF_BAUD = BAUD_DIV / 2;

    //FSM STATE //////////////////////////////////////////////OUR UART RX IS FSM BASED

    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;

    reg [1:0] state;
    reg [31:0] baud_counter;
    reg [2:0] bit_counter;
    reg [7:0] data_reg;

    //SYNCHRONIZE ASYNCHRONOUS RX INPUT, USING TWO FLIP-FLOPS

    reg rx_meta;
    reg rx_sync;

    always @(posedge clk) begin
        if (reset) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end
        else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end
    end

    //SEQUENTIAL LOGICS

    always@(posedge clk) begin

        if(reset) begin
            state          <= IDLE;
            data_out       <= 8'd0;
            data_reg       <= 8'd0;
            busy           <= 1'b0;
            done           <= 1'b0;
            baud_counter   <= 32'd0;
            bit_counter    <= 3'd0;
        end

        else begin

            done <= 1'b0;                // DONE IS NORMALLY LOW

            case (state)

            ///////////////////////////  WAIT FOR START BIT (IDLE BIT)  ///////////////////////////////

            IDLE : begin
                
                busy          <= 1'b0;
                baud_counter  <= 32'd0;
                bit_counter   <= 3'd0;

                if (rx_sync == 1'b0) begin
                    busy <= 1'b1;
                    state <= START;
                end

            end

            ///////////////////////////  VERIFY START BIT ///////////////////////////////////////

            START : begin

                if (baud_counter == HALF_BAUD -1 ) begin
                    baud_counter <= 32'd0;

                    if (rx_sync == 1'b0) begin
                        state <= DATA;
                    end

                    else begin 
                        state <= IDLE ;
                        busy <= 1'b0;
                    end
                end

                else begin 
                    baud_counter <= baud_counter + 1;
                end
            end

            ///////////////////////////// RECEIVE 8 BIT DATA  ////////////////////////////////////////

            DATA : begin

                if (baud_counter == BAUD_DIV - 1) begin

                    baud_counter <= 32'd0;

                    //////////////////////////////////  RECEIVE LSB BIT FIRST  //////////////////////

                    data_reg [bit_counter] <= rx_sync;

                    if (bit_counter == 3'd7) begin
                        bit_counter <= 3'd0;
                        state <= STOP;
                    end

                    else begin
                        bit_counter <= bit_counter + 1;
                    end

                end

                else begin
                    baud_counter <= baud_counter + 1;
                end

            end

            //////////////////////////////////  STOP BIT  /////////////////////////////////////////////

            STOP : begin

                if(baud_counter == BAUD_DIV - 1) begin
                    baud_counter  <= 32'd0;
                    busy          <= 1'b0;
                    state         <= IDLE;

                    if (rx_sync == 1'b1) begin
                        data_out <= data_reg;
                        done <= 1'b1;
                    end

                end

                else begin
                    baud_counter <= baud_counter + 1;
                end
        
            end

            default : begin

                state          <= IDLE;
                busy           <= 1'b0;
                baud_counter   <= 32'd0;
                bit_counter    <= 3'd0;
            end

            endcase
        end
    end
endmodule