`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2015 03:11:45 PM
// Design Name: 
// Module Name: switch_debouncer_fast
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


module switch_debouncer_fast(
    input CLK,
    input BTN_IN,    // input button status
    output BTN_DB    // debounced button status
    );
    
    parameter on = 1;
    parameter idle = 0;
    reg currentState = idle;
    reg [22:0] COUNT = 0;
    
    always @ (posedge CLK) begin
        case (currentState)
            on:
                begin
                    COUNT <= (BTN_IN) ? (COUNT+1) : 0;
                    currentState <= idle;
                end
                
            idle:
                begin
                    COUNT <= (BTN_IN && ~COUNT[22]) ? (COUNT+1) : 0;
                    currentState <= ((BTN_IN) && (COUNT==0 || COUNT[22])) ? on : idle;
                end
        endcase
    end
    
    assign BTN_DB = currentState;
endmodule