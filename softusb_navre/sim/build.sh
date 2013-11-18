#!/bin/sh
set -ex
avr-gcc -o fib.elf -mmcu=avr2 -Os fib.S -nostdlib
avr-objcopy -O ihex fib.elf fib.ihex
python ihex2vlog.py < fib.ihex > fib.v
avr-objdump -d fib.elf
rm -f fib.elf fib.ihex
