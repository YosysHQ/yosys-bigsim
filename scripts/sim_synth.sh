#!/bin/bash

source scripts/settings.sh

mkdir -p $design/gen
rm -f $design/gen/synth.ys
rm -f $design/gen/synth.v
rm -f $design/gen/sim_synth
rm -f $design/gen/sim_synth.out

{
	for file in $rtl_files; do
		echo "read_verilog -I$design/rtl/ -I$design/sim/ $file"
	done
	if test -n "$TOP"; then
		echo "hierarchy -check -top $TOP"
	else
		echo "hierarchy -check"
	fi
	if $YOSYS_GLOBRST; then
		# insertation of global reset (e.g. for FPGA cores)
		echo "add -global_input globrst 1"
		echo "proc -global_arst globrst"
	else
		echo "proc"
	fi
	echo "opt; memory; opt; fsm; opt"
	if ! $YOSYS_COARSE; then
		# some simulations are just to slow on gate level
		echo "techmap; opt; abc; clean"
	fi
	if $YOSYS_SPLITNETS; then
		# icarus verilog has a performance problems when there are
		# dependencies between the bits of a long vector
		echo "splitnets; clean"
	fi
	if $YOSYS_COARSE; then
		echo "write_verilog -noexpr -noattr $design/gen/synth.v"
	else
		echo "write_verilog -noattr $design/gen/synth.v"
	fi
} > $design/gen/synth.ys
yosys -v2 -l $design/gen/synth.log $design/gen/synth.ys

if $YOSYS_COARSE; then
	sim_files="$sim_files $( yosys-config --datdir/simlib.v )"
fi

iverilog -s testbench -o $design/gen/sim_synth -I$design/rtl/ -I$design/sim/ $design/gen/synth.v $sim_files
vvp -n -l $design/gen/sim_synth.out $design/gen/sim_synth

