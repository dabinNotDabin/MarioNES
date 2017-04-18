// Function: StartupMenu
// Displays start menu
// If up button pressed, selector will be on start game
// If down pressed, selector will be on quit
// When selector on Start Game pressed, end function and continue main
// Else Quit selected, end program	
// Set QuitStart to 0 to Quit and 1 to Start Game
// Pass in state (0 initially)
// Return new state (0 for state 1, 1 for state 2, -1 for A pressed)	

//	PatchScreen(width, height, x, y)

/*	
.globl	InitMainMenu3

InitMainMenu3:
	push		{r4-r7, lr}

	buttons		.req	r4			// r4 = buttons
	state		.req	r6			// r6 = state


	bl		MMAnimation


	mov		state, #0


Init:	
	cmp		state, #1			// Check which state it was previously in state 1
	beq		selectDown			// If previous state was 1, branch to selectDown
	
selectUp:						// Selector on start game


	ldr		r0, =smallMario0R	// Draw Selector in top position
	ldr		r1, =356
	ldr		r2, =504
	bl		DrawPicture3

	mov		r0, #32
	mov		r1, #32
	ldr		r2, =356
	ldr		r3, =590
	bl		PatchScreen

	b		checkButtons			// Else check buttons
	
selectDown:						// Selector on quit game
	

	mov		r0, #32
	mov		r1, #32
	ldr		r2, =356
	ldr		r3, =504
	bl		PatchScreen

	ldr		r0, =smallMario0L			// Draw Selector in bottom position
	ldr		r1, =356
	ldr		r2, =590
	bl		DrawPicture3


checkButtons:	
	bl		ReadSNES
	ldr		r7, =ButtonsPressed		// Load address of buttons pressed into r7
	ldr		buttons, [r7]			// Load values of buttons into r4 (buttons)
	ldr		r9, =0xFFFFFFFF
	teq		buttons, r9
	beq		checkButtons


	mov		r5, #1				// Set r5 to 0b1
	lsl		r5, #8				// When 8th bit 0, A pressed (shift 8 times)
	tst		buttons, r5			// AND with buttons to see if 8th bit is 1 (not pressed)
	beq		checkState			// CHECK STATE and RETURN -1

	
upDown:
	cmp		state, #0
	beq		CheckDown
	
	mov		r5, #1				// Set r5 to 0b1
	lsl		r5, #4				// When 4th bit 0, up pressed
	tst		buttons, r5			// AND with buttons to see if 5th bit is 1			

	moveq	state, #0			// Since not equal, button is pressed, set to state 0 for next call
	moveq	r0, state			// Return state = 0
	beq		Init				// RETURN 0


CheckDown:	
	mov		r5, #1				// Set r5 to 0b1
	lsl		r5, #5				// When 5th bit 0, down pressed
	tst		buttons, r5			// AND with buttons to see if 6th bit is 1
	
	moveq	state, #1			// Since not equal, button is pressed, set to state 1 for next call

	mov		r0, state			// Store current state in return
	b		Init				// RETURN CURRENT STATE

checkState:	
	mov		r0, #-1				// Return -1
	
	ldr		r7, =QuitStart		// Load address of QuitStart into r7
	cmp		state, #0			// If State = 0, set QuitStart to 1
	moveq	r4, #1			// Store 1 into r4
	movne	r4, #0			// Since State = 1 (Selector on Quit), store 0 into r4
	str		r4, [r7]			// Store byte in r4 to QuitStart
	


returnStartup:
	.unreq		buttons Ret
	.unreq		state

	pop		{r4-r7, lr}
	mov		pc, lr				//urn to caller

*/




















.globl	InitMainMenu2

InitMainMenu2:
	push		{r4-r9, lr}

	buttons		.req	r4			// r4 = buttons
	state		.req	r6			// r6 = state


	bl		MMAnimation


	mov		state, #0


checkButtons:	
	bl		ReadSNES
	ldr		r7, =ButtonsPressed		// Load address of buttons pressed into r7
	ldr		buttons, [r7]			// Load values of buttons into r4 (buttons)
	ldr		r9, =0xFFFFFFFF
	teq		buttons, r9
	beq		checkButtons


	mov		r5, #1				// Set r5 to 0b1
	lsl		r5, #8				// When 8th bit 0, A pressed (shift 8 times)
	tst		buttons, r5			// AND with buttons to see if 8th bit is 1 (not pressed)
	beq		checkState			// CHECK STATE and RETURN -1

	
