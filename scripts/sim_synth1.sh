#!/bin/bash

source scripts/settings.sh

mkdir -p $design/gen
rm -f $design/gen/synth1.ys
rm -f $design/gen/synth1.v
rm -f $design/gen/sim_synth1
rm -f $design/gen/sim_synth1.out

{
	for file in $rtl_files; do
		echo "read_verilog -I$design/rtl/ $file"
	done
	echo "hierarchy -top $TOP"
	echo "proc; opt; memory; opt; fsm; opt; techmap; opt"
	echo "write_verilog -noattr $design/gen/synth1.v"
} > $design/gen/synth1.ys
yosys -v2 -l $design/gen/synth1.log $design/gen/synth1.ys

iverilog -s testbench -o $design/gen/sim_synth1 -I$design/rtl/ -I$design/sim/ $design/gen/synth1.v $sim_files
vvp -n -l $design/gen/sim_synth1.out $design/gen/sim_synth1

