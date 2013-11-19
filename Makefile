
DESIGNS = openmsp430 aes_5cycle_2stage softusb_navre

all: $(addsuffix /gen/test.ok,$(DESIGNS)) 
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

