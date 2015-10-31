`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2015 11:00:11 AM
// Design Name: 
// Module Name: DISPLAY_DIGIT_COLUMN
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


module DISPLAY_DIGIT_COLUMN(
    );
    
    always @ (num) begin
        case (num) begin
            
            5d'0: begin
                case (colNumber) begin
                    0: out <= 4b'01111110;
                    1: out <= 4b'01000010;
                    2: out <= 4b'01000010;
                    3: out <= 4b'01000010;
                    4: out <= 4b'01000010;
                    5: out <= 4b'01000010;
                    6: out <= 4b'01000010;
                    7: out <= 4b'01111110;
                end
            end
        end
    end
    
endmodule
