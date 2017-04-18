
//**************************************************
// * DrawChar -- Draws the supplied char to screen
// *
// * Inputs:
// * 	r0 - x coord (top left of char cell)
// * 	r1 - y coord (top left of char cell)
// * 	r2 - colour of char -- half-word
// * 	r3 - char to draw -- hex ascii value or pass in as mov, r3, #'B'
//**************************************************

.align
.section    .text
.globl      DrawChar

DrawChar:
	push	{r4-r10, lr}

	chAdr	.req	r4
	x		.req	r5
	y		.req	r6
	row		.req	r7
	mask	.req	r8
	colour	.req	r9
	tmpx	.req	r10
	
	mov		x,		r0			// Init the X coordinate (pixel coordinate)
	mov		y,		r1			// Init the Y coordinate (pixel coordinate)
	mov		colour,	r2			// Move the supplied colour into colour

	
	ldr		chAdr,	=font		// Load the address of the font map

	add		chAdr,	r3, lsl #4	// Char address = font base + (char * 16)


drawCharLoop:
	ldrb	row,	[chAdr], #1	// Load the row bits, post increment chAdr
	mov		mask,	#0x01		// Set the bitmask to 1 in the LSB
	mov		tmpx,	x			// Move starting x coord into tmpx
	

drawRowLoop:
	tst		row,	mask		// Should there be a pixel at this location?
	beq		noDraw				// If not, branch to noDraw, else ...


	mov		r0,		tmpx		// ... Move tmpx into r0 
	mov		r1,		y			// Move y into r1
	mov		r2, 	colour		// Move colour into r2
	bl		DrawPixel			// Draw Pixel at location (x,y)

noDraw:
	add		tmpx,	#1			// Increment tmpx by 1
	lsl		mask,	#1			// Shift bitmask left by 1

	tst		mask,	#0x100		// Have we processed entire row?
	beq		drawRowLoop			// If not, branch to drawRowLoop, else ...

	add		y,		#1			// Increment y coordinate by 1

	tst		chAdr,	#0xF		// Is charAdr evenly divisible by 16?
	bne		drawCharLoop		// If not, branch to drawCharLoop, else ...

	.unreq	chAdr
	.unreq	x
	.unreq	y
	.unreq	row
	.unreq	mask
	.unreq	colour
	.unreq	tmpx
	
	pop		{r4-r10, lr}		// ... Restore callee saved registers
	mov		pc, 	lr			// Link back to calling code
	
	
// Should be in main somewhere??
.section .data
.align 4
font:		.incbin	"font.bin"
