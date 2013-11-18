
DESIGNS = openmsp430 aes_5cycle_2stage # softusb_navre

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

clean:
	rm -rf */gen/

