.section	.text
	
.globl	myIRQA
.align

myIRQA:
	push	{r0-r12, lr}

	// test if there is an interrupt pending in IRQ Basic Pending
	ldr		r0, =0x3F00B200 // IRQ Basic Pending
	ldr		r1, [r0]
	tst		r1, #0x100		// bit 8 corresponds to IRQ pending 1
	beq		irqAEnd

	// test that Clock compare 1 caused the interrupt
	ldr		r0, =0x3F00B204		// IRQ Pending 1 register
	ldr		r1, [r0]
	tst		r1, #0b0010
	beq		irqAEnd



/// DO WHATEVER YOU WNT
	//mov 	r0, #0xFF00
	//lsl		r0, #1
	//bl 		InitLevel
	
	
	ldr		r1, =ObjectStates
	
GetRandom:
	bl		RandomBlock
		
	ldrb	r2, [r1, r0]
	
	cmp		r2, #0
	beq 	GetRandom
	
	
	bl		InitializePow
	
	bl		UsePow
	
	
	// clear bit 1 in the timer control/status register to acknowledge the interrupt was received
	ldr		r0, =0x3F003000			// Control/Status register for system timer
	mov		r1, #0b0010				// Clear bit 1 to acknowledge the IRQ request has been handled
	str		r1, [r0]				// 
	
	
irqAEnd:
	pop		{r0-r12, lr}
	subs	pc, lr, #4
	
	
	
	
.globl InitInterrupts
.align

InitInterrupts:
		
	// Enable IRQs in controller
	ldr		r0, =0x3F00B210			// Enable IRQs 1
	mov		r1, #0b0010				// bit 1 set (IRQ 1 is Timer Compare 1)
	str		r1, [r0]				// Allows 'timer compare 1' to trigger IRQ pending status in the
									// IRQ Pending Registers and to send an IRQ to the CPU?
	

	// Enable IRQs Globally
	mrs		r0, cpsr
	bic		r0, #0x80
	msr		cpsr_c, r0

	
		
	mov		r0, #1					//
	lsl		r0, #23					// ~ 8 seconds

	ldr		r1, =0x3F003004			// Address for low bits of system clock
	ldr		r1, [r1]				// Load value in low 32 bits of system clock
	add		r1, r0					// Add 30 seconds (30,000,000 microseconds)
	
	ldr		r0, =0x3F003010			// Address for timer compare 1
	str		r1, [r0]				// Store value in timer compare 1
	
	mov		pc, lr		


	
