
QUICK_DESIGNS = openmsp430 aes_5cycle_2stage softusb_navre verilog-pong elliptic_curve_group
DESIGNS = amber23 reed_solomon_decoder $(QUICK_DESIGNS)

default:
	@echo "Usage: make [-j8] { quick | full }"

quick: $(addsuffix /gen/test.ok,$(QUICK_DESIGNS))
	@echo ""
	@echo "           ALL QUICK TESTS PASSED."
	@echo ""

full: $(addsuffix /gen/test.ok,$(DESIGNS)) 
	@echo ""
	@echo "           ALL TESTS PASSED."
	@echo ""

# setting .SECONDARY to empty prohibits deletion of all intermediate targets
.SECONDARY:

%/gen/sim_rtl.out:
	bash scripts/sim_rtl.sh $(subst /gen/sim_rtl.out,,$@)

%/gen/sim_synth.out:
	bash scripts/sim_synth.sh $(subst /gen/sim_synth.out,,$@)

%/gen/test.ok: %/gen/sim_rtl.out %/gen/sim_synth.out
	cmp $(word 1,$^) $(word 2,$^)

timing:
	$(MAKE) clean
	echo; for d in $(DESIGNS); do \
		echo "--------------------------------------"; echo; \
		( set -x; time bash -c "bash scripts/sim_rtl.sh   $$d > /dev/null 2>&1" ); echo; \
		( set -x; time bash -c "bash scripts/sim_synth.sh $$d > /dev/null 2>&1" ); echo; \
	done; echo "--------------------------------------"; echo
	$(MAKE) all

clean:
	rm -rf */gen/

