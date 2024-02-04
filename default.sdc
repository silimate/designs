# Create virtual clocks
create_clock -name fast_clk -period 0
create_clock -name slow_clk -period 1000000

# Set input delays
puts "Fast input pins:"
puts [get_ports -filter {direction==in && full_name=~*_fast_*}]
puts "Slow input pins:"
puts [get_ports -filter {direction==in && full_name=~*_slow_*}]
set_input_delay -clock fast_clk 0 [get_ports -filter {direction==in && full_name=~*_fast_*}]
set_input_delay -clock slow_clk 0 [get_ports -filter {direction==in && full_name=~*_slow_*}]

# Set output delays
puts "Fast output pins:"
puts [get_ports -filter {direction==out && full_name=~*_fast_*}]
puts "Slow output pins:"
  
set_output_delay -clock fast_clk 0 [get_ports -filter {direction==out && full_name=~*_fast_*}]
set_output_delay -clock slow_clk 0 [get_ports -filter {direction==out && full_name=~*_slow_*}]
