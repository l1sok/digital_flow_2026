read_floorplan $::env(INNOVUS_FP_OUTPUT_DIR)/statistics_unit_floorplan_4.fp

#=============================================================
# Reproduce core geometry
#=============================================================
update_floorplan \
    -core_to_left 13.92 \
    -core_to_bottom 12.60 \
    -core_to_right 13.92 \
    -core_to_top 12.60

#=============================================================
# One central pair of vertical VDD/VSS stripes
#=============================================================
set_db add_stripes_ignore_block_check false
set_db add_stripes_break_at none
set_db add_stripes_route_over_rows_only false
set_db add_stripes_rows_without_stripes_only false
set_db add_stripes_extend_to_closest_target none
set_db add_stripes_stop_at_last_wire_for_area false
set_db add_stripes_partial_set_through_domain false
set_db add_stripes_ignore_non_default_domains false
set_db add_stripes_trim_antenna_back_to_shape none
set_db add_stripes_spacing_type edge_to_edge
set_db add_stripes_spacing_from_block 0
set_db add_stripes_stripe_min_length stripe_width
set_db add_stripes_stacked_via_top_layer TopMetal2
set_db add_stripes_stacked_via_bottom_layer Metal1
set_db add_stripes_via_using_exact_crossover_size false
set_db add_stripes_split_vias false
set_db add_stripes_orthogonal_only true
set_db add_stripes_allow_jog { padcore_ring block_ring }
set_db add_stripes_skip_via_on_pin { standardcell }
set_db add_stripes_skip_via_on_wire_shape { noshape }

add_stripes -nets {VDD VSS} -layer TopMetal2 -direction vertical \
    -width 4 -spacing 2 -number_of_sets 1 -start_from left \
    -start_offset 81.16 -stop_offset 81.16 \
    -switch_layer_over_obs false -max_same_layer_jog_length 2 \
    -pad_core_ring_top_layer_limit TopMetal2 \
    -pad_core_ring_bottom_layer_limit Metal1 \
    -block_ring_top_layer_limit TopMetal2 \
    -block_ring_bottom_layer_limit Metal1 \
    -use_wire_group 0 -snap_wire_center_to_grid none

#=============================================================
# Cut peripheral rows
#=============================================================
split_row -area 0 0 16 201.18
split_row -area 184.16 0 200.16 201.18
split_row -area 18 0 184.16 18
split_row -area 16 182.18 184.16 201.18

#=============================================================
# Internal blockages
#=============================================================
create_place_blockage -type hard \
    -rects {{40.032 114.673 72.058 148.873}}
create_route_blockage -layers Metal3 \
    -rects {{130.104 54.319 162.130 88.519}}

#=============================================================
# Recheck floorplan and power network
#=============================================================
puts "Die:          [get_db current_design .bbox]"
puts "Core:         [get_db current_design .core_bbox]"
puts "Rows:         [llength [get_db rows]]"
puts "I/O ports:    [llength [get_db ports]]"
puts "Place blocks: [llength [get_db place_blockages]]"
puts "Route blocks: [llength [get_db route_blockages]]"
check_drc -check_only special
check_connectivity -nets {VDD VSS} -type special
check_power_vias -nets {VDD VSS} -report ./power_vias_5_reproduced.rpt
write_floorplan ../../statistics_unit_floorplan_5_reproduced.fp

#=============================================================
# Completed ! :3
#=============================================================
