.section	.text



//////////////////////////////////////////////////////////////////////
// * UpdateActiveAnimations checks the active animation structures
// *	and updates their current state and relevant level/game information
// *
// * Function is called when 12 <= tile's animation code <= 19
//////////////////////////////////////////////////////////////////////

.globl	UpdateActiveAnimations
.align

UpdateActiveAnimations:
	push	{r4, lr}
	
	ldr		r4, =ActiveBlockAnimation

	ldrb	r3, [r4, #9]			// Tile ID
	cmp		r3, #0
	beq		1f						// Check ActiveCoinAnim


	ldrb	r1, [r4, #8]			// Tile's animation stage 

	tst		r1, #0x3				// Check if animation reached end (all states are 0-3, 4 means end)
	bleq	UpdateBlock				// If so, Update level grid and active animation struct
	beq		1f

	//ELSE
	ldr		r1, [r4]				// Tile X
	ldr		r2, [r4, #4]			// Tile Y
	ldrb	r0, [r4, #8]			// Tile Stage of Animation
	
	cmp		r3, #1					// Tile ID
	bleq	DrawWoodBlock
	blgt	DrawQuestionBlock


	ldrb	r1, [r4, #8]			// Tile Animation Stage
	add		r1, #1					
	strb	r1, [r4, #8]			// Increment animation stage
	
	
	ldrb	r3, [r4, #9]			// Tile ID
	cmp		r3, #2					// Check if tile is question block
	bne		1f						// If not, branch out

	//ELSE -- trigger coin animation above block if block's animation stage == 1
	
	ldrb	r1, [r4, #8]			// Tile's animation stage 
	cmp		r1, #2
	bne		1f
	
	ldr		r1, [r4]				// QBlock X
	ldr		r2, [r4, #4]			// QBlock Y
	sub		r2, #32
	mov		r3, #0
	mov		r4, #1
	
	ldr		r0, =ActiveCoinAnimation
	str		r1, [r0]
	str		r2, [r0, #4]
	strb	r3, [r0, #8]
	strb	r4, [r0, #9]


1:	ldr		r4, =ActiveCoinAnimation

	ldrb	r2, [r4, #9]
	cmp		r2, #0
	beq		2f						

	ldrb	r1, [r4, #8]			// Tile's animation stage 

	cmp		r1, #4					// Check if animation reached end (all states are 0-3, 4 means end)
	bleq	UpdateCoin				// If so, Update level grid and active animation struct
	beq		2f

	//ELSE
	ldr		r1, [r4]				// Tile X
	ldr		r2, [r4, #4]			// Tile Y
	ldrb	r0, [r4, #8]			// Tile Stage of Animation
	bl		DrawCoin

	ldrb	r1, [r4, #8]			// Tile's animation stage 
	add		r1, #1
	strb	r1, [r4, #8]			// Increment animation stage

	
	
2:	pop		{r4, lr}
	mov		pc, lr
	
	
	
	
	
	
	
	
	
.align
.globl	UpdateBlock	
	
UpdateBlock:	
	push	{r4-r5, lr}
	
	
	ldr		r0, =ActiveBlockAnimation

	ldrb	r2, [r0, #9]			
	cmp		r2, #1					// 1 is Brick Tile
	bne		1f						


	ldr		r2, [r0]				// Tile X
	ldr		r3, [r0, #4]			// Tile Y

	
	add		r4, r3, r2, lsr #5		// Y + (X / 32) is tile # in level grid
	ldr		r1, =ObjectStates		// Address of level grid
	mov		r0, #0					// Set corresponding tile to 0
	strb	r0, [r1, r4]


	mov		r0, #32					// Patch over tile to be eliminated
	mov		r1, #32
	bl		PatchScreen

	b		2f



1:	cmp		r2, #2					// 2 is Question Block	
	bne		3f						

	ldr		r2, [r0]				// Tile X
	ldr		r3, [r0, #4]			// Tile Y

	
	add		r4, r3, r2, lsr #5		// Y + (X / 32) is tile # in level grid
	ldr		r1, =ObjectStates		// Address of level grid
	mov		r0, #19					// Set corresponding tile to 19 (Dead Question Block)
	strb	r0, [r1, r4]




2:	ldr		r0, =ActiveBlockAnimation
	mov		r1, #0
	strb	r1, [r0, #9]			//	Set Tile ID to 0(for no active animation)





3:	pop		{r4-r5, lr}
	mov		pc, lr
	
	
	
	
	
	
	

	
	
	
.align
.globl	UpdateCoin
	
UpdateCoin:	
	push	{r4-r5, lr}
	
	
	ldr		r5, =ActiveCoinAnimation


	ldr		r2, [r5]				// Tile X
	ldr		r3, [r5, #4]			// Tile Y

	
	add		r4, r3, r2, lsr #5		// Y + (X / 32) is tile # in level grid
	ldr		r1, =ObjectStates		// Address of level grid
	mov		r0, #0					// Set corresponding tile to 0
	strb	r0, [r1, r4]


	mov		r0, #32					// Patch over tile to be eliminated
	mov		r1, #32
	bl		PatchScreen


	mov		r1, #0
	strb	r1, [r5, #9]			// Set Tile ID to 0(for no active animation)


	ldr		r0, =GameState			// Set Game State Update byte to 1 to trigger update next round
	mov		r1, #1
	strb	r1, [r0, #6]



	pop		{r4-r5, lr}
	mov		pc, lr
	
