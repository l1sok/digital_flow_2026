#  ___       _ _   
# |_ _|_ __ (_) |_ 
#  | || '_ \| | __|
#  | || | | | | |_ 
# |___|_| |_|_|\__|

# Load procedures
source $::env(FLOW_DIR)/steps.innovus.tcl

# Initialize design
user_init_design

# 4
#source $::env(FLOW_DIR)/statistic_unit_floorplan_4.tcl

# 5
source $::env(FLOW_DIR)/statistic_unit_floorplan_5.tcl

# Open GUI only after floorplan is completed
gui_show
gui_fit
