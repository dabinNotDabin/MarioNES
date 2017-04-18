.section	.text


//////////////////////////////////////////////////////////////////////
// * SetConstraintsDiagonal uses Marios position and the knowledge that
// *	both the Horizontal and Vertical offset is not a multiple of 32 pixels
// *	This implies certain possibilities for collisions.
// *
// *
// * Uses information from an external structure that indicates
// * 	which tiles have been collided with.
//////////////////////////////////////////////////////////////////////


.globl	SetConstraintsDiagonal
.align

SetConstraintsDiagonal:
	push		{r4-r9, lr}


	
	ldr		r6, =MarioState
	ldr		r4, [r6, #8]			// Mario top left x coord
	ldr		r5, [r6, #12]			// Mario top left y coord
	
	mov		r3, #0x1F				// For masking bottom 5 bits
	and		r0, r4, r3				// r0 contains bottom 5 bits of x coord
	and		r1, r5, r3				// r1 contains bottom 5 bits of y coord
	ldr		r2, =CollisionOccurrences
	add		r2, #4					// First 4 collision occurrence tiles correspond to top, bot, left, right
									// Next 4 correspond to Top L, Top R, Bot L, Bot R
	
////////////////////////////////////////////////////////////
///////////////////////// TOP LEFT /////////////////////////
////////////////////////////////////////////////////////////

	ldrb	r3, [r2], #1			// Get first tile (Mario's Top Left)
	cmp		r3, #0xFF				// Check if tile was collided
	beq		2f						// If not, branch out
	cmp		r0, r1					// Else, test if x overlap against y overlap
	bgt 	1f						// If gt, only shift horizontally 

	add		r7, r5, #32				// Else, Shift mario downwards by 32 px
	bic		r7, #0x1F				// Remove offset from 32px by 32px grid 
	str		r7, [r6, #12]			// Store new y coordinate
	mov		r3, #0
	strb	r3, [r6, #3]

	blt		2f						// Skip horizontal shift if x overlap < y overlap

	
1:	add		r7, r4, #32				// Else, Shift mario right by 32 px
	bic		r7, #0x1F				// Remove offset from 32px by 32px grid 
	str		r7, [r6, #8]			// Store new x coordinate
	mov		r3, #2
	strb	r3, [r6, #1]
	mov		r3, #0
	strb	r3, [r6, #2]
	
	mov		r3, #1					// Store 1 in move bit to indicate Mario was moved this loop
	strb	r3, [r6, #7]
	
2:	
	
	
////////////////////////////////////////////////////////////
//////////////////////// TOP RIGHT /////////////////////////
////////////////////////////////////////////////////////////

	ldrb	r3, [r2], #1			// Get second tile (Mario's Top Right)
	cmp		r3, #0xFF				// Check if tile was collided
	beq		2f						// If not, branch out
	mov		r3, #32					
	sub		r1, r3, r1
	cmp		r0, r1					// Test if x overlap against y overlap
	blt 	1f						// If lt, only shift horizontally 

	add		r7, r5, #32				// Else, Shift mario downwards by 32 px
	bic		r7, #0x1F				// Remove offset from 32px by 32px grid 
	str		r7, [r6, #12]			// Store new y coordinate
	mov		r3, #0
	strb	r3, [r6, #3]
	bgt		2f						// Skip horizontal shift if overlap of x > y
	
1:	bic		r7, r4, #0x1F			// Remove horizontal offset from 32px by 32px grid 
	str		r7, [r6, #8]			// Store new x coordinate
	mov		r3, #2
	strb	r3, [r6, #1]
	mov		r3, #0
	strb	r3, [r6, #2]
	
	mov		r3, #1					// Store 1 in move bit to indicate Mario was moved this loop
	strb	r3, [r6, #7]
	
2:	
	
	
////////////////////////////////////////////////////////////
////////////////////////// BOT LEFT ////////////////////////
////////////////////////////////////////////////////////////

	ldrb	r3, [r2], #1			// Get third tile (Mario's Bottom Left)
	cmp		r3, #0xFF				// Check if tile was collided
	beq		2f						// If not, branch out
	cmp		r0, r1					// Test if x overlap against y overlap
	bgt 	1f						// If gt, only shift horizontally 

	bic		r7, r5, #0x1F			// Remove vertical offset from 32px by 32px grid 
	str		r7, [r6, #12]			// Store new y coordinate
	mov		r3, #2
	strb	r3, [r6, #3]
	mov		r3, #0
	strb	r3, [r6, #6]
	strb	r3, [r6, #4]
	b		2f
	
//	blt		2f						// Skip horizontal shift if overlap of x < y
//////////^^^ MAY NEED TO SET TO B ALWAYS SO MARIO STAYS ON THE BLOCK AND DOESNT GET SHIFTED HORIZONTALLY WHEN X == Y
	
	
1:	add		r7, r4, #32				// Else, Shift mario right by 32 px
	bic		r7, #0x1F				// Remove horizontal offset from 32px by 32px grid 
	str		r7, [r6, #8]			// Store new x coordinate
	mov		r3, #2
	strb	r3, [r6, #1]
	mov		r3, #0
	strb	r3, [r6, #2]
	
	mov		r3, #1					// Store 1 in move bit to indicate Mario was moved this loop
	strb	r3, [r6, #7]
	
2:	
	
	
////////////////////////////////////////////////////////////
///////////////////////// BOT RIGHT ////////////////////////
////////////////////////////////////////////////////////////

	mov		r3, #0x1F				// For masking bottom 5 bits
	and		r0, r4, r3				// r0 contains bottom 5 bits of x coord
	and		r1, r5, r3				// r1 contains bottom 5 bits of y coord
	
	
	ldrb	r3, [r2]				// Get fourth tile (Marios Bottom Right)
	cmp		r3, #0xFF				// Check if tile was collided
	beq		2f						// If not, branch out
	cmp		r0, r1					// Else, test if x overlap against y overlap
	blt 	1f						// If lt, only shift horizontally 

	bic		r7, r5, #0x1F			// Remove vertical offset from 32px by 32px grid 
	str		r7, [r6, #12]			// Store new y coordinate
	mov		r3, #2
	strb	r3, [r6, #3]
	mov		r3, #0
	strb	r3, [r6, #6]
	strb	r3, [r6, #4]
	b		2f

//	bgt		2f						// Skip horizontal shift if overlap of x > y
//////////^^^ MAY NEED TO SET TO B ALWAYS SO MARIO STAYS ON THE BLOCK AND DOESNT GET SHIFTED HORIZONTALLY WHEN X == Y
	
1:	bic		r7, r4, #0x1F			// Remove horizontal offset from 32px by 32px grid 
	str		r7, [r6, #8]			// Store new x coordinate
	mov		r3, #2
	strb	r3, [r6, #1]
	mov		r3, #0
	strb	r3, [r6, #2]

	mov		r3, #1					// Store 1 in move bit to indicate Mario was moved this loop
	strb	r3, [r6, #7]
	
	
2:	pop		{r4-r9, lr}
	mov		pc, lr
	
	
	

	
	
	
	
	
	
//////////////////////////////////////////////////////////////////////
// * SetConstraintsInLine uses Marios position and the knowledge that
// *	Horizontal or Vertical offsets are a multiple of 32 pixels
// *	This implies certain possibilities for collisions.
// *
// *
// * Uses information from an external structure that indicates
// * 	which tiles have been collided with.
//////////////////////////////////////////////////////////////////////


.globl	SetConstraintsInline
.align

SetConstraintsInline:
	push		{r4-r7, lr}


	ldr		r6, =MarioState
	ldr		r4, [r6, #8]			// Mario top left x coord
	ldr		r5, [r6, #12]			// Mario top left y coord


	ldr		r2, =CollisionOccurrences


	ldrb	r0, [r2], #1			// Tile above Mario
	cmp		r0, #0xFF
	beq		1f

	mov		r3, #0
	strb	r3, [r6, #3]			// Vertical Direction to 0 (Down)
	add		r3, r5, #32				// Add 32 to y coord
	bic		r3, #0x1F				// Clear offset from grid to snap
	str		r3, [r6, #12]			// Store new y coord

	mov		r3, #1					// Store 1 in move bit to indicate Mario was moved this loop
	strb	r3, [r6, #7]
	
	
1:	ldrb	r0, [r2], #1			// Tile below Mario
	cmp		r0, #0xFF
	beq		2f

	mov		r3, #2
	strb	r3, [r6, #3] 			// Vertical Direction to 2 (NONE)
	mov		r3, #0
	strb	r3, [r6, #4] 			// Vertical Velocity to 0
	strb	r3, [r6, #6] 			// Vertical Offset to 0

	bic		r3, r5, #0x1F			// Clear offset from grid to snap
	str		r3, [r6, #12]			// Store new y coord

	mov		r3, #1					// Store 1 in move bit to indicate Mario was moved this loop
	strb	r3, [r6, #7]


2:	ldrb	r0, [r2], #1			// Tile left of Mario
	cmp		r0, #0xFF
	beq		3f

	mov		r3, #2
	strb	r3, [r6, #1] 			// Horizontal Direction to 2 (NONE)
	mov		r3, #0
	strb	r3, [r6, #2] 			// Horizontal Velocity to 0

	add		r3, r4, #32
	bic		r3, #0x1F				// Clear offset from grid to snap
	str		r3, [r6, #8]			// Store new x coord

	mov		r3, #1					// Store 1 in move bit to indicate Mario was moved this loop
	strb	r3, [r6, #7]



3:	ldrb	r0, [r2], #1			// Tile right of Mario
	cmp		r0, #0xFF
	beq		4f

	mov		r3, #2
	strb	r3, [r6, #1] 			// Horizontal Direction to 2 (NONE)
	mov		r3, #0
	strb	r3, [r6, #2] 			// Horizontal Velocity to 0

	bic		r3, r4, #0x1F			// Clear offset from grid to snap
	str		r3, [r6, #8]			// Store new x coord

	mov		r3, #1					// Store 1 in move bit to indicate Mario was moved this loop
	strb	r3, [r6, #7]


4:	pop		{r4-r7, lr}
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


	
	
