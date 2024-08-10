module uart_date_time_display(
    input wire clk,          // System clock
    input wire reset,        // Reset signal
    input wire rx,           // UART receive pin
    output wire tx           // UART transmit pin
);

    wire [7:0] received_data;
    reg send_flag;
    wire data_ready;
    wire uart_ready;
    reg [4:0] char_index;    // Index to track which character to send
    reg [7:0] date_time_data [0:19];  // "30.07.2024 21:47:54" + '\n'
    reg [7:0] tx_data;        // Data to send via UART

    // Instantiate UART receiver and transmitter
    uart_rx uart_rx_inst (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data(received_data),
        .ready(data_ready)
    );

    uart_tx uart_tx_inst (
        .clk(clk),
        .reset(reset),
        .data(tx_data),
        .send(send_flag),
        .tx(tx),
        .ready(uart_ready)
    );

    // Initialize date and time data
    initial begin
        date_time_data[0]  <= "3";
        date_time_data[1]  <= "0";
        date_time_data[2]  <= ".";
        date_time_data[3]  <= "0";
        date_time_data[4]  <= "7";
        date_time_data[5]  <= ".";
        date_time_data[6]  <= "2";
        date_time_data[7]  <= "0";
        date_time_data[8]  <= "2";
        date_time_data[9]  <= "4";
        date_time_data[10] <= " ";
        date_time_data[11] <= "2";
        date_time_data[12] <= "1";
        date_time_data[13] <= ":";
        date_time_data[14] <= "4";
        date_time_data[15] <= "7";
        date_time_data[16] <= ":";
        date_time_data[17] <= "5";
        date_time_data[18] <= "4";
        date_time_data[19] <= "\n";
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            send_flag <= 1'b0;
            char_index <= 5'b0;
            tx_data <= 8'b0;
        end else begin
            if (data_ready && !send_flag) begin
                if (received_data == "t") begin  
                    send_flag <= 1'b1;
                    char_index <= 0;
                end
            end

            if (send_flag && uart_ready) begin
                if (char_index < 20) begin
                    tx_data <= date_time_data[char_index];  // Load character to send
                    char_index <= char_index + 1;
                end else begin
                    send_flag <= 1'b0;  // Stop sending after all characters are sent
                end
            end
        end
    end
endmodule
