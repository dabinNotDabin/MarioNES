/*
*	Updates and Draws Game State values (Score, Coins, and Lives)
*	Note: Convert value to ascii +48
*
*	PatchScreen(width, height, x, y)
*
*	Characters are 8 pix wide and 16 pix high
*
*	DrawChar(xcoord, ycoord, colour, char)
*
*	Input:
*			r0 -- colour to draw characters	
*/

.section	.text
.globl		UpdateGameState
	
UpdateGameState:	
	push	{r4-r11, lr}

	lives	.req	r4
	coins	.req	r5
	score	.req	r6
	num	.req	r7
	upd	.req	r8
	white	.req	r9
	c	.req	r10			// Counter

	bl		DrawGameState


    // Load Values of GameState
    ldr        r0, =GameState        // Address of GameState Values
    ldrb        lives, [r0, #2]        // Lives
    ldrb        coins, [r0, #3]        // Coins    
    ldrb        upd, [r0, #6]        // Update if not 0, otherwise keep
    ldr        score, [r0, #8]        // Score

    ldr        white, =0xF800
    
//    cmp        upd, #0
//    beq        noUpdate
    
    // Patch lives area
    mov        r0, #16               
    mov        r1, #16
    ldr        r2, =880
    mov        r3, #64
    bl        PatchMove2PX
    
    // Print Value of Coins
    mov        c, #1
    ldr        r11, =880        // Temp x coord
    
printLives:
    mov        r0, c
    mov        r1, lives
    bl        digitToAscii

    mov        r3, r0
    mov        r0, r11
    mov        r1, #64
    mov        r2, white
    bl        DrawChar

    add        r11, #8
    sub        c, #1

    cmp        c, #0
    bge        printLives
    
/*    // Print Value of Lives
    ldr        r0, =880
    mov        r1, #64
    mov        r2, white
    add        r3, lives, #48
    bl        DrawChar


/*	
	// Load Values of GameState
	ldr		r0, =GameState		// Address of GameState Values
	ldrb		lives, [r0, #2]		// Lives
	ldrb		coins, [r0, #3]		// Coins
	ldrb		upd, [r0, #6]		// Update if not 0, otherwise keep
	ldr		score, [r0, #8]		// Score

	ldr		white, =0xF800
	
//	cmp		upd, #0
//	beq		noUpdate
	
	// Patch lives area
	mov		r0, #8
	mov		r1, #16
	ldr		r2, =880
	mov		r3, #64
	bl		PatchScreen

	// Print Value of Lives
	ldr		r0, =880
	mov		r1, #64
	mov		r2, white
	add		r3, lives, #48
	bl		DrawChar
*/
	// Patch Score Area
	mov		r0, #32
	mov		r1, #16
	mov		r2, #80
	mov		r3, #80
	bl		PatchScreen


	// Print Value of Score
	mov		c, #3
	mov		r11, #80		// Temp x coord

printScore:	
	mov		r0, c
	mov		r1, score
	bl		digitToAscii

	mov		r3, r0
	mov		r0, r11
	mov		r1, #80
	mov		r2, white
	bl		DrawChar

	add		r11, #8			// Increment to next print location
	sub		c, #1			// Decrement Counter

	cmp		c, #0
	bge		printScore		// Print each 4 digits

	// Patch Coins Area
	mov		r0, #32
	mov		r1, #16
	mov		r2, #244
	mov		r3, #80
	bl		PatchScreen
	
	// Print Value of Coins
	mov		c, #1
	mov		r11, #244		// Temp x coord
	
printCoins:
	mov		r0, c
	mov		r1, coins
	bl		digitToAscii

	mov		r3, r0
	mov		r0, r11
	mov		r1, #80
	mov		r2, white
	bl		DrawChar

	add		r11, #8
	sub		c, #1

	cmp		c, #0
	bge		printCoins

//noUpdate:
	pop	{r4-r11, lr}
	mov	pc, lr


// Pass in place of digits to convert (ex. 100: 1 in digit = 2)
// Pass in value in r1
// Max num of digits = 4
// Returns Ascii Value of that digit	
digitToAscii:
	push	{r4-r8, lr}

	digit	.req	r4
	value	.req	r5
	d	.req	r6
	tempV	.req	r7
	tempN	.req	r8
	
	mov		digit, r0
	mov		value, r1
	
	cmp		digit, #3
	beq		digit3
	
	cmp		digit, #2
	beq		digit2
	
	cmp		digit, #1
	beq		digit1
	
	cmp		digit, #0
	beq		digit0
	
digit3:
	mov		tempN, #1000
	udiv		d, value, tempN
	
	b		single

digit2:
	mov		tempN, #100
	udiv		value, value, tempN
	mov		tempN, #10
	udiv		tempV, value, tempN
	mul		tempV, tempV, tempN
	sub		d, value, tempV

	b		single
	
digit1:
	mov		tempN, #10
	udiv		value, value, tempN
	udiv		tempV, value, tempN
	mul		tempV, tempV, tempN
	sub		d, value, tempV

	b		single
	
digit0:
	mov		tempN, #10
	udiv		tempV, value, tempN
	mul		tempV, tempV, tempN
	sub		d, value, tempV

single:
	add		r0, d, #48
	
	pop		{r4-r8, lr}
	mov		pc, lr

/* Algorithm for digitToAscii:
	1. Determine digit you want to extract
	ex. Digit 2 from 1234 is the number 2
	2. Divide your value by 100 (1 of 100 is in location of digit): 12
	3. Then divide that value by 10 (12/10 = 1)
	4. Multiply the result by 10 (1*10 = 10)
	5. Subtract from value produced in 2 (12-10 = 2)
	6. 2 is your digit add 48 to it to get the ascii value and return to caller

