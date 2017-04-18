.section .text


//CANNON STATE INFORMATION
// BYTE OFFSET	|   		NAME		|		DETAILS
////////////////////////////////////////////////////////////////////
//		0		| BULLET X - COORD		|	Top left corner origin
//		4		| BULLET Y - COORD		|	Top left corner	origin
//		8		| BULLET ACTIVITY		|	1 = Bullet Dead, 2 = Dead in Animation , 3 = Bullet Alive
//		9		| MONSTER CODE			|	FOR CANNON AND BULLET BILL = #2
//		10		| ANIMATION STATE		|	Starts at #0, Dead, #1-2 is Left, #3-4 is Right, #4-7 Left Death, #8-11 Right Death
//		11		| X-DIRECTION			|	0 = LEFT, 1 = RIGHT, 2 = NONE
//		12		| X-VELOCITY			|			0 - 255
//		13		| FIRE DIRECTION		|	0 = LEFT, 1 = RIGHT, 2 = NONE
//		14		| CANNON X GRID POS		|	FROM 0-31
//		15		| CANNON Y GRID POS		|	FROM 0-23
//		16 		| START OF NEXT	SPRITE	| 	START POSITION OF THE NEXT SPRITE


.globl InitializeCannon
//**********************************************************************
//* This function initializes Bullet Bill's Cannon based on it's 
//*	location in the level grid.
//*
//* The level grid is a 32x24 2D grid of tiles that are 32x32 pixels each.
//* You will notice shifts by 5 that can be explained by this information.
//*
//* Inputs:
//*		r0 - X position on level grid
//*		r1 - Y position on level grid
//**********************************************************************

InitializeCannon:
	push		{r4-r6, lr}
	
	sPointer	.req	r4
	xPos		.req	r5
	yPos		.req	r6
	
	
	mov		xPos, r0
	mov 	yPos, r1
	ldr		r0, =SpritePointer					// Get pointer to top of stack of sprite states
	ldr 	sPointer, [r0]


//**************** Initialize Cannon State ******************//	
//Bullet X-position
	mov		r0, xPos, lsl #5
	str		r0, [sPointer], #4
	
//Bullet Y-position
	mov		r0, yPos, lsl #5
	str		r0, [sPointer], #4
	
//Status: **Cannot be dead**: 
//1 = No bullet, 2 = Bullet is in death animation, 3 = Active bullet
	mov		r0, #1
	strb 	r0, [sPointer], #1
	
//MONSTER CODE - #2 for Bullet bill
	mov 	r0, #2
	strb	r0, [sPointer], #1
	
//Animation State
	mov		r0, #0
	strb	r0, [sPointer], #1
	
//HORIZONTAL Direction 
	mov		r0, #2
	strb	r0, [sPointer], #1
	
//HORIZONTAL Speed
	mov 	r0, #8
	strb	r0, [sPointer], #1
	
//DIRECTION TO FIRE
	mov		r0, #2
	strb	r0, [sPointer], #1
	
//X CANNON GRID POSITION
	mov		r0, xPos
	strb	r0, [sPointer], #1
	
//Y CANNON GRID POSITION
	mov		r0, yPos
	strb	r0, [sPointer], #1
	
//Updating the stack pointer (stack of sprite states)
	ldr		r0, =SpritePointer
	
	str		sPointer, [r0]
	
//Incrementing the sprite count 
	ldr		r0, =SpriteObj
	ldr		r1, [r0]
	add 	r1, #1	
	str 	r1,	[r0]
		
	.unreq	sPointer
	.unreq	xPos
	.unreq	yPos
	
	pop		{r4-r6, pc}
	
	
	
	
