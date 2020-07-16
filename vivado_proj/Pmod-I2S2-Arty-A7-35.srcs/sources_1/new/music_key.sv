`timescale 1ns / 1ps

module music_key(
    input wire CLK100MHZ,
    input wire wavelet_ready,
    input wire [10:0] wavelet_period,
    output reg note_ready,
    output reg [10:0] note_period
    );
    
    parameter N_KEY_NOTES = 18; 
    reg [10:0] key_periods [0:N_KEY_NOTES - 1] = {
        535, 476, 424, 400, 357, 318, 283, 267, 238, 212, 200, 178, 159, 141, 133, 119, 106, 100
    };
    
    reg [10:0] processing_state = 0;
    
    var reg[10:0] note_idx;
    var reg [10:0] diff;
    var reg [10:0] abs_diff;
    reg [10:0] min_abs_diff = {11{1'b1}};
    
    typedef enum logic[2:0] {IDLE, COMPUTING, CLEANUP} state_t;
    state_t state = IDLE;
    reg [10:0] state_counter = 0;
    
    always @(posedge CLK100MHZ) begin
        case(state)
            IDLE:
            begin
                note_ready <= 0;
                if (wavelet_ready == 1) begin
                    state <= COMPUTING;
                    state_counter <= 0;
                end
            end
            
            COMPUTING:
            begin
                if (state_counter < N_KEY_NOTES) begin
                    diff = key_periods[state_counter] - wavelet_period;
                    abs_diff = diff[10] ? -diff : diff;
                    if (abs_diff < min_abs_diff) begin
                        min_abs_diff <= abs_diff;
                        note_period <= key_periods[state_counter];
                    end
                    state_counter <= state_counter + 1;
                end
                else begin
                    state <= CLEANUP;
                    state_counter <= 0;
                end
            end
            
            CLEANUP:
            begin
                min_abs_diff <= {10{1'b1}};
                note_ready <= 1;
                state <= IDLE;
            end
        endcase
    end
    
endmodule
