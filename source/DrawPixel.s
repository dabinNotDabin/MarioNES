.align
.section    .text
.globl      DrawPixel

//******************************
// *  Draw Pixel
// *
// *  Inputs:
// *  	r0 - x
// *  	r1 - y
// *  	r2 - color (halfword)
//******************************



DrawPixel:
	push	{r4}


	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop		{r4}
	bx		lr



drawPixel:
	push	{r4}

											// Register Equates
	x		.req	r0
	y		.req	r1
	colour	.req	r2
	offset	.req	r3
	tmp		.req	r4
	
	cmp		x, 		#0						// Was supplied x value less than 0?
	movlo	pc,		lr						// If so, link back to caller, else ...
	
	cmp		y, 		#0						// Was supplied y value less than 0?
	movlo	pc, 	lr						// If so, link back to caller, else ...
	
	ldr		tmp, 	=FrameBufferInfo		// ... Get address of FrameBufferInfo
	ldr		tmp, 	[tmp, #24]				// Load the value corresponding to the height of the resolution
	cmp		y,		tmp						// Is the given y value >= height? (We need;  0 <= y <= 1023)
	movhs	pc,		lr						// If so, out of range - Return to caller, else ...
	
	ldr		tmp, 	=FrameBufferInfo		// ... Get address of FrameBufferInfo
	ldr 	tmp, 	[tmp, #20]				// Load the value corresponding to the width of the resolution
	cmp 	x,		tmp						// Is the given x value >= width? (We need;  0 <= x <= 767)
	movhs 	pc, 	lr						// If so, out of range - Return to caller, else ...

	mla		offset,	y, tmp, x				// ... Offset = (y * width) + x
	lsl		offset,	#1						// Offset = Offset * 2 (2 bytes per pixel)
	
	
	ldr		r0, =FrameBufferPointer			// Get Address of FrameBufferPointer (Label In Data Section Where Actual FBP Is Stored For Global Access)
	ldr		r0, [r0]						// Load value at FrameBufferPointer  (Actual FBP)
	strh	r2, [r0, offset]				// Store colour (half-word) at FBP + offset
	
	.unreq	x
	.unreq	y
	.unreq	colour
	.unreq	offset
	.unreq	tmp

	pop		{r4}							// Restore r4
	mov		pc,	lr							// Link back to caller


	
