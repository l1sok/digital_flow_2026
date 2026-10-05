# ============================================================
# Xcelium Makefile
#
# Commands:
#   make        - compile + run
#   make gui    - run with GUI
#   make clean  - remove generated files
# ============================================================

XRUN := xrun

TEST ?= no_test

ifeq ($(TEST),stat)
    RTL := ../rtl/statistics_unit/statistics_unit.sv
    TB  := tb_statistics_unit.sv
else ifeq ($(TEST),proc)
    RTL := ../rtl/processing_unit/processing_unit.sv
    TB  := tb_processing_unit.sv
else ifeq ($(TEST),top)
    RTL := ../rtl/processing_system/processing_system.sv
    TB  := tb_top.sv
else
    $(error Unknown TEST = $(TEST). Use stat, proc or top)
endif

TOP := tb


XRUN_OPTS := \
	-sv \
	-timescale 1ns/1ps \
	-access +rwc \
	-top $(TOP)

WAVES := waves_$(TEST).shm

.PHONY: all run gui clean

all: run

run:
	$(XRUN) \
		$(XRUN_OPTS) \
		$(RTL) \
		$(TB) \
		-input dump.tcl

gui:
	$(XRUN) \
		$(XRUN_OPTS) \
		$(RTL) \
		$(TB) \
		-gui \
		-input dump.tcl

clean:
	rm -rf \
		xcelium.d \
		waves_*.shm \
		xrun.log \
		xrun.history \
		*.key
