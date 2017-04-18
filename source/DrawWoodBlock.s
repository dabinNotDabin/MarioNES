/*
*	Pass in Location and Stage
*	Draw based on Stage
*
*	r1 - xcoord
*	r2 - ycoord
*	r0 - Animation Stage
*
*	Increments through the stages (0-3)
*	
*	PatchScreen(width, height, x, y)
*/
	
.section	.text
.globl		DrawWoodBlock
	
DrawWoodBlock:
	push	{r4-r7, lr}

	AStage	.req	r4
	xcoord	.req	r5
	ycoord	.req	r6
	image	.req	r7
	
	mov		xcoord, r1		// Store X Value
	mov		ycoord, r2		// Store Y Value
	mov		AStage, r0		// Store Animation Stage

stageA:			// Full Block
	cmp		AStage, #0		// Stage Animation = 1
	bne		stageB
		
	ldr		image, =woodBlock	// Question Block
	b		draw

stageB:			// Explode 1
	cmp		AStage, #1
	bne		stageC

	ldr		image, =wbexp1		// Draw Explode 1
	b		draw
	
stageC:			//Explode 2
	cmp		AStage, #2
	bne		draw

	ldr		image, =wbexp2		// Draw Explode 2
	b		draw
	
//stageD:			// Doesnt exist anymore (Empty spot)
//	ldr		image, =emptySky

draw:			// Pass in x and y coordinates and image to draw before
			// First patch the screen behind before draw
	mov		r0, #32			// Patch width
	mov		r1, #32			// Patch height
	mov		r2, xcoord		// X Coordinate
	mov		r3, ycoord		// Y Coordinate
	bl		PatchScreen	

	cmp		AStage, #2		// If greater than 2, just patch, don't draw
	bgt		endDrawWood
	
	mov		r0, image		// Load image to be passed into DrawPicture
	mov		r1, xcoord		// Pass in x value
	mov		r2, ycoord		// Pass in y value
	bl		DrawPicture

endDrawWood:	
	.unreq	AStage
	.unreq	xcoord
	.unreq	ycoord
	
	pop		{r4-r7, lr}
	mov		pc, lr
