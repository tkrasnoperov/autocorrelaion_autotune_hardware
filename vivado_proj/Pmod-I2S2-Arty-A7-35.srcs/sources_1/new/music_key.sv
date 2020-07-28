`timescale 1ns / 1ps

module music_key(
    input wire CLK100MHZ,
    input wire wavelet_ready,
    input wire [10:0] wavelet_period,
    input wire [4:0] key_code,
    input wire [4:0] octave_code,
    input wire [4:0] hardness_code,
    output reg note_ready,
    output reg [10:0] note_period
    );

    parameter N_KEY_NOTES = 36;
    parameter [10:0] C_MAJOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	505, 450, 400, 357, 337, 300, 267, 252, 225, 200, 178, 168, 150, 133, 126, 112, 100, 89, 84, 75, 66, 63, 56, 50, 44, 42, 37, 33, 31, 28, 25, 22, 21, 18, 16, 15
    };
    parameter [10:0] CD_MAJOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	505, 476, 424, 378, 337, 318, 283, 252, 238, 212, 189, 168, 159, 141, 126, 119, 106, 94, 84, 79, 70, 63, 59, 53, 47, 42, 39, 35, 31, 29, 26, 23, 21, 19, 17, 15
    };
    parameter [10:0] D_MAJOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	476, 450, 400, 357, 318, 300, 267, 238, 225, 200, 178, 159, 150, 133, 119, 112, 100, 89, 79, 75, 66, 59, 56, 50, 44, 39, 37, 33, 29, 28, 25, 22, 19, 18, 16, 14
    };
    parameter [10:0] DE_MAJOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	504, 449, 424, 378, 337, 300, 283, 252, 224, 212, 189, 168, 150, 141, 126, 112, 106, 94, 84, 75, 70, 63, 56, 53, 47, 42, 37, 35, 31, 28, 26, 23, 21, 18, 17, 15
    };
    parameter [10:0] E_MAJOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	476, 424, 400, 357, 318, 283, 267, 238, 212, 200, 178, 159, 141, 133, 119, 106, 100, 89, 79, 70, 66, 59, 53, 50, 44, 39, 35, 33, 29, 26, 25, 22, 19, 17, 16, 14
    };
    parameter [10:0] F_MAJOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	505, 449, 400, 378, 337, 300, 267, 252, 224, 200, 189, 168, 150, 133, 126, 112, 100, 94, 84, 75, 66, 63, 56, 50, 47, 42, 37, 33, 31, 28, 25, 23, 21, 18, 16, 15
    };
    parameter [10:0] FG_MAJOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	505, 476, 424, 378, 357, 318, 283, 252, 238, 212, 189, 178, 159, 141, 126, 119, 106, 94, 89, 79, 70, 63, 59, 53, 47, 44, 39, 35, 31, 29, 26, 23, 22, 19, 17, 15
    };
    parameter [10:0] G_MAJOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	476, 450, 400, 357, 337, 300, 267, 238, 225, 200, 178, 168, 150, 133, 119, 112, 100, 89, 84, 75, 66, 59, 56, 50, 44, 42, 37, 33, 29, 28, 25, 22, 21, 18, 16, 14
    };
    parameter [10:0] GA_MAJOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	505, 449, 424, 378, 337, 318, 283, 252, 224, 212, 189, 168, 159, 141, 126, 112, 106, 94, 84, 79, 70, 63, 56, 53, 47, 42, 39, 35, 31, 28, 26, 23, 21, 19, 17, 15
    };
    parameter [10:0] A_MAJOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	476, 424, 400, 357, 318, 300, 267, 238, 212, 200, 178, 159, 150, 133, 119, 106, 100, 89, 79, 75, 66, 59, 53, 50, 44, 39, 37, 33, 29, 26, 25, 22, 19, 18, 16, 14
    };
    parameter [10:0] AB_MAJOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	505, 449, 400, 378, 337, 300, 283, 252, 224, 200, 189, 168, 150, 141, 126, 112, 100, 94, 84, 75, 70, 63, 56, 50, 47, 42, 37, 35, 31, 28, 25, 23, 21, 18, 17, 15
    };
    parameter [10:0] B_MAJOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	476, 424, 378, 357, 318, 283, 267, 238, 212, 189, 178, 159, 141, 133, 119, 106, 94, 89, 79, 70, 66, 59, 53, 47, 44, 39, 35, 33, 29, 26, 23, 22, 19, 17, 16, 14
    };
    parameter [10:0] C_MINOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	505, 450, 400, 357, 337, 300, 267, 252, 225, 200, 178, 168, 150, 133, 126, 112, 100, 89, 84, 75, 66, 63, 56, 50, 44, 42, 37, 33, 31, 28, 25, 22, 21, 18, 16, 15
    };
    parameter [10:0] CD_MINOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	505, 476, 424, 378, 337, 318, 283, 252, 238, 212, 189, 168, 159, 141, 126, 119, 106, 94, 84, 79, 70, 63, 59, 53, 47, 42, 39, 35, 31, 29, 26, 23, 21, 19, 17, 15
    };
    parameter [10:0] D_MINOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	476, 450, 400, 357, 318, 300, 267, 238, 225, 200, 178, 159, 150, 133, 119, 112, 100, 89, 79, 75, 66, 59, 56, 50, 44, 39, 37, 33, 29, 28, 25, 22, 19, 18, 16, 14
    };
    parameter [10:0] DE_MINOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	504, 449, 424, 378, 337, 300, 283, 252, 224, 212, 189, 168, 150, 141, 126, 112, 106, 94, 84, 75, 70, 63, 56, 53, 47, 42, 37, 35, 31, 28, 26, 23, 21, 18, 17, 15
    };
    parameter [10:0] E_MINOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	476, 424, 400, 357, 318, 283, 267, 238, 212, 200, 178, 159, 141, 133, 119, 106, 100, 89, 79, 70, 66, 59, 53, 50, 44, 39, 35, 33, 29, 26, 25, 22, 19, 17, 16, 14
    };
    parameter [10:0] F_MINOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	505, 449, 400, 378, 337, 300, 267, 252, 224, 200, 189, 168, 150, 133, 126, 112, 100, 94, 84, 75, 66, 63, 56, 50, 47, 42, 37, 33, 31, 28, 25, 23, 21, 18, 16, 15
    };
    parameter [10:0] FG_MINOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	505, 476, 424, 378, 357, 318, 283, 252, 238, 212, 189, 178, 159, 141, 126, 119, 106, 94, 89, 79, 70, 63, 59, 53, 47, 44, 39, 35, 31, 29, 26, 23, 22, 19, 17, 15
    };
    parameter [10:0] G_MINOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	476, 450, 400, 357, 337, 300, 267, 238, 225, 200, 178, 168, 150, 133, 119, 112, 100, 89, 84, 75, 66, 59, 56, 50, 44, 42, 37, 33, 29, 28, 25, 22, 21, 18, 16, 14
    };
    parameter [10:0] GA_MINOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	505, 449, 424, 378, 337, 318, 283, 252, 224, 212, 189, 168, 159, 141, 126, 112, 106, 94, 84, 79, 70, 63, 56, 53, 47, 42, 39, 35, 31, 28, 26, 23, 21, 19, 17, 15
    };
    parameter [10:0] A_MINOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	476, 424, 400, 357, 318, 300, 267, 238, 212, 200, 178, 159, 150, 133, 119, 106, 100, 89, 79, 75, 66, 59, 53, 50, 44, 39, 37, 33, 29, 26, 25, 22, 19, 18, 16, 14
    };
    parameter [10:0] AB_MINOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	505, 449, 400, 378, 337, 300, 283, 252, 224, 200, 189, 168, 150, 141, 126, 112, 100, 94, 84, 75, 70, 63, 56, 50, 47, 42, 37, 35, 31, 28, 25, 23, 21, 18, 17, 15
    };
    parameter [10:0] B_MINOR_KEY_PERIODS [0:N_KEY_NOTES - 1] = {
    	476, 424, 378, 357, 318, 283, 267, 238, 212, 189, 178, 159, 141, 133, 119, 106, 94, 89, 79, 70, 66, 59, 53, 47, 44, 39, 35, 33, 29, 26, 23, 22, 19, 17, 16, 14
    };
    reg [10:0] key_periods [0:N_KEY_NOTES - 1];
    initial begin
        for (int i = 0; i < N_KEY_NOTES; i++) begin
            key_periods[i] = 100;
        end
    end

    always @(posedge CLK100MHZ) begin
        // MAJOR: C, CD, D, DE, E, F, FG, G, GA,
        if (key_code == 5'b00000000)
            key_periods <= C_MAJOR_KEY_PERIODS;
        else if (key_code == 5'b00001)
            key_periods <= CD_MAJOR_KEY_PERIODS;
        else if (key_code == 5'b00010)
            key_periods <= D_MAJOR_KEY_PERIODS;
        else if (key_code == 5'b00011)
            key_periods <= DE_MAJOR_KEY_PERIODS;
        else if (key_code == 5'b00100)
            key_periods <= E_MAJOR_KEY_PERIODS;
        else if (key_code == 5'b00101)
            key_periods <= F_MAJOR_KEY_PERIODS;
        else if (key_code == 5'b00110)
            key_periods <= FG_MAJOR_KEY_PERIODS;
        else if (key_code == 5'b00111)
            key_periods <= G_MAJOR_KEY_PERIODS;
        else if (key_code == 5'b01000)
            key_periods <= GA_MAJOR_KEY_PERIODS;
        else if (key_code == 5'b01001)
            key_periods <= A_MAJOR_KEY_PERIODS;
        else if (key_code == 5'b01010)
            key_periods <= AB_MAJOR_KEY_PERIODS;
        else if (key_code == 5'b01011)
            key_periods <= B_MAJOR_KEY_PERIODS;
        // MINOR
        else if (key_code == 5'b10000)
            key_periods <= C_MINOR_KEY_PERIODS;
        else if (key_code == 5'b10001)
            key_periods <= CD_MINOR_KEY_PERIODS;
        else if (key_code == 5'b10010)
            key_periods <= D_MINOR_KEY_PERIODS;
        else if (key_code == 5'b10011)
            key_periods <= DE_MINOR_KEY_PERIODS;
        else if (key_code == 5'b10100)
            key_periods <= E_MINOR_KEY_PERIODS;
        else if (key_code == 5'b10101)
            key_periods <= F_MINOR_KEY_PERIODS;
        else if (key_code == 5'b10110)
            key_periods <= FG_MINOR_KEY_PERIODS;
        else if (key_code == 5'b10111)
            key_periods <= G_MINOR_KEY_PERIODS;
        else if (key_code == 5'b11000)
            key_periods <= GA_MINOR_KEY_PERIODS;
        else if (key_code == 5'b11001)
            key_periods <= A_MINOR_KEY_PERIODS;
        else if (key_code == 5'b11010)
            key_periods <= AB_MINOR_KEY_PERIODS;
        else if (key_code == 5'b11011)
            key_periods <= B_MINOR_KEY_PERIODS;
        // DEFAULT
        else
            key_periods <= E_MAJOR_KEY_PERIODS;
    end

    reg [10:0] processing_state = 0;

    var reg [10:0] note_idx;
    var reg [10:0] diff;
    var reg [10:0] abs_diff;
    reg [10:0] min_abs_diff = {11{1'b1}};

    var reg [10:0] jump;
    var reg [10:0] dry_wet_diff;

    typedef enum logic[2:0] {IDLE, COMPUTING, OCTAVE_PEDAL, DRY_WET, CLEANUP} state_t;
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
                        if (octave_code[4] == 0) begin
                            if (state_counter >= octave_code[3:0]) begin
                                note_period <= key_periods[state_counter - octave_code[3:0]];
                            end
                            else begin
                                note_period <= key_periods[0];
                            end
                        end
                        else begin
                            if (state_counter + octave_code[3:0] < N_KEY_NOTES) begin
                                note_period <= key_periods[state_counter + octave_code[3:0]];
                            end
                            else begin
                                note_period <= key_periods[N_KEY_NOTES - 1];
                            end
                        end
                    end
                    state_counter <= state_counter + 1;
                end
                else begin
                    state <= OCTAVE_PEDAL;
                    state_counter <= 0;
                end
            end

            OCTAVE_PEDAL:
            begin
                // case (octave_code)
                //     5'b00000: note_period <= note_period;
                //     5'b00001: note_period <= note_period >> 1;
                //     5'b00010: note_period <= note_period >> 2;
                //     5'b00011: note_period <= note_period << 1;
                //     5'b00100: note_period <= note_period << 2;
                //     default: note_period <= note_period;
                // endcase;
                state <= DRY_WET;
            end

            DRY_WET:
            begin
                if (note_period < wavelet_period) begin
                    jump = wavelet_period - note_period;
                    dry_wet_diff = (jump * hardness_code) >> 4;
                    note_period <= note_period + dry_wet_diff;
                end
                else if (wavelet_period < note_period) begin
                    jump = note_period - wavelet_period;
                    dry_wet_diff = (jump * hardness_code) >> 4;
                    note_period <= note_period - dry_wet_diff;
                end
                state <= CLEANUP;
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
