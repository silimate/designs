# Utilities
proc ldiff {a b} {
  lmap elem $a {
    expr {[lsearch -exact $b $elem] > -1 ? [continue] : $elem}
  }
}

# Find clocks and resets
set clks [concat [get_ports -filter name=~clk* *] [get_ports -filter name=~clock* *]]
set rsts [concat [get_ports -filter name=~rst* *] [get_ports -filter name=~reset* *]]
set inputs_no_clks [ldiff [all_inputs] $clks]

# DEBUG
puts $clks
puts $rsts
puts $inputs_no_clks

# Create clocks
create_clock -name clk -period 1 $clks

# Set input delays
set_input_delay -clock clk 0 $inputs_no_clks

# Set output delays
set_output_delay -clock clk 0 [all_outputs]
