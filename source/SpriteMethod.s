.section	.text


.globl UpdateSprites
UpdateSprites:
	push	{r4-r6, lr}
	
	
	SprAdr	.req	r4
	NumSpr	.req	r5
	Index	.req	r6
	
	ldr 	r0, =SpriteObj
	ldr		NumSpr, [r0]
	mov		Index, #0
	ldr		SprAdr, =SpriteStates

LoopCheck:
	cmp 	Index, NumSpr
	bge		FinishUpdate
	
	add		SprAdr, #8
	ldrb 	r0, [SprAdr, Index, lsl #4]
	sub 	SprAdr, #8
	
	cmp		r0,	#0
	beq		NextSprite
	
//Check Monster Code
	add		SprAdr, #9
	ldrb	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #9
	
isGoomba:
	//Checking Goomba
	cmp 	r0, #1
	bne		isCannon
	
	mov		r0, Index
	bl		GoombaUpdate

isCannon:
	cmp		r0, #2
	bne		NextSprite
	
	mov		r0, Index
	bl		CannonUpdate
	
NextSprite:
	add		Index, #1
	b LoopCheck
	
	
FinishUpdate:
	.unreq	SprAdr
	.unreq	NumSpr
	.unreq	Index
	
	pop	{r4-r6, pc}


.globl KillSprite
//***********Args************
//		   r0 = Index
//		r1 = Kill Source
//		#1 for Mario
//***************************
KillSprite:
	push	{r4-r6, lr}

	SprAdr	.req	r4
	Index	.req	r5
	Killer	.req	r6
	
	mov 	Index, r0
	ldr		SprAdr, =SpriteStates
	mov		Killer, r1
	
	
	//Setting offset #9 - Monster Code
	add		SprAdr, #9
	ldrb	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #9
	
	add		SprAdr, #8
	ldrb	r1, [SprAdr, Index, lsl #4]
	sub 	SprAdr, #8
	
	cmp 	r0, #2
	beq		KillBill

KillGoomba:
	cmp		r1, #0
	
	beq		EndKillSprite
	
	mov		r0, Index
	mov		r1, Killer
	bl		GoombaDeath
	b		EndKillSprite
		
KillBill:
	cmp		r1, #1
	beq		EndKillSprite

	mov		r0, Index
	mov 	r1, Killer
	bl		BillDeath

	
	
	//CODE TO PROC ANIMATION?
EndKillSprite:
	
	ldr 	r0, =GameState
	ldr		r1, [r0, #8]
	add		r1, #100
	str		r1, [r0, #8]		
	mov 	r1, #1
	strb	r1, [r0, #6]
		
	
	
	
	.unreq	Killer
	.unreq	SprAdr
	.unreq	Index
	
	pop		{r4-r6, pc}
	
	

.globl FindSpriteCollision
//************* ARGS ****************
//:::::::Returns first collision:::::
//r0 = Index value
//***********************************
FindSpriteCollision:
	push	{r4-r8, lr}
	
	SprNum	.req	r4
	SprAdr	.req	r5
	SprInd	.req	r6
	MarioX	.req	r7
	MarioY	.req	r8
	
	ldr 	r0, =MarioState
	ldr		MarioX, [r0, #8]
	ldr		MarioY, [r0, #12]
	

	ldr 	SprAdr, =SpriteStates
	ldr		r0, =SpriteObj
	ldr		SprNum, [r0]
	mov		SprInd, #0
	
CheckStart:	
	cmp		SprInd, SprNum
	beq		notFound
	
	
	add		SprAdr, #10
	ldrb	r0, [SprAdr, SprInd, lsl #4]
	sub 	SprAdr, #10
	
	cmp 	r0, #2
	
GoombaSprite:
	//Check if alive	
	add		SprAdr, #8
	ldrb	r1,	[SprAdr, SprInd, lsl #4]
	sub		SprAdr, #8
	
	
	cmpeq	r1, #2
	cmpne 	r1, #1
	
	ble		nextSprite
	
MatchX:	
	ldr		r0, [SprAdr, SprInd, lsl #4]
	
	subs	r0, MarioX
	mvnmi	r0, r0
	addmi	r0, #1
	
	cmp		r0, #32
	bge		nextSprite
		
MatchY:
	add		SprAdr,	#4
	ldr		r0, [SprAdr, SprInd, lsl #4]
	sub		SprAdr, #4
	
	subs	r0, MarioY
	mvnmi	r0, r0
	addmi	r0, #1
	
	cmp 	r0, #32
	bge		nextSprite
	
	b		Found
	
nextSprite:
	add 	SprInd, #1
	b		CheckStart

notFound:
	mov 	r0, #-1
	b endSearch

Found:
	mov 	r0, SprInd
		
endSearch:
	.unreq	SprNum
	.unreq	SprAdr
	.unreq	SprInd
	.unreq	MarioX
	.unreq	MarioY
	
	pop		{r4-r8, pc}







/////////////////////////////////////
//* r0 -- width of patch
//* r1 -- height of patch
//* r2 -- starting x coord
//* r3 -- starting y coord
////////////////////////////////////
.globl PatchXMoves
PatchXMoves:
	push	{r4-r11}
	push	{lr}

	mov		r8, #1

	mov		r12, r0
	


	add		r6, r2, r3, lsl #10		// r1 = x + (y * 1024)			
	lsl		r6, #1					// r1 =(x + (y * 1024)) * 2



	ldr		r4, =GameState
	ldrb	r4, [r4]				// CurrentMapInstance

	cmp		r4, #0
	ldreq	r2, =LevelBackground
	beq		1f	
	cmp		r4, #1		
	ldreq	r2, =batmanBackground
	beq		1f
	cmp		r4, #4		
	movlt	r8, #0
	ldrlt	r2, =black
	blt		1f
	ldreq	r2, =winBackground
	beq		1f



//	ldr		r2, =winBackground


1:	add		r2, #8					// First 8 bytes are picture size information
	
	ldr		r3, =FrameBufferPointer // Address of Beginning of Frame Buffer
	ldr		r3, [r3]

	cmp		r8, #0
	addne	r2, r6					// Starting offset in ascii file
	add		r3, r6					// Starting offset in FrameBuffer


	lsr		r0, #2					// Divide width by 4	

	
	b	RowTest
ProcessRow:


	b	ColumnTest
ProcessCurrentPixels:

	ldmia	r2!, {r4-r5}
//	stmia	r3!, {r4-r11}
	
	
	str		r4, [r3], #4
	str		r5, [r3], #4
	
	sub		r0, #1			//Since 2 registers is 4 pixels and I divided width by 4, 1 == 4 px	
	

ColumnTest:
	cmp 	r0, #0
	bgt		ProcessCurrentPixels


	mov 	r0, r12 		//Width of the picture


							// New frame buffer offset = currentOffset + (2048 - (width*2))
	ldr		r4, =2048
	sub		r4, r0, lsl #1	// 2048 - (width*2)

	cmp		r8, #0
	addne	r2, r4 			// Current offset  + (2048 - (width*2))
	add		r3, r4 			// Current offset  + (2048 - (width*2))


	lsr		r0, #2			// Divide width by 16
	sub		r1, #1			// To process next column


RowTest:
	cmp 	r1,	#0
	bgt		ProcessRow
	


	pop		{lr}
	pop 	{r4-r11}
	mov		pc, lr
	
	
