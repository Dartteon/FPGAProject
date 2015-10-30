`timescale 1ns / 1ps

module singlePulseCircuit(input CLOCK, input PUSHBUTTON, output singlePulse);
    
    reg Q1, Q2;
    
    always @ (posedge CLOCK) begin
            Q1 <= PUSHBUTTON;
            Q2 <= Q1;
        
    end
    
    assign singlePulse = Q1 & ~Q2;
    
endmodule