upDown:
	cmp		state, #0
	beq		CheckDown
	
	mov		r5, #1				// Set r5 to 0b1
	lsl		r5, #4				// When 4th bit 0, up pressed
	tst		buttons, r5			// AND with buttons to see if 5th bit is 1			
	bleq	UpMario

	tst		buttons, r5
	moveq	state, #0			// Since not equal, button is pressed, set to state 0 for next call
	beq		checkButtons				// RETURN 0


CheckDown:	
	mov		r5, #1				// Set r5 to 0b1
	lsl		r5, #5				// When 5th bit 0, down pressed
	tst		buttons, r5			// AND with buttons to see if 6th bit is 1
	bleq	DownMario

	tst		buttons, r5			// AND with buttons to see if 6th bit is 1
	moveq	state, #1			// Since not equal, button is pressed, set to state 1 for next call

	b		checkButtons		// RETURN CURRENT STATE


checkState:	
	mov		r0, #-1				// Return -1
	
	ldr		r7, =QuitStart		// Load address of QuitStart into r7
	cmp		state, #0			// If State = 0, set QuitStart to 1
	moveq	r4, #1			// Store 1 into r4
	movne	r4, #0			// Since State = 1 (Selector on Quit), store 0 into r4
	str		r4, [r7]			// Store byte in r4 to QuitStart
	
	ldreq	r0, =356
	ldreq	r1, =504
	ldrne	r0, =356
	ldrne	r1, =590
	
	bl		MenuItemSelected
	

returnStartup:
	.unreq		buttons
	.unreq		state

	pop		{r4-r9, lr}
	mov		pc, lr				// Return to caller
























	
	// Mario running away from bullet
	// Goes into pipe
	// Falls from top of screen
	// Lands on start, looks left and right twice
	// Select down: Falls until Quit, looks left and right

MMAnimation:
	push		{r4-r10, lr}

	xcoord		.req	r4			// X coordinate of Mario
	ycoord		.req	r5			// Y Coordinate of Mario
	AStage		.req	r6			// Animation Stage
	BStage		.req	r7			// Bullet Ascii Image
	xcoordB		.req	r8			// X coordinate of Bullet
	ycoordB		.req	r9			// Y coordinate of Bullet
	NoDrawFlag	.req	r10			// Draw while flag = 0
	
	mov		xcoord, #192			// Starting location of Mario
	ldr		ycoord, =704
	sub		xcoordB, xcoord, #64
	mov		ycoordB, ycoord
	mov		AStage, #0

WalkLoop:
	cmp		AStage, #0
	bne		W1

	ldr		r0, =smallMario1R		// Stage 0
	ldr		BStage, =BulletR0
	add		AStage, #1
	b		DrawWalk

W1:	cmp		AStage, #1
	bne		W2

	ldr		r0, =smallMario2R		// Stage 1
	ldr		BStage, =BulletR1
	add		AStage, #1
	b		DrawWalk

W2:	ldr		r0, =smallMario3R		// Stage 2
	ldr		BStage, =BulletR2
	mov		AStage, #0
//	b		DrawWalk

DrawWalk:	
	mov		r1, xcoord			// Draw Mario
	mov		r2, ycoord
	bl		DrawPicture3

							// PatchScreen(width, height, x, y)
	mov		r0, #4				// Patch Mario
	mov		r1, #32
	mov		r2, xcoord
	mov		r3, ycoord
	bl		PatchMove2PX

	mov		r0, BStage			// Draw Bullet
	mov		r1, xcoordB
	mov		r2, ycoord
	bl		DrawPicture3

	mov		r0, #4				// Patch Bullet
	mov		r1, #32
	mov		r2, xcoordB
	mov		r3, ycoord
	bl		PatchMove2PX

	ldr		r0, =0x4000			// Wait (animation too fast)
	bl		wait
	
	add		xcoord, #4 			// Increment x value
	add		xcoordB, #4
	cmp		xcoord, #844			// If location by pipe reached, break loop
	blt		WalkLoop

	mov		NoDrawFlag, #0			// Set 0 = Continue Draw, else don't draw
	
	// Go into pipe
