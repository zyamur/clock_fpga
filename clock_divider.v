module clock_divider(
    input wire clk,
    input wire speed_up,
    input wire enable,  // Controlled externally using debouncer logic
    output reg one_second_pulse
);
    reg [26:0] counter = 0;
    reg [26:0] count_limit;
    reg prev_speed_up = 0;

    always @(posedge clk) begin
        // Update count_limit based on speed_up signal
        if (speed_up)
            count_limit <= 1666666;  // 50MHz / 60Hz = 833,333 cycles
        else
            count_limit <= 100000000; // 50MHz / 1Hz = 50,000,000 cycles

        // Detect falling edge of speed_up signal
        if (prev_speed_up && !speed_up) begin
            if (counter >= count_limit) begin
                counter <= count_limit - 2; // Adjust counter to just below limit
            end
        end

        // Main counter logic, only increment if enabled
        if (enable) begin
            if (counter == count_limit - 1) begin
                counter <= 0;
                one_second_pulse <= 1;
            end else begin
                counter <= counter + 1;
                one_second_pulse <= 0;
            end
        end else begin
            one_second_pulse <= 0; // No pulse when paused
        end

        // Store the current state of speed_up for the next cycle
        prev_speed_up <= speed_up;
    end
endmodule
