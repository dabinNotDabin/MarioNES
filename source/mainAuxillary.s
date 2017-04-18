.section    .text

.globl      startA
.globl	    DrawColour
.globl		InstallIntTable

startA:
    b       mainA
	
	
mainA:
//	bl 		InstallIntTable
//	bl 		EnableJTAG

//	mov 	r0, #9              	//SNES Latch
//	mov 	r1, #1              	//Setting pin to output.
//	bl 		InitGPIO            	//Subroutine to initialize pin for latch
				
//	mov 	r0, #10             	//SNES Data
//	mov 	r1, #0              	//Setting pin to input
//	bl 		InitGPIO            	//Subroutine to initialize pin for data
	
//	mov 	r0, #11             	//SNES Clock
//	mov 	r1, #1              	//Setting pin to output
//	bl 		InitGPIO            	//Subroutine to initialize pin for data
	
	
//	mov     r0, #1          		// Writing 1 to the Latch
//  bl  	WriteLatch              // Call writeLatch subroutine
  
          
            
            
  	
//  Enable Gpio IRQ
//	ldr		r0, =0x3F20004C			// Get address of GPREN0
//	ldr		r1, [r0]				// Load value at GPREN0
//	orr		r1, #0x400				// Turn on bit 10
//	str		r1, [r0]				// Store value to enable GPIO line 10 rising edge to trigger corresponding bit in GPSED0
	

//	ldr		r0, =0x3F200058			// Get address of GPFEN0
//	ldr		r1, [r0]				// Load value at GPFEN0
//	orr		r1, #0x400				// Turn on bit 10
//	str		r1, [r0]				// Store value to enable GPIO line 10 falling edge to trigger corresponding bit in GPSED0


//	ldr		r0, =0x3F200064			// Get address of GPHEN0
//	ldr		r1, [r0]				// Load value at GPHEN0
//	orr		r1, #0x400				// Turn on bit 10
//	str		r1, [r0]				// Store value to enable GPIO line 10 high to trigger corresponding bit in GPSED0
	
//	ldr		r0, =0x3F200070			// Get address of GPLEN0
//	ldr		r1, [r0]				// Load value at GPLEN0
//	orr		r1, #0x400				// Turn on bit 10
//	str		r1, [r0]				// Store value to enable GPIO line 10 low to trigger corresponding bit in GPSED0

	

// Enable IRQ in controller
//	ldr		r0, =0x3F00B214			// Enable IRQs 2
//	mov		r1, #0x001E0000			// bits 17 to 20 set (IRQs 49 to 52)
//	str		r1, [r0]				// Storing this value allows these bits to trigger IRQ pending status in the IRQ Pending 2 Register

	
	



InitFB:
	bl		FrameBufferInit			// Initialize Frame Buffer
	
	cmp		r0, #-1			
	beq		InitFB


	ldr		r1, =FrameBufferPointer	// Get address of Global Frame Buffer Pointer
	str		r0, [r1]				// Store FBP returned by previous call in r1




// Enable IRQ Globally
//	mrs		r0, cpsr
//	bic		r0, #0x80
//	msr		cpsr_c, r0







//ScrollLoop:
//	ldr		r0,	=ScrollOn
//	ldr		r1, [r0]
//	teq		r1, #1
//	bleq	ScrollRight
//	b		ScrollLoop


hang:
	b	hang









	
	
	
	
	
	
	
		
	
	
// Takes a 16 bit colour code as a parameter in r0 and draws the entire screen that colour.
.globl DrawColour
.align	
DrawColour:
	push	{r4 - r11, lr}



	mov		r4,  r0
	mov		r5,  r0
	mov		r6,  r0
	mov		r7,  r0
	mov		r8,  r0
	mov		r9,  r0
	mov		r10, r0
	mov		r11, r0


	ldr		r0, =FrameBufferPointer
	ldr		r0, [r0]


	ldr		r1, =0x180000	// Size of entire FrameBuffer
	add		r2, r0, r1		// End of FrameBuffer in r2



