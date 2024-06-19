//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2024 15:14:07
// Design Name: 
// Module Name: fastInvSqrt
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


module fastInvSqrt #(
    parameter INT_WIDTH = 12,      // Number of integer bits
    parameter FRACT_WIDTH = 4       // Number of fractional bits 
    )
    (    
    input wire clk,
    input wire rst,
    input wire [15:0] data_in,
    input wire valid_in,
    output reg ready_in,
    output reg [15:0] data_out,
    output reg valid_out,
    input wire ready_out
    
//    // Debug internal registers
//    ,
//    output reg [INT_WIDTH+FRACT_WIDTH-1:0] x_half,
//    output reg [31:0] x_single,
//    output reg [31:0] y0_single,
//    output reg [INT_WIDTH+FRACT_WIDTH-1:0] y0_fix,
//    output reg [INT_WIDTH+FRACT_WIDTH-1:0] y,
//    output reg [INT_WIDTH+FRACT_WIDTH-1:0] data_in_fixToSingle,
//    output reg [31:0] data_in_singleToFix
    );
    
    localparam WORD_WIDTH = INT_WIDTH + FRACT_WIDTH;
    
    // Internal signals
    reg [WORD_WIDTH-1:0] x_half;
    (* keep = "true" *) wire [31:0] x_single;
    reg [31:0] y0_single;
    wire [WORD_WIDTH-1:0] y0_fix;
    wire [WORD_WIDTH-1:0] y;
    
    // ---- Fixed point to EEE754 Single prescion Converter ----
    (* keep = "true" *) reg [WORD_WIDTH-1:0] data_in_fixToSingle;
    
    fixToSingle #(
        .INT_WIDTH(INT_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH)
    ) fixToSingle_inst (
        .fixed_point(data_in_fixToSingle),
        .single(x_single)
    );
    
    // ---- EEE754 Single prescion to fixed point Converter ----
    reg [31:0] data_in_singleToFix;

    singleToFix #(
        .INT_WIDTH(INT_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH)
    ) singleToFix_inst (
        .single(data_in_singleToFix),
        .fixed_point(y0_fix)
    );
    
    // ---- Newton-Raphson Logic ----
    newtonRaphson newt_raph_inst(
        .y0(y0_fix),
        .x_half(x_half),
        .y(y)
    );
    
    // State machine states
    typedef enum reg [2:0] {
        IDLE,
        FIX_TO_SINGLE,
        BIT_HACK,
        SINGLE_TO_FIX,
        DONE
    } state_t;
    state_t state, next_state;
    
    // Sequential logic for state transition
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
     always @ (*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (valid_in && ready_in) next_state = FIX_TO_SINGLE;
            end
            FIX_TO_SINGLE: begin
                next_state = BIT_HACK;
            end
            BIT_HACK: begin
                next_state = SINGLE_TO_FIX;
            end
            SINGLE_TO_FIX: begin
                next_state = DONE;
            end
            DONE: begin
                if (ready_out) next_state = IDLE;
            end
        endcase
    end
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            x_half <= 16'b0;    // Reset registers
            y0_single <= 32'b0;
              
            ready_in <= 1'b0;     // Invalidate and clear module outputs
            valid_out <= 1'b0;
            data_out <= 16'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    ready_in <= 1'b1;   // Set ready_in flag
                    valid_out <= 1'b0;   // De-assert valid out 
                end
                FIX_TO_SINGLE: begin
                    ready_in <= 1'b0;   // De-assert ready_in flag
                    
					x_half <= data_in >> 1; // Compute x_half with logical bit shift right
                    data_in_fixToSingle <= data_in; // Convert input to single prescion FP
                end
                BIT_HACK: begin
                    y0_single <= 32'h5f3759df - (x_single >> 1);  // Integer subtract to compute y0 in single EEE754 representation
                end
                SINGLE_TO_FIX: begin
                    data_in_singleToFix <= y0_single;
                end
                DONE: begin
                    if (ready_out) begin    // Set and validate output when ready out asserted
                        data_out <= y;  
                        valid_out <= 1'b1;
                    end
                end
            endcase
        end
    end
    
endmodule
