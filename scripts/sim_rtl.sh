#!/bin/bash

if [ $# -ne 1 -o ! -d "$1" ]; then
	echo "Usage: $0 <design>" >&2
	exit 1
fi

set -ex
design=$1
. scripts/settings.sh

mkdir -p $design/gen
rm -f $design/gen/sim_rtl
rm -f $design/gen/sim_rtl.out

iverilog -o $design/gen/sim_rtl -I$design/rtl/ -I$design/sim/ $rtl_files $sim_files
$design/gen/sim_rtl | tee $design/gen/sim_rtl.out

