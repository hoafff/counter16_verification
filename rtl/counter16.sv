`timescale 1ns/1ps

module counter16 (
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,
    output logic [15:0] count
);

    always_ff @(posedge clk) begin
        if (reset) begin
            count <= 16'h0000;
        end else if (enable) begin
            if (count == 16'hFFFF)
                count <= 16'h0000;
            else
                count <= count + 16'h0001;
        end
    end

endmodule
