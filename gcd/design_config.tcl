# Flowkit v22.11-s006_1
################################################################################
# This file contains 'create_flow_step' content for steps which are required
# in an implementation flow, but whose contents are specific.  Review  all
# <PLACEHOLDER> content and replace with commands and options more appropriate
# for the design being implemented. Any new flowstep definitions should be done
# using the 'flow_config.tcl' file.
################################################################################

##############################################################################
# STEP init_design
##############################################################################
create_flow_step -name init_design -owner design -write_db {
  #- setup library information
  read_mmmc             [get_db init_flow_directory]/mmmc_config.tcl
  # read_physical         
  
  #- read and elaborate design
  read_hdl              -f inputs/rtl/design.f
  elaborate             gcd
  
  #- optionally setup power intent from UPF/CPF/1801
  # read_power_intent     << PLACEHOLDER: POWER INTENT LOAD OPTIONS >>f inputs/upf/design.upf
  
  #- initialize library and design information
  init_design
}
