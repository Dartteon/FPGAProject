`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS ECE
// Engineer: Shahzor Ahmad
// 
// Create Date: 24.09.2015 22:26:45
// Design Name: 
// Module Name: test_switch_debouncer
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


module test_switch_debouncer(
    );
    
    // inputs 
    reg CLK ;
    reg SW_IN ;
    
    // outputs 
    wire SW_DB ;
    
    // instantiate DUT
    switch_debouncer dut( CLK, SW_IN, SW_DB  ) ;
    
    // generate 
    always
        begin
            CLK = 1 ; #5 ; // CLK is then inv(2 * 5 * 1ns) = 100MHz
            CLK = 0 ; #5 ;        
        end
        
    // generate stimuli
    initial 
        begin
            SW_IN = 0 ; #10 ; // wait for 10 clock cycles
            SW_IN = 1 ; #10 ; 
            SW_IN = 0 ; #10 ; 
            SW_IN = 1 ; 
            

                // now let it run to debounce the input
        end   

    
endmodule
