#!/bin/bash

set -ex
for design in openmsp430 aes_5cycle_2stage; do
	bash scripts/sim_rtl.sh $design
	bash scripts/sim_synth1.sh $design
	cmp $design/gen/sim_rtl.out $design/gen/sim_synth1.out
done

