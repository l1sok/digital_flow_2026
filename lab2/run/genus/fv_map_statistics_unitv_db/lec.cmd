REAd IMplementation Information fv/statistics_unit -golden fv_map -revised statistics_unitv
SET PARAllel Option -threads 1,4 -norelease_license
SET COmpare Options -threads 1,4
SET MUltiplier Implementation boothrca -both
SET UNDEfined Cell black_box -noascend -both
ADD SEarch Path . /local/tools/cadence/GENIUS/21.14/tools.lnx86/lib/tech -library -both
REAd LIbrary -liberty -both /home/e.radionova/Desktop/digital_flow_2026/lab2/../PDK/IHP_Open_PDK/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib
REAd DEsign -verilog95 -golden -lastmod -noelab fv/statistics_unit/fv_map.v.gz
ELAborate DEsign -golden -root statistics_unit
REAd DEsign -verilog95 -revised -lastmod -noelab /home/e.radionova/Desktop/digital_flow_2026/lab2/run/genus/outputs/syn_opt/statistics_unit.v
ELAborate DEsign -revised -root statistics_unit
REPort DEsign Data
REPort BLack Box
SET FLatten Model -seq_constant
SET FLatten Model -seq_constant_x_to 0
SET FLatten Model -nodff_to_dlat_zero
SET FLatten Model -nodff_to_dlat_feedback
SET FLatten Model -hier_seq_merge
CHEck VErification Information
SET ANalyze Option -auto -report_map
SET SYstem Mode lec
REPort UNmapped Points -summary
REPort UNmapped Points -notmapped
ADD COmpared Points -all
COMpare
REPort COmpare Data -class nonequivalent -class abort -class notcompared
REPort VErification -verbose
REPort STatistics
WRIte COmpared Points noneq.compared_points.statistics_unit.fv_map.statistics_unitv.tcl -class noneq -tclmode\
   -replace
ANAlyze NOnequivalent -source_diagnosis
REPort NOnequivalent Analysis
REPort TEst Vector -noneq
REPort VErification
WRIte VErification Information
REPort VErification Information
REPort IMplementation Information
RESET
SET MApping Method -sensitive
SET VErification Information rtl_fv_map_db
REAd IMplementation Information fv/statistics_unit -revised fv_map
SET PARAllel Option -threads 1,4 -norelease_license
SET COmpare Options -threads 1,4
SET MUltiplier Implementation boothrca -both
SET UNDEfined Cell black_box -noascend -both
ADD SEarch Path . /local/tools/cadence/GENIUS/21.14/tools.lnx86/lib/tech -library -both
REAd LIbrary -liberty -both /home/e.radionova/Desktop/digital_flow_2026/lab2/../PDK/IHP_Open_PDK/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib
SET UNDRiven Signal 0 -golden
SET NAming Style genus -golden
SET NAming Rule %s[%d] -instance_array -golden
SET NAming Rule %s_reg -register -golden
SET NAming Rule %L.%s %L[%d].%s %s -instance -golden
SET NAming Rule %L.%s %L[%d].%s %s -variable -golden
SET NAming Rule -ungroup_separator _ -golden
SET HDl Options -const_port_extend
SET HDl Options -unsigned_conversion_overflow on
SET HDl Options -nolibext_def on
SET HDl Options -v_to_vd on
SET HDl Options -VERILOG_INCLUDE_DIR cwd:incdir:src:yyd:sep
ADD SEarch Path /home/e.radionova/Desktop/digital_flow_2026/lab2/data/blockB -design -golden
REAd DEsign -enumconstraint -define SYNTHESIS -merge bbox -golden -lastmod -noelab -sv09 -f /home/e.radionova/Desktop/digital_flow_2026/lab2/data/blockB/statistics_unit.lst
ELAborate DEsign -golden -root statistics_unit -rootonly
REAd DEsign -verilog95 -revised -lastmod -noelab fv/statistics_unit/fv_map.v.gz
ELAborate DEsign -revised -root statistics_unit
UNIQuify -all -nolib -golden
REPort DEsign Data
REPort BLack Box
SET FLatten Model -seq_constant
SET FLatten Model -seq_constant_x_to 0
SET FLatten Model -nodff_to_dlat_zero
SET FLatten Model -nodff_to_dlat_feedback
SET FLatten Model -hier_seq_merge
SET FLatten Model -balanced_modeling
CHEck VErification Information
SET ANalyze Option -auto -report_map
WRIte HIer_compare Dofile hier_tmp2.lec.do -verbose -noexact_pin_match -constraint -usage -replace -balanced_extraction\
   -input_output_pin_equivalence -prepend_string "report_design_data; report_unmapped_points -summary; report_unmapped_points -notmapped; analyze_datapath -module -verbose; eval analyze_datapath -flowgraph -verbose"
RUN HIer_compare hier_tmp2.lec.do -dynamic_hierarchy
REPort HIer_compare Result -dynamicflattened
REPort VErification -hier -verbose
SET SYstem Mode lec
WRIte COmpared Points noneq.compared_points.statistics_unit.rtl.fv_map.tcl -class noneq -tclmode -replace
ANAlyze NOnequivalent -source_diagnosis
REPort NOnequivalent Analysis
REPort TEst Vector -noneq
SET SYstem Mode setup
WRIte VErification Information
REPort VErification Information
REPort IMplementation Information
SET SYstem Mode lec
ANAlyze RESults -logfiles /home/e.radionova/Desktop/digital_flow_2026/lab2/run/genus/reports/rtl2final.lec.log
