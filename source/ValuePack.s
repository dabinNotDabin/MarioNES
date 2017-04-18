//Make a random function
//Search in range from (0-767)
//Make X then Make

//**************RETURNS******************
//			Offset value in map
//***************************************
.globl RandomBlock
RandomBlock:
	push	{r4-r6, lr}
	
	ClkAdr 	.req	r4
	xGrid	.req	r5
	yGrid	.req	r6
	
	ldr 	ClkAdr, =0x3F003004		
	ldr		r1, [ClkAdr]
	
	eor		r1, r1, r1, lsl #13
	eor		r1, r1, r1, lsr #17
	eor		r1, r1, r1, lsl #5
	

GetX:	
	and		xGrid, r1, #31

GetY:
	
	ldr		r1, [ClkAdr]
	
	eor		r1, r1, r1, lsl #13
	eor		r1, r1, r1, lsr #17
	eor		r1, r1, r1, lsl #5
	
	
	and		yGrid, r1, #15
	
	add		yGrid, #6
	
	add		r0, xGrid, yGrid, lsl #5
	
endRandomBlock:
	.unreq	ClkAdr
	.unreq	xGrid
	.unreq	yGrid
	
	pop		{r4-r6, pc}
	


.globl InitializePow
//************ARGS**************
//		r0 = Offset value
//******************************

InitializePow:
	push	{r5, lr}
	
	Offset	.req	r5
	
	mov 	Offset, r0
	mov 	r0, #3
	ldr		r1, =ObjectStates
	
	strb	r0, [r1, Offset]
	
	
	and 	r1, Offset, #31
	lsl		r1, #5
	
	bic		r2, Offset, #31
	
	ldr		r0, =PowBlock
	
	bl		DrawPicture
	
	.unreq	Offset
	
	pop		{r5, pc}


.globl UsePow
//*****************************
//
//*****************************
UsePow:
	push	{r4-r7, lr}
	
	SprAdr	.req	r4
	SprInd	.req	r5
	cIndex	.req	r6
	
	//Kill all things
	
	ldr		r0, =SpriteObj
	ldr		SprInd, [r0]
	
	ldr		SprAdr, =SpriteStates
	mov		cIndex, #0
	
Check:
	cmp		SprInd, cIndex
	blt		endPowUse
	
	mov		r0, cIndex
	mov		r1, #1
	bl		KillSprite
	
	add		cIndex, #1
	
	b 		Check
	
	
endPowUse:
	.unreq	SprAdr
	.unreq	SprInd
	.unreq	cIndex
	
	pop		{r4-r7, pc}

