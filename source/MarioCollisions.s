.section	.text




//////////////////////////////////////////////////////////////////////
// * Checks Marios position to determine which tiles in the m X n grid
// *	he may be in conflict with.
//////////////////////////////////////////////////////////////////////


.globl CheckMarioCollisions
.align

CheckMarioCollisions:
	push	{r4-r11, lr}
	
	bl		InitCollisionOccurrences

	
	ldr		r0, =MarioState
	ldr		r8, [r0, #8]			// Mario x coord
	ldr		r9, [r0, #12]			// Mairo y coord


	
	ldr		r0, =ObjectStates

	mov		r4, #0
	mov		r5, #0x1F	
	

1:	ldrb	r10, [r0, r4]
	cmp		r10, #0
	beq		6f
	
	and		r6, r4, r5				// Remainder of tile no when divided by 32 (tile x coord)
	lsl		r6, #5					// Tile no 1 x coord is 32
	bic		r7, r4, #0x1F			// Tile no in increments of 32 (first 32 tiles y == 0, next 32 y == 1)

	sub		r3, r8, r6				// Mario x - Tile x

	cmp 	r3, #0					// Abs value of subtraction
    mvnlt 	r3, r3
    addlt 	r3, #1
	
	
	cmp		r3, #32
	bge		6f			


	sub		r3, r9, r7				// Mario y - Tile y

	cmp 	r3, #0					// Abs value of subtraction
    mvnlt 	r3, r3
    addlt 	r3, #1
	
	cmp		r3, #32
	bge		6f

	/////////// WE KNOW A COLLISION OCCURRED AT THIS POINT ///////////////

	// r6 == Tile X
	// r7 == Tile Y


	cmp		r10, #3
	bleq	UsePow

	cmp		r10, #3
	beq		RemoveFromGrid
	
	cmp		r10, #20				// If tile was a star or a coin, deal with separately
	bge		WinCoinCheck			// Branch to appropriate section
	

2:	ldr		r0, =ObjectStates
	ldrb	r0, [r0, r4]			// Tile involved in collision

	mov		r1, #0

	cmp		r0, #12					// Brick(object code is 12 in 1st animation stage)
	moveq	r1, #1					// Store 1 in active block animation to indicate the tile type collided with
	beq		StoreTileInfo
	cmpgt	r0, #16					// QBlock(object code is 16 in 1st stage)
	moveq	r1, #2					// Store 2 in active block animation to indicate the tile type collided with
	bne		NoStoreInfo
	

StoreTileInfo:	
	ldr		r0, =ActiveBlockAnimation
	mov		r3, #1

	str		r6, [r0]				// Store Tile's X coord
	str		r7, [r0, #4]			// Store Tile's Y coord
	strb	r3, [r0, #8]			// Set Tile's animation stage to 1
	strb	r1, [r0, #9]			// If neither Brick or QBlock, tile type is 0.
	
	ldr		r3, =MarioState

	ldrb	r2, [r3, #3]			// If Mario's vertical direction is 0 (DOWN), do not trigger animation
	cmp		r2, #0					
	moveq	r3, #0					// Set Tile ID to 0 
	streqb	r3, [r0, #9]
	
	mov		r11, r4				// Track Number of Animate-able Tile That Was Collided With
	
NoStoreInfo:
	ldr		r0, =CollisionOccurrences
	mov		r3, #1
	
	cmp		r9, r7
	bge		3f						// Mario Y >= Tile Y ?? If so, branch -- Else, its less than
	
	cmp		r8, r6					// Compare Mario X against Tile X
	strgtb	r3, [r0, #6]			// Indicates a collision on mario's bottom left
	strltb	r3, [r0, #7]			// Indicates a collision on mario's bottom right
	streqb	r3, [r0, #1]			// Indicates a collision on mario's bottom

	cmp		r4, r11					// Since any collision with an animate-able tile triggers an animation
	bne		5f						// A check is required to ensure that the collision was a valid trigger
	ldr		r0, =ActiveBlockAnimation
	mov		r2, #0					// If the block was collided with on it's top, remove the trigger for animation
	strb	r2, [r0, #9]				
						
	b		5f
			
	
3:	beq		4f						// Mario Y == Tile Y ?? If so, branch -- Else, is greater than
	
	cmp		r8, r6					// Compare Mario X against Tile X
	strgtb	r3, [r0, #4]			// Indicates a collision on mario's top left
	strltb	r3, [r0, #5]			// Indicates a collision on mario's top right
	streqb	r3, [r0, #0]			// Indicates a collision on mario's top

	b		5f
	
	
4:	cmp		r8, r6					// Here we know that Mario Y == Tile Y
	strgeb	r3, [r0, #2]			// Indicates a collision on mario's left
	strltb	r3, [r0, #3]			// Indicates a collision on mario's right

	cmp		r4, r11
	bne		5f		

	ldr		r0, =ActiveBlockAnimation
	mov		r2, #0		
	strb	r2, [r0, #9]				


	b		5f


	// Below, I use the newly acquired information to update states

WinCoinCheck:
	cmp		r10, #23				// Know r3 > 19, if between 20 and 23 inclusive, it's a coin
	bgt		WinCheck				// Branch to win check if not
	

	ldr		r3, =GameState			// Increment Mario's score by 100
	ldr		r0, [r3, #8]
	add		r0, #100
	str		r0, [r3, #8]
	mov		r0, #1					// Indicate that a game state update is required next loop
	strb	r0, [r3, #6]

	ldrb	r0, [r3, #3]			 // Increment Coin Count by 1
	add		r0, #1
	strb	r0, [r3, #3]

	b		RemoveFromGrid
	
	
					
WinCheck:					
	cmp		r10, #26					
	bgt		5f						// Should never happen				
		
	
	ldr		r0, =GameState			// Set Game Win byte to 1 (win occurred)
	mov		r3, #1
	strb	r3, [r0, #4]
	
	ldr		r0, =MarioState			// Set Mario Animation to Cheering
	mov		r3, #5
	strb	r3, [r0]
	b		5f
	

RemoveFromGrid:
	ldr		r0, =ObjectStates		// Remove item from dynamic level grid
	mov		r3, #0				
	strb	r3, [r0, r4]			

	mov		r0, #32					// Width of patch == 32
	mov		r1, #32					// Height of patch == 32
	mov		r2, r6					// X coord to start patch
	mov		r3, r7					// Y coord to start patch
	bl		PatchScreen


5:	ldr		r0, =ObjectStates
		
		
		

6:	add		r4, #1
	cmp		r4, #768
	blt		1b


	pop		{r4-r11, lr}
	mov		pc, lr
	
	
	
	
	
	
	
	
	
	
	
	



.globl	DoSpriteCollision
.align

DoSpriteCollision:
	push	{r4-r7, r11, lr}

	mov		r11, r0
	lsl		r11, #4

	ldr		r0, =SpriteStates
	ldr		r4, [r0, r11]			// Sprite X
	add		r11, #4
	ldr		r5, [r0, r11]			// Sprite Y
	sub		r11, #4


	ldr		r0, =MarioState
	ldr		r6,	[r0, #8]			// Mario X
	ldr		r7, [r0, #12]			// Mario Y
	

	cmp		r7, r5
	bge		1f						// Mario Y < Tile Y ?? If not, branch -- Else, Mario Dies

	mov		r0, r4
	mov		r1, r5
	mov		r2, r6
	mov		r3, r7
	bl		ResolveSpriteCollision	// Returns 1 if Mario Wins, 0 if Sprite Wins

	cmp		r0, #0
	beq		1f
	
	
	ldr		r0, =MarioState
	mov		r1, #0
	strb	r1, [r0, #6]
	mov		r1, #1
	strb	r1, [r0, #3]
	mov		r1, #12
	strb	r1, [r0, #4]


	
	mov		r0, r11
	lsr		r0, #4
	mov		r1, #1
	bl		KillSprite
	b		2f
	


1:	// MARIO DIES

	
	
	

	ldr		r0, =GameState			// Decrement Mario's Lives
	ldrb	r1, [r0, #2]
	sub		r1, #1
	strb	r1, [r0, #2]

	mov		r1, #1
	strb	r1, [r0, #12]			// Indicates that the level must be re-initialized next round

	ldr		r0, =MarioState			// Set Mario Animation Stage to 4 (triggers death animation)
	mov		r1, #4
	strb	r1, [r0]

	
	
2:	pop		{r4-r7, r11, lr}
	mov		pc, lr



	
	
	
	
	
	
	


//////////////////////////////////////////////////////////////////////
// * ResolveSpriteCollision is used to determine the 'winner' in a 
// * 	collision between Mario and a Sprite
// *
// * Inputs:
// * 	r0 -- Sprite X
// * 	r1 -- Sprite Y
// * 	r2 -- Mario  X
// * 	r3 -- Mario  Y
// *
// * Returns:
// * 	r0 -- 1 if Mario wins, 0 if sprite wins
// * 
//////////////////////////////////////////////////////////////////////


.globl	ResolveSpriteCollision
.align

ResolveSpriteCollision:
	push		{r4-r5, lr}


	
	sub		r4, r2, r0				// Mario x - Tile x

	cmp 	r4, #0					// Abs value of subtraction
    mvnlt 	r4, r4
    addlt 	r4, #1
	
	
	sub		r5, r3, r1				// Mario y - Tile y

	cmp 	r5, #0					// Abs value of subtraction
    mvnlt 	r5, r5
    addlt 	r5, #1
	

	//r4 -- abs(MarioX - TileX)
	//r5 -- abs(MarioY - TileY)


	cmp		r4, r5
	movgt	r0, #0
	movle	r0, #1



	
2:	pop		{r4-r5, lr}
	mov		pc, lr
	
		
	
