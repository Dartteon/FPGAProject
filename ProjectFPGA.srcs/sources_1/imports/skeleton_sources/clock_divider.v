`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS ECE
// Engineer: Shahzor Ahmad
// 
// Create Date: 22.09.2015 19:55:16
// Design Name: 
// Module Name: clock_divider
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


module clock_divider(

    input CLK_IN,
    input RESET,
    input [27:0] LOAD_VALUE, // for an input clock of 100MHz, output of 1Hz, the value is 0x2FAF07F which needs 28 bits to accomodate
        // (100 MHz / 1 Hz) = 10^8 'ticks' need to be made
        // => LOAD_VALUE = 10^8/2 = 50,000,000 = 0x2FAF080
        
    output CLK_OUT 
    
    );
    
    reg[27:0] counter_for_clk_div = 0 ;    
    reg CLK_DIVIDED = 0 ;
    
    always@(posedge CLK_IN)
        if( RESET | (counter_for_clk_div == 0) )
            begin
                counter_for_clk_div <= LOAD_VALUE - 1 ;
                CLK_DIVIDED <= !CLK_DIVIDED ;
            end
        else
            counter_for_clk_div <= counter_for_clk_div - 1 ;
    
    assign CLK_OUT = CLK_DIVIDED ;
    
    
endmodule












