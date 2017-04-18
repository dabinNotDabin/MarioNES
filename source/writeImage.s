
.section .text
.globl DrawPicture
.globl DrawPicture2
.globl DrawUniformPicture


//r0 = address of picture
//r1 = xCoord
//r2 = yCoord

DrawUniformPicture:
	push 	{r4-r11}
	push	{lr}

	mov		r12, r0

	ldr 	r2, [r0], #4	//Width of the picture
	ldr 	r3, [r0], #4	//Height of the picture


	lsr		r2, #4			//Divide width by 16
	

	ldr		r1, =FrameBufferPointer
	ldr		r1, [r1]


	b	RowTest
ProcessRow:


	b	ColumnTest
ProcessCurrentPixels:


	ldmia	r0!, {r4-r11}
	stmia	r1!, {r4-r11}
	sub		r2, #1			//Since 8 registers is 16 pixels and I divided width by 16, 1 == 16 px	
	

ColumnTest:
	cmp 	r2, #0
	bgt		ProcessCurrentPixels


	ldr 	r2, [r12] 		//Width of the picture


							// New frame buffer offset = currentOffset + (2048 - (width*2))
	ldr		r4, =2048
	sub		r4, r2, lsl #1	// 2048 - (width*2)
	add		r1, r4 			// Current offset  + (2048 - (width*2))


	lsr		r2, #4			// Divide width by 16
	sub		r3, #1			// To process next column


RowTest:
	cmp 	r3,	#0
	bgt		ProcessRow


	pop		{lr}
	pop 	{r4-r11}
	mov		pc, lr







DrawPicture:
	push {r4-r9, lr}
	
	xpos		.req	r4
	ypos		.req	r5
	xIndex		.req	r6
	yIndex		.req	r7
	picAdr		.req	r8
	offset		.req	r9
	