IntoPipe:
	// Draw Mario, patch front and behind
	// Draw Bullet Until pipe then explode
	cmp		NoDrawFlag, #0
	bne		continueBullet
	
	ldr		r0, =smallMario0R
	mov		r1, xcoord
	mov		r2, ycoord
	bl		DrawPicture3

	// Patch Pipe
	mov		r0, #32
	mov		r1, #32
	ldr		r2, =896			// Location of pipe
	mov		r3, ycoord
	bl		PatchScreen

	// Patch Back
	mov		r0, #4
	mov		r1, #32
	mov		r2, xcoord
	mov		r3, ycoord
	bl		PatchMove2PX

continueBullet:	
	// Continue Bullet
	cmp		AStage, #0
	ldreq		BStage,  =BulletR0
	addeq		AStage, #1
	beq		drawBullet

	cmp		AStage, #1
	ldreq		BStage, =BulletR1
	addeq		AStage, #1
	beq		drawBullet

	cmp		AStage, #2
	ldreq		BStage, =BulletR2
	moveq		AStage, #0
	beq		drawBullet
	
drawBullet:	
	
	mov		r0, BStage
	mov		r1, xcoordB
	mov		r2, ycoordB
	bl		DrawPicture3

	ldr		r0, =0x4000			// Wait (animation too fast)
	bl		wait

	mov		r0, #4				// Patch Bullet
	mov		r1, #32
	mov		r2, xcoordB
	mov		r3, ycoord
	bl		PatchMove2PX

	add		xcoord, #4
	cmp		xcoord, #892
	moveq	NoDrawFlag, #1			// End Mario draw
	add		xcoordB, #4
	cmp		xcoordB, #860			// If location by pipe reached, set stage to something else
	blt		IntoPipe

explodeBullet:
	sub		xcoordB, #8

	// Explode 1 (DeadBulletR0)
	ldr		r0, =DeadBulletR0
	mov		r1, xcoordB
	mov		r2, ycoordB
	bl		DrawPicture3

	ldr		r0, =0x8000			// Wait (animation too fast)
	bl		wait
	
	// Explode 2 (DeadBullet1)
	ldr		r0, =DeadBullet1
	mov		r1, xcoordB
	mov		r2, ycoordB
	bl		DrawPicture3

	ldr		r0, =0x8000			// Wait (animation too fast)
	bl		wait
	
	// Explode 3 (DeadBullet2)
	ldr		r0, =DeadBullet2
	mov		r1, xcoordB
	mov		r2, ycoordB
	bl		DrawPicture3


	mov		r0, #32				// Patch Bullet
	mov		r1, #32
	mov		r2, xcoordB
	mov		r3, ycoord
	bl		PatchMove2PX


  
	mov		r0, #32
	mov		r1, #32
	ldr		r2, =864			
	ldr		r3, =704
	bl		PatchScreen



	mov		xcoord, #356
	mov		ycoord, #44
	mov		AStage, #0
	
// New Section - Draw Mario from above and make him fall
MarioFall:	
	cmp			AStage, #0
	ldreq		r0, =smallMarioDeadT
	addeq		AStage, #1
	ldrne		r0, =smallMarioDeadNoT
	subne		AStage, #1

	mov		r1, xcoord
	mov		r2, ycoord
	bl		DrawPicture3

	// Patch (width, height, x, y) Mario Fall
	mov		r0, #32
	mov		r1, #4
	mov		r2, xcoord
	mov		r3, ycoord
	bl		PatchMove2PX

	ldr		r0, =0x4000			// Wait (animation too fast)
	bl		wait
	
	add		ycoord, #4
	cmp		ycoord, #508
	blt		MarioFall

	sub		ycoord, #4
	
	mov		r0, #32
	mov		r1, #4
	mov		r2, xcoord
	add		r3, ycoord, #32
	bl		PatchMove2PX
	
	ldr		r0, =smallMario0L
	mov		r1, xcoord
	mov		r2, ycoord
	bl		DrawPicture3

	ldr		r0, =0x88888	 		// Wait (animation too fast)
	bl		wait
	
	ldr		r0, =smallMario0R
	mov		r1, xcoord
	mov		r2, ycoord
	bl		DrawPicture3
		
   	
 
   	

	pop		{r4-r10, lr}
	mov		pc, lr



	// Currently, patch isn't working (might have to load to main screen first)
	// He isn't dropping
	
	
	
	
	
	
	
	
	
	
	
