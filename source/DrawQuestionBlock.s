/*
*	Pass in Location and Stage
*	Draw based on Stage
*
*	r1 - xcoord
*	r2 - ycoord
*	r0 - Animation Stage
*
*	Increments through the stages (0-3)
*/

.section	.text
.globl		DrawQuestionBlock
	
DrawQuestionBlock:
	push	{r4-r6, lr}

	AStage	.req	r4
	xcoord	.req	r5
	ycoord	.req	r6
	
	mov		xcoord, r1		// Store X Value
	mov		ycoord, r2		// Store Y Value
	mov		AStage, r0		// Store Animation Stage

stageA:			// Full Block
	cmp		AStage, #0		// Stage Animation = 1
	bne		stageB
		
	ldr		r0, =qBlock		// Question Block
	b		draw

stageB:			// Dead Block Lifted - Clear Previous Stage
	cmp		AStage, #1
	bne		stageC

//	ldr		r0, =emptySky		// Erase previous state
//	mov		r1, xcoord
//	mov		r2, ycoord
//	bl		DrawPicture

	mov		r0, #32			// Patch over previous state
	mov		r1, #32
	mov		r2, xcoord
	mov		r3, ycoord
	bl		PatchScreen

	
	sub		ycoord, #16		// Decrement y coordinate (block lifted)
	ldr		r0, =deadqBlock		
	b		draw
	
stageC:			// Dead Block Lifted - Continued (no clear)
	cmp		AStage, #2
	bne		stageD

	sub		ycoord, #16
	
	ldr		r0, =deadqBlock		// Draw previous state
	b		draw
	
stageD:			// Dead Block Original Spot
//	ldr		r0, =emptySky		// Erase previous state
//	mov		r1, xcoord
//	sub		r2, ycoord, #16
//	bl		DrawPicture

	mov		r0, #32			// Patch over previous state
	mov		r1, #32
	mov		r2, xcoord
	sub		r3, ycoord, #16
	bl		PatchScreen
	
	ldr		r0, =deadqBlock

draw:			// Pass in x and y coordinates and image to draw before
	mov		r1, xcoord		// Pass in x value
	mov		r2, ycoord		// Pass in y value
	bl		DrawPicture

	.unreq		AStage
	.unreq		xcoord
	.unreq		ycoord
	
	pop		{r4-r6, lr}
	mov		pc, lr
