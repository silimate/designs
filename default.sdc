# Utilities
proc ldiff {a b} {
  lmap elem $a {
    expr {[lsearch -exact $b $elem] > -1 ? [continue] : $elem}
  }
}

# Find clocks and resets
set clks [get_ports -nocase *clk*]
set inputs_no_clks [all_inputs -no_clocks]

# Create clocks
create_clock -name clk -period $::env(clock_period) $clks

# Set input delays
set_input_delay -clock clk 0 $inputs_no_clks

# Set output delays
set_output_delay -clock clk 0 [all_outputs]
