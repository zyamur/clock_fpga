module uart_tx(
    input wire clk,          // System clock
    input wire reset,        // Reset signal
    input wire [7:0] data,   // Data to transmit
    input wire send,         // Send data signal
    output wire tx,          // UART transmit pin
    output reg ready         // Ready to send next data
);

    // UART parameters
    parameter BAUD_RATE = 9600;
    parameter CLK_FREQ = 100000000;
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    // Internal signals
    reg [3:0] bit_index;
    reg [31:0] clk_counter;
    reg [9:0] tx_shift_reg;
    reg transmitting;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_shift_reg <= 10'b1111111111;
            transmitting <= 1'b0;
            ready <= 1'b1;
            bit_index <= 4'b0;
            clk_counter <= 32'b0;
        end else begin
            if (ready && send) begin
                tx_shift_reg <= {1'b1, data, 1'b0};
                transmitting <= 1'b1;
                ready <= 1'b0;
            end

            if (transmitting) begin
                if (clk_counter == BIT_PERIOD - 1) begin
                    clk_counter <= 32'b0;
                    tx_shift_reg <= {1'b1, tx_shift_reg[9:1]};
                    bit_index <= bit_index + 1;

                    if (bit_index == 9) begin
                        transmitting <= 1'b0;
                        ready <= 1'b1;
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end
        end
    end

    assign tx = tx_shift_reg[0];
endmodule