// Simply make mario fall, then look left and right
DownMario:
    push    {r4-r7, lr}

    xcoord    .req    r4
    ycoord    .req    r5
    AStage    .req    r6

    ldr        xcoord, =356
    ldr        ycoord, =504
    mov        AStage, #0    
    
fall:
    add        ycoord, #4
    
    cmp        AStage, #0
    ldreq        r0, =smallMarioDeadT
    addeq        AStage, #1
    ldrne        r0, =smallMarioDeadNoT
    subne        AStage, #1

    mov        r1, xcoord
    mov        r2, ycoord
    bl        DrawPicture3

    mov        r0, #32
    mov        r1, #4
    mov        r2, xcoord
    sub        r3, ycoord, #4
    bl        PatchMove2PX
    
    ldr		r0, =0x4000			// Wait (animation too fast)
	bl		wait

    
    ldr		   r7, =590	
    cmp        ycoord, r7       // Bottom position
    blt        fall

    mov        r0, #32
    mov        r1, #32
    mov        r2, xcoord
    mov        r3, ycoord
    bl        PatchScreen

    ldr        r0, =smallMario0L
    mov        r1, xcoord
    mov        r2, ycoord
    bl        DrawPicture3

    ldr        r0, =0x88888             // Wait (animation too fast)
    bl        wait

    mov        r0, #32
    mov        r1, #32
    mov        r2, xcoord
    mov        r3, ycoord
    bl        PatchScreen
    
    ldr        r0, =smallMario0R
    mov        r1, xcoord
    mov        r2, ycoord
    bl        DrawPicture3
    
    .unreq		xcoord
    .unreq		ycoord
    .unreq		AStage
    
    
    pop    {r4-r7, lr}    
    mov    pc, lr









UpMario:
    push    {r4-r5, lr}

    xcoord    .req    r4
    ycoord    .req    r5

    ldr        xcoord, =356
    ldr        ycoord, =594
    
jump:
    sub        ycoord, #4    

    ldr        r0, =smallMarioJumpingR
    mov        r1, xcoord
    mov        r2, ycoord
    bl        DrawPicture3

    mov        r0, #32
    mov        r1, #4
    mov        r2, xcoord
    add        r3, ycoord, #32
    bl        PatchMove2PX

    ldr		r0, =0x4000			// Wait (animation too fast)
	bl		wait
  
    
    cmp     ycoord, #472        // 32 above "Start" position
	bgt		jump


peakJump:
    add        ycoord, #2
    
    ldr        r0, =smallMarioJumpingR
    mov        r1, xcoord
    mov        r2, ycoord
    bl        DrawPicture3

    mov        r0, #32
    mov        r1, #2
    mov        r2, xcoord
    sub        r3, ycoord, #2
    bl        PatchMove2PX    

    ldr		r0, =0x4000			// Wait (animation too fast)
	bl		wait


    cmp        ycoord, #504
    blt        peakJump
    
    mov        r0, #32
    mov        r1, #32
    mov        r2, xcoord
    mov        r3, ycoord
    bl        PatchScreen

    ldr        r0, =smallMario0L
    mov        r1, xcoord
    mov        r2, ycoord
    bl        DrawPicture3

    ldr        r0, =0x88888             // Wait (animation too fast)
    bl        wait

    mov        r0, #32
    mov        r1, #32
    mov        r2, xcoord
    mov        r3, ycoord
    bl        PatchScreen
    
    ldr        r0, =smallMario0R
    mov        r1, xcoord
    mov        r2, ycoord
    bl        DrawPicture3

    .unreq        xcoord
    .unreq        ycoord
    
    pop    {r4-r5, lr}    
    mov    pc, lr
	
	
	
	
	
	
	
	
	// Pass in x and y coordinates of Mario
MenuItemSelected:
    push    {r4-r5, lr}

    mov    r4, r0
    mov    r5, r1

    mov    r0, #32
    mov    r1, #32
    mov    r2, r4
    mov    r3, r5
    bl    PatchScreen

    ldr    r0, =0x88888             // Wait (animation too fast)
    bl    wait

    ldr    r0, =smallMario0R
    mov    r1, r4
    mov    r2, r5
    bl    DrawPicture3
    
    
    ldr    r0, =0x88888             // Wait (animation too fast)
    bl    wait
    
    pop    {r4-r5, lr}
    mov    pc, lr


