`timescale 1ns / 1ps

module wavelet_resampler(
    input wire CLK100MHZ,
    
    input wire note_ready,
    input wire [23:0] x_frame,
    input wire [10:0] wavelet_start,
    input wire [10:0] wavelet_period,
    input wire [10:0] note_period,

    output reg [23:0] y    
    );
    
    parameter N_BUFFER_POINTS = 2048;
    reg [10:0] x_buffer_idx = 499;
    reg [23:0] x_buffer [0:N_BUFFER_POINTS];
    initial begin
        for (int i = 0; i < N_BUFFER_POINTS; i++) begin
            x_buffer[i] = 0;
        end
    end
    
    reg [10:0] sample_position = 0;
    reg [10:0] curr_wavelet_start = 0;
    reg [10:0] curr_wavelet_period = 0;
    reg [10:0] curr_note_period = 0;
    var reg signed [11:0] curr_note_period_signed;
    
    reg [21:0] resolution_position;
    reg [10:0] x_left;
    reg [10:0] delta_x;
    var reg signed [11:0] delta_x_signed;
    reg [23:0] y_left;
    var reg signed [24:0] y_left_signed;
    reg [23:0] y_right;
    reg signed [24:0] delta_y;
    reg signed [36:0] delta_x_delta_y;
    var reg signed [24:0] y_add;
    reg [24:0] y_reg;
    
    typedef enum logic[4:0] {IDLE, UPDATING, INTERPOLATE_1, INTERPOLATE_2, INTERPOLATE_3, INTERPOLATE_4, INTERPOLATE_5, INTERPOLATE_6, WAIT_0, WAIT_1, WAIT_2, WAIT_3, WAIT_4, CLEANUP} state_t;
    state_t state = IDLE;
    reg [10:0] state_counter = 0;
    always @(posedge CLK100MHZ) begin
        case(state)
            IDLE:
            begin
                if (note_ready == 1) begin
                    state <= UPDATING;
                end
            end
            
            UPDATING:
            begin
                x_buffer[x_buffer_idx] <= x_frame;
                x_buffer_idx <= x_buffer_idx + 1;
                if (sample_position == curr_note_period) begin
                    curr_wavelet_start <= wavelet_start;
                    curr_wavelet_period <= wavelet_period;
                    curr_note_period <= note_period;
                    sample_position <= 0;
                end
                state <= INTERPOLATE_1;
            end
            
            INTERPOLATE_1:
            begin
                resolution_position <= sample_position * curr_wavelet_period;
                state <= WAIT_0;
            end
       
            WAIT_0:
            begin
                if (state_counter < 10) begin
                    state_counter <= state_counter + 1;
                end
                else begin
                    state_counter <= 0;
                    state <= INTERPOLATE_2;
                end
            end
        
            INTERPOLATE_2:
            begin
                x_left <= resolution_position / curr_note_period;
                delta_x <= resolution_position % curr_note_period;
                state <= WAIT_1;
            end
            
            WAIT_1:
            begin
                if (state_counter < 10) begin
                    state_counter <= state_counter + 1;
                end
                else begin
                    state_counter <= 0;
                    state <= INTERPOLATE_3;
                end
            end
            
            INTERPOLATE_3:
            begin
                y_left <= x_buffer[(curr_wavelet_start + x_left) % N_BUFFER_POINTS];
                y_right <= x_buffer[(curr_wavelet_start + x_left + 1) % N_BUFFER_POINTS];
                state <= INTERPOLATE_4;
            end
            
            INTERPOLATE_4:
            begin
                delta_y <= y_right - y_left;
                state <= INTERPOLATE_5;
            end
            
            INTERPOLATE_5:
            begin
                delta_x_signed = $signed(delta_x);
                delta_x_delta_y <= delta_x_signed * delta_y;
                state <= WAIT_2;
            end
            
            WAIT_2:
            begin
                if (state_counter < 10) begin
                    state_counter <= state_counter + 1;
                end
                else begin
                    state_counter <= 0;
                    state <= INTERPOLATE_6;
                end
            end
            
            INTERPOLATE_6:
            begin
                curr_note_period_signed = $signed(curr_note_period);
                y_left_signed = $signed(y_left);
                y_add = delta_x_delta_y / curr_note_period_signed;
                y_reg <= y_left_signed + y_add;
                state <= WAIT_3;
            end
            
            WAIT_3:
            begin
                if (state_counter < 20) begin
                    state_counter <= state_counter + 1;
                end
                else begin
                    state_counter <= 0;
                    state <= CLEANUP;
                end
            end
            
            CLEANUP:
            begin
                y <= y_reg[23:0];
//                y[10:0] <= sample_position;
//                y[10:0] <= x_left;
//                y[10:0] <= delta_x;
//                y <= delta_y[24:1];
//                y <= delta_x_delta_y[36:36-23];
                
                sample_position <= sample_position + 1;
                state <= IDLE;
            end
        endcase
    end
    
endmodule
