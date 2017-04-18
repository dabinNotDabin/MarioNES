/*
	Draws Game State without actual Values
	Characters are 8 pix wide
	16 pix high 
*/

//**************************************************
// * DrawChar -- Draws the supplied char to screen
// *
// * Inputs:
// * 	r0 - x coord (top left of char cell)
// * 	r1 - y coord (top left of char cell)
// * 	r2 - colour of char -- half-word
// * 	r3 - char to draw -- hex ascii value or pass in as mov, r3, #'B'
//**************************************************
	
.section	.text
.globl		DrawGameState
	
DrawGameState:
	push	{r4-r9, lr}

	xcoord	.req	r4	// X coordinate
	ycoord	.req	r5	// Y coordinate
	lPrint	.req	r6	// Letter to Print
	c	.req	r7	// Counter
	cArray	.req	r8	// Address of Array being printed
	white	.req	r9	// Colour White (half-word)

	ldr		white, =0xF800
	
	// Print Mario
	ldr		cArray, =MarioPrint	// Load Value of Mario Character Array

	mov		xcoord, #64		
	mov		ycoord, #64
	mov		c, #0
pMario:
	ldrb		lPrint, [cArray, c]	// Load value at MarioPrint[c]
	
	mov		r0, xcoord		// Pass in the x coordinate
	mov		r1, ycoord		// Pass in the y coordinate
	mov		r2, white		// Pass in the colour
	mov		r3, lPrint		// Pass in letter to print
	bl		DrawChar		// Call DrawChar to print character to screen

	add		xcoord, #8		// Increment x coordinate by 8 for next letter
	add		c, #1			// Increment counter by 1 for next letter

	cmp		c, #5			// Compare with size of Array (Mario = 5)
	blt		pMario			// If less than 5, print next letter	

	
	// Print Lives
	ldr		cArray, =LivesPrint

	ldr		xcoord, =832
	mov		c, #0
pLives:	
	ldrb		lPrint, [cArray, c]	// Load value at LivesPrint[c]

	mov		r0, xcoord
	mov		r1, ycoord
	mov		r2, white
	mov		r3, lPrint
	bl		DrawChar

	add		xcoord, #8
	add		c, #1

	cmp		c, #5
	blt		pLives	


	// Print Score 00
	mov		xcoord, #64
	add		ycoord, #16
	mov		c, #0
pScore:
	mov		r0, xcoord
	mov		r1, ycoord
	mov		r2, white
	mov		r3, #48			// Ascii "0"
	bl		DrawChar

	add		xcoord, #8		// Increment by 8
	add		c, #1

	cmp		c, #2
	blt		pScore

	
pCoin:	// Print Coins (Coin x like image)
	ldr		r0, =FCoin
	mov		r1, #192		// X coordinate for image
	mov		r2, #72			// Y coordinate for image
	bl		DrawPicture

	mov		xcoord, #228
	mov		ycoord, #80
	
//	ldr		cArray, =CoinQuant
//	mov		c, #0
pCQuant: // Prints Quantity of Coints
//	ldrb		lPrint, [cArray, c]	// Load character from CoinQuant

	mov		r0, xcoord
	mov		r1, ycoord
	mov		r2, white
	mov		r3, #88			// Ascii 'X'
	bl		DrawChar

//	add		xcoord, #8
//	add		c, #1

//	cmp		c, #4
//	blt		pCQuant

	.unreq	xcoord
	.unreq	ycoord
	.unreq	lPrint
	.unreq	c
	.unreq	cArray
	.unreq	white

	pop	{r4-r9, lr}
	mov	pc, lr


.align
.globl MarioPrint
MarioPrint:
	.ascii	"MARIO"

.align
.globl LivesPrint
LivesPrint:
	.ascii	"LIVES"

//.align
//.globl CoinQuant
//CoinQuant:
//	.ascii	"X"

	
/* In Main
.align
.globl GameState
GameState:
	.byte	0		// Map Instance will be 0, 1 or 2 in binary (like above)
				//	for 1st, 2nd, or 3rd section
	.byte	0		// 0000 0000 is MainMenu, 0000 0001 is InGame, 0000 0010 is InGameMenu
	.byte	5		// Lives
	.byte	0		// Coins
	.byte	0		// Win  (1 == Win)
	.byte	0		// Lose (1 == Lose)
	
	
	.word	0		// Score

*/
