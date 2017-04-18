
.section    .init
.globl     start

start:
    b       main
	
	
main:
	bl 		InstallIntTable
	bl 		EnableJTAG
	bl		InitSNES
	



InitFrameBuffer:
	bl		FrameBufferInit			// Initialize Frame Buffer
	
	cmp		r0, #-1			
	beq		InitFrameBuffer


	ldr		r1, =FrameBufferPointer	// Get address of Global Frame Buffer Pointer
	str		r0, [r1]				// Store FBP returned by previous call in r1






InitGame:
	bl		InitSpriteArray
	bl		InitMarioState
	bl		InitObjectStates
	bl		InitGameState
	bl		InitDynamicGrids

	ldr		r0, =GameState
	mov		r1, #0
	strb	r1, [r0, #1]

	mov		r0, #0x0
	bl		DrawColour
	

	

StartMenu:
	bl		InitializeMainMenu

	ldr		r0, =QuitStart			// Byte Representing user selection in Main Menu
	ldr		r0, [r0]
	cmp		r0, #0
	beq		QUIT

	ldr		r0, =GameState
	mov		r1, #1
	strb	r1, [r0, #1]

	ldr		r0, =LevelBackground
	bl		DrawUniformPicture


InitLevel:
	bl		InitInterrupts
	bl		InitSpriteArray
	bl		InitMarioState
	bl		InitObjectStates
	bl		InitGameState
	bl		InitDynamicGrids

	ldr		r0, =LevelBackground
	bl		DrawUniformPicture

	ldr		r0, =Screen1
	bl		DrawLevel
	bl		GetCurrentStaticGrid
	bl		DrawGoombas
	bl      UpdateGameState

	

	
GameLoop:
	bl		SetNextFrameTimer			// Adds an amount to the system timer and stores it globally 
										// Corresponds to a maximum number of frames per second


	ldr		r0, =MarioState
	ldrb	r0, [r0]					// If Mario Animation stage is 4, he died last loop, need to redraw level
	cmp		r0, #4
	bleq	DrawMario
	bleq	DrawNewSection
	bleq	GetCurrentStaticGrid
	bleq	DrawGoombas
	bleq	InitMarioState
	beq		DrawStates

	ldr		r0, =GameState
	ldrb	r1, [r0, #12]
	cmp		r1, #1
	bleq	DrawNewSection			
	bleq	GetCurrentStaticGrid
	bleq	DrawGoombas

	ldr		r0, =GameState				// Reset the 'shift required' byte to 0
	mov		r1, #0
	strb	r1, [r0, #12]


DrawStates:
	bl      UpdateGameState
	bl      DrawMario
	bl		PatchMario
	bl		BackupMario


	ldr		r0, =GameState				// Check for game win condition
	ldrb	r0, [r0, #4]
	cmp     r0, #1
	
	
	
	bleq	GameWin


	ldr		r0, =GameState				// Check for game win condition
	ldrb	r1, [r0, #4]
	cmp     r1, #1
	moveq	r1, #0
	streqb	r1, [r0, #4]
	beq		InitGame


GetInput:
	bl      ReadSNES
	

	ldr		r1, =ButtonsPressed			// Load address of ButtonsPressed
	ldr		r0, [r1]					// Get value
	ldr		r1, =0xFFFFFFFF
	cmp		r0, r1						// Compare buttons pressed with constant representing "No Button Pressed"
	bne		CheckForPause


//// EVERYTHING BELOW ONLY HAPPENS IF NO BUTTONS WERE PRESSED -- SLOWS MARIO DOWN WHILE NO BUTTONS PRESSED
	ldr		r1, =MarioState				

	ldrb	r2, [r1, #2]				// Horizontal Velocity
	subs	r2, #4						// Slow Mario Down
	movle	r2, #0						// If his velocity was less than or equal to 4, set HVel to 0, HDi to 2
	strb	r2, [r1, #2]				
	movle	r2, #2
	strleb  r2, [r1, #1]
	b		UpdateStates

	
CheckForPause:
	tst     r0, #0x08
	bne		UpdateStates
	bl		InitializePauseMenu
	
//////////QuitRestart should be set to -1 if they closed the menu
	ldr		r0, =QuitRestart
	ldr		r0, [r0]
	cmp		r0, #0
	beq		InitGame
	
	cmp		r0, #1
	beq		InitLevel

	bl		DrawNewSection

	ldr		r0, =0x40000
	bl		wait
	
	
UpdateStates:
	bl      UpdateMario					// Updates Marios direction and velocity
	bl      UpdateSprites	
	bl		MoveMario					// Moves Mario according to his updated state
										// (doesnt draw him, just proposes a move by changing his state)


AssessCollisions:						// Assesses his proposed move and adjusts according to collision occurrences
	bl	 	ShiftCheck					// Checks whether Mario moved off screen -- if so, a new screen should be loaded

	bl      CheckMarioCollisions		// Finds Tiles that Mario collided with (by searching the level grid)
	bl		SetConstraintsDiagonal		// Constrains Marios proposed move depending on collisions
	bl      CheckMarioCollisions		// Finds Tiles that Mario collided with (by searching the level grid)
	bl		SetConstraintsInline		// Constrains Marios proposed move depending on collisions
	bl		DropCheck					// Checks that Mario is on solid ground
	bl		MarioFellCheck				// Checks if Mario Fell off the map
	bl		UpdateActiveAnimations		// Uses structures to store and update information on active animations and draws them accordingly

	bl		FindSpriteCollision
	
	mov		r1, #-1
	cmp		r0, r1
	blne	DoSpriteCollision


	bl		FrameControl				// Compares the system timer against the next frame timer
										// Used to limit the number of frames per second

	

//	ldr		r0, =GameState				// Check for game win condition
//	ldrb	r0, [r0, #4]
//	cmp     r0, #1
//	bleq	GameWin


//	ldr		r0, =GameState				// Check for game win condition
//	ldrb	r1, [r0, #4]
//	cmp     r1, #1
//	moveq	r1, #0
//	streqb	r1, [r0, #4]
//	beq		GameLoop

	
	ldr		r0, =GameState				// Check if Lives ran out			
	ldrb	r0, [r0, #2]
	cmp     r0, #0

	bgt     GameLoop

	bl		GameOver
	b       InitGame






QUIT:
	mov		r0, #0x0
	bl		DrawColour

hang:
	b		hang






	
	
	
	
	
//************** GAME OVER ADDITION *******************
	
	
GameOver:
	push	{r4, r5}
	
	
	//disable interupts
	mrs		r0, cpsr
	orr		r0, #0x80
	msr		cpsr_c, r0
	
	mov		r0, #0x0
	bl 		DrawColour
	
	mov 	r4, #1
	lsl 	r4, #9
	
	mov 	r5, #3
	lsl 	r5, #7
	
	ldr 	r0, =Game
	mov 	r1, r4
	sub		r1, #150
	mov		r2, r5
	sub 	r2, #100
	
	bl		DrawPicture3
	
	
	mov		r0, #1
	lsl 	r0, #20
	bl		wait
	
	
	
	ldr 	r0, =Over
	mov 	r1, r4
	sub		r1, #150
	mov		r2, r5
	
	bl		DrawPicture3

	mov		r0, #1
	lsl 	r0, #20
	bl		wait


	ldr 	r0, =GOInstruction
	mov 	r1, r4
	sub		r1, #150
	mov		r2, r5
	add		r2, #100
	
	bl 		DrawPicture3

WaitForButtonsGO:
	bl		ReadSNES
	ldr		r0, =ButtonsPressed
	ldr		r1, [r0]
	ldr		r2, =0xFFFFFFFF
	teq 	r1, r2
	beq		WaitForButtonsGO
	

ReturnToTitleGO:
	
	pop		{r4, r5}
	b		InitGame
	
	
	
	
.globl	MarioFellCheck	
.align

MarioFellCheck:
	push	{lr}
	
	ldr		r0, =MarioState
	ldr		r1, [r0, #12]
	ldr		r2, =736
	cmp		r1, r2
	blt		1f

	bl		BackupMario
	bl		PatchMario

	ldr		r1, =672
	str		r1, [r0, #12]
	
	
	ldr		r0, =GameState			// Decrement Mario's Lives
	ldrb	r1, [r0, #2]
	sub		r1, #1
	strb	r1, [r0, #2]

	mov		r1, #1
	strb	r1, [r0, #12]			// Indicates that the level must be re-initialized next round

	ldr		r0, =MarioState			// Set Mario Animation Stage to 4 (triggers death animation)
	mov		r1, #4
	strb	r1, [r0]




	
1:	pop		{lr}
	mov		pc, lr










.globl	FrameControl
.align

FrameControl:

	ldr		r0, =FrameTimerCompare
	ldr		r0, [r0]

top:

	ldr		r1, =0x3F003004			// Address for low bits of system clock
	ldr		r1, [r1]				// Load value in low 32 bits of system clock

	
	cmp		r1, r0
	blt		top


	mov		pc, lr








.globl	SetNextFrameTimer
.align

SetNextFrameTimer:

	mov		r0, #3					//
	lsl		r0, #14					// ~  1/15 second

	ldr		r1, =0x3F003004			// Address for low bits of system clock
	ldr		r1, [r1]				// Load value in low 32 bits of system clock
	add		r1, r0					// Add 1/15 second (65,500 microseconds)
	
	ldr		r0, =FrameTimerCompare
	str		r1, [r0]

	mov		pc, lr








.globl	FrameTimerCompare
FrameTimerCompare:
	.word	0

	
.globl	ButtonsPressed
.align
ButtonsPressed:
	.word	0
	.word	0						// May be used to store a copy of some button sampling
	
.globl	QuitStart	
QuitStart:
	.word	0

.globl	QuitRestart	
QuitRestart:
	.word	0