drawInit:	
	mov 	picAdr, r0
	mov 	xIndex, #0
	mov 	yIndex, #0
	add 	picAdr, #8
	mov 	xpos, r1
	mov 	ypos, r2
	
	
	ldr 	r10, [picAdr, #-8]	//Width of the picture
	ldr 	r11, [picAdr, #-4]	//Height of the picture


	b		RowLoopTest
ProcessCurrentRow:


	b		ColumnLoopTest
ProcessCurrentPixel:
	
	ldrh 	r2, [picAdr], #2
		
	add 	r0, xpos, xIndex
	add 	r1, ypos, yIndex
	
	ldr		r3, =0xF81F
	cmp		r2, r3
	blne	DrawPixel

	add 	xIndex, #1

ColumnLoopTest:
	cmp 	xIndex, r10
	blt		ProcessCurrentPixel



	mov 	xIndex, #0
	add 	yIndex, #1

RowLoopTest:
	cmp 	yIndex, r11
	blt		ProcessCurrentRow

	
	
  
endDraw:

	.unreq	xpos
	.unreq	ypos
	.unreq	xIndex
	.unreq	yIndex
	.unreq	picAdr
	.unreq	offset

	pop {r4-r9, pc}

	
	
	
	

//r0 - picture address
//r1 - picture x coord
//r2 - picture y coord
DrawPicture2:
	push {r10-r11, lr}
	
	add		r1, r1, r2, lsl #10		// r1 = x + (y * 1024)			
	lsl		r1, #1					// r1 =(x + (y * 1024)) * 2

	ldr		r2, =FrameBufferPointer
	ldr		r2, [r2]
	add		r1, r1, r2				// Where to start drawing in buffer
	
	
	ldr 	r10, [r0], #4	//Width of the picture
	ldr 	r11, [r0], #4	//Height of the picture
	mov		r12, r10

	
	// r0  == start of ascii colour data
	// r1  == starting position in FrameBuffer
	// r10 == width of picture
	// r11 == height of picture 
	// r12 == width of picture
	
	b		RowCounter
CurrentRowLoop:


	b		ColumnCounter
DrawCurrentPixel:
	
	ldrh 	r2, [r0], #2
		
	ldr		r3, =0xF81F
	cmp		r2, r3
	strneh	r2, [r1], #2
	addeq	r1, #2
	
	sub		r10, #1

ColumnCounter:
	cmp 	r10, #0
	bgt		DrawCurrentPixel

	
	mov 	r10, r12			// Picture width

	ldr		r3, =2048			
	sub		r3, r10, lsl #1		// 2048 - (width*2)
	add		r1, r3 				// Current offset  + (2048 - (width*2))


	sub 	r11, #1

RowCounter:
	cmp 	r11, #0
	bgt		CurrentRowLoop

	
	
	pop 	{r10-r11, lr}
	mov		pc, lr
	
	
	
	
	
	
	
	


//r0 - picture address
//r1 - picture x coord
//r2 - picture y coord
.globl DrawPicture3
DrawPicture3:
	push {r4, r8-r11, lr}
	
	mov		r8, #1
	
	add		r1, r1, r2, lsl #10		// r1 = x + (y * 1024)			
	lsl		r1, #1					// r1 =(x + (y * 1024)) * 2


	ldr		r4, =GameState
	ldrb	r4, [r4, #1]			// MainMenu byte
	cmp		r4, #0
	bne		GetImg1

	ldr		r9, =MM2
	b		1f


GetImg1:
	ldr		r4, =GameState
	ldrb	r4, [r4]				// CurrentMapInstance

	cmp		r4, #0
	ldreq	r9, =LevelBackground
	beq		1f	
	cmp		r4, #1		
	ldreq	r9, =batmanBackground
	beq		1f
	cmp		r4, #4		
	movlt	r8, #0
	ldrlt	r9, =black
	blt		1f
	ldreq	r9, =winBackground
	beq		1f


//	ldr		r9, =LevelBackground


1:	ldr		r2, =FrameBufferPointer
	ldr		r2, [r2]


	add		r9, #8				// Skip picture size information

	cmp		r8, #0
	addne	r9, r1
	add		r2, r1				// Where to start drawing in buffer
	
	
	

	
	
	ldr 	r10, [r0], #4	//Width of the picture
	ldr 	r11, [r0], #4	//Height of the picture
	mov		r12, r10

	
	// r9  == start of ascii background colour data
	// r1  == starting position in FrameBuffer
	// r10 == width of picture
	// r11 == height of picture 
	// r12 == width of picture
	
	b		RowCounter3
CurrentRowLoop3:


	b		ColumnCounter3
DrawCurrentPixel3:
	
	ldrh 	r1, [r0], #2
		
	ldr		r3, =0xF81F
	cmp		r1, r3
	
	strneh	r1, [r2], #2
	addne	r9, #2
	

//	moveq	r9, #0
//	streqh	r9, [r2], #2
	
	ldreqh	r1, [r9], #2
	streqh	r1, [r2], #2
	
	sub		r10, #1

ColumnCounter3:
	cmp 	r10, #0
	bgt		DrawCurrentPixel3

	
	mov 	r10, r12			// Picture width

	ldr		r3, =2048			
	sub		r3, r10, lsl #1		// 2048 - (width*2)
	add		r2, r3 				// Current offset  + (2048 - (width*2))

	cmp		r8, #0
	addne	r9, r3


	sub 	r11, #1

RowCounter3:
	cmp 	r11, #0
	bgt		CurrentRowLoop3

	
	
	pop 	{r4, r8-r11, lr}
	mov		pc, lr
	
	
	
	
	


/////////////////////////////////////
//* r0 -- width of patch
//* r1 -- height of patch
//* r2 -- starting x coord
//* r3 -- starting y coord
////////////////////////////////////
.globl PatchMove2PX
PatchMove2PX:
	push	{r4-r11}
	push	{lr}

	mov		r8, #1

	mov		r12, r0
	
	add		r6, r2, r3, lsl #10		// r1 = x + (y * 1024)			
	lsl		r6, #1					// r1 =(x + (y * 1024)) * 2


	ldr		r4, =GameState
	ldrb	r4, [r4, #1]			// MainMenu byte
	cmp		r4, #0
	bne		GetImg2

	ldr		r2, =MM2
	b		1f


GetImg2:
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



1:	add		r2, #8					// First 8 bytes are picture size information
	
	ldr		r3, =FrameBufferPointer // Address of Beginning of Frame Buffer
	ldr		r3, [r3]

	cmp		r8, #0
	addne	r2, r6					// Starting offset in ascii file
	add		r3, r6					// Starting offset in FrameBuffer


	lsr		r0, #1					// Divide width by 2	

	
	b	RowTest2
ProcessRow2:


	b	ColumnTest2
ProcessCurrentPixels2:

	ldr		r4, [r2], #4
	str		r4, [r3], #4
	

	sub		r0, #1			//Since 2 registers is 4 pixels and I divided width by 4, 1 == 4 px	
	

ColumnTest2:
	cmp 	r0, #0
	bgt		ProcessCurrentPixels2


	mov 	r0, r12 		//Width of the picture


							// New frame buffer offset = currentOffset + (2048 - (width*2))
	ldr		r4, =2048
	sub		r4, r0, lsl #1	// 2048 - (width*2)
	
	cmp		r8, #0
	addne	r2, r4 			// Current offset  + (2048 - (width*2))
	add		r3, r4 			// Current offset  + (2048 - (width*2))


	lsr		r0, #1			// Divide width by 2
	sub		r1, #1			// To process next column


RowTest2:
	cmp 	r1,	#0
	bgt		ProcessRow2
	


	pop		{lr}
	pop 	{r4-r11}
	mov		pc, lr
	
	
	
