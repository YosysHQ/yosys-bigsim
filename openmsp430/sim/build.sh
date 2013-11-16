#!/bin/sh
set -ex
msp430-gcc -o demo.elf demo.c
msp430-objcopy -O ihex demo.elf demo.ihex
python ihex2vlog.py < demo.ihex > demo.v
rm -f demo.elf demo.ihex
