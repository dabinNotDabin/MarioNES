.section .text


//GOOMBA BYTE INFORMATION
//OFFSET  #	| 		NAME		|		DETAILS
////////////////////////////////////////////////////////////////////
//		0	| X - COORD			|	Top left corner origin
//		4	| Y - COORD			|	Top left corner	origin
//		8	| ACTIVITY STATUS	|	0 = Dead, 1 = Dead in Animation , 2 = Alive
//		9	| MONSTER CODE		|	GOOMBA = #1
//		10	| ANIMATION STATE	|	Starts at #1
//		11	| X-DIRECTION		|	0 = LEFT, 1 = RIGHT, 2 = NONE
//		12	| X-VELOCITY		|		0 - 255
//		13	| Y-DIRECTION		|	0 = UP, 1 = DOWN, 2 = NONE
//		14	| Y-VELOCITY		|		0 - 255
//		15	| COLLISION STATUS	|	1 = COLLISION, 0 = NO COLLISION
//		16 	| START OF NEXT		| START POSITION OF THE NEXT SPRITE

.globl InitializeGoomba
//r0 - X-Position
//r1 - Y-Position

//**********************************************************************
InitializeGoomba:
	push		{r4-r6, lr}
	
	sPointer	.req	r4
	xPos		.req	r5
	yPos		.req	r6
	
	
	mov xPos, r0
	mov yPos, r1
	ldr		r0, =SpritePointer
	ldr 	sPointer, [r0]
	
	//X-position
	mov		r0, xPos
	str		r0, [sPointer], #4
	
	//Y-position
	mov		r0, yPos
	str		r0, [sPointer], #4
	
	//IS ALIVE? 0 = Dead, 1 = Dead but in Animation, 2 = Alive
	mov		r0, #2
	strb 	r0, [sPointer], #1
	
	//MONSTER CODE
	mov 	r0, #1
	strb	r0, [sPointer], #1
	
	//State
	mov		r0, #1
	strb	r0, [sPointer], #1
	
	//HORIZONTAL Direction 
	mov		r0, #1
	strb	r0, [sPointer], #1
	
	//HORIZONTAL Speed
	mov 	r0, #4
	strb	r0, [sPointer], #1
	
	//VERTICAL Direction
	mov		r0, #2
	strb	r0, [sPointer], #1
	
	//VERTICAL Speed
	mov		r0, #0
	strb	r0, [sPointer], #1
	
	//Collision status
	mov		r0, #1
	strb	r0, [sPointer], #1
	
	//Updating the pointer
	ldr		r0, =SpritePointer
	
	str		sPointer, [r0]
	
	ldr		r0, =SpriteObj
	
	ldr		r1, [r0]
	add 	r1, #1	
	str 	r1,	[r0]
		
	.unreq	sPointer
	.unreq	xPos
	.unreq	yPos
	
	pop		{r4-r6, pc}
	
