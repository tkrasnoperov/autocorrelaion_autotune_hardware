`timescale 1ns / 1ps

module state_ram #(parameter N_PERIODS = 460) (
    input wire CLK100MHZ,
    input wire [10:0] read_addr,
    input wire [10:0] write_addr,
    input wire write_on,
    input wire [47:0] write_data,
    output reg [47:0] read_data
    );

    reg [47:0] memory_array [0:N_PERIODS - 1];
    initial begin
        for (int i = 0; i < N_PERIODS; i++) begin
            memory_array[i] = 0;
        end
        read_data = 0;
    end

    always @(posedge CLK100MHZ)
    begin
        if (write_on) begin
            memory_array[write_addr] <= write_data;
        end
        read_data <= memory_array[read_addr];
    end
endmodule
