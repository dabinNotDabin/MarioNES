
//**************************************************
// * FrameBufferInit -- Initializes a Frame Buffer
// *
// * Returns:
// *	 FrameBufferPointer in r0 or -1 on fail
//**************************************************

.align
.section 	.text
.globl      FrameBufferInit


FrameBufferInit:
												// Register equates
	mail	.req	r2	
	fbInfo	.req	r3
	
	
	ldr		mail, 	=0x3F00B880					// Get base address for mailbox
	ldr		fbInfo,	=FrameBufferInfo			// Get address for start of FrameBufferInfo

	
whileMailBoxFull:
	ldr		r0,		[mail, #0x18]				// Get the value in the mailbox status register

	tst		r0,		#0x80000000					// Is the mailbox full? If so, 
	bne		whileMailBoxFull					// Branch to whileMailBoxFull, else...

	add		r0, 	fbInfo,	#0x40000000			// ...Set 30th bit to 1 so GPU doesn't cache FBI
	orr		r0, 	#0b1000						// Set lower 4 bits to mailbox channel 8

	str		r0,		[mail, #0x20]				// Store in mailbox write register

	
whileMailBoxEmpty:
	ldr		r0,		[mail, #0x18]				// Get the value in the mailbox status register

	tst		r0,		#0x40000000					// Is the mailbox empty? If so,
	bne		whileMailBoxEmpty						// Branch to whileMailBoxEmpty, else...

	ldr		r0,		[mail, #0x00]				// ... Get address for mailbox read register

	and		r1,		r0, #0xF					// Get channel information (low 4 bits)

	teq		r1,		#0b1000						// Was message for channel 8? 
	bne		whileMailBoxEmpty					// If not, branch to whileMailBoxEmpty, else...
	
	ldr		r0,		=FrameBufferInfo			// ... Get base address of FrameBufferInfo
	ldr		r1,		[r0, #0x04]					// Load the request value from buffer
	teq		r1,		#0x80000000					// Was the request successful?
	bne		badExit								// If not, branch to badExit, else ...

waitForGPU:
	ldr		r0, 	=FBP 						// ... Get address of Frame Buffer Pointer 
	ldr		r0, 	[r0]						// Load value at Frame Buffer Pointer
	teq		r0,		#0							// Has the GPU set the pointer?
	beq		waitForGPU							// If not, branch to waitForGPU, else ...

	ldr		r0,		=FBP
	ldr		r0,		[r0]

	.unreq	mail
	.unreq	fbInfo

	b		exit
	
	
badExit:
	mov		r0,		#-1							// Return -1 if the request failed

exit:
	mov		pc, 	lr							// Link back to calling code


	
	
	
	
	////////////////////////Should be in main somewhere
.section .data
.align 4
.globl FrameBufferInfo

FrameBufferInfo:

	.int 	22 * 4							// Buffer size in bytes
	.int	0								// Indicates a request to GPU
	.int	0x00048003						// Set Physical Display width and height
	.int	8								// size of buffer
	.int	8								// length of value
	.int	1024							// horizontal resolution
	.int	768								// vertical resolution

	.int	0x00048004						// Set Virtual Display width and height
	.int	8								// size of buffer
	.int	8								// length of value
	.int 	1024							// horizontal resolution
	.int 	768								// vertical resolution

	.int	0x00048005						// Set bits per pixel
	.int 	4								// size of value buffer
	.int	4								// length of value
	.int	16								// bits per pixel value

	.int	0x00040001						// Allocate framebuffer
	.int	8								// size of value buffer
	.int	8								// length of value
	
FBP:
	.int	0								// value will be set to framebuffer pointer
	.int	0								// value will be set to framebuffer size			

	.int	0								// end tag, indicates the end of the buffer

