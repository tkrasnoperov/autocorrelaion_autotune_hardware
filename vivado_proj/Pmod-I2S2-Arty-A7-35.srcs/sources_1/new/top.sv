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

    input wire UART_RX_USB,
    input wire UART_RX_SDA,
    output wire [3:0] led,
    output wire [3:0] led_b,
    output wire [3:0] led_r
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

    var reg [23:0] x_frame_unsigned = 0;
    reg [23:0] x_frame = 0;
    reg [23:0] y_frame = 0;
    wire [23:0] y_frame_wire;
    reg frame_ready = 0;

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

        .s_axis_data(axis_rx_data),
        .s_axis_valid(axis_rx_valid),
        .s_axis_ready(axis_rx_ready),
        .s_axis_last(axis_rx_last),

        .m_axis_data(axis_tx_data),
        .m_axis_valid(axis_tx_valid),
        .m_axis_ready(axis_tx_ready),
        .m_axis_last(axis_tx_last)
    );

  	reg [23:0] x_frame_dry = 0;
		reg [23:0] y_frame_wet = 0;
		wire [4:0] dry_wet_code;
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
						x_frame_dry <= x_frame_unsigned >> 12;
						y_frame_wet <= (dry_wet_code[4:0] * y_frame_wet + (16 - dry_wet_code[4:0]) * x_frame_dry) >> 4;
            y_frame <= (y_frame_wet << 12) + (2 ** 23);
            frame_ready <= 1;
        end
        else begin
            frame_ready <= 0;
        end
    end

    wire UART_RX;
    assign UART_RX = sw[0] ? UART_RX_USB : UART_RX_SDA;

        // ===============================================================================

    // Key controller
    wire [4:0] key_code;
    wire [4:0] octave_code;

    settings_controller settings_controller_1(
        .CLK100MHZ(clk),
        .UART_RX(UART_RX),

        .key_code(key_code),
        .octave_code(octave_code),
        .dry_wet_code(dry_wet_code),

        .key_led(led),
        .major_minor_led(led_b[0]),
        .octave_led(led_b[3:1]),
        .dry_wet_led(led_r)
    );


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
        .octave_code(octave_code),
        // .dry_wet_code(dry_wet_code),

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

endmodule
