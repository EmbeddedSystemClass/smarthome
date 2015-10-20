-include Makefile.inc.linux
-include system.config

TARGETS = fw
BUILDDIR = build

.PHONY: all $(TARGETS) clean distclean help

all: $(TARGETS)

help:
	@echo "Targets:"
	@echo
	@echo "	DEBUG			enable debug output to USART1 in all firmware parts"

$(TARGETS):
	@$(MAKE) -C $@ $(MAKECMDGOALS)

clean: $(TARGETS)

distclean:
	rm -f shared/config.h
	rm -rf build output
	rm -rf build output output_elf

output: $(TARGETS)
