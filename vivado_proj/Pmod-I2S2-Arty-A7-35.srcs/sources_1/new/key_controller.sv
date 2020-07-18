`timescale 1ns / 1ps

module key_controller(
    input wire       clk,
    //    input wire [3:0] sw,
    input wire UART_RX,
    output wire [3:0] led
    );
    
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

endmodule
