.section	.text


.globl	ShiftCheck
.align

ShiftCheck:
	push	{lr}
	
	ldr		r0, =MarioState
	ldr		r1, [r0, #8]
	
	cmp		r1, #0					// Compare Mario's X coord with 0, if <= 0, try to shift left
	bge		1f
	movlt	r0, #0					// Shift screen with r0 = 0 attempts a shift left
	bllt	ShiftScreen


	ldr		r0, =GameState
	ldrb	r0, [r0]
	cmp		r0, #0
	bne		2f
	
	ldr		r0, =MarioState
	ldr		r1, [r0, #8]
	ldr		r2, =990
	cmp		r1, r2					// Compare Mario's X coord with 0, if <= 0, try to shift left
	beq		2f
	
	
	add		r1, #31					//Snap mario to edge of screen
	bic		r1, #0x1F
//	sub		r1, #2
	str		r1, [r0, #8]
	mov		r1, #1					// Store 1 in move bit to indicate Mario was moved this loop
	strb	r1, [r0, #7]
	b		2f

	
1:	cmp		r1, #992
	ble		2f
	movgt	r0, #1
	blgt	ShiftScreen


	ldr		r0, =MarioState
	ldr		r1, [r0, #8]
	cmp		r1, #0
	beq		2f

	bic		r1, #0x1F				// Snap Mario to edge of screen
//	add		r1, #2
	str		r1, [r0, #8]
	mov		r1, #1					// Store 1 in move bit to indicate Mario was moved this loop
	strb	r1, [r0, #7]

	
	
2:	pop		{lr}
	mov		pc, lr






//////////////////////////////////////////////////////////////////////
// * ShiftScreen checks whether a screen shift is possible and performs
// * 	the shift if necessary by updating the shift status byte in the
// * 	GameState
// *
// * This byte must be checked and reset before each Game Loop and
// *	the new instance drawn if necessary.
// *
// * Inputs:
// *	r0 -- The direction to attempt to shift	0 == left, 1 == right
//*
//* Returns:
//* 	r0 -- 0 if shift not made, 1 if shift successful
//////////////////////////////////////////////////////////////////////
.globl	ShiftScreen
.align

ShiftScreen:
	push	{lr}
	
	
	ldr		r1, =GameState
	ldrb	r2, [r1]			// Current Game Instance
	
	cmp		r0, #0				// Check which direction to attempt to shift
	bne		1f					// Branch if direction is 1 (right)
	
	//ELSE -- Attempt shift left						
	cmp		r2, #0				// Check if current level instance is greater than 0  
	beq		2f					// If not, no shift possible.

	//ELSE -- Do Shift Left
	push	{r0-r2}
	bl		StoreInstance
	pop		{r0-r2}

	sub		r2, #1				// Decrement current Game Instance
	strb	r2, [r1]			// Store new instance
	mov		r2, #1				// Set byte in game state to indicate screen shift occurred
	strb	r2, [r1, #12]
	
	
	ldr		r0, =MarioState		// Marios X coord is 992 when screen shifts left
	ldr		r1, =990
	str		r1, [r0, #8]
	
	mov		r0, #1
	b		3f
	

1:	//ELSE	-- Attempt shift right
	
	ldrb	r3, [r1, #7]		// Max number of level instances
	sub		r3, #1				// Instances are 0, 1, 2... total instances == 2 means instance 0 and instance 1 are possible
	cmp		r2, r3				// Check if current level instance is >= to total number of instances  
	bge		2f					// If so, no shift possible

	//ELSE -- Do shift right
	push	{r0-r2}
	bl		StoreInstance
	pop		{r0-r2}
	
	add		r2, #1				// Increment current Game Instance
	strb	r2, [r1]			// Store new instance
	mov		r2, #1				// Set byte in game state to indicate screen shift occurred
	strb	r2, [r1, #12]


	ldr		r0, =MarioState		// Marios X coord is 0 when screen shifts right
	mov		r1, #0
	str		r1, [r0, #8]


	mov		r0, #1
	b		3f



2:	mov		r0, #0

	
3:
	pop		{lr}
	mov		pc, lr






	





.globl	DrawNewSection
.align

DrawNewSection:
	push	{lr}

	mov		r0, #0x0
	bl		DrawColour
	bl		InitObjectStates
	bl		InitSpriteArray

	
	bl		BackupMario
	
	
	ldr		r0, =GameState
	ldrb	r1, [r0] 				// Current level instance

	cmp		r1, #0
	bne		1f
	ldr		r0, =LevelBackground
//	ldr		r0, =winBackground
	bl		DrawUniformPicture
	ldr		r0, =Screen1
	bl		DrawLevel
	b		end

	
1:	cmp		r1, #1
	bne		2f
	ldr		r0, =batmanBackground
//	ldr		r0, =winBackground
	bl		DrawUniformPicture
	ldr		r0, =Screen2
	bl		DrawLevel
	b		end

2:	cmp		r1, #2
	bne		3f
	ldr		r0, =Screen3
	bl		DrawLevel
	b		end

3:	cmp		r1, #3
	bne		4f
	ldr		r0, =Screen4
	bl		DrawLevel
	b		end

4:	ldr		r0, =winBackground
	bl		DrawUniformPicture
	ldr		r0, =Screen5
	bl		DrawLevel

	
	
end:
	pop		{lr}
	mov		pc, lr


	

	
	
	
	

.globl	StoreInstance
.align

StoreInstance:
	push	{r4-r11}
	push	{lr}


	ldr		r0, =GameState
	ldrb	r0, [r0] 				// Current level instance


	bl		GetCurrentGrid
	mov		r1, r0
	
	

1:	ldr		r0, =ObjectStates		

	add		r2, r0, #768		
	
	b		check	
		
top:
	ldmltia r0!, {r4-r11}

	stmltia	r1!, {r4-r11}

check:	
	cmp		r0, r2
	blt		top



	pop		{lr}
	pop		{r4-r11}
	
	mov		pc, lr
	
	
	




// Returns the address for the beginning of the level grid
// corresponding to the current level (gets dynamic grid).

.globl	GetCurrentGrid
.align

GetCurrentGrid:
	
	ldr		r0, =GameState
	ldrb	r0, [r0] 				// Current level instance

	cmp		r0, #0
	ldreq	r0, =Screen1
	beq		1f

	cmp		r0, #1
	ldreq	r0, =Screen2
	beq		1f
	
	cmp		r0, #2
	ldreq	r0, =Screen3
	beq		1f

	cmp		r0, #3
	ldreq	r0, =Screen4
	beq		1f

	cmp		r0, #4
	ldreq	r0, =Screen5
	beq		1f


	
1:	mov		pc, lr
	











// Returns the address for the beginning of the level grid
// corresponding to the current level (gets dynamic grid).

.globl	GetCurrentStaticGrid
.align

GetCurrentStaticGrid:
	
	ldr		r0, =GameState
	ldrb	r0, [r0] 				// Current level instance

	cmp		r0, #0
	ldreq	r0, =Screen1Static
	beq		1f

	cmp		r0, #1
	ldreq	r0, =Screen2Static
	beq		1f

	cmp		r0, #2
	ldreq	r0, =Screen3Static
	beq		1f

	cmp		r0, #3
	ldreq	r0, =Screen4Static
	beq		1f

	cmp		r0, #4
	ldreq	r0, =Screen5Static
	beq		1f


	
1:	mov		pc, lr
	











.globl	InitDynamicGrids
.align

InitDynamicGrids:
	push	{r4-r11}
	push	{lr}


	ldr		r0, =GameState
	ldrb	r3, [r1, #7]		// Max number of level instances


	mov		r12, #0
	b		CheckInstanceCount
	

Prepare:

	add		r2, r0, #768		
	
	
	b		check1	
		
top1:
	ldmltia r0!, {r4-r11}

	stmltia	r1!, {r4-r11}

check1:	
	cmp		r0, r2
	blt		top1


	add		r12, #1


CheckInstanceCount:
	cmp		r12, r3 
	bge		End
	
	cmp		r12, #0
	ldreq	r0, =Screen1Static
	ldreq	r1, =Screen1
	beq		Prepare

	cmp		r12, #1
	ldreq	r0, =Screen2Static
	ldreq	r1, =Screen2
	beq		Prepare

	cmp		r12, #2
	ldreq	r0, =Screen3Static
	ldreq	r1, =Screen3
	beq		Prepare
	
	cmp		r12, #3
	ldreq	r0, =Screen4Static
	ldreq	r1, =Screen4
	beq		Prepare
	
	cmp		r12, #4
	ldreq	r0, =Screen5Static
	ldreq	r1, =Screen5
	beq		Prepare



End:
	pop		{lr}
	pop		{r4-r11}
	
	mov		pc, lr
	


	
	
	
	
