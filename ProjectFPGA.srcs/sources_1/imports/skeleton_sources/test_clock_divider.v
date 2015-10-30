`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS ECE
// Engineer: Shahzor Ahmad   
// 
// Create Date: 22.09.2015 20:27:41
// Design Name: 
// Module Name: test_clock_divider
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


module test_clock_divider(
    );
    
    // inputs 
    reg CLK_IN ;
    reg RESET ;
    reg [27:0] LOAD_VALUE ;
    
    // outputs 
    wire CLK_OUT ;
    
    // instantiate DUT
    clock_divider dut( CLK_IN, RESET, LOAD_VALUE, CLK_OUT ) ;
    
    // generate CLK_IN
    always
        begin
            CLK_IN = 1 ; #500000 ; // CLK_IN is then inv(2 * 500,000 * 1ns) = 1khz
            CLK_IN = 0 ; #500000 ;        
        end
        
    // generate stimuli
    initial 
        begin
            RESET = 0 ; #5000000 ; // wait for 5 clock cycle (5ms)
            LOAD_VALUE = 28'H5 ; RESET = 1; #1000000 ; // wait for 1 clock cycle (1ms)
            RESET = 0 ; #2000000 ; // wait for 2 clock cycle (5ms)
            
            RESET = 1; #1000000 ; // wait for 1ms
            RESET = 0 ;
                // now let it run to generate a CLK_OUT of 100Hz
        end   
    
endmodule















