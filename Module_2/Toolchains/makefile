SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/4b_full_adder.sv

TOPLEVEL = full_adder_4bit           # Name of the Verilog module
MODULE = testbench2        # Name of the Python file (without .py)

include $(shell cocotb-config --makefiles)/Makefile.sim
