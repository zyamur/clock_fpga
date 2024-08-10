module test_debouncer(
    input wire clk,
    input wire switch,
    output reg speed_up
);

    reg prev_switch_state = 0;

    always @(posedge clk) begin
        // Capture the previous state of the switch
        prev_switch_state <= switch;

        // Rising edge detection: switch changes from 0 to 1
        if (!prev_switch_state && switch) begin
            speed_up <= 1;  // Set speed_up to 1 on rising edge
        end
        // Falling edge detection: switch changes from 1 to 0
        else if (prev_switch_state && !switch) begin
            speed_up <= 0;  // Set speed_up to 0 on falling edge
        end
    end
endmodule
