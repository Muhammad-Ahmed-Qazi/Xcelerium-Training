# run.do — Questa simulation script for multiplier TB

# Clean libraries
if { [file exists work] } { vdel -all }
vlib work
vmap work work

# Compile design and TB files
vlog -sv \
    mult_if.sv \
    mult_tb_pkg.sv \
    adder_tree_multiplier_top.sv \
    tb_multiplier.sv

# Elaborate with ARRAY_MULT enabled (comment this line and uncomment the next
# one if you want to simulate the adder-tree implementation)
vopt -sv tb_multiplier +define+ARRAY_MULT -o tb_multiplier_opt -voptargs=+acc=npr

# For adder-tree only:
# vopt -sv tb_multiplier -o tb_multiplier_opt -voptargs=+acc=npr

# Run simulation
vsim tb_multiplier_opt

# Optional waveform setup
add wave -r /*
run -all
quit -f
