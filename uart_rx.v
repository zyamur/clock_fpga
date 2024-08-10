module uart_rx(
    input wire clk,          // System clock
    input wire reset,        // Reset signal
    input wire rx,           // UART receive pin
    output reg [7:0] data,   // Received data
    output reg ready         // Data ready flag
);

    // UART parameters
    parameter BAUD_RATE = 9600;
    parameter CLK_FREQ = 100000000;
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;
    localparam BIT_PERIOD_1_5 = (BIT_PERIOD * 3) / 2;

    // Internal signals
    reg [3:0] bit_index;
    reg [31:0] clk_counter;
    reg [9:0] rx_shift_reg;
    reg receiving;
    integer i = 1;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all signals
            data <= 8'b0;
            ready <= 1'b0;
            bit_index <= 4'b0;
            clk_counter <= 32'b0;
            rx_shift_reg <= 10'b0;
            receiving <= 1'b0;
        end else begin
            ready <= 1'b0;  // Clear ready flag
            
            if (!receiving) begin
                if (!rx) begin
                    receiving <= 1'b1;  // Start receiving when a start bit is detected
                end
            end else begin
                if (clk_counter < (BIT_PERIOD_1_5 - 1) && i) begin
                   clk_counter <= clk_counter + 1;
                   
                end else if(clk_counter < BIT_PERIOD - 1)begin
                    clk_counter <= clk_counter + 1;
                    
                end else begin
                
                    clk_counter <= 32'b0;
                    bit_index <= bit_index + 1;
                    rx_shift_reg <= {rx, rx_shift_reg[9:1]};
                    i = 0;

                    if (bit_index == 9) begin
                        data <= rx_shift_reg[8:1];
                        ready <= 1'b1;
                        receiving <= 1'b0;
                        bit_index <= 1'b0;
                        i =1;
                    end
                end
            end
        end
    end
endmodule
