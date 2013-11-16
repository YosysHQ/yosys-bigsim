
#include <stdint.h>

int main()
{
	*((volatile uint16_t*)0x0023) = 23;
	*((volatile uint16_t*)0x0042) = 42;
	while (1) { }
}

