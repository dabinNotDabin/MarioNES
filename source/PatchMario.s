.globl	PatchMario
.align

PatchMario:
	push	{r4, lr}

	ldr		r3, =MarioState
	ldr		r0, [r3, #8]				// New Mario X
	ldr		r1, [r3, #12]				// New Mario Y
	ldr		r2, [r3, #16]				// Old Mario X
	ldr		r3, [r3, #20]				// Old Mario Y
	
	mov		r4, r2

	cmp		r2, r0
	addgt	r2, r0, #32					// If OldX > NewX -- Starting X,Y are NewX+32,OldY
										// ELSE Starting X,Y are OldX,OldY
	subs	r0, r4						// Width of patch is  abs(NewX - OldX)
	mvnlt	r0, r0
	addlt	r0, #1
	mov		r1, #32						// Height of patch is 32
	bl		PatchMove2PX

	
	ldr		r3, =MarioState
	ldr		r0, [r3, #8]				// New Mario X
	ldr		r1, [r3, #12]				// New Mario Y
	ldr		r2, [r3, #16]				// Old Mario X
	ldr		r3, [r3, #20]				// Old Mario Y

	mov		r4, r3
	
	cmp		r3, r1						// OldY VS NewY
	addgt	r3, r1, #32					// Starting X,Y are OldX,NewY+32	
										// ELSE Starting X,Y are OldX,OldY
	mov		r0, #32						// Width of patch is 32						
	subs	r1, r4						// Height of patch is  abs(OldY - NewY)
	mvnlt	r1, r1
	addlt	r1, #1
	bl		PatchMove2PX
	
	

	ldr		r0, =MarioState
	mov		r1, #0
	strb	r1, [r0, #7]				// Mario move bit, 0 moved in after patch to reset move bit
	
	
	
4:	pop		{r4, lr}
	mov		pc, lr
	
	
	
	



.globl	BackupMario
.align

BackupMario:

	ldr		r0, =MarioState
	
	ldr		r1, [r0, #8]
	str		r1, [r0, #16]
	
	ldr		r1, [r0, #12]
	str		r1, [r0, #20]
	
	
	mov		pc, lr
