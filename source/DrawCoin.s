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
.globl		DrawCoin
	
DrawCoin:
	push	{r4-r6, lr}

	AStage	.req	r4
	xcoord	.req	r5
	ycoord	.req	r6
	
	mov		xcoord, r1		// Store X Value
	mov		ycoord, r2		// Store Y Value
	mov		AStage, r0		// Store Animation Stage

stageA:			// Lifted Coin
	cmp		AStage, #0		// Stage Animation = 1
	bne		stageB

	sub		ycoord, #16		// Lifted Coin 16 bits
	ldr		r0, =FCoin		
	b		draw

stageB:			// Higher Coin
	cmp		AStage, #1
	bne		stageC

	sub		ycoord, #16
//	ldr		r0, =emptySky		// Erase Previous
//	mov		r1, xcoord
//	mov		r2, ycoord
//	bl		DrawPicture

	mov		r0, #32			// Patch over previous state
	mov		r1, #32
	mov		r2, xcoord
	mov		r3, ycoord
	bl		PatchScreen
	
	sub		ycoord, #16		// Lifted 32 bits (16 higher)
	ldr		r0, =FCoin		// Draw Higher Lifted Coin
	b		draw
	
stageC:			// Lifted Coin
	cmp		AStage, #2
	bne		stageD

	sub		ycoord, #32
//	ldr		r0, =emptySky		// Erase previous
//	mov		r1, xcoord
//	mov		r2, ycoord
//	bl		DrawPicture

	mov		r0, #32			// Patch over previous state
	mov		r1, #32
	mov		r2, xcoord
	mov		r3, ycoord
	bl		PatchScreen
	
	add		ycoord, #16		// Lifted 16 bits (16 lower)
	ldr		r0, =FCoin		// Erase previous state
	b		draw
	
stageD:			// Coin Original Spot
	sub		ycoord, #16
//	ldr		r0, =emptySky		// Erase Previous
//	mov		r1, xcoord
//	mov		r2, ycoord
//	bl		DrawPicture

	mov		r0, #32			// Patch over previous state
	mov		r1, #32
	mov		r2, xcoord
	mov		r3, ycoord
	bl		PatchScreen
	
	ldr		r0, =FCoin		
	add		ycoord, #16
	
draw:			// Pass in x and y coordinates and image to draw before
	mov		r1, xcoord		// Pass in x value
	mov		r2, ycoord		// Pass in y value
	bl		DrawPicture

	.unreq	AStage
	.unreq	xcoord
	.unreq	ycoord
	
	pop		{r4-r6, lr}
	mov		pc, lr
