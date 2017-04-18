.globl	PatchMario
.align

PatchMario:
	push	{lr}
	
	
	ldr		r1, =MarioState
	ldr		r0, [r1, #8]				// New Mario X
	ldr		r1, [r1, #12]				// New Mario Y
	
	ldr		r3, =MarioBackupState
	ldr		r2, [r3, #8]				// Old Mario X
	ldr		r3, [r3, #12]				// Old Mario Y
		
	cmp		r2, r0						// Old MarioX VS New MarioX
	bgt		1f							
	
	// OldX <= NewX
	sub		r0, r0, r2					// Width of Patch is NewX - OldX
	mov		r1, #32						// Height is 32
										// Starting X,Y are OldX,OldY
	bl		PatchMove2PX
	b		2f


	// OldX > NewX
1:	sub		r0, r2, r0					// Width of patch is OldX - NewX
	mov		r1, #32						// Height is 32
	add		r2, r0, #32					// Starting X is NewX+32
										// Starting Y is OldY
	bl		PatchMove2PX
	
	
	
2:	ldr		r1, =MarioState
	ldr		r0, [r1, #8]				// New Mario X
	ldr		r1, [r1, #12]				// New Mario Y
	
	ldr		r3, =MarioBackupState
	ldr		r2, [r3, #8]				// Old Mario X
	ldr		r3, [r3, #12]				// Old Mario Y
	
	

	cmp		r3, r1						// OldY VS NewY
	bgt		3f

	// OldY <= NewY
	mov		r0, #32						// Width of patch is 32						
	sub		r1, r1, r3					// Height is NewY - OldY
										// Starting X,Y are OldX,OldY
	bl		PatchMove2PX
	b		4f
	
	
	// OldY > NewY
3:	mov		r0, #32						// Width of patch is 32						
	sub		r1, r3, r1					// Height is OldY - NewY
										// Starting X is OldX
	add		r3, r1, #32					// Starting Y is NewY + 32	
	bl		PatchMove2PX
	
	
4:	pop		{lr}
	mov		pc, lr
	
	
	
	
	