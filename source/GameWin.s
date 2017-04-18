.section	.text
.globl		GameWin

GameWin:
	push	{r4-r10, lr}

	//disable interupts
	mrs		r0, cpsr
	orr		r0, #0x80
	msr		cpsr_c, r0

	xcoord	.req	r4		// X coordinate of Image
	ycoord	.req	r5		// Y coordinate of Image
	MB	.req	r6		// MarioOnBullet Image address
	height	.req	r7		// Image Height
	width	.req	r8		// Image Width
	AStage	.req	r9		// Animation Stage
	c	.req	r10		// Counter

	mov	r0, #0x0
	bl	DrawColour
	
	ldr	MB, =MarioOnBullet
	ldr	xcoord, =800
	ldr	ycoord, =320
	mov	height, #160
	mov	width, #224
	
BulletAnimation:
	mov	r0, MB
	mov	r1, xcoord
	mov	r2, ycoord
	bl	DrawPicture2

	mov	r0, #8
	mov	r1, height
	add	r2, xcoord, width
	mov	r3, ycoord
	bl	PatchScreen

	// Wait if needed

	sub	xcoord, #8

	cmp	xcoord, #0
	bne	BulletAnimation

	mov	AStage, #0
//	mov	c, #0
YouWinAnimation:
	cmp	AStage, #0
	ldreq	r0, =YouWin0
	beq	draw

	cmp	AStage, #1
	ldreq	r0, =YouWin1
	beq	draw

	cmp	AStage, #3
	ldr	r0, =YouWin2
//	b	draw

draw:
	mov	r1, #320
	mov	r2, #256
	bl	DrawPicture2

//	add	c, #1
	cmp	AStage, #3
	moveq	AStage, #0
	addne	AStage, #1

	// Wait	- Or wait for input from controller
	bl	ReadSNES
	ldr	r0, =ButtonsPressed
	ldr	r1, [r0]
	ldr	r2, =0xFFFFFFFF
	teq	r1, r2
	beq	YouWinAnimation
	
//	cmp	c, #20
	
	.unreq	xcoord
	.unreq	ycoord
	.unreq	MB
	.unreq	height
	.unreq	width
	.unreq	AStage
	.unreq	c

	pop 	{r4-r10, lr}
	mov 	pc, lr

	// Draw Black
	// Draw MarioOnBullet
	// Patch from Current X to old X, same y
