`timescale 1ns / 1ps

module buffer_2048 #(parameter N_POINTS = 2048)(
    input wire CLK100MHZ,
    input wire write,
    input wire [10:0] read_select,
    input wire [23:0] write_value,
    output reg [23:0] read_value
    );
    
    reg signed [23:0] queue [0:N_POINTS - 1];
    initial begin
        for (integer i = 0; i < N_POINTS; i++) begin
            queue[i] = 0;
        end
       read_value = 0;
    end
    
    reg [10:0] idx = 0;
    always @(posedge CLK100MHZ) begin
        read_value <= queue[(idx - read_select) % N_POINTS];
        if (write == 1) begin
            queue[idx] <= write_value;
            idx <= idx + 1;
        end
    end
    
endmodule
