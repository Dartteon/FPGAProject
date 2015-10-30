`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS
// Engineer: Baron Chan
// 
// Create Date:
// Design Name: 
// Module Name: FSM_inc_dec
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


module FSM_inc_dec(
    
    input CLK_MAIN,
    
    input btnL_DB,                  // debounced inputs
    input btnR_DB,
    
    output reg [1:0] ctrl            
        // FSM outputs a 2-bit control signal
        //      00 -- do nothing
        //      01 -- increment CLK_SUBSAMPLE_ID
        //      10 -- decrement CLK_SUBSAMPLE_ID
    
    );
    
    reg[1:0] state = 0; 
    reg[1:0] nextState;
    parameter hold = 2'b00;
    parameter increase = 2'b10;
    parameter decrease = 2'b01;

    always @ (*) begin
            case(state)
                hold: 
                    nextState = (btnL_DB) ? decrease : ((btnR_DB) ? increase : hold);
                increase: 
                    if (btnR_DB)
                        nextState =  increase;
                     else
                        nextState = hold;
                decrease: 
                    if (btnL_DB)
                        nextState =  decrease;
                    else
                        nextState = hold;
            endcase
    end
    
    always @ (posedge CLK_MAIN) begin
        state <= nextState;
        ctrl <= nextState;
    end

endmodule





