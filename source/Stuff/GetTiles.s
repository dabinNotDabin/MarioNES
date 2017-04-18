.section	.text


//////////////////////////////////////////////////////////////////////
// * GetTilesBothFlags uses Marios position and the knowledge that
// *	both Horizontal and Vertical offset is not a multiple of
// *	32 pixels. This implies certain possibilities for collisions.
// *
// * Input:
// * 	r0 - Column : Marios column in the m X n grid (top left corner)
// * 	r1 - Row    : Marios  row   in the m X n grid (top left corner)
// *
// * Sets information in a structure implemented as a global variable.
// *
// * Returns:
// * 	r0 - Collision Flag : 0 iff no collisions, else 1
//////////////////////////////////////////////////////////////////////


.globl GetTilesBothFlags
.align

GetTilesBothFlags
	push	{lr}
	
	bl		InitCollisionOccurrances
	
	ldr		r2, =CollisionOccurrances
	ldr		r2, =CollisionMap		// Array representing tile collide properties
	add		r3, r0, r1, lsl #5		// (row * 32) + column
	add		r2, r3					// First tile to check

	mov		r0, #0					// Returns 0 if no collisions
	
	ldrb	r3, [r2]				// Get Value of first tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #1]!			// Get Value of second tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #31]!			// Get Value of third tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #1]			// Get Value of fourth tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	
	
	pop		{lr}					// Restore registers
	mov		pc, lr					// Return
	
	
	
	
	
	
	
	
	
//////////////////////////////////////////////////////////////////////
// * GetTilesHFlag uses Marios position and the knowledge that
// *	just the Horizontal offset is not a multiple of 32 pixels
// *	This implies certain possibilities for collisions.
// *
// * Input:
// * 	r0 - Column : Marios column in the m X n grid (top left corner)
// * 	r1 - Row    : Marios  row   in the m X n grid (top left corner)
// *
// * Sets information in a structure implemented as a global variable.
// *
// * Returns:
// * 	r0 - Collision Flag : 0 iff no collisions, else 1
//////////////////////////////////////////////////////////////////////



.globl GetTilesHFlag
.align

GetTilesHFlag
	push	{lr}
	
	bl		InitCollisionOccurrences
	
	ldr		r2, =CollisionOccurrences
	ldr		r2, =CollisionMap		// Array representing tile collide properties
	sub		r1, #1					// row = row - 1
	add		r3, r0, r1, lsl #5		// ((row-1) * 32) + column
	add		r2, r3					// First tile to check
	
	mov		r0, #0					// Returns 0 if no collisions
	
	ldrb	r3, [r2]				// Get Value of first tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #1]!			// Get Value of second tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #31]!			// Get Value of third tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #1]!			// Get Value of fourth tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1
	
	ldrb	r3, [r2, #31]!			// Get Value of third tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #1]!			// Get Value of fourth tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1

	
	pop		{lr}					// Restore registers
	mov		pc, lr					// Return
	
	
	
	
	
	
	
	
	
//////////////////////////////////////////////////////////////////////
// * GetTilesVFlag uses Marios position and the knowledge that
// *	just the Vertical offset is not a multiple of 32 pixels
// *	This implies certain possibilities for collisions.
// *
// * Input:
// * 	r0 - Column : Marios column in the m X n grid (top left corner)
// * 	r1 - Row    : Marios  row   in the m X n grid (top left corner)
// *
// * Sets information in a structure implemented as a global variable.
// *
// * Returns:
// * 	r0 - Collision Flag : 0 iff no collisions, else 1
//////////////////////////////////////////////////////////////////////



.globl GetTilesVFlag
.align

GetTilesVFlag
	push	{lr}
	
	bl		InitCollisionOccurrences
	
	ldr		r2, =CollisionOccurrences
	ldr		r2, =CollisionMap		// Array representing tile collide properties
	sub		r0, #1					// column = column - 1
	add		r3, r0, r1, lsl #5		// (row * 32) + (column - 1)
	add		r2, r3					// First tile to check
	
	mov		r0, #0					// Returns 0 if no collisions
	
	ldrb	r3, [r2]				// Get Value of first tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #1]!			// Get Value of second tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #1]!			// Get Value of third tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #30]!			// Get Value of fourth tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1
	
	ldrb	r3, [r2, #1]!			// Get Value of third tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #1]!			// Get Value of fourth tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1

	
	pop		{lr}					// Restore registers
	mov		pc, lr					// Return
	
	
	
	
	
	
	
//////////////////////////////////////////////////////////////////////
// * GetTilesNoFlags uses Marios position and the knowledge that
// *	both Horizontal and Vertical offset is a multiple of
// *	32 pixels. This implies certain possibilities for collisions.
// *
// * Input:
// * 	r0 - Column : Marios column in the m X n grid (top left corner)
// * 	r1 - Row    : Marios  row   in the m X n grid (top left corner)
// *
// * Sets information in a structure implemented as a global variable.
// *
// * Returns:
// * 	r0 - Collision Flag : 0 iff no collisions, else 1
//////////////////////////////////////////////////////////////////////


.globl GetTilesNoFlags
.align

GetTilesNoFlags
	push	{lr}
	
	bl		InitCollisionOccurrences
	
	ldr		r2, =CollisionOccurrences
	ldr		r2, =CollisionMap		// Array representing tile collide properties
	sub		r1, #1					// row = row - 1
	add		r3, r0, r1, lsl #5		// ((row-1) * 32) + column
	add		r2, r3					// First tile to check
	
	mov		r0, #0					// Returns 0 if no collisions
	
	ldrb	r3, [r2]				// Get Value of first tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #31]!			// Get Value of second tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #2]!			// Get Value of third tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	add		r12, #1

	ldrb	r3, [r2, #31]			// Get Value of fourth tile (1 == collidable, 0 == passable)
	cmp		r3, #1
	streqb	r2, [r12]
	moveq	r0, #1
	
	
	pop		{lr}					// Restore registers
	mov		pc, lr					// Return
	
	
	
	
	
	
	
	
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
	
	strb	r1, [r0], #1
	strb	r1, [r0], #1
	strb	r1, [r0], #1
	strb	r1, [r0], #1
	strb	r1, [r0], #1
	strb	r1, [r0]
	
	pop		{lr}					// Restore registers
	mov		pc, lr					// Return


