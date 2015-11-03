`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2015 09:45:59 AM
// Design Name: 
// Module Name: DigitDrawer
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


module DigitDrawer(
    input [3:0] number,
    input [1:0] colNum,
    output reg [4:0] out
    );
    
    always @ (number) begin
    case (number)
        4'd0:
                case (colNum)
                    2'b00: out <= 5'b11111;
                    2'b01: out <= 5'b10001;
                    2'b10: out <= 5'b11111;
                endcase
        4'd1:
                case (colNum)
                    2'b00: out <= 5'b01001;
                    2'b01: out <= 5'b11111;
                    2'b10: out <= 5'b00001;
                endcase
        4'd2:
                case (colNum)
                    2'b00: out <= 5'b10111;
                    2'b01: out <= 5'b10101;
                    2'b10: out <= 5'b11101;
                endcase
        4'd3:
                case (colNum)
                    2'b00: out <= 5'b10101;
                    2'b01: out <= 5'b10101;
                    2'b10: out <= 5'b11111;
                endcase
        4'd4:
                case (colNum)
                    2'b00: out <= 5'b11100;
                    2'b01: out <= 5'b00100;
                    2'b10: out <= 5'b11111;
                endcase
        4'd5:
                case (colNum)
                    2'b00: out <= 5'b11101;
                    2'b01: out <= 5'b10101;
                    2'b10: out <= 5'b10111;
                endcase
        4'd6:
                case (colNum)
                    2'b00: out <= 5'b11111;
                    2'b01: out <= 5'b10101;
                    2'b10: out <= 5'b10111;
                endcase
        4'd7:
                case (colNum)
                    2'b00: out <= 5'b10000;
                    2'b01: out <= 5'b10000;
                    2'b10: out <= 5'b11111;
                endcase
        4'd8:
                case (colNum)
                    2'b00: out <= 5'b11111;
                    2'b01: out <= 5'b10101;
                    2'b10: out <= 5'b11111;
                endcase
        4'd9:
                case (colNum)
                    2'b00: out <= 5'b11101;
                    2'b01: out <= 5'b10101;
                    2'b10: out <= 5'b11111;
                endcase
        
        
    endcase
    end    
    
endmodule
