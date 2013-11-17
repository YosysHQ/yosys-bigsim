#!/bin/bash

source scripts/settings.sh

mkdir -p $design/gen
rm -f $design/gen/sim_rtl
rm -f $design/gen/sim_rtl.out

iverilog -o $design/gen/sim_rtl -I$design/rtl/ -I$design/sim/ $rtl_files $sim_files
$design/gen/sim_rtl | tee $design/gen/sim_rtl.out

