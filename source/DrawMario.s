
.section    .text
.globl      DrawMario
.align

DrawMario:
	push	{r4-r5, lr}


	ldr		r0, =MarioState
	ldr		r1, [r0, #8]				// Mario Top Left X coord
	ldr		r2, [r0, #12]				// Mario Top Left Y coord
	ldrb	r3, [r0]					// Stage of Animation
	cmp		r3, #4
	beq		stageE

	cmp		r3, #5
	beq		stageF
	


	ldrb	r5, [r0, #1]				// Mario Horizontal Direction
	ldrb	r4, [r0, #3]				// Mario Vertical Direction
	cmp		r4, #2						// 2 == NONE
	bne		MidAir						// If not NONE, mario is midair



	
	ldrb	r4, [r0, #1]				// Mario Horizontal Direction
	cmp		r4, #2						// If 2, set stage of animation to 0			
	moveq	r3, #0
	streqb	r3, [r0]
	


stageA:	
	cmp		r3, #0
	bne		stageB

	cmp		r5, #1
	ldrlt	r0, =smallMario0L
	ldrge	r0, =smallMario0R
	bl		DrawPicture3
	
	b		EndAnim00	

	
stageB:	
	cmp		r3, #1
	bne		stageC

	cmp		r5, #1
	ldrlt	r0, =smallMario1L
	ldrge	r0, =smallMario1R
	bl		DrawPicture3
	
	b		EndAnim00

	
stageC:
	cmp		r3, #2
	bne		stageD

	cmp		r5, #1
	ldrlt	r0, =smallMario2L
	ldrge	r0, =smallMario2R
	bl		DrawPicture3

	b		EndAnim00


stageD:
	cmp		r3, #3
	bne		stageE

	cmp		r5, #1
	ldrlt	r0, =smallMario3L
	ldrge	r0, =smallMario3R
	bl		DrawPicture3
	
	b		EndAnim00


stageE:
	cmp		r3, #4
	bgt		stageF
	bl		DoMarioDeathAnim
	bl		InitMarioState
	b		EndAnim00



stageF:
	
	bl		DoMarioWinAnim
	bl		InitMarioState
	b		EndAnim00
	
	
	

MidAir:
	cmp		r5, #1
	ldrlt	r0, =smallMarioJumpingL
	ldrge	r0, =smallMarioJumpingR
	bl		DrawPicture3
	
	
	

EndAnim00:

	ldr		r0, =MarioState
	ldrb	r1, [r0]
	add		r1, #1

	cmp		r1, #4
	strltb	r1, [r0]

	movge	r1, #1
	strgeb	r1, [r0]
	

	pop		{r4-r5, lr}
	mov		pc, lr









.section    .text
.globl      DoMarioDeathAnim
.align

DoMarioDeathAnim:
	push	{r4-r5, lr}

	ldr		r3, =MarioState
	mov		r0, #32
	mov		r1, #44
	ldr		r2, [r3, #16] 				// Mario X
	ldr		r3, [r3, #20]				// Mario Y
	sub		r3, #12
	
	bl		PatchScreen




	mov		r4, #0
	b		test0
	
	
top0:
	ldr		r0, =MarioState
	ldr		r1, [r0, #8] 				// Mario X
	ldr		r2, [r0, #12]				// Mario Y


	
	tst		r4, #0x1
	ldreq	r0, =smallMarioDeadT		// If zero flag set, result is even
	ldrne	r0, =smallMarioDeadNoT		// Else result is odd

	bl		DrawPicture3
	ldr		r0, =0x18000
	bl		wait

	add		r4, #1

test0:
	cmp		r4, #8
	blt		top0



	ldr		r0, =MarioState
	ldr		r5, [r0, #12]

	b		test1

top1:

	ldr		r0, =MarioState
	ldr		r2, [r0, #8] 				// Mario X
	sub		r3, r5, #8					// Mario Y

	mov		r0, #32
	mov		r1, #32
	bl		PatchScreen
	
	
	ldr		r0, =MarioState
	ldr		r1, [r0, #8] 				// Mario X
	mov		r2, r5	
	
	tst		r4, #0x1
	ldreq	r0, =smallMarioDeadT		// If zero flag set, result is even
	ldrne	r0, =smallMarioDeadNoT		// Else result is odd
	bl		DrawPicture3


	ldr		r0, =0x8000
	bl		wait

	add		r5, #8
	add		r4, #1

test1:
	cmp		r5, #736
	blt		top1

	
	pop		{r4-r5, lr}
	mov		pc, lr
















.section    .text
.globl      DoMarioWinAnim
.align

DoMarioWinAnim:
	push	{r4-r5, lr}



	mov		r4, #0
	mov		r5, #1
	b		test2
	
	
top2:
	ldr		r0, =MarioState
	ldr		r1, [r0, #8] 				// Mario X
	ldr		r2, [r0, #12]				// Mario Y

	
	cmp		r5, #2
	ldrlt	r0, =smallMario0R		
	ldreq	r0, =smallMarioCheer
	ldrgt	r0, =smallMario0L		

	movgt	r5, #0


	bl		DrawPicture3
	ldr		r0, =0x80000
	bl		wait

	add		r4, #1
	add		r5, #1

test2:
	cmp		r4, #6
	blt		top2


	
	pop		{r4-r5, lr}
	mov		pc, lr



















/////////////////////////////////////
//* r0 -- width of patch
//* r1 -- height of patch
//* r2 -- starting x coord
//* r3 -- starting y coord
////////////////////////////////////

.globl      PatchScreen
.align

PatchScreen:
	push	{r4-r11}
	push	{lr}


	mov		r8, #1


	mov		r12, r0

	add		r6, r2, r3, lsl #10		// r1 = x + (y * 1024)			
	lsl		r6, #1					// r1 =(x + (y * 1024)) * 2


	ldr		r4, =GameState
	ldrb	r4, [r4, #1]			// MainMenu byte
	cmp		r4, #0
	bne		GetImg

	ldr		r2, =MM2
	b		1f

GetImg:
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


1:	
	add		r2, #8					// First 8 bytes are picture size information
	
	ldr		r3, =FrameBufferPointer // Address of Beginning of Frame Buffer
	ldr		r3, [r3]


	cmp		r8, #0
	addne	r2, r6					// Starting offset in ascii file
	add		r3, r6					// Starting offset in FrameBuffer


	lsr		r0, #4					// Divide width by 16	


	push	{r8}

	
	b	RowTest
ProcessRow:


	b	ColumnTest
ProcessCurrentPixels:

	ldmia	r2!, {r4-r11}
//	stmia	r3!, {r4-r11}
	
	
	str		r4, [r3], #4
	str		r5, [r3], #4
	str		r6, [r3], #4
	str		r7, [r3], #4
	str		r8, [r3], #4
	str		r9, [r3], #4
	str		r10, [r3], #4
	str		r11, [r3], #4
	
	
	sub		r0, #1			//Since 8 registers is 16 pixels and I divided width by 16, 1 == 16 px	
	

ColumnTest:
	cmp 	r0, #0
	bgt		ProcessCurrentPixels


	mov 	r0, r12 		//Width of the picture


							// New frame buffer offset = currentOffset + (2048 - (width*2))
	ldr		r4, =2048
	sub		r4, r0, lsl #1	// 2048 - (width*2)

	pop		{r8}	
	cmp		r8, #0
	addne	r2, r4 			// Current offset  + (2048 - (width*2))
	push	{r8}
	
	add		r3, r4 			// Current offset  + (2048 - (width*2))


	lsr		r0, #4			// Divide width by 16
	sub		r1, #1			// To process next column


RowTest:
	cmp 	r1,	#0
	bgt		ProcessRow
	

	pop		{r8}

	pop		{lr}
	pop 	{r4-r11}
	mov		pc, lr







	
	
	

