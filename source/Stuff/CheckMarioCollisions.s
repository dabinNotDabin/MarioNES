.section	.text


//////////////////////////////////////////////////////////////////////
// * Checks Marios position to determine which tiles in the m X n grid
// *	he may be in conflict with.
// * This may be up to 6 tiles so the helper functions set the tiles
// *	in the 'TileStruct' data structure according to its rules.
// * The helper functions set the TileStruct accordingly, then
// *	SetConstraints uses it to constrain the proposed movement
// *	to certain tiles.
//////////////////////////////////////////////////////////////////////


.globl CheckMarioCollisions
.align

CheckMarioCollisions:
	push	{r4-r7, lr}
	
	ldr		r0, =MarioState
	ldr		r6, [r0, #8]			// Mario top left x coord
	ldr		r7, [r0, #12]			// Mario top left y coord
	
	
	mov		r3, 0x1F
	
	tst		r6, r3
	movne	r4, #1					// Horizontal Flag set if x coord not evenly divisible by 32
	
	tst		r7, r3
	movne	r5, #1					// Vertical Flag set if y coord not evenly divisible by 32
	
	
	cmp		r4, #1					// If No Horizontal Flag
	bne		2f						// Branch down to 2
	cmp		r5, #1					// Else check for Vertical Flag in combination with Horizontal Flag
	bne		1f						// If no Vertical Flag, branch down to 1
	lsr		r0, r6, #5 				// Column arg for GetTilesBothFlags
	lsr		r1, r7, #5				// Row arg for GetTilesBothFlags
	bl		GetTilesBothFlags		// Else GetTilesBothFlags
	cmp		r0, #1					// Return from GetTiles is 1 if collision occurred
	bleq	SetConstraintsBothFlags
	b		4f						// Branch down to 4 
	
1:	lsr		r0, r6, #5 
	lsr		r1, r7, #5
	bl		GetTilesHFlag			// GetTilesHFlag - Only Horizontal Flag set
	cmp		r0, #1					// Return from GetTiles is 1 if collision occurred
	bleq	SetConstraintsHFlag
	b		4f						// Branch down to 4
	
	
2:	cmp		r5, #1					// Check for Vertical Flag in isolation
	bne		3f						// If none, branch down to 3
	lsr		r0, r6, #5 
	lsr		r1, r7, #5
	bl		GetTilesVFlag			// GetTilesVFlag - Only Vertical Flag set
	cmp		r0, #1					// Return from GetTiles is 1 if collision occurred
	bleq	SetConstraintsVFlag
	b		4f						// Branch down to 4
	
	
3:	lsr		r0, r6, #5 
	lsr		r1, r7, #5
	bl		GetTilesNoFlags			// GetTilesNoFlags - No flags set
	cmp		r0, #1					// Return from GetTiles is 1 if collision occurred
	bleq	SetConstraintsNoFlags
	
4:	pop		{r4-r7, lr}			// Restore registers
	mov		pc, lr					// Return
	
	
	
	
	
	
	
	