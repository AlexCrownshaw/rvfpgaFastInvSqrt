//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.06.2024 16:43:10
// Design Name: 
// Module Name: fixToSingle
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


module fixToSingle #(
    parameter INT_WIDTH = 12,      // Number of integer bits
    parameter FRACT_WIDTH = 4      // Number of fractional bits 
)
(
    input wire [(INT_WIDTH + FRACT_WIDTH - 1):0] fixed_point,  // Fixed-point input
    output reg [31:0] single    // IEEE 754 single-precision float output
);

    reg [(INT_WIDTH + FRACT_WIDTH - 1):0] normalised;  // Normalised fixed-point representation
    reg [7:0] exponent; 
    reg [22:0] mantissa;
    reg [5:0] shift_amount; // Amount to shift to normalise the fixed-point number

    always @(*) begin
        // Handle the special case of zero input
        if (fixed_point == 0) begin
            single = 32'b0;
        end else begin
            // Initialise shift amount
            shift_amount = 0;

            // Find the position of the most significant 1 (normalize the fixed-point number)
            if (fixed_point[(INT_WIDTH + FRACT_WIDTH - 1)] == 0) begin
                for (shift_amount = 0; shift_amount < (INT_WIDTH + FRACT_WIDTH); shift_amount = shift_amount + 1) begin
                    if (fixed_point[(INT_WIDTH + FRACT_WIDTH - 1) - shift_amount] == 1'b1) begin
                        break;
                    end
                end
            end

            normalised = fixed_point << shift_amount;

            // Calculate exponent using bias of 127
            exponent = 127 + ((INT_WIDTH - 1) - shift_amount);

            // Extract mantissa (drop the leading 1 and shift left by the fractional bit count)
            mantissa = normalised[(INT_WIDTH + FRACT_WIDTH - 2):0] << (23 - (INT_WIDTH + FRACT_WIDTH - 1));

            // Assemble IEEE 754 single-precision float
            single = {1'b0, exponent, mantissa[22:0]};
        end
    end

endmodule