.section .text
.globl DrawLevel
//r0 = level address	(each is 1 byte)
//32 by 24
//Looks at object code.
//0 = nothing
//1 = Block
//2 = Goomba
//4 = Top Left Pipe
//5 = Top Right Pipe
//6 = Base Left Pipe
//7 = Base Right Pipe
DrawLevel:
	push 	{r4-r8, lr}
	
	xIndex	.req 	r4
	yIndex	.req	r5
	objCode	.req	r6
	objAdr	.req	r7
	offset	.req	r8
	
	mov 	objAdr, r0
	mov		xIndex, #0
	mov		yIndex, #0
	
	b check
	
newRow:
	mov 	xIndex, #0	
	add		yIndex, #1
	
	cmp		yIndex, #24
	bge		endRoutine
	
check:
	cmp		xIndex, #32
	bge		newRow
	
	add		offset, xIndex, yIndex, lsl #5
	ldrb	objCode, [objAdr, offset]

//is it nothing		
	cmp 	objCode, #0
	bne		isBlock
	
	b increment
	
isBlock:
	cmp		objCode, #1
	bne		isTLPipe
	
	ldr		r0, =ObjectStates
	mov		r1, #1
	strb	r1, [r0, offset]
	
	ldr		r0, =block
	
	b 		DrawGrid

		
isTLPipe:
	cmp 	objCode, #4
	bne		isTRPipe
	
	ldr		r0, =ObjectStates
	mov 	r1, #4
	strb	r1, [r0, offset]

	ldr		r0, =pipeTL
	b		DrawGrid

isTRPipe:
	cmp 	objCode, #5
	bne		isBLPipe
	
	ldr		r0, =ObjectStates
	mov 	r1, #5
	strb	r1, [r0, offset]
	
	ldr 	r0, =pipeTR
	b		DrawGrid
	

isBLPipe:
	cmp 	objCode, #6
	bne		isBRPipe

	ldr		r0, =ObjectStates
	mov 	r1, #6
	strb	r1, [r0, offset]

	ldr 	r0, =pipeL
	b		DrawGrid
	
isBRPipe:
	cmp 	objCode, #7
	bne		isCannonTop
	
	ldr		r0, =ObjectStates
	mov 	r1, #7
	strb	r1, [r0, offset]
	
	ldr 	r0, =pipeR
	b		DrawGrid
	
	
isCannonTop:
	cmp 	objCode, #8
	bne		isCannonBot
	
	ldr		r0, =ObjectStates
	mov 	r1, #8
	strb	r1, [r0, offset]
	
	mov 	r0, xIndex
	mov 	r1, yIndex
	bl		InitializeCannon
	
	ldr 	r0, =CannonTop
	b		DrawGrid

isCannonBot:
	cmp		objCode, #9
	bne		isBrickBlock
	
	ldr		r0, =ObjectStates
	mov 	r1, #9
	strb	r1, [r0, offset]
	
	ldr 	r0, =CannonBase
	b		DrawGrid
	
	
isBrickBlock:
	cmp 	objCode, #12
	bne		isQuestionBlock

	ldr		r0, =ObjectStates
	mov 	r1, #12
	strb	r1, [r0, offset]

	ldr 	r0, =woodBlock
	b		DrawGrid

isQuestionBlock:
	cmp 	objCode, #16
	bne		isCoin

	ldr		r0, =ObjectStates
	mov 	r1, #16
	strb	r1, [r0, offset]

	ldr 	r0, =qBlock
	b		DrawGrid


isCoin:
	cmp 	objCode, #20
	bne		isWin

	ldr		r0, =ObjectStates
	mov 	r1, #20
	strb	r1, [r0, offset]

	ldr 	r0, =FCoin
	b		DrawGrid
	
	
isWin:
	cmp 	objCode, #25
	bne		increment

	ldr		r0, =ObjectStates
	mov 	r1, #25
	strb	r1, [r0, offset]
	b		increment




	
DrawGrid:
	mov 	r1, xIndex, lsl #5			//x coord
	mov		r2,	yIndex, lsl #5			//y coord
	bl 		DrawPicture2
	
increment:
	add 	xIndex, #1
	b check

endRoutine:
	pop 	{r4-r8, pc}












.section .text
.globl DrawGoombas
//r0 = level address	(each is 1 byte)
//32 by 24
//Looks at object code.
//0 = nothing
//1 = Block
//2 = Goomba
//4 = Top Left Pipe
//5 = Top Right Pipe
//6 = Base Left Pipe
//7 = Base Right Pipe
DrawGoombas:
	push 	{r4-r8, lr}
	
	xIndex	.req 	r4
	yIndex	.req	r5
	objCode	.req	r6
	objAdr	.req	r7
	offset	.req	r8
	
	mov 	objAdr, r0
	mov		xIndex, #0
	mov		yIndex, #0
	
	b 		check1
	
newRow1:
	mov 	xIndex, #0	
	add		yIndex, #1
	
	cmp		yIndex, #24
	bge		endRoutine1
	
check1:
	cmp		xIndex, #32
	bge		newRow1
	
	add		offset, xIndex, yIndex, lsl #5
	ldrb	objCode, [objAdr, offset]


isGoomba1:
	cmp 	objCode, #2
	bne		increment1

	mov 	r0, xIndex, lsl #5
	mov 	r1, yIndex, lsl #5
	bl		InitializeGoomba	
	
	ldr 	r0, =goomba1
	b		DrawGrid1
	
	
DrawGrid1:
	mov 	r1, xIndex, lsl #5			//x coord
	mov		r2,	yIndex, lsl #5			//y coord
	bl 		DrawPicture2
	
increment1:
	add 	xIndex, #1
	b 		check1

endRoutine1:
	pop 	{r4-r8, pc}















