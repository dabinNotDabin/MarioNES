.section	.text


.globl UpdateMario
.align
UpdateMario:
	push	{lr}
	
	ldr		r3, =MarioState	
	
	ldr		r0, =ButtonsPressed
	ldr		r0, [r0]


CheckUp:
//	tst		r0, #0x00000010 		// Position of the up bit
	tst		r0, #0x00000100
	bne		CheckLeft

	ldrb	r1, [r3, #6]			// Vertical Offset
	cmp		r1, #0					// If vertical offset is 0 
	moveq	r1, #2					// Store 2 (NONE) in vertical direction
	streqb	r1, [r3, #3]
///// This fixes mario stuck on edge of block but also causes double jump bug


// CAUSES MARIO TO JUMP IMMEDIATELY IF JUMP BUTTON HELD

	ldrb	r1, [r3, #3]			// Vertical Direction byte; 2 == NONE
	cmp		r1, #2					// If 2, we will process jump command, else we are mid animation
	
	bne		CheckLeft				// Skip jump command if mid animation
	
	mov		r1, #0					// Set current offset from base to 0.
	strb	r1, [r3, #6]			// Offset from base byte, used to track animation
	strb	r1, [r3]				// Marios stage of animation is reset to 0

	mov		r1, #1					// Set vertical direction to 1
	strb	r1, [r3, #3]			// Vertical Direction byte; 1 == up
	
	mov		r1, #12					// Set vertical velocity to 12
	strb	r1, [r3, #4]			// Vertical Velocity byte

	
//	b		DoneUpdateMario
	/////////^^ Should maybe branch to CheckAButton?


	
CheckLeft:
	tst		r0, #0x00000040			// Position of the left bit
	bne		CheckRight 
	ldrb	r2, [r3, #1]			// Horizontal Direction byte; 1 == right
	
	cmp		r2, #1					// IF HORIZONTAL DIRECTION IS RIGHT AND THEY PRESS LEFT, WE SUBTRACT 4 FROM VELOCITY AND IF THE RESULT IS <= 0, WE INVERT DIRECTION
	bne		1f						

	ldrb	r1, [r3, #2]			// Horizontal Velocity byte
	subs	r1, #4					// Subtract 4 from current velocity
	strgeb	r1, [r3, #2]			// If greater than or equal to 0, we store new velocity
	beq		1f						// If equal to 0, we invert direction
	bgt		DoneUpdateMario			// If greater than 0 we exit since mario isnt done changing direction

	mov		r1, #0					// Only makes it here if velocity is negative
	strb	r1, [r3, #2]			// Horizontal Velocity byte

1:	mov		r1, #0					
	strb	r1, [r3, #1]			// Horizontal Direction byte; 0 == left

	b		DoneUpdateMario
	/////////^^ Should maybe branch to CheckAButton?

	
CheckRight:
	tst		r0, #0x00000080			// Position of the right bit
	bne		CheckAButton// Set H Di to 2?
	ldr		r3, =MarioState	
	ldrb	r2, [r3, #1]			// Horizontal Direction byte; 0 == left

	cmp		r2, #0					// IF HORIZONTAL DIRECTION IS LEFT AND THEY PRESS RIGHT, WE SUBTRACT 4 FROM VELOCITY AND IF THE RESULT IS <= 0, WE INVERT DIRECTION
	bne		1f						

	ldrb	r1, [r3, #2]			// Horizontal Velocity byte
	subs	r1, #4
	strgeb	r1, [r3, #2]
	beq		1f
	bgt		DoneUpdateMario

	mov		r1, #0
	strb	r1, [r3, #2]			// Horizontal Velocity byte

1:	mov		r1, #1					
	strb	r1, [r3, #1]			// Horizontal Direction byte; 1 == right

	b		DoneUpdateMario
	/////////^^ Should maybe branch to CheckAButton?

	
CheckAButton:	
	tst		r0, #0x00000100 		// Position of the A bit
	bne		DoneUpdateMario
	ldrb	r1, [r3, #3]			// Vertical Direction byte; 2 == NONE
	cmp		r1, #2					// If 2, we will process jump command, else we are mid animation
	bne		DoneUpdateMario			// Skip jump command if mid animation
	
	mov		r1, #0					// Set current offset from base to 0.
	strb	r1, [r3, #6]			// Offset from base byte, used to track animation
	strb	r1, [r3]				// Marios stage of animation is reset to 0
	
	mov		r1, #1					// Set vertical direction to 1
	strb	r1, [r3, #3]			// Vertical Direction byte; 1 == up
	
	b		DoneUpdateMario


	
DoneUpdateMario:


	pop		{lr}
	mov		pc, lr












.globl MoveMario
.align
MoveMario:
	push	{r4, lr}



UpDown:
	ldr		r3, =MarioState

	ldrb	r0, [r3, #3]			// Vertical Direction
	cmp		r0, #2					// Is his vertical direction 2 (NONE)
	beq		LeftRight				// If so check for Left/Right Movement

	
	mov		r1, #1					// Store 1 in move bit to indicate Mario was moved this loop
	strb	r1, [r3, #7]

	
	ldrb	r1, [r3, #6]			// Offset From Base byte
	ldr		r2, [r3, #12]			// Leftmost y coord


	cmp		r1, #0xFF				// If his offset is negative
	moveq	r1, #0					// Default it to 0
	

	cmp		r1, #8					// Check his offset from base
	bge		SlowerA					// If its 8 or more, movement is slower

	cmp		r0, #0					// Check Direction
	addeq	r2, #12					// If 0 (down) add 12 px from y coord
	subeq	r1, #1					// Decrement vertical offset from base
	subne	r2, #12					// If 1 (up) subtract 12 px from y coord
	addne	r1, #1					// Increment vertical offset from base
	str		r2, [r3, #12]			// Leftmost y coord
	strb	r1, [r3, #6]
	mov		r1, #12
	strb	r1, [r3, #4]
	
	b		LeftRight

		
SlowerA:
	cmp		r1, #11					// Check his offset from base
	bge		SlowerB					// If its 10 or more, movement is even slower

	cmp		r0, #0					// Check Direction
	addeq	r2, #8					// If 0 (down) add 8 px to y coord
	subeq	r1, #1					// Decrement vertical offset from base
	subne	r2, #8					// If 1 (up) subtract 8 px from y coord
	addne	r1, #1					// Increment vertical offset from base
	str		r2, [r3, #12]			// Leftmost y coord
	strb	r1, [r3, #6]
	mov		r1, #8
	strb	r1, [r3, #4]
	
	b		LeftRight
	
	
SlowerB:
	cmp		r1, #13					// Check his offset from base
	bge		InvertDirection			// If its 13 or more, invert his direction

	cmp		r0, #0					// Check Direction
	addeq	r2, #4					// If 0 (down) add 4 px from y coord
	subeq	r1, #1					// Decrement vertical offset from base
	subne	r2, #4					// If 1 (up) subtract 4 px from y coord
	addne	r1, #1					// Increment vertical offset from base
	str		r2, [r3, #12]			// Leftmost y coord
	strb	r1, [r3, #6]
	mov		r1, #4
	strb	r1, [r3, #4]

	b		LeftRight
	
	
InvertDirection:

	mov		r0, #0					// Only ever reach offset greater than 13 if moving upwards				
	strb	r0, [r3, #3]			// So store 0 (down) in vertical direction
	
	mov		r0, #12					// Set Offset to 12
	strb	r0, [r3, #6]			// Store offset
	


	
LeftRight:
	ldr		r3, =MarioState

	ldrb	r0, [r3, #1]			// Load Horizontal direction
	cmp		r0, #2					// Check if horizontal direction is 2 (NONE)
	beq		2f
	ldr		r1, [r3, #8]			// Load Leftmost x coord
	ldrb	r2, [r3, #2]			// Load Horizontal Velocity

	
	cmp		r0, #0					// Check horizontal direction against 1
	subeq	r1, r2					// Sub Velocity from x coord -- (moving left)
	addgt	r1, r2					// Add Velocity to x coord -- (moving right)
	str		r1, [r3, #8]			// Store new x coord
	mov		r1, #1					// Store 1 in move bit to indicate Mario was moved this loop
	strb	r1, [r3, #7]
	b		2f

	
2:	cmp		r2, #12					// Is velocity max (12)
	bge		DoneMoveMario			// If so, branch to DoneMoveMario, else ...
	add		r2, #2					// .... Add 2 to current velocity
	strb	r2, [r3, #2]			// Store new velocity


DoneMoveMario:

	pop		{r4, lr}
	mov		pc, lr












// Execute After Shift Check to Eliminate Checking Non Existent Tiles (OffScren)
.globl	DropCheck
.align

DropCheck:
	push	{r4, lr}
	
	
	ldr		r0, =MarioState
	ldrb	r1, [r0, #3]				// Mario Vertical Direction
	cmp		r1, #2						// 2 == NONE
	bne		2f							// If Mario is moving vertically, drop check is not necessary
	
	ldr		r1, [r0, #8]				// Mario x coord

	mov		r2, #0x1F					// Used to check is Mario is 'x-wise' aligned with 32px grid
	tst		r1, r2						// Test Marios X coord
	lsr		r1, #5						// Divide x coord by 32 to get x pos in level grid
	mov		r2, r1						// Move value into r2, used further down
	beq		1f							// If Mario was aligned, we only need to check the tile directly below him
	
	//ELSE
	ldr		r2, [r0, #8]				// Mario x coord
	add		r2, #31						// Add 31 px to Marios x coord 
	lsr		r2, #5						// Get x pos in level grid for second tile Mario is partially standing on
	

1:	ldr		r3, [r0, #12]				// Mario Y, we skip 32 square tiles per row of Mario's offset
	add		r3, #32						// Tile is 32 px below Mario (corresponds to 32 tiles in level grid)
//	bic		r3, #0x1F					// Round y coord even though Mario Y should always be a multiple of 32 if his vertical direction is 2(NONE)
	tst		r3, #0x1F					// Check that Mario is y-wise aligned, If not, get out of function
	bne		2f	

	add		r4, r1, r3					// Skip 32 tiles per row in level grid plus Tile X offset
	ldr		r3, =ObjectStates			
	ldrb	r3, [r3, r4]				// Load value from level grid
	cmp		r3, #0						// If greater than 0, tile is collidable, Else ..
	streqb	r3, [r0, #3]				// Tile is not collidable, Mario VDi == 0(Down) and 
	streqb	r3, [r0, #4]				// VVel == 0


	cmp		r2, r1						// If r2 == r1, then Mario was aligned vertically by 32 px
	beq		2f							//

	//ELSE
	ldr		r3, [r0, #12]				// Mario Y, we skip 32 square tiles per row of Mario's offset
	add		r3, #32						// Tile is 32 px below Mario (corresponds to 32 tiles in level grid)
//	bic		r3, #0x1F					// Round y coord even though Mario Y should always be a multiple of 32 if his vertical direction is 2(NONE)
	tst		r3, #0x1F					// Check that Mario is y-wise aligned, If not, get out of function
	bne		2f	

	add		r4, r2, r3					// Skip 32 tiles per row in level grid plus Tile X offset
	ldr		r3, =ObjectStates			
	ldrb	r3, [r3, r4]				// Load value from level grid
	cmp		r3, #0						// If greater than 0, tile is collidable, Else ..
	streqb	r3, [r0, #3]				// Tile is not collidable, Mario VDi == 0(Down) and 
	streqb	r3, [r0, #4]				// VVel == 0


	
	
2:	pop		{r4, lr}
	mov		pc, lr




