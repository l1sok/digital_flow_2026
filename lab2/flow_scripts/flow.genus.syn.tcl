# ------------------------------------------------------------------------------
# Start
# ------------------------------------------------------------------------------

source "$::env(FLOW_DIR)/steps.genus.tcl"

step_genus_host_info
step_genus_global_options
step_genus_read_hdl
step_genus_read_mmmc
step_genus_elaborate
step_genus_init_design

step_genus_lec $::env(GENUS_RUN_DIR)/genus/outputs/syn_opt/counter.v
step_genus_gen
step_genus_map
step_genus_opt

step_genus_lec "$::env(GENUS_OUTPUT_DIR)/syn_opt/$::env(ENV_DESIGN).v"

# ------------------------------------------------------------------------------
# Finish
# ------------------------------------------------------------------------------

puts "============================"
puts "Synthesis Finished"
puts "============================"

gui_show
# quit
