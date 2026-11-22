#=============================================================
# Reproduce die/core geometry
#=============================================================
create_floorplan -site CoreSite -die_size 200.16 201.18 20.16 20.16 20.16 20.16

#=============================================================
# I/O pins
#=============================================================
set_db assign_pins_edit_in_batch true

# --- Clock, center of top side.-----------------
edit_pin -fix_overlap 1 -unit micron -spread_direction clockwise -side Top -layer 3 -spread_type start -spacing 0.48 -start 101.0 0.0 -pin clk

# --- Control inputs, bottom ----------------------
edit_pin -fix_overlap 1 -unit micron -spread_direction clockwise -side Bottom -layer 3 -spread_type start -spacing 0.48 -start 99.84 0.0 -pin rst_n
edit_pin -fix_overlap 1 -unit micron -spread_direction clockwise -side Bottom -layer 3 -spread_type start -spacing 0.48 -start 109.92 0.0 -pin clear
edit_pin -fix_overlap 1 -unit micron -spread_direction clockwise -side Bottom -layer 3 -spread_type start -spacing 0.48 -start 89.76 0.0 -pin valid_in

# --- Left edge: data_in ----------------------------
edit_pin -pin_width 0.16 -pin_depth 0.565 -fix_overlap 1 -unit micron -spread_direction clockwise -side Left -layer 3 -spread_type start -spacing 0.42 -start 0.0 93.66 \
    -pin {{data_in[0]} {data_in[1]} {data_in[2]} {data_in[3]} \
          {data_in[4]} {data_in[5]} {data_in[6]} {data_in[7]} \
          {data_in[8]} {data_in[9]} {data_in[10]} {data_in[11]} \
          {data_in[12]} {data_in[13]} {data_in[14]} {data_in[15]} \
          {data_in[16]} {data_in[17]} {data_in[18]} {data_in[19]} \
          {data_in[20]} {data_in[21]} {data_in[22]} {data_in[23]} \
          {data_in[24]} {data_in[25]} {data_in[26]} {data_in[27]} \
          {data_in[28]} {data_in[29]} {data_in[30]} {data_in[31]}}


# --- Right edge ---------------------------------

# count[9:0]
edit_pin -pin_width 0.20 -pin_depth 0.72 -fix_overlap 1 -unit micron -spread_direction clockwise -side Right -layer 3 -spread_type start -spacing 0.42 -start 200.16 154.56 \
    -pin {{count[0]} {count[1]} {count[2]} {count[3]} \
          {count[4]} {count[5]} {count[6]} {count[7]} \
          {count[8]} {count[9]}}

# max[31:0]
edit_pin -pin_width 0.20 -pin_depth 0.72 -fix_overlap 1 -unit micron -spread_direction clockwise -side Right -layer 3 -spread_type start -spacing 0.42 -start 200.16 129.78 \
    -pin {{max[0]} {max[1]} {max[2]} {max[3]} \
          {max[4]} {max[5]} {max[6]} {max[7]} \
          {max[8]} {max[9]} {max[10]} {max[11]} \
          {max[12]} {max[13]} {max[14]} {max[15]} \
          {max[16]} {max[17]} {max[18]} {max[19]} \
          {max[20]} {max[21]} {max[22]} {max[23]} \
          {max[24]} {max[25]} {max[26]} {max[27]} \
          {max[28]} {max[29]} {max[30]} {max[31]}}

# min[31:0]
edit_pin -pin_width 0.20 -pin_depth 0.72 -fix_overlap 1 -unit micron -spread_direction clockwise -side Right -layer 3 -spread_type start -spacing 0.42 -start 200.16 99.96 \
    -pin {{min[0]} {min[1]} {min[2]} {min[3]} \
          {min[4]} {min[5]} {min[6]} {min[7]} \
          {min[8]} {min[9]} {min[10]} {min[11]} \
          {min[12]} {min[13]} {min[14]} {min[15]} \
          {min[16]} {min[17]} {min[18]} {min[19]} \
          {min[20]} {min[21]} {min[22]} {min[23]} \
          {min[24]} {min[25]} {min[26]} {min[27]} \
          {min[28]} {min[29]} {min[30]} {min[31]}}

# sum[31:0]
edit_pin -pin_width 0.20 -pin_depth 0.72 -fix_overlap 1 -unit micron -spread_direction clockwise -side Right -layer 3 \
    -spread_type start -spacing 0.42 -start 200.16 69.72 \
    -pin {{sum[0]} {sum[1]} {sum[2]} {sum[3]} \
          {sum[4]} {sum[5]} {sum[6]} {sum[7]} \
          {sum[8]} {sum[9]} {sum[10]} {sum[11]} \
          {sum[12]} {sum[13]} {sum[14]} {sum[15]} \
          {sum[16]} {sum[17]} {sum[18]} {sum[19]} \
          {sum[20]} {sum[21]} {sum[22]} {sum[23]} \
          {sum[24]} {sum[25]} {sum[26]} {sum[27]} \
          {sum[28]} {sum[29]} {sum[30]} {sum[31]}}

set_db assign_pins_edit_in_batch false

#=============================================================
# Power rings
#=============================================================
set_db add_rings_target default
set_db add_rings_extend_over_row 0
set_db add_rings_ignore_rows 0
set_db add_rings_avoid_short 0
set_db add_rings_skip_shared_inner_ring none
set_db add_rings_stacked_via_top_layer TopMetal2
set_db add_rings_stacked_via_bottom_layer Metal1
set_db add_rings_via_using_exact_crossover_size 1
set_db add_rings_orthogonal_only true
set_db add_rings_skip_via_on_pin {  standardcell }
set_db add_rings_skip_via_on_wire_shape {  noshape }
add_rings -nets {VDD VSS} -type core_rings -follow core \
    -layer {top TopMetal1 bottom TopMetal1 left TopMetal2 right TopMetal2} \
    -width {top 4 bottom 4 left 4 right 4} \
    -spacing {top 2 bottom 2 left 2 right 2} \
    -offset {top 6 bottom 6 left 6 right 6} \
    -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none


#=============================================================
# rails and connections from core pins to the rings
#=============================================================
set_db route_special_via_connect_to_shape { noshape }
route_special -connect core_pin -layer_change_range { Metal1(1) TopMetal2(7) } \
    -block_pin_target nearest_target \
    -core_pin_target first_after_row_end \
    -allow_jogging 1 \
    -crossover_via_layer_range { Metal1(1) TopMetal2(7) } \
    -nets { VDD VSS } \
    -allow_layer_change 1 \
    -target_via_layer_range { Metal1(1) TopMetal2(7) }

#=============================================================
# Recheck floorplan and power network
#=============================================================
puts "Die:     [get_db current_design .bbox]"
puts "Core:    [get_db current_design .core_bbox]"
puts "Rows:    [llength [get_db rows]]"
puts "I/O pins:[llength [get_db ports]]"
check_drc -check_only special
check_connectivity -nets {VDD VSS} -type special
check_power_vias -nets {VDD VSS} -report ./power_vias_4.rpt

#=============================================================
# Completed ! :3
#=============================================================
