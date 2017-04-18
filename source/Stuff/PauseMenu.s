// Function: PauseMenu
// Displays pause menu
// Pressing start will close Game Menu
// Up will move selector up
// Down will move selector down
// Other buttons will do nothing
// State 0, selector on restart game
// State 1, selector on quit game
// If they push start to resume - set QuitRestart = -1
// QuitRestart = 0 if Quit	
// QuitRestart = 1 if Restart Game
	
.globl	PauseMenu

PauseMenu:
	push		{r4-r8, lr}

	buttons		.req	r4			// r4 = buttons
	state		.req	r6			// r6 = state
	QR		.req	r8			// r8 = Return value in QuitRestart
	
	mov		state, r0			// Pass in state from main
	///////////////////////////// Use this in main

	ldr		r0, =PauseMenuImg		// Draw Pause Screen
	ldr		r1, =256
	ldr		r2, =256
	bl		DrawPicture

	//////////////////////////////////////////////
	
	cmp		state, #1			// Check previous state
	beq		selectDown			// Redraw selector position based on state
	
selectUp:						// Selector on Restart Game
	ldr		r0, =PSelector			// Draw Selector in top position
	ldr		r1, =284
	ldr		r2, =308
	bl		DrawPicture

	ldr		r0, =ErasePSelector		// Draw Eraser in bottom position
	ldr		r1, =284
	ldr		r2, =400
	bl		DrawPicture

	b		checkButtons			// Check buttons after read

selectDown:						// Selector on quit game
	ldr		r0, =ErasePSelector		// Draw Eraser in top position
	ldr		r1, =284
	ldr		r2, =308
	bl		DrawPicture

	ldr		r0, =PSelector			// Draw Eraser in bottom position
	ldr		r1, =284
	ldr		r2, =400
	bl		DrawPicture

checkButtons:
	bl		ReadSNES			// Read buttons from SNES
	ldr		r7, =ButtonsPressed		// Load address of buttons pressed into r7
	ldr 	buttons, [r7]			// Load values of buttons into r4 (buttons)

	// If start pressed, set QuitRestart to -1
	mov		r5, #1				// Set r5 to 0b1
	lsl		r5, #3				// When 3rd bit 0, Start Pressed
	tst		buttons, r5			// AND with buttons
	moveq	QR, #-1				// Set QuitRestart to -1
	beq		setQR				// Branch to set QuitRestart

	// If A pressed, determine state, set QuitRestart
	mov		r5, #1				// Set r5 to 0b1
	lsl		r5, #8				// When 8th bit 0, A pressed
	tst		buttons, r5			// AND with buttons to see if 8th but is 1 (not pressed)
	bne		upDown				// If equal, A not preesed, check Up/Down buttons

	cmp		state, #1			// If in state 1, set QR to 0, else set to 1 (To Quit Game)
	moveq	QR, #0
	movne	QR, #1				// Else in state 0, set QR to 1 (To Restart Game)
	b		setQR				// Branch to set QuitRestart
	
upDown:
	// If up pressed, return state 0
	mov		r5, #1				// Set r5 to 0b1
	lsl		r5, #4				// When 4th bit 0, up pressed
	tst		buttons, r5			// AND with buttons to see if 5th bit is 1
	moveq	state, #0			// State = 0

	// If down pressed, return state 1
	lsl		r5, #1				// Move 1 more over (check 
	tst		buttons, r5
	moveq	state, #1			// State = 1
	
	b		returnPause			// Branch to return state, should return previous state if none above selected

setQR:	
	ldr		r7, =QuitRestart		// Load address of QuitRestart into r7
	str		QR, [r7]			// Store appropriate QR value into QuitRestart
	mov		state, #-1			// Return value will be -1 indicating A or Start pressed

returnPause:
	mov		r0, state			// Return value of state 0 (Selector Up), 1 (Selector Down), -1 (Quit, Restart, or Resume)

	.unreq		buttons
	.unreq		state
	.unreq		QR
	
	pop		{r4-r8, lr}
	mov		pc, lr
