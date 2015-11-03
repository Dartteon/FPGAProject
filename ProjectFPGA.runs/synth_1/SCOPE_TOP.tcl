# 
# Synthesis run script generated by Vivado
# 

set_param xicom.use_bs_reader 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a35tcpg236-3

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.cache/wt [current_project]
set_property parent.project_path C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property vhdl_version vhdl_2k [current_fileset]
read_verilog -library xil_defaultlib {
  C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/sources_1/imports/skeleton_sources/xadc_wiz_0.v
  C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/sources_1/new/DigitDrawer.v
  C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/sources_1/new/switch_debouncer_fast.v
  C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/sources_1/imports/skeleton_sources/switch_debouncer.v
  C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/sources_1/imports/skeleton_sources/FSM_inc_dec.v
  C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/sources_1/imports/skeleton_sources/clock_divider.v
  C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/sources_1/imports/skeleton_sources/ADC_sampler.v
  C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/sources_1/imports/skeleton_sources/SCOPE_TOP.v
}
read_vhdl -library xil_defaultlib {
  C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/sources_1/imports/skeleton_sources/clk_wiz_0_clk_wiz.vhd
  C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/sources_1/imports/skeleton_sources/vga_ctrl.vhd
  C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/sources_1/imports/skeleton_sources/clk_wiz_0.vhd
}
read_xdc C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/constrs_1/imports/skeleton_sources/Basys3_Master.xdc
set_property used_in_implementation false [get_files C:/Users/Dartteon/Desktop/ProjectFPGA/ProjectFPGA.srcs/constrs_1/imports/skeleton_sources/Basys3_Master.xdc]

synth_design -top SCOPE_TOP -part xc7a35tcpg236-3
write_checkpoint -noxdef SCOPE_TOP.dcp
catch { report_utilization -file SCOPE_TOP_utilization_synth.rpt -pb SCOPE_TOP_utilization_synth.pb }
