#!/bin/bash

set -ex
for tst in openmsp430; do
	. $tst/sim/settings.txt
	rm -rf $tst/gen
	mkdir $tst/gen
	rtl_files=""
	sim_files=""
	for src in $RTL; do
		rtl_files="$rtl_files $tst/rtl/$src"
	done
	for src in $SIM; do
		sim_files="$sim_files $tst/sim/$src"
	done
	{
		for file in $rtl_files; do
			echo "read_verilog -I$tst/rtl/ $file"
		done
		echo "hierarchy -top $TOP"
		echo "proc; fsm; opt; techmap; opt"
		echo "write_verilog -noattr $tst/gen/synth.v"
	} > $tst/gen/synth.ys
	yosys $tst/gen/synth.ys
	iverilog -o $tst/gen/sim_rtl -I$tst/rtl/ -I$tst/sim/ $rtl_files $sim_files
	iverilog -o $tst/gen/sim_synth -I$tst/rtl/ -I$tst/sim/ $tst/gen/synth.v $sim_files
	$tst/gen/sim_rtl | tee $tst/gen/sim_rtl.out
	$tst/gen/sim_synth | tee $tst/gen/sim_synth.out
	cmp $tst/gen/sim_rtl.out $tst/gen/sim_synth.out
done

