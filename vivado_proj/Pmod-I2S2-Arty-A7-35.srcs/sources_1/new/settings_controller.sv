`timescale 1ns / 1ps

module settings_controller(
    input wire CLK100MHZ,
    input wire UART_RX,

    output wire [4:0] key_code,
    output wire [4:0] octave_code,
    output wire [4:0] dry_wet_code,
    output wire [4:0] hardness_code,

    output wire [3:0] key_led,
    output wire major_minor_led,
    output wire [2:0] octave_led,
    output wire [3:0] dry_wet_led
    );

    wire settings_byte_ready;
    wire [7:0] settings_byte_wire;
    reg [7:0] settings_byte;
    uart_rx reciever(
        .i_Clock(CLK100MHZ),
        .i_Rx_Serial(UART_RX),
        .o_Rx_DV(settings_byte_ready),
        .o_Rx_Byte(settings_byte_wire)
    );

    reg [4:0] key_code_reg;
    reg [4:0] octave_code_reg;
    reg [4:0] dry_wet_code_reg;
    reg [4:0] hardness_code_reg;
    always @(posedge CLK100MHZ) begin
        if (settings_byte_ready == 1) begin
            case (settings_byte_wire[7:5])
                3'b000: key_code_reg <= settings_byte_wire[4:0];
                3'b001: octave_code_reg <= settings_byte_wire[4:0];
                3'b010: dry_wet_code_reg <= settings_byte_wire[4:0];
                3'b011: hardness_code_reg <= settings_byte_wire[4:0];
            endcase
        end
    end

    assign key_code = key_code_reg;
    assign octave_code = octave_code_reg;
    assign dry_wet_code = dry_wet_code_reg;
    assign hardness_code = hardness_code_reg;

    assign key_led = key_code[3:0];
    assign major_minor_led = key_code[4];
    assign octave_led = octave_code[2:0];
    assign dry_wet_led = dry_wet_code[3:0];

endmodule
