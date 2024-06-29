`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2024 21:28:26
// Design Name: 
// Module Name: priorityEncoder_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_priority_encoder;

    // Parameters
    localparam WIDTH = 16;
    localparam OUT_WIDTH = $clog2(WIDTH);

    // Inputs
    reg [WIDTH-1:0] in;

    // Outputs
    wire [OUT_WIDTH-1:0] out;

    // Instantiate the priority encoder
    priority_encoder #(
        .WIDTH(WIDTH)
    ) uut (
        .in(in),
        .out(out)
    );

    // Test vectors
    initial begin
        // Initialize the input
        in = 0;

        // Apply test vectors
        $display("Input (binary)             | Output (decimal)");

        // Test case 1: No '1' bit
        in = 16'b0000000000000000;
        #10 $display("%b | %d", in, out);

        // Test case 2: '1' bit at position 0
        in = 16'b0000000000000001;
        #10 $display("%b | %d", in, out);

        // Test case 3: '1' bit at position 15
        in = 16'b1000000000000000;
        #10 $display("%b | %d", in, out);

        // Test case 4: '1' bit at position 7
        in = 16'b0000000010000000;
        #10 $display("%b | %d", in, out);

        // Test case 5: Multiple '1' bits, highest at position 10
        in = 16'b0000010010000000;
        #10 $display("%b | %d", in, out);

        // Test case 6: Multiple '1' bits, highest at position 6
        in = 16'b0100010000000000;
        #10 $display("%b | %d", in, out);

        // Test case 7: Random test case
        in = 16'b0010101010101010;
        #10 $display("%b | %d", in, out);

        // Test case 8: Random test case
        in = 16'b1111000000000000;
        #10 $display("%b | %d", in, out);

        // Test case 9: Random test case
        in = 16'b0000000001111000;
        #10 $display("%b | %d", in, out);

        // Test case 10: All bits set to 1
        in = 16'b1111111111111111;
        #10 $display("%b | %d", in, out);

        // End of test
        $finish;
    end

endmodule
