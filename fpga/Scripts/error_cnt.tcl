# Quick and dirty log parser for Vivado sim counting the Assert Errors at the end of each Simulation visual Studio and other IDEs like.
# tor run the script from tcl console in vivado: source litefury_pcie_daq.scripts/parse_log.tcl
# Built this based on the Xilinx UG900 guide:
# https://www.xilinx.com/support/documents/sw_manuals/xilinx2022_1/ug900-vivado-logic-simulation.pdf

# Suppress Tcl Command Trace (like 'echo off' in Windows batch files)
#?? couldn't find any thing till now :(

set proj_dir [get_property DIRECTORY [current_project]]
# in my case the simulation results are in simulate.log
set log_file "$proj_dir/litefury_pcie_daq.sim/sim_1/behav/xsim/simulate.log"


if {![file exists $log_file]} {
    puts "WARNING: No simulation log found at $log_file"
    puts "Please run the behavioral simulation in Vivado first!"
    return
}

set f [open $log_file r]
set file_data [read $f]
close $f

# Split into lines and check for errors/asserts
set lines [split $file_data "\n"]
set line_count 0
set error_count 0

puts "--- SEARCHING FOR ERRORS ---"

foreach line $lines {
    incr line_count
    # Simple search for assert or error keywords
    if {[string match -nocase "*assert*" $line] || [string match -nocase "*error*" $line]} {
        puts "Line $line_count: $line"
	    incr error_count
        #todo: could also add_marker time ns. 
    }
}
puts "$error_count Errors!"
puts "--- DONE ---"