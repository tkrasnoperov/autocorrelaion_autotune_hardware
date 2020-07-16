`timescale 1ns / 1ps

module wavelet_splitter(
    input wire CLK100MHZ,
    input wire detected_period_ready,
    input wire [10:0] detected_period,
    output reg wavelet_ready,
    output reg [10:0] wavelet_start,
    output reg [10:0] wavelet_period
    );
    
    initial wavelet_ready = 0;
    initial wavelet_start = 0;
    initial wavelet_period = 0;
    
    typedef enum logic[2:0] {IDLE, COMPUTING, CLEANUP} state_t;
    state_t state = IDLE;
    
    reg [10:0] curr_buffer_position = 0;
    reg [10:0] curr_wavelet_start = 0;
    reg [10:0] curr_period = 0;
    always @(posedge CLK100MHZ) begin
        case (state)
            IDLE:
            begin
                wavelet_ready <= 0;
                if (detected_period_ready == 1) begin
                    state <= COMPUTING;
                end
            end
            
            COMPUTING:
            begin
                if (curr_buffer_position == curr_wavelet_start + curr_period) begin
                    curr_wavelet_start <= curr_buffer_position;
                    curr_period <= detected_period;
                end
                curr_buffer_position <= curr_buffer_position + 1;
                state <= CLEANUP;
            end
            
            CLEANUP:
            begin
                wavelet_ready <= 1;
                wavelet_start <= curr_wavelet_start;
                wavelet_period <= curr_period;
                state <= IDLE;
            end
        endcase    
    end
    
endmodule
