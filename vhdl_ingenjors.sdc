# Company: TEIS AB
# Engineer: Fredrik Furufors
#
# Create Date: 2015 nov 8
# Design Name: vhdl_uppgift_10 extends vhdl_uppgift_9
# SDC file: vhdl_uppgift_10.sdc
# Target Devices: ALTERA Cyclone IV EP4CE115F29C7
# Description:
# - Ensures that the output timing satisfies the given
#   specifications
# - Asynchronous inputs are treated as false paths
# - There is no synchronous inputs to the system

# System clock 50 MHz
create_clock -name SYSTEM_CLOCK -period 20.000 [get_ports {CLOCK_50}]

# PLL and clock uncertainty is derived from the project files
derive_clock_uncertainty
derive_pll_clocks

# Since done-signal from sensor acts like a clock:
derive_clocks -period 20.00

# Asynchronous inputs are treated as false paths
set_false_path -from [get_ports {SW[17]}]

# Input timing specifications
set_input_delay -clock { SYSTEM_CLOCK } -min 0.7 [all_inputs]
set_input_delay -clock { SYSTEM_CLOCK } -max 3.15 [all_inputs]

# Output timing specifications
set_output_delay -clock { SYSTEM_CLOCK } -min 1 [all_outputs]
set_output_delay -clock { SYSTEM_CLOCK } -max 2.05 [all_outputs]