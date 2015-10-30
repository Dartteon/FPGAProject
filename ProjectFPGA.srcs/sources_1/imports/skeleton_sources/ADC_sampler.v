`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS ECE
// Engineer: Shahzor Ahmad, Chua Dingjuan
// 
// Create Date: 25.09.2015 17:05:09
// Design Name: 
// Module Name: ADC_sampler
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


module ADC_sampler(
    
    input CLK,
    
    input vauxp6,
    input vauxn6,
//    input vauxp7,
//    input vauxn7,
    
    output reg [7:0] ADC_SAMPLE

    );
    
    wire enable;  
    wire ready;
    wire [15:0] data;       // xadc_wiz_0.v defines it to be 16-bit so we must follow the module def, otherwise 12-bits would have done
    wire [6:0] Address_in;   // address of data register to retrieve     
       
   //Instantiation of xadc ( connect the eoc_out .den_in to get continuous conversion)
   xadc_wiz_0  XLXI_7 (
                     .daddr_in(Address_in), //addresses can be found in the artix 7 XADC user guide DRP register space
                     .dclk_in(CLK), // 100MHz 
                     .den_in(enable), 
                     .di_in(15'b0), // unused, tie to 0 
                     .dwe_in(15'b0), // unused, tie to 0 
                     .busy_out(),                    
                     .vauxp6(vauxp6),
                     .vauxn6(vauxn6),
//                     .vauxp7(vauxp7),
//                     .vauxn7(vauxn7),
                     .vn_in(1'b0), 
                     .vp_in(1'b0), 
                     .alarm_out(), 
                     .do_out(data), 
                     .eos_out(),
                     .eoc_out(enable),
                     .channel_out(),
                     .drdy_out(ready));
    
// With DCLK = CLK100MHz, and DCLK divider set to 4 (config register 2), ADCCLK = 961.5 ksps
// inv(inv(100M/4)*26) 
// note 26 ADCCLK cycles are required to acquire an analog signal and perform a conversion
    
           
    //Setting DRP Register for use of ADC
//    always @(posedge(CLK))
//          begin
//              Address_in <= 8'h16;  // for VAUXP[6]/VAUXN[6] channel                                                    
//          end
  
    assign  Address_in = 8'h16;  // for VAUXP[6]/VAUXN[6] channel            
  
         
     // output data    
     always @( posedge(CLK))
        begin
             if(ready == 1'b1)
                begin
                    ADC_SAMPLE <= data[15:8] ; 
                        // 12-bit ADC output appears in the 16-bit reg 'data', MSB justified
                        // we employ only the 8 MSbs
                end
        end 
    
endmodule


















