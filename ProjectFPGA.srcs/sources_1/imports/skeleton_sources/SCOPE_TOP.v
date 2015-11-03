`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS ECE
// Engineer: Shahzor Ahmad
// 
// Create Date: 02.10.2015 14:31:19
// Design Name: 
// Module Name: SCOPE_TOP
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


module SCOPE_TOP(

    input CLK,                  // main system clock, 100MHz
        
    input btnL,                 // decrease clock sampling rate
    input btnR,                 // increase clock sampling rate
    input btnU,
    input btnD,
    input btnC,
    
    input sw0,                  // special feature 1: point joiner to align points
    input sw1,                  // special feature 2: triggering
    input sw2,                  // special feature 3: RAINBOWS
    input sw3,                  //special feature 4: aim mode
    
    //special feature 6: Grid Color
    input sw13,
    input sw14,
    input sw15,
    
    //special feature 5: Background Color
    input sw10,
    input sw11,
    input sw12,
    
    input ADC_IN_P,             // differential +ve & -ve analog inputs to ADC
    input ADC_IN_N,  
     
    output reg[3:0] VGA_RED,    // RGB outputs to VGA connector (4 bits per channel gives 4096 possible colors)
    output reg[3:0] VGA_GREEN,
    output reg[3:0] VGA_BLUE,
    output reg VGA_VS,          // horizontal & vertical sync outputs to VGA connector
    output reg VGA_HS,
    
    output [11:0] led           // debug LEDs    
    
    );   
         
    //-------------------------------------------------------------------------
    
    wire CLK_MAIN = CLK ;   // this is just a renaming (simply a short-circuit, or two names for the same trace/route)           
       
        
    //-------------------------------------------------------------------------
    
    //         INSTANTITATE EXTERNAL MODULES FOR VGA CONTROL
    
    // Note the VGA controller is configured to produce a 1024 x 1280 pixel resolution
    //-------------------------------------------------------------------------
    
    // PIXEL CLOCK GENERATOR 
    wire CLK_VGA ;          // pixel/VGA clock is generated by MMCM/PLL via external VHDL code (108MHz)    
    clk_wiz_0 PIXEL_CLOCK_GENERATOR( 
            CLK_MAIN,   // 100 MHz
            CLK_VGA     // 108 MHz
        ) ;     
    
    
    // VGA SIGNALS (as output by VGA controller (vga_ctrl.vhd))
    wire VGA_horzSync ;
    wire VGA_vertSync ;
    wire VGA_active ;
    wire[11:0] VGA_horzCoord ;
    wire[11:0] VGA_vertCoord ;
        // it is not required but good practice to declare single-bit wires
        // it is required to declare multi-bit wires (bus) before use    
    
    // VGA CONTROLLER    
    vga_ctrl VGA_CONTROLLER(
            CLK_VGA,
            VGA_horzSync,
            VGA_vertSync,
            VGA_active,  
            VGA_horzCoord,  
            VGA_vertCoord  
        ) ; 
        // - VGA_horzCoord changes at a rate of 108 MHz (CLK_VGA) to traverse each pixel in a row, while VGA_vertCoord changes at a rate of ~63.98 KHz to 
        // scan each row one by one and back to the top. These tech details are handled by vga_ctrl.vhd. One only needs to make use of these coordinates 
        // to output whatever they want at desired pixel locations. 
        // 
        // - VGA_active is a binary indicator specifying when VGA_horzCoord, VGA_vertCoord are valid (i.e., with the 1024 x 1280 pixel screen). For technical 
        // reasons the said coordinates do go outside this screen area for a short while and no VGA signal should be output during this time (it will and does
        // mess up the display). 
        //
        // - hence, VGA_active, VGA_horzCoord and VGA_vertCoord may be used in conjunction with each other to generate VGA_RED, VGA_GREEN, VGA_BLUE. The Sync
        // signals should be output to the VGA port as well, and are responsible to generate the raster scan on the screen       


    //-------------------------------------------------------------------------
                                    
    //                      SAMPLING VIA ADC 
    
    // On-chip ADC is clocked at [ inv(inv(CLK_ADC/4)*26) = 961.538 KHZ ], 
    // where CLK_ADC is the clock passed to ADC (in this case CLK_ADC = CLK_MAIN = 100MHz)
    
    // The on-chip ADC is 12-bit. We employ the most significant 8 bits to keep things simple
    
    //-------------------------------------------------------------------------


    wire [7:0] ADC_SAMPLE ; // the latest value as sampled via ADC
    ADC_sampler SAMPLER( CLK_MAIN, ADC_IN_P, ADC_IN_N, ADC_SAMPLE ) ; // sampling at 961.538 KHZ
    
        // Either lines # 104-105 OR lines # 129-136 should be used at a time

    
    assign led[7:0] = ADC_SAMPLE ; 
        // the sampled 8-bit value reflects on 8 LEDs. Every time ADC_SAMPLE changes 
        // (and that happens at 961.538KHz!), this assignment is triggered again 
    
   
    //-------------------------------------------------------------------------
                                        
    //                  SIMULATE SAMPLING VIA ADC 
    
    // In the absence of a signal generator (e.g., when working at home), you may use 
    // the following code instead of the above, i.e., COMMENT out lines # 104-105, 
    // UN-COMMENT lines # 129-136
    
    // A square wave at 1Hz is generated via a clock-divider module, and serves as our 
    // 'analog' signal to be sampled.
    //-------------------------------------------------------------------------
/*
    wire CLK_SYNTH_SQUARE ; 
    clock_divider GEN_CLK_SYNTH_SQUARE( CLK_MAIN, 1'b0, 28'H2FAF080, CLK_SYNTH_SQUARE ) ; 
        // Synthesize a 1Hz waveform given 100MHz clock          

    reg [7:0] ADC_SAMPLE ; // the latest value as sampled via ADC
    always@(posedge CLK_MAIN) // sample the synthesized waveform at 100 MHz
        begin
            if( CLK_SYNTH_SQUARE )
                ADC_SAMPLE <= 255 ;
            else
                ADC_SAMPLE <= 0 ;        
        end   
     
     assign led[7:0] = ADC_SAMPLE ; 

     // this LED blinks at 1 Hz (just for visualization)
     reg LED_DEBUG = 0 ;
        // signals on LHS of assignments in 'always' blocks must be declared as reg before use
     always@(posedge CLK_SYNTH_SQUARE)
        begin
            LED_DEBUG <= !LED_DEBUG ;
        end
     assign led[8] = LED_DEBUG ; 
 */    
               
    //-------------------------------------------------------------------------
                                    
    //        SELECTING SAMPLING FREQUENCY (ESSENTIALLY, TIME/DIV)
    
    // this configures the CLK_SUBSAMPLE (fs)
    
    // NOTE: currently CLK_SUBSAMPLE_ID has been hard-coded to 0, and no provision
    // is made to modify it at FPGA run-time
    //-------------------------------------------------------------------------
   
    reg [2:0] CLK_SUBSAMPLE_ID = 0 ; 
        
    reg [27:0] LOAD_VALUE_SUBSAMPLE ;
        // we generate CLK_SUBSAMPLE from CLK_MAIN 
    
    
    always@(posedge CLK_MAIN)
        case(CLK_SUBSAMPLE_ID)
            0:  LOAD_VALUE_SUBSAMPLE <= 28'd500000 ;    // CLK_SUBSAMPLE = 100 Hz => TIME/DIV = 0.8 sec/div
            1:  LOAD_VALUE_SUBSAMPLE <= 28'd125000 ;    // CLK_SUBSAMPLE = 400 Hz => TIME/DIV = 0.2 sec/div 
            2:  LOAD_VALUE_SUBSAMPLE <= 28'd62500 ;     // CLK_SUBSAMPLE = 800 Hz => TIME/DIV = 0.1 sec/div
            3:  LOAD_VALUE_SUBSAMPLE <= 28'd50000 ;     // CLK_SUBSAMPLE = 1 KHz => TIME/DIV = 
            4:  LOAD_VALUE_SUBSAMPLE <= 28'd31250 ;     // CLK_SUBSAMPLE = 1600 Hz => TIME/DIV = 50 ms/div 
            5:  LOAD_VALUE_SUBSAMPLE <= 28'd6250 ;      // CLK_SUBSAMPLE = 8 KHz => TIME/DIV = 10 ms/div 
            6:  LOAD_VALUE_SUBSAMPLE <= 28'd625 ;       // CLK_SUBSAMPLE = 80 KHz => TIME/DIV = 1 ms/div      
            7:  LOAD_VALUE_SUBSAMPLE <= 28'd62 ;        // CLK_SUBSAMPLE = 806.451 KHz => TIME/DIV = 0.0992 ms/div 
        endcase
            // Each LOAD_VALUE_SUBSAMPLE defines the stated CLK_SUBSAMPLE (sampling frequency fs). 
            // The TIME/DIV values, however, assume the 1280 horizontal pixels on the screen are divided into 16 equal DIVISIONS of 80 px each 
                      
    
    wire CLK_SUBSAMPLE ;    // sub-sampling rate for ADC output samples
                            // It essentially defines time/div 
                            
                            // Use CLK_SUBSAMPLE to clock your bank of shift registers below
                            // Use CLK_SUBSAMPLE to clock your trigger process if you implement one   
                            
                            // For all practical purposes, this can be taken to be our fs (sampling frequency) as described in the manual
                            // We could have modified ADC sampling frequency, but give the long formula to dervie it from CLK_MAIN (see line 96),
                            // we're better off sub-sampling to achieve flexible sampling frequencies and corresponding time/div configurations
                                                        
                                                     
    clock_divider GEN_CLK_SUBSAMPLE( CLK_MAIN, 1'b0, LOAD_VALUE_SUBSAMPLE, CLK_SUBSAMPLE ) ;
        // note as many times you instantiate a module in HDL, that many times it will replicate the actual hardware on the FPGA 
        // so there are two physical clock_divider circuits in our design    
    
    switch_debouncer BTNL_DEBOUNCER( CLK_MAIN, btnL, btnL_DB ) ;
    switch_debouncer BTNR_DEBOUNCER( CLK_MAIN, btnR, btnR_DB ) ;
        // you may implement debounce in switch_debouncer.vhd as an extension feature
    
    
    wire [1:0] ctrl ; 
    reg [1:0] testCtrl;
    
 //   FSM_inc_dec FSM1( CLK_MAIN, btnL, btnR, ctrl ) ;        // use if you don't implement debounce, but would like to write an FSM
    FSM_inc_dec FSM1( CLK_MAIN, btnL_DB, btnR_DB, ctrl ) ;  // use if you've implemented debounce, and now would also like to implement FSM
        // you may implement a FSM in FSM_inc_dec.vhd as an extension feature
        // This FSM should output a 2-bit control signal
        //      00 -- do nothing
        //      01 -- increment CLK_SUBSAMPLE_ID
        //      10 -- decrement CLK_SUBSAMPLE_ID

 //   assign ctrl = 0 ; // remove this if you implement your FSM

    // this process increments / decrements CLK_SUBSAMPLE_ID depending on ctrl        
    /*
    always@(posedge CLK_MAIN)
        begin
            if( ctrl == 2'b01 )begin
                CLK_SUBSAMPLE_ID = CLK_SUBSAMPLE_ID + 1 ;
                testCtrl = ctrl;
            end
            else if (ctrl == 2'b10)begin
                CLK_SUBSAMPLE_ID = CLK_SUBSAMPLE_ID - 1 ;
                testCtrl = ctrl;
            end
        end
 */
     always@(posedge CLK_MAIN)
            begin
                if( ctrl == 2'b10 && CLK_SUBSAMPLE_ID < 7) begin
                    CLK_SUBSAMPLE_ID = CLK_SUBSAMPLE_ID + 1 ;
                    testCtrl = ctrl;
                end
                else if ( ctrl == 2'b01  && CLK_SUBSAMPLE_ID > 0) begin
                    CLK_SUBSAMPLE_ID = CLK_SUBSAMPLE_ID - 1 ;
                    testCtrl = ctrl;
                end
            end    

    assign led[11:9] = CLK_SUBSAMPLE_ID ;  
        // leds[11:9] provide a visual indication of CLK_SUBSAMPLE_ID at all times    
  
    
    //-------------------------------------------------------------------------
                                    
    //               UPDATE DISPLAY_MEM @ CLK_SUBSAMPLE
    
    // DISPLAY_MEM is a bank of 1280 shift registers
    //
    // shift all samples one position to the left in memory, and  
    // store the latest ADC sample in the right/left most position    
    //-------------------------------------------------------------------------

    reg [7:0] DISPLAY_MEM[0:1279] ; 
    reg [7:0] TEMP_MEM[0:1279];
        // display memory - store samples here and output them on screen
   // DISPLAY_MEM = 
    // TOOD:    implement Verilog here that treats DISPLAY_MEM as a bank of 
    //          1280 shift registers, each 8-bit wide. The latest sample should 
    //          be stored in the right (or left)-most register, while contents of
    //          all the other registers should be shifted to the neighboring register
    //          on the right (respectively, left). 
    //          
    //          This process of bringing in a new sample from the right/left while 
    //          shifting all the other samples should be done in a single clock cycle 
    //          (use CLK_SUBSAMPLE)

    //To adjust trigger levels
    reg [8:0] triggerLevel = 128;
    switch_debouncer_fast BTNU_DEBOUNCER( CLK_MAIN, btnU, btnU_DB ) ;
    switch_debouncer_fast BTND_DEBOUNCER( CLK_MAIN, btnD, btnD_DB ) ;
    always @ (posedge CLK) begin
        if (!sw3 && btnU_DB)
            triggerLevel <= triggerLevel + 1;
        else if (!sw3 && btnD_DB)
            triggerLevel <= triggerLevel - 1;
    end
    wire CONDITION_FOR_TRIGGER_LINE = (sw1 && (VGA_horzCoord%2==0) && (VGA_vertCoord == ((511+128) - triggerLevel))) ? 1 : 0;
    wire[3:0] VGA_TRIGGER_LINE = CONDITION_FOR_TRIGGER_LINE ? 4'h7 : 0 ;
    
    
    
    
    
    
    integer i;
    always @ (posedge CLK_SUBSAMPLE) begin
        TEMP_MEM[1279] <= ADC_SAMPLE;
        for (i=1; i<1279; i=i+1)
            TEMP_MEM[i] <= TEMP_MEM[i+1];
        
        if (!sw1) begin
            for (i=1; i<1279; i=i+1)
                DISPLAY_MEM[i] <= TEMP_MEM[i];
        end
        
        else if (sw1) begin
            //if (ADC_SAMPLE == triggerLevel && ADC_SAMPLE > TEMP_MEM[1279]) begin
            if (TEMP_MEM[1279]>=triggerLevel && TEMP_MEM[1278]<triggerLevel) begin
                for (i=0; i<=1279; i=i+1)
                    DISPLAY_MEM[i] <= TEMP_MEM[i];
            end
        end
    end
       
    //-------------------------------------------------------------------------
                
    //                  DRAWING WAVEFORM ON SCREEN
    
    // waveform is drawn using its samples from display memory
    //-------------------------------------------------------------------------       
           
    wire[3:0] VGA_GREEN_WAVEFORM = (sw0) ?
                ((((VGA_horzCoord < 1280) & (VGA_vertCoord == ((511+128) - DISPLAY_MEM[VGA_horzCoord]))) 
                || ((DISPLAY_MEM[VGA_horzCoord] > DISPLAY_MEM[VGA_horzCoord-1]) ? 
                    ((((VGA_vertCoord > ((511+128) -DISPLAY_MEM[VGA_horzCoord]))) &&  ((VGA_vertCoord < ((511+128) -DISPLAY_MEM[VGA_horzCoord-1])))  ) ? 1:0 ) : 0)
                || ((DISPLAY_MEM[VGA_horzCoord] > DISPLAY_MEM[VGA_horzCoord+1]) ? 
                    ((((VGA_vertCoord > ((511+128) -DISPLAY_MEM[VGA_horzCoord]))) &&  ((VGA_vertCoord < ((511+128) -DISPLAY_MEM[VGA_horzCoord+1])))  ) ? 1:0 ) : 0)
                ) ? 4'hF : 0 )
                    
                    :
                (((VGA_horzCoord < 1280) & (VGA_vertCoord == ((511+128) - DISPLAY_MEM[VGA_horzCoord]))) ? 4'hF : 0 );
                  
        
    //-------------------------------------------------------------------------
        
    //                  DRAWING GRID LINES ON SCREEN
    
    // Grid lines are drawn at pixels # 320, 640, 960 along the x-axis, and
    // pixels # 256, 512, 768 along the y-axis
    
    // Note the VGA controller is configured to produce a 1024 x 1280 pixel resolution
    //-------------------------------------------------------------------------
            
//    wire CONDITION_FOR_GRID = (VGA_horzCoord == 319) || (VGA_horzCoord == 639) || (VGA_horzCoord == 959) ||
 //                   (VGA_vertCoord == 255) || (VGA_vertCoord == 511) || (VGA_vertCoord == 767) ;
    wire CONDITION_FOR_GRID = (VGA_horzCoord%80 == 0 
                                || VGA_vertCoord%64 == 0 
                                || ((VGA_vertCoord%8) == 0 && ((VGA_horzCoord == 639) || (VGA_horzCoord == 641)))
                                || ((VGA_horzCoord%16) == 0 && ((VGA_vertCoord == 511)  || (VGA_vertCoord == 513)))
                                );
    
    wire[3:0] VGA_RED_GRID = CONDITION_FOR_GRID ? ((sw15) ? 4'h7 : ((sw12) ? 4'h7 : 0)) : ((sw12) ? 4'h7 : 0) ;
    wire[3:0] VGA_GREEN_GRID = CONDITION_FOR_GRID ? ((sw14) ? 4'h7 : ((sw11) ? 4'h7 : 0)) : ((sw11) ? 4'h7 : 0) ;
    wire[3:0] VGA_BLUE_GRID = CONDITION_FOR_GRID ? ((sw13) ? 4'h7 : ((sw10) ? 4'h7 : 0)) : ((sw10) ? 4'h7 : 0) ;
    
        // if true, a black pixel is put at coordinates (VGA_horzCoord, VGA_vertCoord), 
        // else a cyan background is generated, characteristic of oscilloscopes! 
        
    // TOOD:    Draw grid lines at every 80-th pixel along the horizontal axis, and every 64th pixel
    //          along the vertical axis. This gives us a 16x16 grid on screen. 
    //          
    //          Further draw ticks on the central x and y grid lines spaced 16 and 8 pixels apart in the 
    //          horizontal and vertical directions respectively. This gives us 5 sub-divisions per division 
    //          in the horizontal and 8 sub-divisions per divsion in the vertical direction   
    
    
    //-------------------------------------------------------------------------
    
    //              SYNCHRONOUS OUTPUT OF VGA SIGNALS
    
    //-------------------------------------------------------------------------
    
    //Special feature 3: RAINBOWS
        wire CONDITION_FOR_RED_RAINBOW = 
            (sw2 && ((VGA_vertCoord > ((511+128) + 20 -DISPLAY_MEM[VGA_horzCoord]))) && ((VGA_vertCoord < ((511+128) + 80 -DISPLAY_MEM[VGA_horzCoord])))) ? 1 : 0;
        wire[3:0] VGA_RED_RAINBOW = CONDITION_FOR_RED_RAINBOW ? 4'h7 : 0 ;
        
        wire CONDITION_FOR_GREEN_RAINBOW =
            (sw2 && ((VGA_vertCoord > ((511+128) - 50 -DISPLAY_MEM[VGA_horzCoord]))) && ((VGA_vertCoord < ((511+128) + 50 -DISPLAY_MEM[VGA_horzCoord])))) ? 1 : 0;
        wire[3:0] VGA_GREEN_RAINBOW = CONDITION_FOR_GREEN_RAINBOW ? 4'h7 : 0 ;
        
        wire CONDITION_FOR_BLUE_RAINBOW =
            (sw2 && ((VGA_vertCoord > ((511+128) - 80 -DISPLAY_MEM[VGA_horzCoord]))) && ((VGA_vertCoord < ((511+128) - 20 -DISPLAY_MEM[VGA_horzCoord])))) ? 1 : 0;
        wire[3:0] VGA_BLUE_RAINBOW = CONDITION_FOR_BLUE_RAINBOW ? 4'h7 : 0 ;
        
    //-------------------------------------------------------------------------
    
    //Special feature 4: Targeting
    switch_debouncer BTNC_DEBOUNCER( CLK_MAIN, btnC, btnC_DB ) ;
    reg [1:0] currentTarget;
    
    reg [11:0] currentxPos = (640);
    reg [7:0] currentyPos = (540);
    
    reg [11:0] target1xPos = 0;
    reg [7:0] target1yPos = 0;
    
    reg [11:0] target2xPos = 0;
    reg [7:0] target2yPos = 0;
    
    reg [11:0] target3xPos = 0;
    reg [7:0] target3yPos = 0;
    
    reg [11:0] target4xPos = 0;
    reg [7:0] target4yPos = 0;
    
    always @ (posedge CLK) begin
        if (sw3) begin
            if (btnU_DB)
                currentxPos = currentxPos + 1;
            else if (btnD_DB)
                currentxPos = currentxPos - 1;
                
            currentyPos = DISPLAY_MEM[currentxPos];
            
            if (btnC_DB) begin
                case (currentTarget)
                    2'b00: begin
                        target1xPos <= currentxPos;
                        target1yPos <= currentyPos;
                    end
                    2'b01: begin
                        target2xPos <= currentxPos;
                        target2yPos <= currentyPos;
                    end
                    2'b10: begin
                        target3xPos <= currentxPos;
                        target3yPos <= currentyPos;
                    end
                    2'b11: begin
                        target4xPos <= currentxPos;
                        target4yPos <= currentyPos;
                    end
                endcase
                currentTarget <= currentTarget + 1;              
            end
        end
    end
    
    wire CONDITION_FOR_TARGET_CURRENT = (sw3 && ((VGA_vertCoord == ((511+128) - currentyPos)) || (VGA_horzCoord == currentxPos))) ? 1 : 0;
    wire[3:0] VGA_TARGET_CURRENT = CONDITION_FOR_TARGET_CURRENT ? 4'h7 : 0 ;
    //color: RED
    
    wire CONDITION_FOR_TARGET_1 = (sw3 && ((VGA_vertCoord == ((511+128) - target1yPos)) || (VGA_horzCoord == target1xPos))) ? 1 : 0 ;
    wire[3:0] VGA_TARGET_1 = CONDITION_FOR_TARGET_1 ? 4'h7 : 0 ;
    //color: BLUE + RED (purple)
    
    wire CONDITION_FOR_TARGET_2 = (sw3 && ((VGA_vertCoord == ((511+128) - target2yPos)) || (VGA_horzCoord == target2xPos))) ? 1 : 0 ;
    wire[3:0] VGA_TARGET_2 = CONDITION_FOR_TARGET_2 ? 4'h7 : 0 ;
    //color: BLUE + GREEN (cyan)
    
    wire CONDITION_FOR_TARGET_3 = (sw3 && ((VGA_vertCoord == ((511+128) - target3yPos)) || (VGA_horzCoord == target3xPos))) ? 1 : 0 ;
    wire[3:0] VGA_TARGET_3 = CONDITION_FOR_TARGET_3 ? 4'h7 : 0 ;
    //color: RED + GREEN (orange)
    
    wire CONDITION_FOR_TARGET_4 = (sw3 && ((VGA_vertCoord == ((511+128) - target4yPos)) || (VGA_horzCoord == target4xPos))) ? 1 : 0 ;
    wire[3:0] VGA_TARGET_4 = CONDITION_FOR_TARGET_4 ? 4'h7 : 0 ;
    //color: BLUE (orange)
    
//    reg [11:0] xBallPos = 640;
//    reg [11:0] yBallPos = 900;
    
//    always @ (CLK_SUBSAMPLE) begin
//        if (yBallPos > DISPLAY_MEM[xBallPos] + 10) begin
//            yBallPos <= yBallPos - 1;
//        end
//        else begin
//            if (xBallPos <1279 && DISPLAY_MEM[xBallPos] > DISPLAY_MEM[xBallPos+1]) begin
//                xBallPos <= xBallPos + 1;
//                yBallPos <= DISPLAY_MEM[xBallPos+1];
//            end
//            else if (xBallPos > 0 && DISPLAY_MEM[xBallPos] > DISPLAY_MEM[xBallPos-1]) begin
//                xBallPos <= xBallPos - 1;
//                yBallPos <= DISPLAY_MEM[xBallPos-1];
//            end
//        end
//    end
    
//    wire CONDITION_FOR_BALL =
//        (sw3 && (VGA_vertCoord > ((511+128) - 20 -yBallPos)) && (VGA_vertCoord < ((511+128) + 20 -yBallPos))
//            && (VGA_horzCoord > xBallPos - 20) && (VGA_horzCoord < xBallPos + 20)) ? 1 : 0;
//    wire[3:0] VGA_BALL = CONDITION_FOR_BALL ? 4'h7 : 0 ;
    
    //-------------------------------------------------------------------------
    
    //Special feature 5: DIGITS
    
    reg [3:0] firstDigit;
    reg [3:0] secondDigit;
    reg [3:0] thirdDigit;
    
    always @ (posedge CLK_SUBSAMPLE) begin
        firstDigit <= ((DISPLAY_MEM[currentxPos])/128);
        secondDigit <= (((DISPLAY_MEM[currentxPos])/13)%10);
        thirdDigit <= (((DISPLAY_MEM[currentxPos]))%10);
    end
    
    DigitDrawer digit1 (firstDigit, 0, firstDigitCol1);
    DigitDrawer digit2 (firstDigit, 1, firstDigitCol2);
    DigitDrawer digit3 (firstDigit, 2, firstDigitCol3);
    
    DigitDrawer digit4 (secondDigit, 0, secondDigitCol1);
    DigitDrawer digit5 (secondDigit, 1, secondDigitCol2);
    DigitDrawer digit6 (secondDigit, 2, secondDigitCol3);
    
    DigitDrawer digit7 (thirdDigit, 0, thirdDigitCol1);
    DigitDrawer digit8 (thirdDigit, 1, thirdDigitCol2);
    DigitDrawer digit9 (thirdDigit, 2, thirdDigitCol3);
    
    wire [4:0] firstDigitCol1;
    wire [4:0] firstDigitCol2;
    wire [4:0] firstDigitCol3;
    
    wire [4:0] secondDigitCol1;
    wire [4:0] secondDigitCol2;
    wire [4:0] secondDigitCol3;
    
    wire [4:0] thirdDigitCol1;
    wire [4:0] thirdDigitCol2;
    wire [4:0] thirdDigitCol3;
    
    wire CONDITION_FOR_DIGIT =
        (sw3 && (
        
           ((VGA_horzCoord == currentxPos-10) && (VGA_vertCoord >= ((511+128) - 314)) && (VGA_vertCoord <= ((511+128) - 311)))
        || ((VGA_horzCoord == currentxPos-9) && (VGA_vertCoord == ((511+128) - 310)))
        || ((VGA_horzCoord == currentxPos-8) && (VGA_vertCoord >= ((511+128) - 314)) && (VGA_vertCoord <= ((511+128) - 311)))
        
        || ((VGA_horzCoord >= currentxPos-5) && (VGA_horzCoord <= currentxPos-3) && ((VGA_vertCoord == ((511+128) - 311)) || (VGA_vertCoord == ((511+128) - 313))))
        
        || (firstDigitCol1[0] && (VGA_horzCoord == currentxPos+3) && ((VGA_vertCoord == ((511+128) - 310))))
        || (firstDigitCol1[1] && (VGA_horzCoord == currentxPos+3) && ((VGA_vertCoord == ((511+128) - 311))))
        || (firstDigitCol1[2] && (VGA_horzCoord == currentxPos+3) && ((VGA_vertCoord == ((511+128) - 312))))
        || (firstDigitCol1[3] && (VGA_horzCoord == currentxPos+3) && ((VGA_vertCoord == ((511+128) - 313))))
        || (firstDigitCol1[4] && (VGA_horzCoord == currentxPos+3) && ((VGA_vertCoord == ((511+128) - 314))))
        
        || (firstDigitCol2[0] && (VGA_horzCoord == currentxPos+4) && ((VGA_vertCoord == ((511+128) - 310))))
        || (firstDigitCol2[1] && (VGA_horzCoord == currentxPos+4) && ((VGA_vertCoord == ((511+128) - 311))))
        || (firstDigitCol2[2] && (VGA_horzCoord == currentxPos+4) && ((VGA_vertCoord == ((511+128) - 312))))
        || (firstDigitCol2[3] && (VGA_horzCoord == currentxPos+4) && ((VGA_vertCoord == ((511+128) - 313))))
        || (firstDigitCol2[4] && (VGA_horzCoord == currentxPos+4) && ((VGA_vertCoord == ((511+128) - 314))))
        
        || (firstDigitCol3[0] && (VGA_horzCoord == currentxPos+5) && ((VGA_vertCoord == ((511+128) - 310))))
        || (firstDigitCol3[1] && (VGA_horzCoord == currentxPos+5) && ((VGA_vertCoord == ((511+128) - 311))))
        || (firstDigitCol3[2] && (VGA_horzCoord == currentxPos+5) && ((VGA_vertCoord == ((511+128) - 312))))
        || (firstDigitCol3[3] && (VGA_horzCoord == currentxPos+5) && ((VGA_vertCoord == ((511+128) - 313))))
        || (firstDigitCol3[4] && (VGA_horzCoord == currentxPos+5) && ((VGA_vertCoord == ((511+128) - 314))))
        
        || ((VGA_horzCoord == currentxPos+8) && (VGA_vertCoord == ((511+128) - 310)))
        
        || (secondDigitCol1[0] && (VGA_horzCoord == currentxPos+11) && ((VGA_vertCoord == ((511+128) - 310))))
        || (secondDigitCol1[1] && (VGA_horzCoord == currentxPos+11) && ((VGA_vertCoord == ((511+128) - 311))))
        || (secondDigitCol1[2] && (VGA_horzCoord == currentxPos+11) && ((VGA_vertCoord == ((511+128) - 312))))
        || (secondDigitCol1[3] && (VGA_horzCoord == currentxPos+11) && ((VGA_vertCoord == ((511+128) - 313))))
        || (secondDigitCol1[4] && (VGA_horzCoord == currentxPos+11) && ((VGA_vertCoord == ((511+128) - 314))))
     
        || (secondDigitCol2[0] && (VGA_horzCoord == currentxPos+12) && ((VGA_vertCoord == ((511+128) - 310))))
        || (secondDigitCol2[1] && (VGA_horzCoord == currentxPos+12) && ((VGA_vertCoord == ((511+128) - 311))))
        || (secondDigitCol2[2] && (VGA_horzCoord == currentxPos+12) && ((VGA_vertCoord == ((511+128) - 312))))
        || (secondDigitCol2[3] && (VGA_horzCoord == currentxPos+12) && ((VGA_vertCoord == ((511+128) - 313))))
        || (secondDigitCol2[4] && (VGA_horzCoord == currentxPos+12) && ((VGA_vertCoord == ((511+128) - 314))))
     
        || (secondDigitCol3[0] && (VGA_horzCoord == currentxPos+13) && ((VGA_vertCoord == ((511+128) - 310))))
        || (secondDigitCol3[1] && (VGA_horzCoord == currentxPos+13) && ((VGA_vertCoord == ((511+128) - 311))))
        || (secondDigitCol3[2] && (VGA_horzCoord == currentxPos+13) && ((VGA_vertCoord == ((511+128) - 312))))
        || (secondDigitCol3[3] && (VGA_horzCoord == currentxPos+13) && ((VGA_vertCoord == ((511+128) - 313))))
        || (secondDigitCol3[4] && (VGA_horzCoord == currentxPos+13) && ((VGA_vertCoord == ((511+128) - 314))))
        
        
        
        || (thirdDigitCol1[0] && (VGA_horzCoord == currentxPos+16) && ((VGA_vertCoord == ((511+128) - 310))))
        || (thirdDigitCol1[1] && (VGA_horzCoord == currentxPos+16) && ((VGA_vertCoord == ((511+128) - 311))))
        || (thirdDigitCol1[2] && (VGA_horzCoord == currentxPos+16) && ((VGA_vertCoord == ((511+128) - 312))))
        || (thirdDigitCol1[3] && (VGA_horzCoord == currentxPos+16) && ((VGA_vertCoord == ((511+128) - 313))))
        || (thirdDigitCol1[4] && (VGA_horzCoord == currentxPos+16) && ((VGA_vertCoord == ((511+128) - 314))))
     
        || (thirdDigitCol2[0] && (VGA_horzCoord == currentxPos+17) && ((VGA_vertCoord == ((511+128) - 310))))
        || (thirdDigitCol2[1] && (VGA_horzCoord == currentxPos+17) && ((VGA_vertCoord == ((511+128) - 311))))
        || (thirdDigitCol2[2] && (VGA_horzCoord == currentxPos+17) && ((VGA_vertCoord == ((511+128) - 312))))
        || (thirdDigitCol2[3] && (VGA_horzCoord == currentxPos+17) && ((VGA_vertCoord == ((511+128) - 313))))
        || (thirdDigitCol2[4] && (VGA_horzCoord == currentxPos+17) && ((VGA_vertCoord == ((511+128) - 314))))
     
        || (thirdDigitCol3[0] && (VGA_horzCoord == currentxPos+18) && ((VGA_vertCoord == ((511+128) - 310))))
        || (thirdDigitCol3[1] && (VGA_horzCoord == currentxPos+18) && ((VGA_vertCoord == ((511+128) - 311))))
        || (thirdDigitCol3[2] && (VGA_horzCoord == currentxPos+18) && ((VGA_vertCoord == ((511+128) - 312))))
        || (thirdDigitCol3[3] && (VGA_horzCoord == currentxPos+18) && ((VGA_vertCoord == ((511+128) - 313))))
        || (thirdDigitCol3[4] && (VGA_horzCoord == currentxPos+18) && ((VGA_vertCoord == ((511+128) - 314))))
        )
        );
        
    wire[3:0] VGA_DIGIT = CONDITION_FOR_DIGIT ? 4'h7 : 0 ;
    
    //-------------------------------------------------------------------------
    
        //Special Feature 6: Volt Difference
    reg [3:0] diffFirstDigit;
    reg [3:0] diffSecondDigit;
    reg [3:0] diffThirdDigit;
    
   // wire currentDifference = DISPLAY_MEM[currentxPos] - DISPLAY_MEM[target1xPos];
    
    always @ (posedge CLK_SUBSAMPLE) begin
            diffFirstDigit <= ((DISPLAY_MEM[currentxPos] - DISPLAY_MEM[target1xPos])/128);
            diffSecondDigit <= (((DISPLAY_MEM[currentxPos] - DISPLAY_MEM[target1xPos])/13)%10);
            diffThirdDigit <= (((DISPLAY_MEM[currentxPos] - DISPLAY_MEM[target1xPos]))%10);
    end
        
        DigitDrawer digitA (diffFirstDigit, 0, diffFirstDigitCol1);
        DigitDrawer digitB (diffFirstDigit, 1, diffFirstDigitCol2);
        DigitDrawer digitC (diffFirstDigit, 2, diffFirstDigitCol3);
        
        DigitDrawer digitD (diffSecondDigit, 0, diffSecondDigitCol1);
        DigitDrawer digitE (diffSecondDigit, 1, diffSecondDigitCol2);
        DigitDrawer digitF (diffSecondDigit, 2, diffSecondDigitCol3);
        
        DigitDrawer digitG (diffThirdDigit, 0, diffThirdDigitCol1);
        DigitDrawer digitH (diffThirdDigit, 1, diffThirdDigitCol2);
        DigitDrawer digitI (diffThirdDigit, 2, diffThirdDigitCol3);
        
        wire [4:0] diffFirstDigitCol1;
        wire [4:0] diffFirstDigitCol2;
        wire [4:0] diffFirstDigitCol3;
        
        wire [4:0] diffSecondDigitCol1;
        wire [4:0] diffSecondDigitCol2;
        wire [4:0] diffSecondDigitCol3;
        
        wire [4:0] diffThirdDigitCol1;
        wire [4:0] diffThirdDigitCol2;
        wire [4:0] diffThirdDigitCol3;
        
        wire CONDITION_FOR_DIGIT_DIFF =
            (sw3 && (
            
               ((VGA_horzCoord == 3) && (VGA_vertCoord >= ((511+128) - 563)) && (VGA_vertCoord <= ((511+128) - 560)))
            || ((VGA_horzCoord == 4) && ((VGA_vertCoord == ((511+128) - 560)) || (VGA_vertCoord == ((511+128) - 564))))
            || ((VGA_horzCoord == 5) && (VGA_vertCoord >= ((511+128) - 563)) && (VGA_vertCoord <= ((511+128) - 560)))
            
            || ((VGA_horzCoord >= 8) && (VGA_horzCoord <= 11) && ((VGA_vertCoord == ((511+128) - 561)) || (VGA_vertCoord == ((511+128) - 563))))
            
            || (diffFirstDigitCol1[0] && (VGA_horzCoord == 17) && ((VGA_vertCoord == ((511+128) - 560))))
            || (diffFirstDigitCol1[1] && (VGA_horzCoord == 17) && ((VGA_vertCoord == ((511+128) - 561))))
            || (diffFirstDigitCol1[2] && (VGA_horzCoord == 17) && ((VGA_vertCoord == ((511+128) - 562))))
            || (diffFirstDigitCol1[3] && (VGA_horzCoord == 17) && ((VGA_vertCoord == ((511+128) - 563))))
            || (diffFirstDigitCol1[4] && (VGA_horzCoord == 17) && ((VGA_vertCoord == ((511+128) - 564))))
            
            || (diffFirstDigitCol2[0] && (VGA_horzCoord == 18) && ((VGA_vertCoord == ((511+128) - 560))))
            || (diffFirstDigitCol2[1] && (VGA_horzCoord == 18) && ((VGA_vertCoord == ((511+128) - 561))))
            || (diffFirstDigitCol2[2] && (VGA_horzCoord == 18) && ((VGA_vertCoord == ((511+128) - 562))))
            || (diffFirstDigitCol2[3] && (VGA_horzCoord == 18) && ((VGA_vertCoord == ((511+128) - 563))))
            || (diffFirstDigitCol2[4] && (VGA_horzCoord == 18) && ((VGA_vertCoord == ((511+128) - 564))))
            
            || (diffFirstDigitCol3[0] && (VGA_horzCoord == 19) && ((VGA_vertCoord == ((511+128) - 560))))
            || (diffFirstDigitCol3[1] && (VGA_horzCoord == 19) && ((VGA_vertCoord == ((511+128) - 561))))
            || (diffFirstDigitCol3[2] && (VGA_horzCoord == 19) && ((VGA_vertCoord == ((511+128) - 562))))
            || (diffFirstDigitCol3[3] && (VGA_horzCoord == 19) && ((VGA_vertCoord == ((511+128) - 563))))
            || (diffFirstDigitCol3[4] && (VGA_horzCoord == 19) && ((VGA_vertCoord == ((511+128) - 564))))
            
            || ((VGA_horzCoord == 22) && (VGA_vertCoord == ((511+128) - 560)))
            
            || (diffSecondDigitCol1[0] && (VGA_horzCoord == 25) && ((VGA_vertCoord == ((511+128) - 560))))
            || (diffSecondDigitCol1[1] && (VGA_horzCoord == 25) && ((VGA_vertCoord == ((511+128) - 561))))
            || (diffSecondDigitCol1[2] && (VGA_horzCoord == 25) && ((VGA_vertCoord == ((511+128) - 562))))
            || (diffSecondDigitCol1[3] && (VGA_horzCoord == 25) && ((VGA_vertCoord == ((511+128) - 563))))
            || (diffSecondDigitCol1[4] && (VGA_horzCoord == 25) && ((VGA_vertCoord == ((511+128) - 564))))
         
            || (diffSecondDigitCol2[0] && (VGA_horzCoord == 26) && ((VGA_vertCoord == ((511+128) - 560))))
            || (diffSecondDigitCol2[1] && (VGA_horzCoord == 26) && ((VGA_vertCoord == ((511+128) - 561))))
            || (diffSecondDigitCol2[2] && (VGA_horzCoord == 26) && ((VGA_vertCoord == ((511+128) - 562))))
            || (diffSecondDigitCol2[3] && (VGA_horzCoord == 26) && ((VGA_vertCoord == ((511+128) - 563))))
            || (diffSecondDigitCol2[4] && (VGA_horzCoord == 26) && ((VGA_vertCoord == ((511+128) - 564))))
         
            || (diffSecondDigitCol3[0] && (VGA_horzCoord == 27) && ((VGA_vertCoord == ((511+128) - 560))))
            || (diffSecondDigitCol3[1] && (VGA_horzCoord == 27) && ((VGA_vertCoord == ((511+128) - 561))))
            || (diffSecondDigitCol3[2] && (VGA_horzCoord == 27) && ((VGA_vertCoord == ((511+128) - 562))))
            || (diffSecondDigitCol3[3] && (VGA_horzCoord == 27) && ((VGA_vertCoord == ((511+128) - 563))))
            || (diffSecondDigitCol3[4] && (VGA_horzCoord == 27) && ((VGA_vertCoord == ((511+128) - 564))))
            
            
            
            || (diffThirdDigitCol1[0] && (VGA_horzCoord == 30) && ((VGA_vertCoord == ((511+128) - 560))))
            || (diffThirdDigitCol1[1] && (VGA_horzCoord == 30) && ((VGA_vertCoord == ((511+128) - 561))))
            || (diffThirdDigitCol1[2] && (VGA_horzCoord == 30) && ((VGA_vertCoord == ((511+128) - 562))))
            || (diffThirdDigitCol1[3] && (VGA_horzCoord == 30) && ((VGA_vertCoord == ((511+128) - 563))))
            || (diffThirdDigitCol1[4] && (VGA_horzCoord == 30) && ((VGA_vertCoord == ((511+128) - 564))))
         
            || (diffThirdDigitCol2[0] && (VGA_horzCoord == 31) && ((VGA_vertCoord == ((511+128) - 560))))
            || (diffThirdDigitCol2[1] && (VGA_horzCoord == 31) && ((VGA_vertCoord == ((511+128) - 561))))
            || (diffThirdDigitCol2[2] && (VGA_horzCoord == 31) && ((VGA_vertCoord == ((511+128) - 562))))
            || (diffThirdDigitCol2[3] && (VGA_horzCoord == 31) && ((VGA_vertCoord == ((511+128) - 563))))
            || (diffThirdDigitCol2[4] && (VGA_horzCoord == 31) && ((VGA_vertCoord == ((511+128) - 564))))
         
            || (diffThirdDigitCol3[0] && (VGA_horzCoord == 32) && ((VGA_vertCoord == ((511+128) - 560))))
            || (diffThirdDigitCol3[1] && (VGA_horzCoord == 32) && ((VGA_vertCoord == ((511+128) - 561))))
            || (diffThirdDigitCol3[2] && (VGA_horzCoord == 32) && ((VGA_vertCoord == ((511+128) - 562))))
            || (diffThirdDigitCol3[3] && (VGA_horzCoord == 32) && ((VGA_vertCoord == ((511+128) - 563))))
            || (diffThirdDigitCol3[4] && (VGA_horzCoord == 32) && ((VGA_vertCoord == ((511+128) - 564))))
            )
            );
            
        wire[3:0] VGA_DIGIT_DIFF = CONDITION_FOR_DIGIT_DIFF ? 4'h7 : 0 ;
    
    //-------------------------------------------------------------------------
    
    // COMBINE ALL OUTPUTS ON EACH CHANNEL
    wire[3:0] VGA_RED_CHAN = VGA_RED_GRID | VGA_RED_RAINBOW | VGA_TARGET_CURRENT | VGA_TARGET_1 | VGA_TARGET_3;
    wire[3:0] VGA_GREEN_CHAN = VGA_GREEN_GRID | VGA_GREEN_WAVEFORM | VGA_GREEN_RAINBOW | VGA_TARGET_3 | VGA_TARGET_2 | VGA_TRIGGER_LINE | VGA_DIGIT | VGA_DIGIT_DIFF; 
    wire[3:0] VGA_BLUE_CHAN = VGA_BLUE_GRID | VGA_BLUE_RAINBOW | VGA_TARGET_1 | VGA_TARGET_4 | VGA_TARGET_2;  


    // CLOCK THEM OUT
    always@(posedge CLK_VGA)
        begin      
        
            VGA_RED <= {VGA_active, VGA_active, VGA_active, VGA_active} & VGA_RED_CHAN ;  
            VGA_GREEN <= {VGA_active, VGA_active, VGA_active, VGA_active} & VGA_GREEN_CHAN ; 
            VGA_BLUE <= {VGA_active, VGA_active, VGA_active, VGA_active} & VGA_BLUE_CHAN ; 
                // VGA_active turns off output to screen if scan lines are outside the active screen area
            
            VGA_HS <= VGA_horzSync ;
            VGA_VS <= VGA_vertSync ;
            
        end

                         



    
endmodule
