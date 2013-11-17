
. $design/sim/settings.sh

rtl_files=""
for src in $RTL; do
	rtl_files="$rtl_files $design/rtl/$src"
done

sim_files=""
for src in $SIM; do
	sim_files="$sim_files $design/sim/$src"
done

