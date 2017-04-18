
EnableGpioIRQ:
	ldr		r0, =0x7E20004C			// Get address of GPREN0
	ldr		r1, [r0]				// Load value at GPREN0
	orr		r1, #0x400				// Turn on bit 10
	str		r1, [r0]				// Store value to enable GPIO line 10 to trigger corresponding bit in GPSED0

	ldr		r0, =0x7E00B214			// Enable IRQs 2
	mov		r1, #0x001E0000			// bits 17 to 20 set (IRQs 49 to 52)
	str		r1, [r0]				// Storing this value allows these bits to trigger IRQ pending status in the IRQ Pending 2 Register

	// Enable IRQ Globally
	mrs		r0, cpsr
	bic		r0, #0x80
	msr		cpsr_c, r0


SampleIRQHandler:	
	// test if there is an interrupt pending in IRQ Basic Pending
	ldr		r0, =0x3F00B200 // IRQ Basic Pending
	ldr		r1, [r0]
	tst		r1, #0x200		// bit 9 corresponds to IRQ pending 2
	beq		irqEnd

	// test that at least one GPIO IRQ line caused the interrupt
	ldr		r0, =0x3F00B208		// IRQ Pending 2 register
	ldr		r1, [r0]
	tst		r1, #0x001E0000
	beq		irqEnd

	// test if GPIO line 10 caused the interrupt
	ldr		r0, =0x3F200040		// GPIO event detect status register (GPSED0)
	ldr		r1, [r0]			//
	tst		r1, #0x400			// bit 10
	beq		irqEnd


	// do something with information (Line 10 triggered IRQ)
	
	// clear bit 10 in the event detect register to acknowledge the interrupt was received
	ldr		r0, =0x3F200040
	mov		r1, #0x400
	str		r1, [r0]
	
	

InstallIntTable:
	ldr		r0, =IntTable
	mov		r1, #0x00000000

	// load the first 8 words and store at the 0 address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// load the second 8 words and store at the next address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// switch to IRQ mode and set stack pointer
	mov		r0, #0xD2
	msr		cpsr_c, r0
	mov		sp, #0x8000

	// switch back to Supervisor mode, set the stack pointer
	mov		r0, #0xD3
	msr		cpsr_c, r0
	mov		sp, #0x8000000
	
	
	
	
	
	
	
	
	
IntTable:
	ldr		pc, reset_handler
	ldr		pc, undefined_handler
	ldr		pc, swi_handler
	ldr		pc, prefetch_handler
	ldr		pc, data_handler
	ldr		pc, unused_handler
	ldr		pc, irq_handler
	ldr		pc, fiq_handler

reset_handler:		.word InstallIntTable
undefined_handler:	.word hang
swi_handler:		.word hang
prefetch_handler:	.word hang
data_handler:		.word hang
unused_handler:		.word hang
irq_handler:		.word myIRQ
fiq_handler:		.word hang


hang:
	b	hang