FillLoop:
	cmp			r0, r2
	stmltia		r0!, {r4 - r11}
	blt			FillLoop

	
	pop		{r4 - r11, lr}
	mov		pc, lr









.globl wait
.align	
wait:
    ldr     r3, =0x3F003000     	// Get address of CLO
    ldr 	r1, [r3, #4]        	// read vaue in CLO
    add 	r1, r0          		// Add micro-seconds accepted as argument

check:
    ldr     r2, [r3, #4]        	// Get
    cmp     r1, r2          		// Stop when CLO = r1
    bhi     check           		// Have we passed the number of micro-seconds           
    mov 	pc, lr          		// Branch back to calling code








	
	
InstallIntTable:
	ldr		r0, =IntTable
	mov		r1, #0x00000000

	// load the first 8 words and store at the 0 address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// load the second 8 words and store at the next address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// switch to IRQ mode and set stack pointer
	mov		r0, #0xD2
	msr		cpsr_c, r0
	mov		sp, #0x8000

	// switch back to Supervisor mode, set the stack pointer
	mov		r0, #0xD3
	msr		cpsr_c, r0
	mov		sp, #0x8000000
	
	mov		pc,	lr
	
	
	
	
	
	
	
	
	
	
.globl	myIRQA
.align

myIRQA:
	push	{r0-r12, lr}

	// test if there is an interrupt pending in IRQ Basic Pending
	ldr		r0, =0x3F00B200 // IRQ Basic Pending
	ldr		r1, [r0]
	tst		r1, #0x100		// bit 8 corresponds to IRQ pending 1
	beq		irqAEnd

	// test that Clock compare 1 caused the interrupt
	ldr		r0, =0x3F00B204		// IRQ Pending 1 register
	ldr		r1, [r0]
	tst		r1, #0b0010
	beq		irqAEnd



	
GetRandom:
	bl		RandomBlock

	ldr		r1, =ObjectStates
	ldrb	r2, [r1, r0]
	
	cmp		r2, #0
	bgt 	GetRandom
	
	bl		InitializePow

	
	// clear bit 1 in the timer control/status register to acknowledge the interrupt was received
	ldr		r0, =0x3F003000			// Control/Status register for system timer
	mov		r1, #0b0010				// Clear bit 1 to acknowledge the IRQ request has been handled
	str		r1, [r0]				// 
	
	
irqAEnd:
	pop		{r0-r12, lr}
	subs	pc, lr, #4
		






	
	
	
.section	.data
	
.align 4	
.globl FrameBufferPointer
FrameBufferPointer:
			.int	0
			
			
		
		
			
.align
.globl MarioState
MarioState:
	.byte	0		// Stage of Animation
	.byte	2		// Horizontal Direction (0 == LEFT, 1 == RIGHT)
	.byte	0		// Horizontal Velocity  (0 - 12) in multiples of 2
	.byte	2		// Vertical Direction	(0 == DOWN, 1 == UP, 2 == NONE) 
	.byte	0		// Vertical Velocity	(0 - 12) in multiples of 2
	.byte	0		// Collission Status	(0 == NoCOLLISION, 1 == COLLISION)
	.byte	0		// Vertical Offset From Base
	.byte	0		// Move Bit (1 if Mario Was Moved in Current Game Loop)
	.word	64		// Mario top left x coord			
	.word	672		// Mario top left y coord
	.word	64		// Mario old top left x coord			
	.word	672		// Mario old top left y coord
	
	
			
.align
.globl MarioBackupState
MarioBackupState:
	.byte	0		// Stage of Animation
	.byte	2		// Horizontal Direction (0 == LEFT, 1 == RIGHT)
	.byte	0		// Horizontal Velocity  (0, 4, 8 or 12)
	.byte	2		// Vertical Direction	(0 == DOWN, 1 == UP, 2 == NONE) 
	.byte	0		// Vertical Velocity	(0, 4, 8 or 12)
	.byte	0		// Collission Status	(0 == NoCOLLISION, 1 == COLLISION)
	.byte	0		// Vertical Offset From Base
	.byte	0		// Collision direction 	(0 == Horizontal, 1 == vertical)
	.word	128		// Mario top left x coord			
	.word	672		// Mario top left y coord
	.word	32		// Mario old top left x coord			
	.word	672		// Mario old top left y coord
		

	
			
.align
.globl GameState
GameState:
	.byte	0		// Map Instance will be 0, 1, 2,... for 1st, 2nd, 3rd,... section
	.byte	0		// 0000 0000 is MainMenu, 0000 0001 is InGame, 0000 0010 is InGameMenu
	.byte	15		// Lives
	.byte	0		// Coins
	.byte	0		// Win  (1 == Win)
	.byte	0		// Lose (1 == Lose)
	.byte	0		// Game State byte -- 1 means game info needs to be redrawn (score, lives, etc).
	.byte	5		// Max number of Level Instances
	
	.word	0		// Score
	.byte	0		// Game Shift byte -- 1 if a screen shift occurred (offset from base #12)

	
//.align
//.globl WBlockState
//WBlockState:
//	.byte	1		// Block Animation Stage
//	.byte	0		// Hit/Not (1 - Hit, 0 - Not)
//	.byte	0		// padding
//	.byte	0		// padding
//	.word	0		// Block X-Coord
//	.word	0		// Block Y-Coord




.align
.globl	CollisionOccurrences
CollisionOccurrences:
	.byte	0		// Top
	.byte	0		// Bot
	.byte	0		// Left
	.byte	0		// Right
	.byte	0		// TopL
	.byte	0		// TopR
	.byte	0		// BotL
	.byte	0		// BotR
	
	

.align
.globl	SpriteCollisions
SpriteCollisions:
	.byte	0		// BotL
	.byte	0		// BotR	
	.byte	0		// Bot
	.byte	0		// Reserved
	
.align
.globl	ActiveBlockAnimation	
ActiveBlockAnimation:
	.word	0		// Tile X
	.word	0		// Tile Y
	.byte	0		// Stage of Animation
	.byte	0		// Tile ID -- 0==NONE, 1==Brick, 2==QBlock
	.byte	0
	.byte	0


.align	
.globl	ActiveCoinAnimation
ActiveCoinAnimation:
	.word	0		// Tile X
	.word	0		// Tile Y
	.byte	0		// Stage of Animation
	.byte	0		// Status -- 1 means animation is active/underway
	.byte	0
	.byte	0



.align
.globl ObjectStates
ObjectStates:
	.rept 768
	.byte 0
	.endr


.globl SpriteObj
SpriteObj:
	.word 0

.globl SpritePointer
SpritePointer:
	.word 0

.globl SpriteStates
SpriteStates:
	.rept 160
	.word 0
	.endr

	
	
.align
.globl	Screen1
Screen1:
	.rept 768
	.byte 0
	.endr
	

.align
.globl	Screen2
Screen2:
	.rept 768
	.byte 0
	.endr
	
	
.align
.globl	Screen3
Screen3:
	.rept 768
	.byte 0
	.endr
	
	
	
.align
.globl	Screen4
Screen4:
	.rept 768
	.byte 0
	.endr
		
	
.align
.globl	Screen5
Screen5:
	.rept 768
	.byte 0
	.endr			

	
	
	
.align
	
IntTable:
	ldr		pc, reset_handler
	ldr		pc, undefined_handler
	ldr		pc, swi_handler
	ldr		pc, prefetch_handler
	ldr		pc, data_handler
	ldr		pc, unused_handler
	ldr		pc, irq_handler
	ldr		pc, fiq_handler

reset_handler:		.word InstallIntTable
undefined_handler:	.word hang
swi_handler:		.word hang
prefetch_handler:	.word hang
data_handler:		.word hang
unused_handler:		.word hang
irq_handler:		.word myIRQA
fiq_handler:		.word hang


