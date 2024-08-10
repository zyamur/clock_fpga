module top_module(
    input wire clk,
    input wire speed_up_switch,
    input wire pause_button,
    input wire hour_inc_button,   // Button to increase hours
    input wire hour_dec_button,   // Button to decrease hours
    input wire min_inc_button,    // Button to increase minutes
    input wire min_dec_button,    // Button to decrease minutes
    input wire reset_switch,
    input wire [5:0] second_switches,
    output wire [6:0] segments,
    output wire [3:0] anodes,
    output wire [5:0] leds
);

    wire speed_up;
    wire enable;
    wire hour_inc, hour_dec, min_inc, min_dec;
    wire reset_up;

    // Instantiate the speed up switch debouncer
    test_debouncer td(
        .clk(clk),
        .switch(speed_up_switch),
        .speed_up(speed_up)
    );
    
    // Instantiate enable debouncer
    enable_toggle_debouncer enable_debouncer(
        .clk(clk),
        .button(pause_button),
        .enable(enable)
    );

    // Instantiate debouncers for hour and minute control
    debouncer hour_inc_debouncer(
        .clk(clk),
        .PB(hour_inc_button),
        .PB_state(),
        .PB_down(),
        .PB_up(hour_inc)
    );

    debouncer hour_dec_debouncer(
        .clk(clk),
        .PB(hour_dec_button),
        .PB_state(),
        .PB_down(),
        .PB_up(hour_dec)
    );

    debouncer min_inc_debouncer(
        .clk(clk),
        .PB(min_inc_button),
        .PB_state(),
        .PB_down(),
        .PB_up(min_inc)
    );

    debouncer min_dec_debouncer(
        .clk(clk),
        .PB(min_dec_button),
        .PB_state(),
        .PB_down(),
        .PB_up(min_dec)
    );

    
    // Instantiate the display module
    display display_inst (
        .clk(clk),
        .speed_up(speed_up),
        .enable(enable),
        .hour_inc(hour_inc),
        .hour_dec(hour_dec),
        .min_inc(min_inc),
        .min_dec(min_dec),
	.reset_switch(reset_switch),
        .second_switches(second_switches),
        .segments(segments),
        .anodes(anodes),
        .leds(leds)
    );

endmodule



/*module top_module(
    input wire clk,
    input wire pause_button,
    input wire inc_hour_button,
    input wire dec_hour_button,
    input wire inc_minute_button,
    input wire dec_minute_button,
    output wire [6:0] segments,
    output wire [3:0] anodes,
    output wire [5:0] leds
);

    wire enable;

    // Instantiate the test_debouncer module for the pause button
    test_debouncer td_pause(
        .clk(clk),
        .button(pause_button),
        .enable(enable)
    );

    wire inc_hour_up, dec_hour_up;
    wire inc_minute_up, dec_minute_up;

    // Instantiate debouncers for time adjustment buttons
    debouncer db_inc_hour(.clk(clk), .PB(inc_hour_button), .PB_state(), .PB_down(), .PB_up(inc_hour_up));
    debouncer db_dec_hour(.clk(clk), .PB(dec_hour_button), .PB_state(), .PB_down(), .PB_up(dec_hour_up));
    debouncer db_inc_minute(.clk(clk), .PB(inc_minute_button), .PB_state(), .PB_down(), .PB_up(inc_minute_up));
    debouncer db_dec_minute(.clk(clk), .PB(dec_minute_button), .PB_state(), .PB_down(), .PB_up(dec_minute_up));

    // Instantiate the display module
    display display_inst (
        .clk(clk),
        .enable(enable),
        .inc_hour_up(inc_hour_up),
        .dec_hour_up(dec_hour_up),
        .inc_minute_up(inc_minute_up),
        .dec_minute_up(dec_minute_up),
        .segments(segments),
        .anodes(anodes),
        .leds(leds)
    );

endmodule*/