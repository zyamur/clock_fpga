module display(
    input wire clk,
    input wire speed_up,
    input wire enable,
    input wire hour_inc,
    input wire hour_dec,
    input wire min_inc,
    input wire min_dec,
    input wire reset_switch,	
    input wire [5:0] second_switches,
    output reg [6:0] segments,
    output reg [3:0] anodes,
    output reg [5:0] leds
);
    reg [7:0] hours = 0;
    reg [7:0] minutes = 0;
    reg [7:0] seconds = 0;

    reg [1:0] digit_select = 0;
    reg [17:0] refresh_counter = 0; // Adjusted for 4ms refresh rate
    reg [3:0] current_digit;

    wire one_second_pulse;
    
    reg prev_hour_inc = 0;
    reg prev_hour_dec = 0;
    reg prev_min_inc = 0;
    reg prev_min_dec = 0;
    reg prev_reset_switch = 0;

    // Instantiate the clock divider to generate a 1 Hz pulse
    clock_divider clk_div(
        .clk(clk),
        .speed_up(speed_up),
        .enable(enable),
        .one_second_pulse(one_second_pulse)
    );

    // Instantiate the segment decoder
    wire [6:0] seg;
    seven_segment_decoder decoder (
        .binary_input(current_digit),
        .segments(seg)
    );

    // Update minutes, hours, and seconds every second
    always @(posedge clk) begin
	if(prev_reset_switch && reset_switch) begin
	    hours <= 0;
	    minutes <= 0;
	    seconds <= 0;
	end

        if (enable) begin
            if (one_second_pulse) begin
                if (seconds == 59) begin
                    seconds <= 0;
                    if (minutes == 59) begin
                        minutes <= 0;
                        if (hours == 23) begin
                            hours <= 0;
                        end else begin
                            hours <= hours + 1;
                        end
                    end else begin
                        minutes <= minutes + 1;
                    end
                end else begin
                    seconds <= seconds + 1;
                end
            end
        end else begin
            // Manual hour and minute adjustment when paused
            if (prev_hour_inc && !hour_inc) begin
                if (hours == 23)
                    hours <= 0;
                else
                    hours <= hours + 1;
            end else if (prev_hour_dec && !hour_dec) begin
                if (hours == 0)
                    hours <= 23;
                else
                    hours <= hours - 1;
            end

            if (prev_min_inc && !min_inc) begin
                if (minutes == 59)
                    minutes <= 0;
                else
                    minutes <= minutes + 1;
            end else if (prev_min_dec && !min_dec) begin
                if (minutes == 0)
                    minutes <= 59;
                else
                    minutes <= minutes - 1;
            end
            
            seconds <= second_switches;
        end
        
        prev_hour_inc <= hour_inc;
        prev_hour_dec <= hour_dec;
        prev_min_inc <= min_inc;
        prev_min_dec <= min_dec;
	prev_reset_switch <= reset_switch;
    end

    // Refresh rate control (4 ms per digit)
    always @(posedge clk) begin
        if (refresh_counter == 199999) begin // 50MHz / 4ms = 200,000 cycles
            refresh_counter <= 0;
            digit_select <= digit_select + 1;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end

    // Multiplexing logic for displaying hours and minutes
    // Multiplexing logic for displaying hours and minutes
always @(*) begin
    case (digit_select)
        2'b00: begin
            anodes = 4'b0111; // Enable the fourth digit (rightmost)
            current_digit = hours / 10; // Tens digit of hours
        end
        2'b01: begin
            anodes = 4'b1011; // Enable the third digit
            current_digit = hours % 10; // Units digit of hours
        end
        2'b10: begin
            anodes = 4'b1101; // Enable the second digit
            current_digit = minutes / 10; // Tens digit of minutes
        end
        2'b11: begin
            anodes = 4'b1110; // Enable the first digit (leftmost)
            current_digit = minutes % 10; // Units digit of minutes
        end
    endcase
    segments = seg;
    leds = seconds[5:0]; // Display seconds in binary on the LEDs
end

endmodule



