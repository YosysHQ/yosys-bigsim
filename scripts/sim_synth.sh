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
	echo "hierarchy -check -top $TOP"
	echo "proc; opt; memory; opt; fsm; opt; techmap; opt"
	if $YOSYS_SPLITNETS; then
		echo "splitnets; clean"
	fi
	echo "write_verilog -noattr $design/gen/synth.v"
} > $design/gen/synth.ys
yosys -v2 -l $design/gen/synth.log $design/gen/synth.ys

iverilog -s testbench -o $design/gen/sim_synth -I$design/rtl/ -I$design/sim/ $design/gen/synth.v $sim_files
vvp -n -l $design/gen/sim_synth.out $design/gen/sim_synth