.globl CannonUpdate
//******************EXPECTS********************
//				  r0 = Index
//			  Cannon can never die.
//*********************************************
CannonUpdate:
	push	{r4-r8, lr}
	
	Index	.req	r4
	SprAdr	.req	r5
	xPos	.req	r6
	yPos	.req	r7
	FDir	.req	r8
	
	
	ldr		SprAdr, =SpriteStates
	mov		Index, r0
	
	add		SprAdr, #14
	ldrb	xPos, [SprAdr, Index, lsl #4]
	
	add		SprAdr, #1
	ldrb	yPos, [SprAdr, Index, lsl #4]
	
FindMario:
	//Finds Mario's X center position and compares
	ldr 	r0, =MarioState
	ldr		r1, [r0, #8]
	add		r1, #16
	lsr 	r1, #5
	mov		FDir, r1
	
	//Setting offset #13 - Fire Direction
	sub		SprAdr, #2
	
//Comparing Mario Position with Cannon
//If Mario centered X is less than Cannon X  =  Fire Left
//Else Mario centered X is greater than Cannon X  = Fire Right 
//Else Mario centered X = Cannon X = No direction

	cmp 	r1, xPos

SetAimDirection:
	
	//EQ = No Direction
	//GT = Aiming Right
	//LT = Aiming Left
	
	moveq	r0, #2
	movgt	r0,	#1
	movlt	r0,	#0
	
	strb	r0, [SprAdr, Index, lsl #4]
	
	
CheckStatus:
	
	//At offset #8 - Bullet Activity
	sub		SprAdr, #5
	ldrb	r0, [SprAdr, Index, lsl #4]
	sub 	SprAdr, #8
	
	
	cmp 	r0, #1
	beq		FireBill
	
	cmp		r0, #2
	beq		UpdateAnimation
	
	
BulletUpdating:
	mov		r0, Index
	bl		UpdateBullet
	
UpdateAnimation:
	
	mov		r0, Index
	bl		AnimationDealing
	
DrawNewImage:
	ldr		r1, [SprAdr, Index, lsl #4]
	
	lsl 	r3, xPos, #5
	sub 	r3, r1
	mvnmi	r3, r3
	addmi	r3, #1
	
	cmp 	r3, #40
	
	add		SprAdr, #4
	ldr		r2, [SprAdr, Index, lsl #4]
	
	bl		DrawPicture3
	bgt		endCannonUpdate
	
ClearCannonSmoke:
	add		SprAdr, #7
	ldrb	r0, [SprAdr, Index, lsl #4]
	
	cmp		r0, #0
	
	ldr		r0, =ClearSmoke
	mov		r2, yPos, lsl #5	
	
	beq		CLeftSmoke
	
	
CRightSmoke:
	mov		r1, xPos, lsl #5
	add		r1, #28
	bl		DrawPicture3
	
	b		endCannonUpdate
	
CLeftSmoke:
	mov 	r1, xPos, lsl #5
	bl		DrawPicture3
	
	b		endCannonUpdate
	

FireBill:
	cmp		FDir, #2
	beq		endCannonUpdate
	
	mov		r0, Index
	bl		FireBullet

	
endCannonUpdate:	
	.unreq	Index
	.unreq	SprAdr
	.unreq	xPos	
	.unreq	yPos
	.unreq	FDir
	
	pop		{r4-r8, pc}
	
	
	
//****************ARGS******************
//			   r0 = Index
//Should write and initialize new bullet
//**************************************

FireBullet:
	push 	{r4-r7, lr}
	
	SprAdr	.req	r4
	Index	.req	r5
	xPos	.req	r6
	yPos	.req	r7
	
	mov 	Index, r0
	ldr		SprAdr, =SpriteStates

	
	add		SprAdr, #14
	ldrb	xPos, [SprAdr, Index, lsl #4]
	
	//Setting #15 - Y Grid position
	add		SprAdr, #1
	ldrb	yPos, [SprAdr, Index, lsl #4]
	
	//Setting #13 - Fire Direction
	sub 	SprAdr, #2
	ldrb	r0, [SprAdr, Index, lsl #4]
	
	cmp		r0, #2
	beq		endFire
	
	//Comparing the value for fire direction to #1
	cmp		r0, #1

FireDirection:
	
	//Setting #11 - Direction
	//******NE for Left******
	//******EQ for Right*****
	
	movne	r0, #0
	moveq	r0, #1
	
	sub		SprAdr, #2
	strb	r0, [SprAdr, Index, lsl #4]
	
	//Setting #10 - Animation State
	//Set correct animation cycle for left bullet
	sub		SprAdr, #1
	
	movne	r0, #1
	moveq	r0,	#4
	
	strb	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #10
	
	
	//Making sure the block adjacent is not solid
	//		NE = LEFT, so (xPos - 1)
	//		EQ = RIGHT, so (xPos + 1)
	
	subne	r0, xPos, #1
	addeq	r0, xPos, #1
	
	ldr		r3, =ObjectStates
	add		r0, yPos, lsl #5
	ldrb 	r2, [r3, r0]

	subne	r1, xPos, #1
	addeq	r1, xPos, #1
	
	cmp		r2, #0
	bgt 	endFire
	
	//Storing bullet position	
	lsl		r1, #5
	str		r1, [SprAdr, Index, lsl #4]
	
	lsl 	r2, yPos, #5
	add		SprAdr, #4
	str		r2, [SprAdr, Index, lsl #4]
	sub 	SprAdr, #4
	
DrawBullet:

	//Setting to #11: X-Direction
	add		SprAdr, #11
	ldrb	r0, [SprAdr, Index, lsl #4]
	
	cmp		r0, #0
	ldreq	r0,	=BulletL0
	ldrne	r0, =BulletR0
	bl		DrawPicture3
	
	
	//Setting the Smoke Drawing
	ldrb	r0, [SprAdr, Index, lsl #4]
	cmp		r0, #0
	
	ldrne	r0, =SmokeR
	ldreq	r0, =SmokeL
	
	mov		r1, xPos, lsl #5
	addne	r1, #28
	
	mov		r2, yPos, lsl #5
	
	bl		DrawPicture3
	
	//Setting to #8: Bullet Activity setting to active: #3
	mov		r0, #3
	sub		SprAdr, #3
	strb	r0, [SprAdr, Index, lsl #4]
	
	
endFire:
	.unreq	SprAdr
	.unreq	Index
	.unreq	xPos
	.unreq	yPos
	
	
	pop		{r4-r7, pc}	
	


//**********************ARGS*************************
//					r0 = Index
//***************************************************
UpdateBullet:
	push	{r4-r7, lr}
	
	SprAdr	.req	r4
	xPos	.req	r5
	newX	.req	r6
	Index	.req	r7
	
	mov		Index, r0
	ldr 	SprAdr, =SpriteStates

	ldr		xPos, [SprAdr, Index, lsl #4]
	
	//Checking the direction
	
	add		SprAdr, #11
	ldrb	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #11
		
	//Setting to #12 - X Velocity	
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
	
	teq		r1, r2
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
	
	
OkayMove:

	add		SprAdr, #11
	ldrb 	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #11
	
	cmp		r0, #0
	
	mov		r0, #8
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
	//noGood makes it die
	mov		r0, #2
	
	add		SprAdr, #8
	strb	r0, [SprAdr, Index, lsl #4]

	
endMove: 

	.unreq	SprAdr
	.unreq	xPos
	.unreq	newX
	.unreq	Index
	
	pop		{r4-r7, pc}
	
	
//*********************ARGS*************************
//					r0 = Index
//		  	 ::::::::RETURNS:::::::::
//		 Address of the Next animation picture
//**************************************************
//ANIMATION CHANGE CODE
AnimationDealing:
	push	{r4-r5, lr}
	
	Index	.req	r4
	SprAdr	.req	r5
	
	mov 	Index, r0
	ldr		SprAdr, =SpriteStates
	
	
	add		SprAdr, #8
	ldrb	r0, [SprAdr, Index, lsl #4]
	sub		SprAdr, #8
	
	cmp		r0, #3
	beq		Alive
	
Dead:
	
	//Setting to #10 - Animation State
	add		SprAdr, #10
	ldrb	r0, [SprAdr, Index, lsl #4]
	
	cmp		r0, #4
	blt		DeadLeft
	
	cmp		r0, #7
	blt		DeadRight
	
	cmp		r0, #9
	blt		D7o8
	beq		D9
	
	cmp		r0, #10
	beq		D10
	
	b		Clear

DeadLeft:
	mov		r0, #7

	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr 	r0, =DeadBulletL0
	b 		endAniUpdate


DeadRight:
	mov		r0, #8
	
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr 	r0, =DeadBulletR0
	b 		endAniUpdate


D7o8:
	mov 	r0, #9
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr 	r0, =DeadBullet1
	b 		endAniUpdate

D9:
	mov		r0, #10
	strb	r0, [SprAdr, Index, lsl #4]
		
	ldr 	r0, =DeadBullet2
	b 		endAniUpdate

D10:
	//NEED TO CLEAR
	
	mov		r0, #1
	sub 	SprAdr, #2
	
	strb	r0, [SprAdr, Index, lsl #4]
	ldr		r0, =Clear
	b		endAniUpdate
	
Alive:
	add		SprAdr, #10
	ldrb	r0, [SprAdr, Index, lsl #4]
	
	cmp		r0, #2
	blt		B1
	beq		B2

	cmp		r0, #4
	blt		B3
	beq 	B4
	
	cmp		r0, #5
	beq		B5

B6:
	mov 	r0, #5
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =BulletR1
	
	b		endAniUpdate
	


B1:
	mov 	r0, #2
	strb	r0, [SprAdr, Index, lsl #4]

	ldr		r0, =BulletL1	

	b		endAniUpdate
	
	

B2:
	mov 	r0, #3
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =BulletL2	
	
	b		endAniUpdate
	
	
	
B3:
	mov 	r0, #2
	strb	r0, [SprAdr, Index, lsl #4]

	ldr		r0, =BulletL1
	
	b		endAniUpdate

	
B4:
	mov 	r0, #5
	strb	r0, [SprAdr, Index, lsl #4]
	
	ldr		r0, =BulletR1	
	
	b		endAniUpdate


B5:
	mov 	r0, #6
	strb	r0, [SprAdr, Index, lsl #4]
	ldr		r0, =BulletR2


endAniUpdate:
	
	.unreq	Index
	.unreq	SprAdr
	
	pop		{r4-r5, pc}
	
	
	
.globl BillDeath
//*************ARG*****************
//	r0 = Index
//	r1 = Killed by   #1 = Mario
//*********************************
	
BillDeath:	
	push 	{r4, r5, lr}
	
	Index	.req	r4
	SprAdr 	.req	r5
	
	ldr		SprAdr, =SpriteStates
	mov 	Index, r0
	
	mov		r0, #2
	
	add		SprAdr, #8
	strb	r0, [SprAdr, Index, lsl #4]	 	
	
	.unreq	Index
	.unreq	SprAdr
	
	pop		{r4, r5, pc}
