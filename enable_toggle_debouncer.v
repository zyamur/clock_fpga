module enable_toggle_debouncer(
    input wire clk,
    input wire button,
    output reg enable
);
    wire debounced_button_up;

    // Instantiate the debouncer
    debouncer db(
        .clk(clk),
        .PB(button),
        .PB_state(),
        .PB_down(),
        .PB_up(debounced_button_up)
    );

    initial begin
        enable = 1; // Start with the clock enabled
    end
    
    reg prev_debounced_button_up = 0;

    always @(posedge clk) begin
        prev_debounced_button_up <= debounced_button_up;
        if(prev_debounced_button_up && !debounced_button_up) begin
            enable <= ~enable;    
        end
    end

    // Toggle enable on each negative edge of PB_up
    /*always @(negedge debounced_button_up) begin
       enable <= ~enable; 
    end*/
endmodule
