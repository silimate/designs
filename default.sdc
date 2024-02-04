# Create clocks (virtual if none are found)
set clks [get_ports -nocase *clk*]
if {[llength $clks] == 0} {
  create_clock -name clk -period $::env(clock_period)
} else {
  create_clock -name clk -period $::env(clock_period) $clks
}

# Set input delays
set_input_delay -clock clk 0 [all_inputs -no_clocks]

# Set output delays
set_output_delay -clock clk 0 [all_outputs]
