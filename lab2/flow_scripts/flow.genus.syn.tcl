# ------------------------------------------------------------------------------
# Start
# ------------------------------------------------------------------------------

source $::env(FLOW_DIR)/steps.genus.tcl

# HOST info
step_genus_host_info

# global options
step_genus_global_options

# read HDL
step_genus_read_hdl

# read MMMC
step_genus_read_mmmc

# elaborate
step_genus_elaborate

# init and check timing
step_genus_init_design

# generic, mapping, optimization
step_genus_gen
step_genus_map
step_genus_opt

# LEC prepare (.do script)
step_genus_lec $::env(GENUS_OUTPUT_DIR)/syn_opt/$::env(ENV_DESIGN).v

# ------------------------------------------------------------------------------
# Finish
# ------------------------------------------------------------------------------
puts "============================"
puts "Synthesis Finished"
puts "============================"

gui_show
# quit