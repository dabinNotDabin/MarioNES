.section	.text








.globl	InitializeMainMenu
.align
	
InitializeMainMenu:
	push	{lr}
	
	ldr		r0, =MM2
	mov		r1, #0
	mov		r2, #0
	bl		DrawUniformPicture


	ldr		r0, =GameState
	mov		r1, #0
	strb	r1, [r0, #1]


	bl		InitMainMenu2


	pop		{lr}
	mov		pc, lr
	
	




	
.globl	InitializePauseMenu
.align

InitializePauseMenu:
	push	{lr}
	
//	ldr		r0, =PauseMenuImg
//	mov		r1, #256
//	mov		r2, #256
//	bl		DrawPicture

	
	
	//This Code pauses the interrupts
	ldr		r0, =0x3F003004
	ldr 	r1, [r0]
	
	
	ldr		r0, =0x3F003010			//Load the value of timer compare 1
	ldr 	r2, [r0]
	
	sub 	r4, r2, r1				//Time left in interrupts
	
	mrs 	r0, cpsr				
	orr 	r0, #0x80					//Clears CPSR
	msr		cpsr_c, r0

	mov		r0, #0

PauseMenuLoop:	
	bl		PauseMenu
	ldr		r1, =0xFFFFFFFF
	cmp		r0, r1
	
	bne		PauseMenuLoop
	
	//Re-enable interrupts
	// clear bit 1 in the timer control/status register to acknowledge the interrupt was received
	ldr		r0, =0x3F003000			// Control/Status register for system timer
	mov		r1, #0b0010				// Clear bit 1 to acknowledge the IRQ request has been handled
	str		r1, [r0]				// 
	
	
	mrs		r0, cpsr
	bic		r0, #0x80
	msr		cpsr_c, r0				//Re-enable IRQs
	
	
	ldr		r0, =0x3F003004			//Load current time
	ldr		r1, [r0] 
	
	add		r1, r4					//Add the difference from before
	
	ldr 	r0, =0x3F003010			//Load from Timer compare 1
	str 	r1,	[r0]				//Set new compare timer
	
	
1:	pop		{lr}
	mov		pc, lr





	
	
	
	
	
	
.globl	InitObjectStates
.align

InitObjectStates:
		push	{r4-r11}
		
		mov		r4,	 #0
		mov		r5,	 #0
		mov		r6,	 #0
		mov		r7,	 #0
		mov		r8,	 #0
		mov		r9,	 #0
		mov		r10, #0
		mov		r11, #0
		

		ldr		r0, =ObjectStates
		add		r1, r0, #768		
	
		b		check	
		
top:
		stmltia	r0!, {r4-r11}

check:	
		cmp		r0, r1
		blt		top
		
			
		pop		{r4-r11}
		mov		pc, lr
	
	
	
	
	

	
	
	
	
	
		
	
//////////////////////////////////////////////////////////////////////
// * InitCollisionOccurrences initializes the CollisionOccurrances data
// * 	structure where all values == -1
// *  
// * This gives a default value to be skipped when processing collision
// * 	information.
// *
// * This structure represents the set of tiles Mario may be in 
// * 	collision with (-1 for no collision) and their position
// * 	relative to Mario is implicit in their ordering when under
// * 	a context defined by the function that is using this data.
//////////////////////////////////////////////////////////////////////
.globl InitCollisionOccurrences
.align

InitCollisionOccurrences:
	push	{lr}

	ldr		r0, =CollisionOccurrences
	mov		r1, #-1
	
	strb	r1, [r0]
	strb	r1, [r0, #1]
	strb	r1, [r0, #2]
	strb	r1, [r0, #3]
	strb	r1, [r0, #4]
	strb	r1, [r0, #5]
	strb	r1, [r0, #6]
	strb	r1, [r0, #7]




	pop		{lr}					// Restore registers
	mov		pc, lr					// Return

	
	
	
	
	
	
	



.globl      InitMarioState
.align

InitMarioState:
	
	ldr		r0, =MarioState
	
	
	mov 	r1, #0					// Stage of animation
	strb	r1, [r0]				 
	strb	r1, [r0, #2]			// Horizontal Velocity
	strb	r1, [r0, #4]			// Vertical Velocity
	strb	r1, [r0, #5]			// Collision Status
	strb	r1, [r0, #6]			// Vertical Offset
	strb	r1, [r0, #7]			// Collision Direction

	mov		r1, #64					
	str		r1, [r0, #8]			// TopLeft X coord
	str		r1, [r0, #16]

	ldr 	r1, =672
	str		r1, [r0, #12]			// TopLeft Y coord
	str		r1, [r0, #20]
	

	mov 	r1, #2
	strb	r1, [r0, #1]			// Horizontal Direction
	strb	r1, [r0, #3]			// Vertical Direction


	mov		pc, lr





.globl      InitGameState
.align

InitGameState:
	
	ldr		r0, =GameState
	
	
	mov 	r1, #0					
	strb	r1, [r0]				// Map Instance 

	strb	r1, [r0, #3]			// Coins
	strb	r1, [r0, #4]			// Win byte
	strb	r1, [r0, #5]			// Lose byte
	strb	r1, [r0, #6]			// Game Info update byte
	strb	r1, [r0, #12]			// Map Instance Shift Occurred byte
	str		r1, [r0, #8]			// Mario Score
	
	
	mov 	r1, #15
	strb	r1, [r0, #2]			// Mario Lives

	mov		pc, lr







.globl	InitSpriteArray
.align

InitSpriteArray:
		
	ldr		r0, =SpriteObj
	mov		r1, #0
	str		r1, [r0]
	
	ldr		r0, =SpritePointer
	ldr		r1, =SpriteStates
	str		r1, [r0]


	mov		pc, lr






	
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
	lsl		r0, #25					// ~ 30 seconds

	ldr		r1, =0x3F003004			// Address for low bits of system clock
	ldr		r1, [r1]				// Load value in low 32 bits of system clock
	add		r1, r0					// Add 30 seconds (30,000,000 microseconds)
	
	ldr		r0, =0x3F003010			// Address for timer compare 1
	str		r1, [r0]				// Store value in timer compare 1
	
	mov		pc, lr		




