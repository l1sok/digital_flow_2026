#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Sun Nov  8 17:04:53 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v21.14-s109_1 (64bit) 06/29/2022 09:53 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 21.14-s109_1 NR220628-1629/21_14-UB (database version 18.20.582) {superthreading v2.17}
#@(#)CDS: AAE 21.14-s031 (64bit) 06/29/2022 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 21.14-s031_1 () Jun 22 2022 10:32:17 ( )
#@(#)CDS: SYNTECH 21.14-s014_1 () May 29 2022 20:47:50 ( )
#@(#)CDS: CPE v21.14-s062
#@(#)CDS: IQuantus/TQuantus 21.1.1-w001 (64bit) Wed Jun 1 22:42:35 PDT 2022 (Linux 3.10.0-693.el7.x86_64)

#@ source $::env(FLOW_DIR)/steps.innovus.tcl
#@ Begin verbose source (pre): source $::env(FLOW_DIR)/steps.innovus.tcl
proc user_init_design {} \
{
 
    # ------------------
    # Init design
    # ------------------
    if {[info exists ::env(TECH_SIZE)] && $::env(TECH_SIZE) ne ""} {
        set_db design_process_node $::env(TECH_SIZE)
    }

    set_db init_netlist_files  $::env(ENV_NETLIST)
    set_db init_lef_files      $::env(ENV_LEF_FILES)
    set_db init_power_nets     $::env(ENV_POWER_NETS)
    set_db init_ground_nets    $::env(ENV_GROUND_NETS)
    set_db init_mmmc_files     $::env(ENV_MMMC)

    read_mmmc     $::env(ENV_MMMC)
    read_physical -lef $::env(ENV_LEF_FILES)

    read_netlist  $::env(ENV_NETLIST) -top $::env(ENV_DESIGN)
    init_design


}
proc user_read_floorplan {} {
    # ----------------------------------------------------------
    # Floorplan file Ã¡Ã¥Ã°Â¸Ã¬ Ã¨Ã§ ENV_FLOORPLAN_FILE (Ã±Ã¬. Makefile)
    # ENV_INNOVUS_FP Â Ã½Ã²Ã® Ã¨Ã¬Ã¿ Ã§Ã Ã¯Ã³Ã±ÃªÃ Ã¥Ã¬Ã®Ã© Ã³Ã²Ã¨Ã«Ã¨Ã²Ã», ÃÃ Ã´Ã Ã©Ã« floorplan
    # ----------------------------------------------------------
    set fp_file ""

    if {[info exists ::env(ENV_FLOORPLAN_FILE)] && $::env(ENV_FLOORPLAN_FILE) ne ""} {
        set fp_file $::env(ENV_FLOORPLAN_FILE)
    }

    if {$fp_file eq ""} {
        puts "WARN: ENV_FLOORPLAN_FILE is not set, skip read_floorplan"
        return
    }

    if {![file exists $fp_file]} {
        puts "WARN: floorplan file not found: $fp_file"
        return
    }

    # ÃÃ¨Ã²Ã Ã¥Ã¬ floorplan
    read_floorplan $fp_file

    # ÃÃ®Ã¯Ã¨Ã°Ã³Ã¥Ã¬ Ã¨Ã±ÃµÃ®Ã¤Ã­Ã»Ã© .fp Ã¨ Ã¥Ã£Ã® .spr (Ã¥Ã±Ã«Ã¨ Ã¥Ã±Ã²Ã¼) Ã¢ ./in
proc global_net {} \
{
    connect_global_net VDD -type pg_pin -pin_base_name vdd -inst_base_name *
    connect_global_net VSS -type pg_pin -pin_base_name vss -inst_base_name *
    connect_global_net VSS -type pg_pin -pin_base_name gnd -inst_base_name *
}
#@ End verbose source: /home/e.radionova/Desktop/digital_flow_2026/lab3/flow_scripts/steps.innovus.tcl
user_init_design
#@ Begin verbose source (pre): 
set lib_list_typ {}
lappend lib_list_typ  " $::env(PDK_DIR)/IHP_Open_PDK/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib"
create_rc_corner -name typ -temperature {25} -pre_route_res {1} -pre_route_cap {1} -pre_route_clock_res {0} -pre_route_clock_cap {0} -post_route_res {1} -post_route_cap {1} -post_route_cross_cap {1} -post_route_clock_res {0} -post_route_clock_cap {0}
create_library_set -name typ -timing $lib_list_typ
create_opcond -name typ -process {1} -voltage {1.20} -temperature {25}
create_timing_condition -name typ -opcond {typ} -library_sets {typ}
create_delay_corner -name typ -timing_condition {typ} -rc_corner {typ}
create_constraint_mode -name func -sdc_files "$::env(ENV_DESIGN_DIR)/$::env(ENV_DESIGN).sdc"
create_analysis_view -name typ -constraint_mode {func} -delay_corner {typ}
set_analysis_view -setup {typ} -hold {typ}
#@ End verbose source: /home/e.radionova/Desktop/digital_flow_2026/lab3/data/statistics_unit/mmmc.view
global_net
global_net
global_net
proc global_net {} {
    connect_global_net VDD -type pg_pin -pin_base_name VDD -inst_base_name *
    connect_global_net VSS -type pg_pin -pin_base_name VSS -inst_base_name *
}
global_net
gui_select -point {0.03300 0.08900}
gui_pan 28.91700 38.19100
gui_pan 50.64700 475.41700
gui_pan 86.61400 82.52000
gui_pan -59.32900 7.01000
set_io_flow_flag 0
create_floorplan -core_margins_by die -site CoreSite -core_density_size 1 0.5 20 20 20 20
set_io_flow_flag 0
create_floorplan -site CoreSite -core_density_size 1 0.50 20 20 20 20
set_io_flow_flag 0
create_floorplan -site CoreSite -core_density_size 0.975663716814 0.498666 20.16 20.16 20.16 20.16
set_io_flow_flag 0
create_floorplan -site CoreSite -core_density_size 1 0.50 20 20 20 20
gui_select -point {-35.29700 95.47700}
gui_select -point {246.88500 169.34000}
gui_pan -61.55300 67.74500
set_io_flow_flag 0
create_floorplan -site CoreSite -die_size 202 202 20.16 20.16 20.16 20.16
gui_select -point {203.38900 5.56600}
gui_select -point {203.80200 9.89500}
gui_select -point {207.51200 61.63700}
llength [get_db rows]
set_db assign_pins_edit_in_batch true
edit_pin -fix_overlap 1 -unit micron -spread_direction clockwise -side Left -layer 3 -spread_type start -spacing 93.56 -start 0.0 70.7 -pin {{data_in[0]} {data_in[1]} {data_in[2]} {data_in[3]} {data_in[4]} {data_in[5]} {data_in[6]} {data_in[7]} {data_in[8]} {data_in[9]} {data_in[10]} {data_in[11]} {data_in[12]} {data_in[13]} {data_in[14]} {data_in[15]} {data_in[16]} {data_in[17]} {data_in[18]} {data_in[19]} {data_in[20]} {data_in[21]} {data_in[22]} {data_in[23]} {data_in[24]} {data_in[25]} {data_in[26]} {data_in[27]} {data_in[28]} {data_in[29]} {data_in[30]} {data_in[31]}}
set_db assign_pins_edit_in_batch false
gui_pan -2.42600 174.62800
set_db assign_pins_edit_in_batch true
edit_pin -fix_overlap 1 -unit micron -spread_direction clockwise -side Left -layer 1 -spread_type start -spacing 0.48 -start 0.0 93.56 -pin {{data_in[0]} {data_in[1]} {data_in[2]} {data_in[3]} {data_in[4]} {data_in[5]} {data_in[6]} {data_in[7]} {data_in[8]} {data_in[9]} {data_in[10]} {data_in[11]} {data_in[12]} {data_in[13]} {data_in[14]} {data_in[15]} {data_in[16]} {data_in[17]} {data_in[18]} {data_in[19]} {data_in[20]} {data_in[21]} {data_in[22]} {data_in[23]} {data_in[24]} {data_in[25]} {data_in[26]} {data_in[27]} {data_in[28]} {data_in[29]} {data_in[30]} {data_in[31]}}
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
edit_pin -pin_width 0.16 -pin_depth 0.565 -fix_overlap 1 -unit micron -spread_direction clockwise -side Left -layer 1 -spread_type start -spacing 0.48 -start 0.0 93.66 -pin {{data_in[0]} {data_in[1]} {data_in[2]} {data_in[3]} {data_in[4]} {data_in[5]} {data_in[6]} {data_in[7]} {data_in[8]} {data_in[9]} {data_in[10]} {data_in[11]} {data_in[12]} {data_in[13]} {data_in[14]} {data_in[15]} {data_in[16]} {data_in[17]} {data_in[18]} {data_in[19]} {data_in[20]} {data_in[21]} {data_in[22]} {data_in[23]} {data_in[24]} {data_in[25]} {data_in[26]} {data_in[27]} {data_in[28]} {data_in[29]} {data_in[30]} {data_in[31]}}
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
edit_pin -pin_width 0.16 -pin_depth 0.565 -fix_overlap 1 -unit micron -spread_direction clockwise -side Left -layer 1 -spread_type start -spacing 0.48 -start 0.0 93.66 -pin {{data_in[0]} {data_in[1]} {data_in[2]} {data_in[3]} {data_in[4]} {data_in[5]} {data_in[6]} {data_in[7]} {data_in[8]} {data_in[9]} {data_in[10]} {data_in[11]} {data_in[12]} {data_in[13]} {data_in[14]} {data_in[15]} {data_in[16]} {data_in[17]} {data_in[18]} {data_in[19]} {data_in[20]} {data_in[21]} {data_in[22]} {data_in[23]} {data_in[24]} {data_in[25]} {data_in[26]} {data_in[27]} {data_in[28]} {data_in[29]} {data_in[30]} {data_in[31]}}
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
edit_pin -pin_width 0.16 -pin_depth 0.565 -fix_overlap 1 -unit micron -spread_direction clockwise -side Left -layer 1 -spread_type start -spacing 0.5 -start 0.0 93.66 -pin {{data_in[0]} {data_in[1]} {data_in[2]} {data_in[3]} {data_in[4]} {data_in[5]} {data_in[6]} {data_in[7]} {data_in[8]} {data_in[9]} {data_in[10]} {data_in[11]} {data_in[12]} {data_in[13]} {data_in[14]} {data_in[15]} {data_in[16]} {data_in[17]} {data_in[18]} {data_in[19]} {data_in[20]} {data_in[21]} {data_in[22]} {data_in[23]} {data_in[24]} {data_in[25]} {data_in[26]} {data_in[27]} {data_in[28]} {data_in[29]} {data_in[30]} {data_in[31]}}
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
edit_pin -pin_width 0.16 -pin_depth 0.565 -fix_overlap 1 -unit micron -spread_direction clockwise -side Left -layer 1 -spread_type start -spacing 0.49 -start 0.0 93.66 -pin {{data_in[0]} {data_in[1]} {data_in[2]} {data_in[3]} {data_in[4]} {data_in[5]} {data_in[6]} {data_in[7]} {data_in[8]} {data_in[9]} {data_in[10]} {data_in[11]} {data_in[12]} {data_in[13]} {data_in[14]} {data_in[15]} {data_in[16]} {data_in[17]} {data_in[18]} {data_in[19]} {data_in[20]} {data_in[21]} {data_in[22]} {data_in[23]} {data_in[24]} {data_in[25]} {data_in[26]} {data_in[27]} {data_in[28]} {data_in[29]} {data_in[30]} {data_in[31]}}
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
edit_pin -pin_width 0.16 -pin_depth 0.565 -fix_overlap 1 -unit micron -spread_direction clockwise -side Left -layer 1 -spread_type start -spacing 0.48 -start 0.0 93.66 -pin {{data_in[0]} {data_in[1]} {data_in[2]} {data_in[3]} {data_in[4]} {data_in[5]} {data_in[6]} {data_in[7]} {data_in[8]} {data_in[9]} {data_in[10]} {data_in[11]} {data_in[12]} {data_in[13]} {data_in[14]} {data_in[15]} {data_in[16]} {data_in[17]} {data_in[18]} {data_in[19]} {data_in[20]} {data_in[21]} {data_in[22]} {data_in[23]} {data_in[24]} {data_in[25]} {data_in[26]} {data_in[27]} {data_in[28]} {data_in[29]} {data_in[30]} {data_in[31]}}
set_db assign_pins_edit_in_batch false
gui_pan 40.04100 137.69400
set_db assign_pins_edit_in_batch true
edit_pin -fix_overlap 1 -unit micron -spread_direction clockwise -side Top -layer 3 -spread_type start -spacing 0.48 -start 101.0 0.0 -pin clk
set_db assign_pins_edit_in_batch false
set_partition_pin_status -partition statistics_unit -pins {count[0]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {count[1]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {count[2]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {count[3]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {count[4]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {count[5]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {count[6]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {count[7]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {count[8]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {count[9]} -status unplaced -quiet
set_db assign_pins_edit_in_batch true
edit_pin -fix_overlap 1 -unit micron -spread_direction clockwise -side Right -layer 3 -spread_type start -spacing 1.0 -start 0.0 0.0 -pin {{count[0]} {count[1]} {count[2]} {count[3]} {count[4]} {count[5]} {count[6]} {count[7]} {count[8]} {count[9]}}
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
edit_pin -pin_width 0.2 -pin_depth 0.72 -fix_overlap 1 -unit micron -spread_direction clockwise -side Right -layer 3 -spread_type start -spacing 0.48 -start 202.08 154.56 -pin {{count[0]} {count[1]} {count[2]} {count[3]} {count[4]} {count[5]} {count[6]} {count[7]} {count[8]} {count[9]}}
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
edit_pin -pin_width 0.2 -pin_depth 0.72 -fix_overlap 1 -unit micron -spread_direction clockwise -side Right -layer 3 -spread_type start -spacing -0.42 -start 202.08 165.0 -pin {{count[0]} {count[1]} {count[2]} {count[3]} {count[4]} {count[5]} {count[6]} {count[7]} {count[8]} {count[9]}}
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
set_db assign_pins_edit_in_batch false
set_partition_pin_status -partition statistics_unit -pins {max[0]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[1]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[2]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[3]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[4]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[5]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[6]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[7]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[8]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[9]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[10]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[11]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[12]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[13]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[14]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[15]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[16]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[17]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[18]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[19]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[20]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[21]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[22]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[23]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[24]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[25]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[26]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[27]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[28]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[29]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[30]} -status unplaced -quiet
set_partition_pin_status -partition statistics_unit -pins {max[31]} -status unplaced -quiet
set_db assign_pins_edit_in_batch true
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
set_db assign_pins_edit_in_batch false
set_db assign_pins_edit_in_batch true
set_db assign_pins_edit_in_batch false
gui_pan -2.45600 93.85800
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
add_rings -nets {VDD VSS} -type core_rings -follow core -layer {top TopMetal1 bottom TopMetal2 left TopMetal1 right TopMetal2} -width {top 4 bottom 4 left 4 right 4} -spacing {top 2 bottom 2 left 2 right 2} -offset {top 6 bottom 6 left 6 right 6} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none
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
add_rings -nets {VDD VSS} -type core_rings -follow core -layer {top TopMetal1 bottom TopMetal2 left TopMetal2 right TopMetal1} -width {top 4 bottom 4 left 4 right 4} -spacing {top 2 bottom 2 left 2 right 2} -offset {top 6 bottom 6 left 6 right 6} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none
gui_select -point {67.63300 193.20000}
delete_selected_from_floorplan
gui_select -point {7.76700 186.38800}
delete_selected_from_floorplan
gui_select -point {12.72100 180.40100}
delete_selected_from_floorplan
gui_select -point {22.21700 185.97500}
delete_selected_from_floorplan
gui_select -point {40.17700 7.20100}
delete_selected_from_floorplan
gui_select -point {44.92500 8.85300}
delete_selected_from_floorplan
gui_select -point {43.68700 11.94900}
delete_selected_from_floorplan
gui_select -point {50.70500 5.34300}
delete_selected_from_floorplan
gui_select -point {191.28800 32.38600}
delete_selected_from_floorplan
gui_select -point {197.68800 30.32200}
delete_selected_from_floorplan
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
add_rings -nets {VDD VSS} -type core_rings -follow core -layer {top TopMetal1 bottom TopMetal2 left TopMetal2 right TopMetal1} -width {top 4 bottom 4 left 4 right 4} -spacing {top 2 bottom 2 left 2 right 2} -offset {top 6 bottom 6 left 6 right 6} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none
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
add_rings -nets {VDD VSS} -type core_rings -follow core -layer {top TopMetal1 bottom TopMetal1 left TopMetal2 right TopMetal2} -width {top 4 bottom 4 left 4 right 4} -spacing {top 2 bottom 2 left 2 right 2} -offset {top 6 bottom 6 left 6 right 6} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none
gui_pan -5.10000 200.53900
gui_pan 130.21600 163.75900
gui_pan -9.29100 109.34400
gui_pan 43.48000 147.07000
set_db route_special_via_connect_to_shape { noshape }
route_special -connect core_pin -layer_change_range { Metal1(1) TopMetal2(7) } -block_pin_target nearest_target -core_pin_target first_after_row_end -allow_jogging 1 -crossover_via_layer_range { Metal1(1) TopMetal2(7) } -nets { VDD VSS } -allow_layer_change 1 -target_via_layer_range { Metal1(1) TopMetal2(7) }
check_drc -check_only special
check_connectivity -nets {VDD VSS} -type special
check_drc -check_only special
check_connectivity -nets {VDD VSS} -type special
check_drc -check_only special
check_drc -check_only special
check_drc -check_only special
get_db current_design .bbox
get_db current_design .core_bbox
puts "Rows count: [llength [get_db rows]]"
get_db rows .rect
Read in 142 physical pins
puts "Ports: [llength [get_db ports]]"
gui_pan 1.19200 108.98500
gui_pan -1.04300 36.14700
gui_pan 14.56000 108.91200
gui_pan 3.92500 191.46300
gui_pan 10.76100 109.04000
gui_pan -2.38400 83.39100
check_power_vias -nets {VDD VSS} \
    -report ./power_vias.rpt
gui_pan 48.18600 172.60600
write_floorplan ../../statistics_unit_floorplan_4.fp
