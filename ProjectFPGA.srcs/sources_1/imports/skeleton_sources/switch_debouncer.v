`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS
// Engineer: Baron Chan
// 
// Create Date:
// Design Name: 
// Module Name: switch_debouncer
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


module switch_debouncer(
    input CLK,
    input BTN_IN,    // input button status
    output BTN_DB    // debounced button status
    );
    
    parameter on = 1;
    parameter idle = 0;
    reg currentState = idle;
    reg [26:0] COUNT = 0;
    
    always @ (posedge CLK) begin
        case (currentState)
            on:
                begin
                    COUNT <= (BTN_IN) ? (COUNT+1) : 0;
                    currentState <= idle;
                end
                
            idle:
                begin
                    COUNT <= (BTN_IN && ~COUNT[26]) ? (COUNT+1) : 0;
                    currentState <= ((BTN_IN) && (COUNT==0 || COUNT[26])) ? on : idle;
                end
/*
                if (BTN_IN) begin 
                    if (COUNT == 0) begin
                        currentState <= on;
                        COUNT <= COUNT+1;
                    end
                    else if (COUNT[26]) begin
                        currentState <= on;
                        COUNT <= 0;
                    end
                    else begin
                        COUNT <= COUNT+1;
                    end
                end
                
                else begin
                    COUNT <= 0;
                end
*/
        endcase
    end
    
    assign BTN_DB = currentState;
endmodule














