// *****************************************
// * Problems could include
// * 		 branching conditions incorrect like bgt should be bge
// * 		 does not check for edge of screen condition
// * 		 does not check if tiles leftmost edge is where x == 0
// * 		 calculation when 1024 - x coord < width may be off by 1
// *****************************************

.globl	ScrollRight

ScrollRight:

	push	{r4 - r7}
	
	ldr		r0, =Tiles		// Address of structure holding information about all tiles on the map.
							//		-- (active/inactive status flag, top left x,y coord, width and height in pixels
							//				-- Active meaning 100% on map, other objects dealt with differently.

	//Check num tiles to process
	b		CheckNumTiles


NextFlag:
	ldr		r1,	[r0], #4			// Get Tile Status Flag then increment r0
	cmp		r1, #0				// Is Tile Inactive (0)?
	addeq	r0, #16				// Skip over 16 more bytes (20 total with previous increment) to load next tile flag
	beq		CheckNumTiles		// Check that num tiles processed < num tiles
	
	
// --------------------------------------------------------------------------------------
// LOAD AND PREPARE TILE INFORMATION
// --------------------------------------------------------------------------------------

	ldmia	r0!, {r1, r2}		// Load x and y coord from r0 + 4 and r0 + 8, Increment r0
	mov		r4, r1, lsl #1 	
	add 	r3, r4, r2, lsl #11	// Pixel Offset(r3) = x + (y * 2048)


	ldr		r2,	=FrameBufferPointer
	ldr		r2, [r2]
	add		r3, r2				// Location in memory = FBP + offset

	add		r6, r3, #2048		// Store current offset + 2048 (for next row)
	mov		r4, r1				// Store leftmost x coord for loop check on reaching edge of screen
	
	
	sub		r1, #4
//	sub		r1, #2				// newX coord will be oldX-1
/////^^^^^ change to sub #1 for pixel by pixel

	str		r1, [r0, #-8]		// r0 is at tile origin + 8, sub 4 to store new x coord
	
	ldmia	r0!, {r1, r2}		// Load width and height for current tile from r0 + 12 and r0 + 16, Increment r0
								// r0 = original r0 + #20 -- next tile's status flag

	mov		r12, #1024			// Move 1024 into r12
	sub		r12, r4				// 1024 - starting x coord
	cmp		r12, r1				// Is result less than width of image?
	movlt	r1, r12				// If so, use result for num columns to shift
	
	mov		r5, r1				// Track num columns to shift for iterating through each row


	mov		r10, #0x0
	mov		r11, #0x0


	b		CheckRow			// Branch to test condition
ShiftTileLoop:

	b		CheckColumn
ShiftRowLoop:
	ldmia	r3,  {r8, r9}
	sub		r3,  #8
	stmia	r3!, {r8, r9}
	add		r3,  #8
	sub		r1,  #4

//	ldr 	r7, [r3], #-4		// Load the value of 1 pixel, decrement offset by 2 bytes
//	str 	r7,	[r3], #8		// Store pixel at previously decremented offset, increment by 4 for next pixel
//	sub		r1, #2				// Subtract 1 from number of columns to process

////^^^^ change to ldrh, strh with altered post increments and sub #1 instead of sub#2 for 1px at a time


CheckColumn:
	cmp		r1, #0				// Is num columns to process > 0
	bge		ShiftRowLoop		// If so, branch to top of ShiftRowLoop
	
	stmia	r3, {r10, r11}
	
								// (to fill in column that the shifted tile leaves behind)
//	ldr		r7, [r3], #-4		// Load the value of 1 pixel, decrement offset by 2 bytes
//	str		r7,	[r3]			// Store pixel at previously decremented offset
/////^^^^^^ change to ldrh, strh and post decrment by 2 instead for pixel by pixel


	
DoneRow:
	mov		r1, r5				// Reset the width variable to original to iterate through next row
	mov		r3, r6				// I stored original offset + 2048 in r6
	add		r6, #2048			// Add 2048 to r7 (for next row)
	sub		r2, #1				// Subtract 1 from number of rows to process
	
	
CheckRow:
	cmp 	r2, #0				//  Is num rows to process > 0
	bge		ShiftTileLoop		// 	If so, branch to top of ShiftTileLoop
	
	
	
	
	CheckNumTiles:
	ldr		r12, =EndOfTiles
	cmp		r0, r12				
	blt		NextFlag
	
	
	pop		{r4 - r7}
	mov		pc, lr
	
	
	
.globl Tiles
Tiles:
					// Green Pipe
	.int	1					// Status Flag
	.int	200					// Top Left x coord
	.int	200					// Top Left y coord
	.int	32					// Image width in pixels
	.int	64					// Image height in pixels
	
						// Green Pipe
	.int	1					// Status Flag
	.int	300					// Top Left x coord
	.int	300					// Top Left y coord
	.int	32					// Image width in pixels
	.int	64					// Image height in pixels
	
						// Green Pipe
	.int	1					// Status Flag
	.int	400					// Top Left x coord
	.int	400					// Top Left y coord
	.int	32					// Image width in pixels
	.int	64					// Image height in pixels
	

						// Small Mario
	.int	1					// Status Flag
	.int	0					// Top Left x coord
	.int	500					// Top Left y coord
	.int	49					// Image width in pixels
	.int	64					// Image height in pixels

	
	
						// WoodBlocks
	.int	1					// Status Flag
	.int	600					// Top Left x coord
	.int	300					// Top Left y coord
	.int	128					// Image width in pixels
	.int	32					// Image height in pixels
	
	
		
						// GrassHill
	.int	1					// Status Flag
	.int	600					// Top Left x coord
	.int	500					// Top Left y coord
	.int	128					// Image width in pixels
	.int	64					// Image height in pixels
	
	
	
			
						// SmallCloud
	.int	1					// Status Flag
	.int	10					// Top Left x coord
	.int	10					// Top Left y coord
	.int	96					// Image width in pixels
	.int	74					// Image height in pixels
	
	
			
						// SmallCloud
	.int	1					// Status Flag
	.int	60					// Top Left x coord
	.int	120					// Top Left y coord
	.int	96					// Image width in pixels
	.int	74					// Image height in pixels
	
	
			
						// LargeCloud
	.int	1					// Status Flag
	.int	300					// Top Left x coord
	.int	60					// Top Left y coord
	.int	192					// Image width in pixels
	.int	77					// Image height in pixels
	
	
			
						// LargeCloud
	.int	1					// Status Flag
	.int	800					// Top Left x coord
	.int	200					// Top Left y coord
	.int	192					// Image width in pixels
	.int	77					// Image height in pixels
	
	
	
EndOfTiles:
