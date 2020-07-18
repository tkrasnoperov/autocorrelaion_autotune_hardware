`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc
// Engineer: Arthur Brown
// 
// Create Date: 03/23/2018 11:53:54 AM
// Design Name: Arty-A7-100-Pmod-I2S2
// Module Name: top
// Project Name: 
// Target Devices: Arty A7 100
// Tool Versions: Vivado 2017.4
// Description: Implements a volume control stream from Line In to Line Out of a Pmod I2S2 on port JA
// 
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module top #(
	parameter NUMBER_OF_SWITCHES = 4,
	parameter RESET_POLARITY = 0
) (
    input wire       clk,
    input wire [NUMBER_OF_SWITCHES-1:0] sw,
    input wire       reset,
    
    output wire tx_mclk,
    output wire tx_lrck,
    output wire tx_sclk,
    output wire tx_data,
    output wire rx_mclk,
    output wire rx_lrck,
    output wire rx_sclk,
    input  wire rx_data,
    
    input wire UART_RX,
    output wire [3:0] led
);
    wire axis_clk;
    
    wire [23:0] axis_tx_data;
    wire axis_tx_valid;
    wire axis_tx_ready;
    wire axis_tx_last;
    
    wire [23:0] axis_rx_data;
    wire axis_rx_valid;
    wire axis_rx_ready;
    wire axis_rx_last;

	wire resetn = (reset == RESET_POLARITY) ? 1'b0 : 1'b1;
	
    clk_wiz_0 m_clk (
        .clk_in1(clk),
        .axis_clk(axis_clk)
    );

    axis_i2s2 m_i2s2 (
        .axis_clk(axis_clk),
        .axis_resetn(resetn),
    
        .tx_axis_s_data(y_frame),
//        .tx_axis_s_data(axis_tx_data),
        .tx_axis_s_valid(axis_tx_valid),
        .tx_axis_s_ready(axis_tx_ready),
        .tx_axis_s_last(axis_tx_last),
    
        .rx_axis_m_data(axis_rx_data),
        .rx_axis_m_valid(axis_rx_valid),
        .rx_axis_m_ready(axis_rx_ready),
        .rx_axis_m_last(axis_rx_last),
        
        .tx_mclk(tx_mclk),
        .tx_lrck(tx_lrck),
        .tx_sclk(tx_sclk),
        .tx_sdout(tx_data),
        .rx_mclk(rx_mclk),
        .rx_lrck(rx_lrck),
        .rx_sclk(rx_sclk),
        .rx_sdin(rx_data)
    );
    
    axis_volume_controller #(
		.SWITCH_WIDTH(NUMBER_OF_SWITCHES),
		.DATA_WIDTH(24)
	) m_vc (
        .clk(axis_clk),
        .sw(sw),
        
        .s_axis_data(axis_rx_data),
        .s_axis_valid(axis_rx_valid),
        .s_axis_ready(axis_rx_ready),
        .s_axis_last(axis_rx_last),
        
        .m_axis_data(axis_tx_data),
        .m_axis_valid(axis_tx_valid),
        .m_axis_ready(axis_tx_ready),
        .m_axis_last(axis_tx_last)
    );
    
    var reg [23:0] x_frame_unsigned = 0;
    reg [23:0] x_frame = 0;
    reg [23:0] y_frame = 0;
    wire [23:0] y_frame_wire;
    reg frame_ready = 0;    
    always@(posedge axis_clk) begin
        if (resetn == 1'b0) begin
//            tx_data_r <= 32'b0;
//            tx_data_l <= 32'b0;
            y_frame <= 24'b0;
            frame_ready <= 0;
        end 
        else if (axis_tx_valid == 1'b1 && axis_tx_ready == 1'b1) begin
//            x_frame[23:0]
            x_frame_unsigned = axis_tx_data + (2 ** 23);
            x_frame <= x_frame_unsigned >> 12;
            y_frame <= (y_frame_wire << 12) + (2 ** 23);
            frame_ready <= 1;
        end
        else begin
            frame_ready <= 0;
        end
    end
    
        // ===============================================================================

    // Key controller
    wire key_code_ready;
    wire [7:0] key_code_wire;
    reg [7:0] key_code = 0;
    uart_rx reciever(
        .i_Clock(clk),
        .i_Rx_Serial(UART_RX),
        .o_Rx_DV(key_code_ready),
        .o_Rx_Byte(key_code_wire)
    );
    always @(posedge clk) begin
        if (key_code_ready == 1) begin
            key_code <= key_code_wire;
        end
    end
    assign led = key_code[3:0];
    
    
    // AC period detection
    wire detected_period_ready;
    wire [10:0] detected_period_wire;
    // wavelet splitting
    wire wavelet_ready;
    wire [10:0] wavelet_start_wire;
    wire [10:0] wavelet_period_wire;
    // nearest note in key
    wire note_ready;
    wire [10:0] note_period_wire;
    
    autocorrelation_spectrum ac(
        .CLK100MHZ(clk),
        
        .signal(frame_ready),
        .x(x_frame),
        
        .detected_period_ready(detected_period_ready),
        .detected_period(detected_period_wire)
    );
    
    
    wavelet_splitter wavelet_splitter_1(
        .CLK100MHZ(clk),
        
        .detected_period_ready(detected_period_ready),
        .detected_period(detected_period_wire),
        
        .wavelet_ready(wavelet_ready),
        .wavelet_start(wavelet_start_wire),
        .wavelet_period(wavelet_period_wire)
    );
    
    
    music_key key(
        .CLK100MHZ(clk),
        
        .wavelet_ready(wavelet_ready),
        .wavelet_period(wavelet_period_wire),
        .key_code(key_code),
        
        .note_ready(note_ready),
//        .note_period(y_frame_wire[10:0])
        .note_period(note_period_wire)
   );
   
   wavelet_resampler wavelet_resampler_1(
        .CLK100MHZ(clk),
        
        .note_ready(note_ready),
        .x_frame(x_frame),
        .wavelet_start(wavelet_start_wire),
        .wavelet_period(wavelet_period_wire),
        .note_period(note_period_wire),
        
        .y(y_frame_wire)    
    );        
       
//    reg [23:0] x_frame = 0;
//    reg [23:0] y_frame = 0;
//    reg prev_state = 0;
//    always @(posedge clk) begin
//        if ((axis_tx_ready == 1) && (prev_state == 0)) begin
//            y_frame <= axis_tx_data;
//        end
//        prev_state <= axis_tx_ready;
//    end
    
endmodule