#!/bin/bash

if [ $# -ne 1 -o ! -d "$1" ]; then
	echo "Usage: $0 <design>" >&2
	exit 1
fi

set -ex
design=$1
. scripts/settings.sh

mkdir -p $design/gen
rm -f $design/gen/sim_modelsim
rm -f $design/gen/sim_modelsim.out

MODELSIM_DIR=/opt/altera/13.1/modelsim_ase/bin
$MODELSIM_DIR/vlib work
for f in $rtl_files $sim_files; do
	$MODELSIM_DIR/vlog +incdir+$design/rtl +incdir+$design/sim $f
done
$MODELSIM_DIR/vsim -c -do "run -all; exit" work.testbench | tee $design/gen/sim_modelsim.out
rm -rf transcript work

