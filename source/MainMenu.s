// Function: StartupMenu
// Displays start menu
// If up button pressed, selector will be on start game
// If down pressed, selector will be on quit
// When selector on Start Game pressed, end function and continue main
// Else Quit selected, end program	
// Set QuitStart to 0 to Quit and 1 to Start Game
// Pass in state (0 initially)
// Return new state (0 for state 1, 1 for state 2, -1 for A pressed)	
	
.globl	InitMainMenu

InitMainMenu:
	push		{r4-r7, lr}

	buttons		.req	r4			// r4 = buttons
	state		.req	r6			// r6 = state

	mov		state, r0			// Pass in state from main (0 initially)
	

	cmp		state, #1			// Check which state it was previously in state 1
	beq		selectDown			// If previous state was 1, branch to selectDown
	
selectUp:						// Selector on start game
	ldr		r0, =Selector			// Draw Selector in top position
	ldr		r1, =450
	ldr		r2, =480
	bl		DrawPicture2

	ldr		r0, =EraseSelector		// Erase Selector in bottom position
	ldr		r1, =450
	ldr		r2, =594
	bl		DrawPicture2

	b		checkButtons			// Else check buttons
	
selectDown:						// Selector on quit game
	ldr		r0, =EraseSelector		// Erase Selector in top position
	ldr		r1, =450
	ldr		r2, =480
	bl		DrawPicture2
	
	ldr		r0, =Selector			// Draw Selector in bottom position
	ldr		r1, =450
	ldr		r2, =594
	bl		DrawPicture2

checkButtons:	
	bl		ReadSNES

	ldr		r7, =ButtonsPressed		// Load address of buttons pressed into r7
	ldr 		buttons, [r7]			// Load values of buttons into r4 (buttons)

	mov		r5, #1				// Set r5 to 0b1
	lsl		r5, #8				// When 8th bit 0, A pressed (shift 8 times)
	tst		buttons, r5			// AND with buttons to see if 8th bit is 1 (not pressed)
//	moveq		r0, #-1				// Return -1 indicating A was pressed
	beq		checkState			// CHECK STATE and RETURN -1
	
upDown:
	mov		r5, #1				// Set r5 to 0b1
	lsl		r5, #4				// When 4th bit 0, up pressed
	tst		buttons, r5			// AND with buttons to see if 5th bit is 1			
	moveq		state, #0			// Since not equal, button is pressed, set to state 0 for next call
	moveq		r0, state			// Return state = 0
	beq		returnStartup			// RETURN 0
	
	mov		r5, #1				// Set r5 to 0b1
	lsl		r5, #5				// When 5th bit 0, down pressed
	tst		buttons, r5			// AND with buttons to see if 6th bit is 1
	moveq		state, #1			// Since not equal, button is pressed, set to state 1 for next call
//	moveq		r0, state			// Return state = 1

	mov		r0, state			// Store current state in return
	b		returnStartup			// RETURN CURRENT STATE

checkState:	
	mov		r0, #-1				// Return -1
	
	ldr		r7, =QuitStart			// Load address of QuitStart into r7
	cmp		state, #0			// If State = 0, set QuitStart to 1
	moveq		r4, #1				// Store 1 into r4
	movne		r4, #0				// Since State = 1 (Selector on Quit), store 0 into r4
	str		r4, [r7]			// Store byte in r4 to QuitStart
	b		returnStartup			// Return state (-1)


returnStartup:
	.unreq		buttons
	.unreq		state

	pop		{r4-r7, lr}
	mov		pc, lr				// Return to caller
