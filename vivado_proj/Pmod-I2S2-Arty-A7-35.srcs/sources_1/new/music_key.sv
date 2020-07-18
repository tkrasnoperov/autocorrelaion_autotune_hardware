`timescale 1ns / 1ps

module music_key(
    input wire CLK100MHZ,
    input wire wavelet_ready,
    input wire [10:0] wavelet_period,
    input wire [7:0] key_code,
    output reg note_ready,
    output reg [10:0] note_period
    );
    
    parameter N_KEY_NOTES = 18; 
    parameter [10:0] c_major_key_periods [0:N_KEY_NOTES - 1] = {
        505, 450, 400, 357, 337, 300, 267, 252, 225, 200, 178, 168, 150, 133, 126, 112, 100, 89
    };
    parameter [10:0] cd_major_key_periods [0:N_KEY_NOTES - 1] = {
        505, 476, 424, 378, 337, 318, 283, 252, 238, 212, 189, 168, 159, 141, 126, 119, 106, 94
    };
    parameter [10:0] d_major_key_periods [0:N_KEY_NOTES - 1] = {
        476, 450, 400, 357, 318, 300, 267, 238, 225, 200, 178, 159, 150, 133, 119, 112, 100, 89
    };
    parameter [10:0] de_major_key_periods [0:N_KEY_NOTES - 1] = {
        504, 449, 424, 378, 337, 300, 283, 252, 224, 212, 189, 168, 150, 141, 126, 112, 106, 94
    };
    parameter [10:0] e_major_key_periods [0:N_KEY_NOTES - 1] = {
        535, 476, 424, 400, 357, 318, 283, 267, 238, 212, 200, 178, 159, 141, 133, 119, 106, 100
    };
    parameter [10:0] f_major_key_periods [0:N_KEY_NOTES - 1] = {
        535, 505, 449, 400, 378, 337, 300, 267, 252, 224, 200, 189, 168, 150, 133, 126, 112, 100
    };
    parameter [10:0] fg_major_key_periods [0:N_KEY_NOTES - 1] = {
        505, 476, 424, 378, 357, 318, 283, 252, 238, 212, 189, 178, 159, 141, 126, 119, 106, 94
    };
    parameter [10:0] g_major_key_periods [0:N_KEY_NOTES - 1] = {
        535, 476, 450, 400, 357, 337, 300, 267, 238, 225, 200, 178, 168, 150, 133, 119, 112, 100
    };    
    parameter [10:0] ga_major_key_periods [0:N_KEY_NOTES - 1] = {
        505, 449, 424, 378, 337, 318, 283, 252, 224, 212, 189, 168, 159, 141, 126, 112, 106, 94
    };
    parameter [10:0] a_major_key_periods [0:N_KEY_NOTES - 1] = {
        535, 476, 424, 400, 357, 318, 300, 267, 238, 212, 200, 178, 159, 150, 133, 119, 106, 100
    };
    parameter [10:0] ab_major_key_periods [0:N_KEY_NOTES - 1] = {
        505, 449, 400, 378, 337, 300, 283, 252, 224, 200, 189, 168, 150, 141, 126, 112, 100, 94
    };
    parameter [10:0] b_major_key_periods [0:N_KEY_NOTES - 1] = {
        535, 476, 424, 378, 357, 318, 283, 267, 238, 212, 189, 178, 159, 141, 133, 119, 106, 94
    };
    
    parameter [10:0] c_minor_key_periods [0:N_KEY_NOTES - 1] = {
        505, 450, 424, 378, 337, 300, 283, 252, 225, 212, 189, 168, 150, 141, 126, 112, 106, 94
    };
    parameter [10:0] cd_minor_key_periods [0:N_KEY_NOTES - 1] = {
        535, 476, 424, 400, 357, 318, 283, 267, 238, 212, 200, 178, 159, 141, 133, 119, 106, 100
    };
    parameter [10:0] d_minor_key_periods [0:N_KEY_NOTES - 1] = {
        535, 505, 450, 400, 378, 337, 300, 267, 252, 225, 200, 189, 168, 150, 133, 126, 112, 100
    };
    parameter [10:0] de_minor_key_periods [0:N_KEY_NOTES - 1] = {
        504, 476, 424, 378, 357, 318, 283, 252, 238, 212, 189, 178, 159, 141, 126, 119, 106, 94
    };
    parameter [10:0] e_minor_key_periods [0:N_KEY_NOTES - 1] = {
        535, 476, 450, 400, 357, 337, 300, 267, 238, 225, 200, 178, 168, 150, 133, 119, 112, 100
    };
    parameter [10:0] f_minor_key_periods [0:N_KEY_NOTES - 1] = {
        505, 449, 424, 378, 337, 318, 283, 252, 224, 212, 189, 168, 159, 141, 126, 112, 106, 94
    };
    parameter [10:0] fg_minor_key_periods [0:N_KEY_NOTES - 1] = {
        535, 476, 424, 400, 357, 318, 300, 267, 238, 212, 200, 178, 159, 150, 133, 119, 106, 100
    };
    parameter [10:0] g_minor_key_periods [0:N_KEY_NOTES - 1] = {
        505, 449, 400, 378, 337, 300, 283, 252, 224, 200, 189, 168, 150, 141, 126, 112, 100, 94
    };
    parameter [10:0] ga_minor_key_periods [0:N_KEY_NOTES - 1] = {
        535, 476, 424, 378, 357, 318, 283, 267, 238, 212, 189, 178, 159, 141, 133, 119, 106, 94
    };
    parameter [10:0] a_minor_key_periods [0:N_KEY_NOTES - 1] = {
        535, 505, 450, 400, 357, 337, 300, 267, 252, 225, 200, 178, 168, 150, 133, 126, 112, 100
    };
    parameter [10:0] ab_minor_key_periods [0:N_KEY_NOTES - 1] = {
        505, 476, 424, 378, 337, 318, 283, 252, 238, 212, 189, 168, 159, 141, 126, 119, 106, 94
    };
    parameter [10:0] b_minor_key_periods [0:N_KEY_NOTES - 1] = {
       535, 476, 449, 400, 357, 318, 300, 267, 238, 224, 200, 178, 159, 150, 133, 119, 112, 100
    };
    reg [10:0] key_periods [0:N_KEY_NOTES - 1];
    initial begin
        for (int i = 0; i < N_KEY_NOTES; i++) begin
            key_periods[i] = 100;
        end
    end
    
    always @(posedge CLK100MHZ) begin
        // MAJOR: C, CD, D, DE, E, F, FG, G, GA, 
        if (key_code == 8'b00000000)
            key_periods <= c_major_key_periods;
        else if (key_code == 8'b00000001)
            key_periods <= cd_major_key_periods;
        else if (key_code == 8'b00000010)
            key_periods <= d_major_key_periods;
        else if (key_code == 8'b00000011)
            key_periods <= de_major_key_periods;
        else if (key_code == 8'b00000100)
            key_periods <= e_major_key_periods;
        else if (key_code == 8'b00000101)
            key_periods <= f_major_key_periods;
        else if (key_code == 8'b00000110)
            key_periods <= fg_major_key_periods;
        else if (key_code == 8'b00000111)
            key_periods <= g_major_key_periods;
        else if (key_code == 8'b00001000)
            key_periods <= ga_major_key_periods;
        else if (key_code == 8'b00001001)
            key_periods <= a_major_key_periods;
        else if (key_code == 8'b00001010)
            key_periods <= ab_major_key_periods;
        else if (key_code == 8'b00001011)
            key_periods <= b_major_key_periods;
        // MINOR 
        else if (key_code == 8'b00010000)
            key_periods <= c_minor_key_periods;
        else if (key_code == 8'b00010000)
            key_periods <= cd_minor_key_periods;
        else if (key_code == 8'b00010000)
            key_periods <= d_minor_key_periods;
        else if (key_code == 8'b00010000)
            key_periods <= de_minor_key_periods;
        else if (key_code == 8'b00010000)
            key_periods <= e_minor_key_periods;
        else if (key_code == 8'b00010000)
            key_periods <= f_minor_key_periods;
        else if (key_code == 8'b00010000)
            key_periods <= fg_minor_key_periods;
        else if (key_code == 8'b00010000)
            key_periods <= g_minor_key_periods;
        else if (key_code == 8'b00010000)
            key_periods <= ga_minor_key_periods;
        else if (key_code == 8'b00010000)
            key_periods <= a_minor_key_periods;
        else if (key_code == 8'b00010000)
            key_periods <= ab_minor_key_periods;
        else if (key_code == 8'b00010000)
            key_periods <= b_minor_key_periods;
        // DEFAULT
        else
            key_periods <= e_major_key_periods;
    end
    
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
