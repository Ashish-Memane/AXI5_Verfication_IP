# =========================================================================
# File Name   : Makefile
# Description : Universal Makefile for AXI5 Master VIP Verification
# =========================================================================

# SIMULATOR = Questa for Mentor's Questasim
# SIMULATOR = VCS for Synopsys's VCS
SIMULATOR = Questa

FSDB_PATH=/home/cad/eda/SYNOPSYS/VERDI_2022/verdi/T-2022.06-SP1/share/PLI/VCS/LINUX64

RTL   = ../rtl/*
work  = work
SVTB1 = ../tb/axi5_tb_top.sv

# Include Directories for AXI5 VIP
INC   = +incdir+../tb +incdir+../axi5_agent +incdir+../test

# Unified testbench package
SVTB2 = ../test/axi5_pkg.sv

VSIMOPT = -vopt -voptargs=+acc
VSIMCOV = -coverage -sva

# Batch Commands for Questa
VSIMBATCH_SANITY    = -c -do " log -r /* ;coverage save -onexit cov_sanity;run -all; exit"
VSIMBATCH_RAND      = -c -do " log -r /* ;coverage save -onexit cov_rand_burst;run -all; exit"
VSIMBATCH_NARROW    = -c -do " log -r /* ;coverage save -onexit cov_narrow;run -all; exit"
VSIMBATCH_UNALIGNED = -c -do " log -r /* ;coverage save -onexit cov_unaligned;run -all; exit"
VSIMBATCH_WRAP      = -c -do " log -r /* ;coverage save -onexit cov_wrap;run -all; exit"
VSIMBATCH_ATOMIC    = -c -do " log -r /* ;coverage save -onexit cov_atomic;run -all; exit"
VSIMBATCH_POISON    = -c -do " log -r /* ;coverage save -onexit cov_poison;run -all; exit"
VSIMBATCH_OOO       = -c -do " log -r /* ;coverage save -onexit cov_ooo;run -all; exit"

help:
        @echo =============================================================================================================
        @echo "! USAGE          --  make target                                                                           !"
        @echo "! clean          =>  Clean the earlier log and intermediate files.                                         !"
        @echo "! sv_cmp         =>  Create library and compile the code.                                                  !"
        @echo "! sanity         =>  Run axi5_sanity_test (Basic Write-after-Read loop)                                    !"
        @echo "! rand_burst     =>  Run axi5_rand_burst_test (Fully randomized transactions)                              !"
        @echo "! narrow         =>  Run axi5_narrow_transfer_test (Strobe alignment stress)                               !"
        @echo "! unaligned      =>  Run axi5_unaligned_addr_test (Cross-boundary stress)                                  !"
        @echo "! wrap           =>  Run axi5_wrap_burst_test (Cache-line wrap simulations)                                !"
        @echo "! atomic         =>  Run axi5_atomic_test (AXI5 AWATOP operations)                                         !"
        @echo "! poison         =>  Run axi5_poison_test (AXI5 Data Poisoning)                                            !"
        @echo "! ooo            =>  Run axi5_out_of_order_test (Interleaved/Parallel IDs)                                 !"
        @echo "! regress        =>  Clean, compile, and run ALL testcases in batch mode.                                  !"
        @echo "! report         =>  Merge coverage reports for all testcases and convert to HTML.                         !"
        @echo "! cov            =>  Open merged coverage report in HTML format.                                           !"
        @echo =============================================================================================================

clean: clean_$(SIMULATOR)
sv_cmp: sv_cmp_$(SIMULATOR)
regress: regress_$(SIMULATOR)
report: report_$(SIMULATOR)
cov: cov_$(SIMULATOR)

sanity: sanity_$(SIMULATOR)
rand_burst: rand_burst_$(SIMULATOR)
narrow: narrow_$(SIMULATOR)
unaligned: unaligned_$(SIMULATOR)
wrap: wrap_$(SIMULATOR)
atomic: atomic_$(SIMULATOR)
poison: poison_$(SIMULATOR)
ooo: ooo_$(SIMULATOR)

# ----------------------------- Start of Definitions for Mentor's Questa Specific Targets -------------------------------#

sv_cmp_Questa:
        vlib $(work)
        vmap work $(work)
        vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1)

sanity_Questa: sv_cmp_Questa
        vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH_SANITY) -wlf wave_sanity.wlf -l sanity.log -sv_seed random work.axi5_tb_top +UVM_TESTNAME=axi5_sanity_test
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html cov_sanity

rand_burst_Questa: sv_cmp_Questa
        vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH_RAND) -wlf wave_rand.wlf -l rand.log -sv_seed random work.axi5_tb_top +UVM_TESTNAME=axi5_rand_burst_test
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html cov_rand_burst

narrow_Questa: sv_cmp_Questa
        vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH_NARROW) -wlf wave_narrow.wlf -l narrow.log -sv_seed random work.axi5_tb_top +UVM_TESTNAME=axi5_narrow_transfer_test
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html cov_narrow

unaligned_Questa: sv_cmp_Questa
        vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH_UNALIGNED) -wlf wave_unaligned.wlf -l unaligned.log -sv_seed random work.axi5_tb_top +UVM_TESTNAME=axi5_unaligned_addr_test
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html cov_unaligned

wrap_Questa: sv_cmp_Questa
        vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH_WRAP) -wlf wave_wrap.wlf -l wrap.log -sv_seed random work.axi5_tb_top +UVM_TESTNAME=axi5_wrap_burst_test
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html cov_wrap

atomic_Questa: sv_cmp_Questa
        vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH_ATOMIC) -wlf wave_atomic.wlf -l atomic.log -sv_seed random work.axi5_tb_top +UVM_TESTNAME=axi5_atomic_test
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html cov_atomic

poison_Questa: sv_cmp_Questa
        vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH_POISON) -wlf wave_poison.wlf -l poison.log -sv_seed random work.axi5_tb_top +UVM_TESTNAME=axi5_poison_test
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html cov_poison

ooo_Questa: sv_cmp_Questa
        vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH_OOO) -wlf wave_ooo.wlf -l ooo.log -sv_seed random work.axi5_tb_top +UVM_TESTNAME=axi5_out_of_order_test
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html cov_ooo

report_Questa:
        vcover merge axi5_cov_merged cov_sanity cov_rand_burst cov_narrow cov_unaligned cov_wrap cov_atomic cov_poison cov_ooo
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html axi5_cov_merged

regress_Questa: clean_Questa sanity_Questa rand_burst_Questa narrow_Questa unaligned_Questa wrap_Questa atomic_Questa poison_Questa ooo_Questa report_Questa cov_Questa

cov_Questa:
        firefox covhtmlreport/index.html &

clean_Questa:
        rm -rf transcript* *log* fcover* covhtml* cov_* axi5_cov_merged* *.wlf modelsim.ini work
        clear

# ----------------------------- End of Definitions for Mentor's Questa Specific Targets -------------------------------#

# ----------------------------- Start of Definitions for Synopsys's VCS Specific Targets -------------------------------#

sv_cmp_VCS:
        vcs -l vcs_compile.log -timescale=1ns/1ps -sverilog -ntb_opts uvm -debug_access+all -full64 -kdb -lca -P $(FSDB_PATH)/novas.tab $(FSDB_PATH)/pli.a $(RTL) $(INC) $(SVTB2) $(SVTB1)

sanity_VCS: clean_VCS sv_cmp_VCS
        ./simv -a vcs_sanity.log +fsdbfile+wave_sanity.fsdb -cm_dir ./cov_sanity +ntb_random_seed_automatic +UVM_TESTNAME=axi5_sanity_test
        urg -dir cov_sanity.vdb -format both -report urgReport_sanity

rand_burst_VCS: sv_cmp_VCS
        ./simv -a vcs_rand.log +fsdbfile+wave_rand.fsdb -cm_dir ./cov_rand_burst +ntb_random_seed_automatic +UVM_TESTNAME=axi5_rand_burst_test
        urg -dir cov_rand_burst.vdb -format both -report urgReport_rand

narrow_VCS: sv_cmp_VCS
        ./simv -a vcs_narrow.log +fsdbfile+wave_narrow.fsdb -cm_dir ./cov_narrow +ntb_random_seed_automatic +UVM_TESTNAME=axi5_narrow_transfer_test
        urg -dir cov_narrow.vdb -format both -report urgReport_narrow

unaligned_VCS: sv_cmp_VCS
        ./simv -a vcs_unaligned.log +fsdbfile+wave_unaligned.fsdb -cm_dir ./cov_unaligned +ntb_random_seed_automatic +UVM_TESTNAME=axi5_unaligned_addr_test
        urg -dir cov_unaligned.vdb -format both -report urgReport_unaligned

wrap_VCS: sv_cmp_VCS
        ./simv -a vcs_wrap.log +fsdbfile+wave_wrap.fsdb -cm_dir ./cov_wrap +ntb_random_seed_automatic +UVM_TESTNAME=axi5_wrap_burst_test
        urg -dir cov_wrap.vdb -format both -report urgReport_wrap

atomic_VCS: sv_cmp_VCS
        ./simv -a vcs_atomic.log +fsdbfile+wave_atomic.fsdb -cm_dir ./cov_atomic +ntb_random_seed_automatic +UVM_TESTNAME=axi5_atomic_test
        urg -dir cov_atomic.vdb -format both -report urgReport_atomic

poison_VCS: sv_cmp_VCS
        ./simv -a vcs_poison.log +fsdbfile+wave_poison.fsdb -cm_dir ./cov_poison +ntb_random_seed_automatic +UVM_TESTNAME=axi5_poison_test
        urg -dir cov_poison.vdb -format both -report urgReport_poison

ooo_VCS: sv_cmp_VCS
        ./simv -a vcs_ooo.log +fsdbfile+wave_ooo.fsdb -cm_dir ./cov_ooo +ntb_random_seed_automatic +UVM_TESTNAME=axi5_out_of_order_test
        urg -dir cov_ooo.vdb -format both -report urgReport_ooo

report_VCS:
        urg -dir cov_sanity.vdb cov_rand_burst.vdb cov_narrow.vdb cov_unaligned.vdb cov_wrap.vdb cov_atomic.vdb cov_poison.vdb cov_ooo.vdb -dbname merged_dir/merged_test -format both -report urgReport_merged

regress_VCS: clean_VCS sv_cmp_VCS sanity_VCS rand_burst_VCS narrow_VCS unaligned_VCS wrap_VCS atomic_VCS poison_VCS ooo_VCS report_VCS

cov_VCS:
        verdi -cov -covdir merged_dir.vdb

clean_VCS:
        rm -rf simv* csrc* *.tmp *.vpd *.vdb *.key *.log *hdrs.h urgReport* *.fsdb novas* verdi*
        clear

# ----------------------------- END of Definitions for Synopsys's VCS Specific Targets -------------------------------#
