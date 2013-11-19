	.section .text
	.extern main

start:
	/* Switch to User Mode */
	/* and unset interrupt mask bits */
	mov  r0, #0x00000000
	teqp pc, r0 

	/* Enable the cache */
#if 0
	mov  r0, #0x0fffffff
	mcr  15, 0, r0, cr3, cr0, 0   /* cacheable area */
	mov  r0, #1
	mcr  15, 0, r0, cr2, cr0, 0   /* cache enable */
#endif

	/* initialize the stack pointer */
	mov  sp, #0x00010000

	/* jump to main */
	bl main

	/* freeze in endless loop */
endloop:
	b endloop