.globl GoombaUpdate
//****************** GOOMBA UPDATE****************
//Takes in:
//r0 = Index of Goomba in structure
//Assumes everything is alive
//*************************************************
GoombaUpdate:
	push	{r4-r7, lr}
	
	Index	.req	r4
	SprAdr	.req	r5
	xPos	.req	r6
	yPos	.req	r7
	
	ldr		SprAdr, =SpriteStates
	mov		Index, r0
	
	//Checking Activity Status
	add		SprAdr, #8
	ldrb	r0, [SprAdr, Index, lsl #4]
	sub 	SprAdr, #8
	cmp		r0, #2
	beq		Alive
	
	mov		r0, Index
	bl		UpdateDeathAnimation
	
	b		endUpdate
	
Alive:
	
	mov 	r0, Index
	bl 		SpriteUpdateX
	
	mov		r0, Index
	bl		SpriteUpdateY

	//Getting the X Position of sprite in r6
	ldr		xPos, [SprAdr, Index, lsl #4]
	

	//Getting the Y Position of sprite in r7
	add		SprAdr, #4
	ldr		yPos, [SprAdr, Index, lsl #4]		
	sub		SprAdr, #4

ChangeAni:
	add		SprAdr, #10
	ldrb	r0, [SprAdr, Index, lsl #4]		
	
	cmp		r0, #3
	beq		MoveAni3

//ASSUMING MOVING	
MoveAni2:
	mov		r0, #3
	strb	r0, [SprAdr, Index, lsl #4]		
	sub 	SprAdr, #10
	
	ldr 	r0, =goomba2
	mov		r1, xPos
	mov		r2, yPos

	
	bl		DrawPicture3
	b		endUpdate
	
MoveAni3:
	mov		r0, #2
	strb	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #10
	
	ldr		r0, =goomba3
	mov		r1, xPos
	mov		r2, yPos
	
	bl		DrawPicture3
	b		endUpdate

endUpdate:
	.unreq	Index
	.unreq	SprAdr
	.unreq	xPos
	.unreq	yPos
	
	pop		{r4-r7, pc}

//**************ARGS*******************************************
//r0 is Index
//***********************************************************
SpriteUpdateX:
	push	{r4-r7, lr}
	
	SprAdr	.req	r4
	xPos	.req	r5
	newX	.req	r6
	Index	.req	r7
	
	mov		Index, r0
	ldr 	SprAdr, =SpriteStates
	ldr		xPos, [SprAdr, Index, lsl #4]
	
	add		SprAdr, #11
	
	//Checking the direction
	ldrb	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #11
		
	add		SprAdr, #12
	cmp 	r0, #0
	beq		MovingLeft

MovingRight:
	
	ldrb	r0, [SprAdr, Index, lsl #4]
	add		newX, xPos, r0
	sub 	SprAdr, #12
	
	
	mov		r0, #1
	lsl 	r0, #10
	
	add		r1, newX, #31
	
	//Checking going offscreen from the Right
	cmp		r1, r0
	bge		noGood
	
	
	mov 	r0, newX
	add		r0, #31
	lsr		r2, r0, #5	
	
	b 		predictCollision

MovingLeft:	
	
	ldrb	r0, [SprAdr, Index, lsl #4]
	sub		newX, xPos, r0
	sub		SprAdr, #12
	
	mov 	r0, newX
	
	cmp		r0, #0
	blt		noGood
	
	
	lsr		r2, r0, #5
		
predictCollision:
	
	mov 	r0, xPos
	lsr		r1, r0, #5
	
	cmp		r1, r2
	beq		OkayMove
	
	//Loading the y-coordinate
	add		SprAdr, #4
	ldr		r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #4
	
	
	//r2 has new X grid - coord
	//r0 should have Y grid coord
	//offset is y * 32 + x	
	
	lsr		r0, #5
	
	ldr		r3, =ObjectStates
	add		r2, r0, lsl #5
	ldrb 	r1, [r3, r2]
	
	cmp		r1, #0
	bgt 	noGood
	
	sub		r2, r0, lsl #5
	
	add		SprAdr, #4
	ldr		r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #4
	
	add		r0, #31
	lsr		r0, #5
	
	cmp		r0, #24
	bge		OkayMove
	
	add		r2, r0, lsl #5
	ldrb	r1, [r3, r2]
	
	cmp		r1, #0
	bgt		noGood
	
	
	
OkayMove:
	add		SprAdr, #11
	ldrb 	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #11
	
	cmp		r0, #0
	
	mov		r0, #4
	mov		r1, #32
	addeq	r2, newX, #32
	movne	r2, xPos
	
	add		SprAdr, #4
	ldr		r3, [SprAdr, Index, lsl #4]
	sub		SprAdr, #4
	
	bl		PatchXMoves
	
	str		newX, [SprAdr, Index, lsl #4]
	b 		endMove
	
noGood:
	str		xPos, [SprAdr, Index, lsl #4]
	add		SprAdr, #11
	ldrb	r0, [SprAdr, Index, lsl #4]
	
	cmp		r0, #1
	beq		changeLeft
	
changeRight:
	mov		r0, #1
	strb	r0, [SprAdr, Index, lsl #4]
	b		endMove
	
changeLeft:	
	mov		r0, #0
	strb	r0, [SprAdr, Index, lsl #4]

endMove:
	sub 	SprAdr, #11 

	.unreq	SprAdr
	.unreq	xPos
	.unreq	newX
	.unreq	Index
	
	pop		{r4-r7, pc}

//*************************************************************
//ARGS
//r0 = Index
//**************************************
SpriteUpdateY:
	push	{r4-r8, lr}
	
	SprAdr	.req	r4
	yPos	.req	r5
	xPos	.req	r6
	newY	.req	r7
	Index	.req	r8
	
	mov		Index, r0
	ldr 	SprAdr, =SpriteStates
	
	ldr		xPos, [SprAdr, Index, lsl #4]
	
	add		SprAdr, #4
	ldr		yPos, [SprAdr, Index, lsl #4]
	
	add		SprAdr, #11
	ldrb	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #15
	
	
	cmp		r0, #1
	beq		CheckGrounded

	//Goomba is falling, Have to properly apply the falling velocity
	
	
	mov		r0, #8
	
	add		SprAdr, #14
	strb	r0, [SprAdr, Index, lsl #4]
	sub 	SprAdr, #14	
	
	add		newY, yPos, #8
	
	
	mov		r0, #3
	lsl		r0, #8
	sub		r0, #31
		
	cmp		newY, r0
	blt		LandCheck
	
	b		UpdateY
	
	
LandCheck:
	//Checking if will be able to land
	lsr		r0, xPos, #5
	add		r1, newY, #32
	lsr		r1, #5
	
	cmp		r1, #24
	bge		UpdateY
	
	add		r3, r0, r1, lsl #5
	ldr		r2, =ObjectStates
	
	ldrb	r0, [r2, r3]
	cmp		r0, #0
	bgt		Landed
	
	
	mov		r0, xPos
	add		r0, #31
	lsr		r0, #5
	
	
	add		r3, r0, r1, lsl #5
	ldrb	r0, [r2, r3]
	cmp 	r0, #0
	
	//Defaults to just update position
	beq		UpdateY
	
	
Landed:
	mov		r0, #1
	add		SprAdr, #15
	strb	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #1
	mov 	r0, #0
	strb	r0,	[SprAdr, Index, lsl #4]
	sub		SprAdr, #14
	
	b 		UpdateY
	

CheckGrounded:	
	
	lsr		r0, xPos, #5
	lsr		r1, yPos, #5
	add		r1, #1
	
	add		r3, r0, r1, lsl #5
	ldr		r2,	=ObjectStates
	
	ldrb	r0, [r2, r3]
	
	cmp		r0, #1
	bge		Grounded		
	
CheckRightBlock:
	
	add		r0, xPos, #31
	lsr		r0, #5
	add		r3, r0, r1, lsl #5
	
	ldrb	r0, [r2, r3]
	
	cmp		r0, #1
	bge		Grounded

//KNOW WE ARE FALLING
Falling:
	mov 	r0, #8
	add		SprAdr, #14
	strb	r0, [SprAdr, Index, lsl #4]
	
	add		SprAdr, #1
	strb	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #15
	
	add		newY, yPos, #8
	b 		UpdateY

Grounded:
	mov		r0, #1
	add		SprAdr, #15
	strb	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #15
	b 		end

UpdateY:
	//add		SprAdr, #11
	//ldrb 	r0, [SprAdr, Index, lsl #4]
	//sub		SprAdr, #11
	
	//cmp		r0, #0
	
	mov		r0, #32
	mov		r1, #8
	mov		r2, xPos
	
	add		SprAdr, #4
	ldr		r3, [SprAdr, Index, lsl #4]
	sub		SprAdr, #4
	
	bl		PatchScreen
	
	
	add		SprAdr, #4
	str		newY, [SprAdr, Index, lsl #4]
	
checkOffscreen:
	mov		r0, #3
	lsl		r0, #8
	
	cmp		newY, r0
	blt		end
	
	mov		r0, Index
	mov 	r1, #0
	bl		GoombaDeath


end:
	.unreq	SprAdr
	.unreq	yPos
	.unreq	xPos
	.unreq	newY
	.unreq	Index
	
	pop		{r4-r8, pc}
	
	
.globl	GoombaDeath
//********************************************************
//		Args
//r0 = Index
//r1 = How he died
//r1 = 0, If offscreened
//r1 = 1, If stepped on by mario
//**********************************************************

GoombaDeath:
	push 	{r4, r5, lr}
	
	Index	.req	r4
	SprAdr 	.req	r5
	
	ldr		SprAdr, =SpriteStates
	mov 	Index, r0
	
	
	//Checking offscreen death
	cmp 	r1, #0
	bne		killedByMario
	
	mov		r0, #0
	add		SprAdr, #8
	
	strb	r0, [SprAdr, Index, lsl #4]
	b 		endKilling
	
killedByMario:
	cmp		r1, #1
	bne		blockKilled

	mov		r0, #1
	add		SprAdr, #8
	strb	r0, [SprAdr, Index, lsl #4]
	
	mov		r0, #7
	add		SprAdr, #2	
	
	strb	r0, [SprAdr, Index, lsl #4]
	b 		endKilling

blockKilled:
	
	mov		r0, #1
	add		SprAdr, #8
	strb	r0, [SprAdr, Index, lsl #4]
	
	mov		r0, #19
	add		SprAdr, #2
	
	strb	r0, [SprAdr, Index, lsl #4]
	b		endKilling

endKilling:
	.unreq	SprAdr
	.unreq	Index
	
	pop		{r4, r5, pc}

//****************************************************
//r0 Takes in index value

UpdateDeathAnimation:
	push	{r4-r7, lr}
	
	Index	.req	r4
	SprAdr	.req	r5
	xPos	.req	r6
	yPos	.req	r7
	
	ldr		SprAdr, =SpriteStates
	mov		Index, r0
	
	ldr		xPos, [SprAdr, Index, lsl #4]
	
	add		SprAdr, #4	
	ldr 	yPos, [SprAdr, Index, lsl #4]
	
	add		SprAdr, #6
	ldrb	r0, [SprAdr, Index, lsl #4]
	
	cmp		r0, #3
	beq 	ClearSprite
	
	cmp 	r0, #7
	beq		DrawFlatGoomba
	blt		DecrementFlatGoomba
	
	cmp 	r0, #11
	beq		ClearSprite
	
	cmp		r0,	#12
	beq		D2P7
	
	cmp		r0,	#13
	beq		D2P6
	
	cmp		r0,	#14
	beq		D2P5
	
	cmp		r0,	#15
	beq		D2P4
	
	cmp		r0,	#16
	beq		D2P3
	
	cmp		r0,	#17
	beq		D2P2
	
	cmp		r0,	#18
	beq		D2P1
	
	cmp		r0, #19
	beq		D2P0
	

ClearSprite:
	sub		SprAdr, #2
	mov		r0, #0
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =Clear	
	b		DrawSprite
	
DecrementFlatGoomba:
	sub		r0, #1
	
	strb	r0, [SprAdr, Index, lsl #4]
	b		EndDeathUpdate

DrawFlatGoomba:
	sub 	r0, #1
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =GoombaD1
	b		DrawSprite

D2P0:
	sub		r0, #1
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =GoombaD2P0
	b		DrawSprite

D2P1:
	sub		r0, #1
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =GoombaD2P1
	b		DrawSprite

D2P2:
	sub		r0, #1
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =GoombaD2P2
	b		DrawSprite

D2P3:
	sub		r0, #1
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =GoombaD2P3
	b		DrawSprite

D2P4:
	sub		r0, #1
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =GoombaD2P4
	b		DrawSprite

D2P5:
	sub		r0, #1
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =GoombaD2P5
	b		DrawSprite


D2P6:
	sub		r0, #1
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =GoombaD2P6
	b		DrawSprite

D2P7:
	sub		r0, #1
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =GoombaD2P7
	b		DrawSprite


DrawSprite:

	mov		r1, xPos
	mov		r2, yPos
	bl		DrawPicture3
	
	b		EndDeathUpdate


EndDeathUpdate:

	.unreq	Index
	.unreq	SprAdr
	.unreq	xPos
	.unreq	yPos
	
	pop		{r4-r7, pc}
	

	