/*module display(
    input wire clk,
    input wire enable,
    input wire inc_hour_up,  // PB_up signal from debouncer for incrementing hours
    input wire dec_hour_up,  // PB_up signal from debouncer for decrementing hours
    input wire inc_minute_up,  // PB_up signal from debouncer for incrementing minutes
    input wire dec_minute_up,  // PB_up signal from debouncer for decrementing minutes
    output reg [6:0] segments,
    output reg [3:0] anodes,
    output reg [5:0] leds
);
    reg [7:0] hours = 0;
    reg [7:0] minutes = 0;
    reg [7:0] seconds = 0;

    reg [1:0] digit_select = 0;
    reg [17:0] refresh_counter = 0; // Adjusted for 4ms refresh rate
    reg [3:0] current_digit;

    wire one_second_pulse;

    // Instantiate the clock divider to generate a 1 Hz pulse
    clock_divider clk_div(
        .clk(clk),
        .enable(enable),
        .one_second_pulse(one_second_pulse)
    );

    // Instantiate the segment decoder
    wire [6:0] seg;
    seven_segment_decoder decoder (
        .binary_input(current_digit),
        .segments(seg)
    );

    // Registers to hold previous states of PB_up signals
    reg prev_inc_hour_up, prev_dec_hour_up;
    reg prev_inc_minute_up, prev_dec_minute_up;

    // Update minutes, hours, and seconds every second
    always @(posedge clk) begin
        if (one_second_pulse && enable) begin
            if (seconds == 59) begin
                seconds <= 0;
                if (minutes == 59) begin
                    minutes <= 0;
                    if (hours == 23) begin
                        hours <= 0;
                    end else begin
                        hours <= hours + 1;
                    end
                end else begin
                    minutes <= minutes + 1;
                end
            end else begin
                seconds <= seconds + 1;
            end
        end
    end

    // Logic to adjust hours and minutes when the clock is paused
    always @(posedge clk) begin
        if (!enable) begin  // Only allow adjustment when paused
            // Hour adjustment on negative edge of PB_up signals
            if (prev_inc_hour_up && !inc_hour_up) begin
                if (hours == 23)
                    hours <= 0;
                else
                    hours <= hours + 1;
            end
            if (prev_dec_hour_up && !dec_hour_up) begin
                if (hours == 0)
                    hours <= 23;
                else
                    hours <= hours - 1;
            end

            // Minute adjustment on negative edge of PB_up signals
            if (prev_inc_minute_up && !inc_minute_up) begin
                if (minutes == 59)
                    minutes <= 0;
                else
                    minutes <= minutes + 1;
            end
            if (prev_dec_minute_up && !dec_minute_up) begin
                if (minutes == 0)
                    minutes <= 59;
                else
                    minutes <= minutes - 1;
            end
        end

        // Update previous states
        prev_inc_hour_up <= inc_hour_up;
        prev_dec_hour_up <= dec_hour_up;
        prev_inc_minute_up <= inc_minute_up;
        prev_dec_minute_up <= dec_minute_up;
    end

    // Refresh rate control (4 ms per digit)
    always @(posedge clk) begin
        if (refresh_counter == 199999) begin // 50MHz / 4ms = 200,000 cycles
            refresh_counter <= 0;
            digit_select <= digit_select + 1;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end

    // Multiplexing logic for displaying hours and minutes
    always @(*) begin
        case (digit_select)
            2'b00: begin
                anodes = 4'b1110; // Enable the first digit
                current_digit = hours / 10; // Tens digit of hours
            end
            2'b01: begin
                anodes = 4'b1101; // Enable the second digit
                current_digit = hours % 10; // Units digit of hours
            end
            2'b10: begin
                anodes = 4'b1011; // Enable the third digit
                current_digit = minutes / 10; // Tens digit of minutes
            end
            2'b11: begin
                anodes = 4'b0111; // Enable the fourth digit
                current_digit = minutes % 10; // Units digit of minutes
            end
        endcase
        segments = seg;
        leds = seconds[5:0]; // Display seconds in binary on the LEDs
    end
endmodule
*/