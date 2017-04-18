

.section    .text
.globl      InitSNES
.align
InitSNES:
	push	{lr}

	mov 	r0, #9              	//SNES Latch
	mov 	r1, #1              	//Setting pin to output.
	bl 		InitGPIO            	//Subroutine to initialize pin for latch
	
	mov 	r0, #10             	//SNES Data
	mov 	r1, #0              	//Setting pin to input
	bl 		InitGPIO            	//Subroutine to initialize pin for data
	
	mov 	r0, #11             	//SNES Clock
	mov 	r1, #1              	//Setting pin to output
	bl 		InitGPIO            	//Subroutine to initialize pin for clock

	pop		{lr}
	mov		pc, lr











.globl      ReadSNES
.align
ReadSNES:

    push	{r5, r6, r7, lr}

           

latchButtons:
    mov     r0, #1          		// Writing 1 to the Latch
    bl  	writeLatch              // Call writeLatch subroutine
            
    mov     r0, #1                  // Writing 1 to the Clock
    bl  	writeClock              // Call writeClock subroutine
            
    mov     r0, #12                 // Wait 12 us
    bl  	wait            		// Call wait subroutine
            
    mov     r0, #0                  // Write the value of 0 to latch
    bl  	writeLatch              // Call writeLatch subroutine
            
    mov 	r6, #0					// Move 0 into r6
    mov 	r12, #0xFFFFFFFF		// Move 1111 .... 1111 into r12 - represents button register
    b		1f         
        

	
ReadLine:
    mov 	r0, #6          		// Move 6 into r0
    bl  	wait            		// Wait for 6 micro-seconds

    mov 	r0, #0          		// Move 0 into r0
    bl  	writeClock      		// Set Clock line to 0

    mov 	r0, #6          		// Move 6 into r0
    bl  	wait            		// Wait for 6 micro-seconds

    bl  	readData        		// Read from data line -- 1 MEANS A BUTTON WAS PRESSED 

    mov 	r5, r0          		// Move result into r5
    eor 	r12, r5, lsl r6			// Shift result by current index (button index)
									// EOR it with button register to set appropriate bit
        
    mov     r0, #1             		//Setting the clock to on as 1
    bl  	writeClock              //Call subroutine writeClock
             
    add     r6, #1              	//Increment index


1:  cmp 	r6, #15         		// Check how many times we've sampled the data line
    ble 	ReadLine        		// If less than 16, continue, else...



	mov 	r0, r12					// Move button register value into r0
    
    
	ldr		r1, =ButtonsPressed
    str		r0, [r1]		
    
    
    pop 	{r5, r6, r7, lr}		// Load r5, r6, r7, lr
    mov 	pc, lr					// Link back to calling code



















.globl      InitGPIO
.align

// r0 - Line to initialize (9 - Latch, 10 - Data, or 11 - Clock) - unpredictable otherwise
// r1 - Function Code (0 for input, 1 for output) - unpredictable otherwise
InitGPIO:

	cmp		r0, #10         		// Is line == 10
    ldrlt   r2, =0x3F200000     	// If less than, load address of GPFSEL0
    ldrge   r2, =0x3F200004     	// Otherwise, load address of GPFSEL1


    ldr 	r3, [r2]        		// Load value of GPFSELx into r3

    mov 	r12, #7         		// Move 0111 into r12
    mov 	r4, #3          		// Move 3 into r2

    subge   r0, r0, #10     		// If pin# is 10 or 11, subtract 10 
    
    mul 	r0, r0, r4      		// Multiply pin number by 3 for offset
    
    
    bic 	r3, r12, lsl r0     	// Clear appropriate bits in GPFSELx (Shift 0111 by appropriate offset first)

    orr 	r3, r1, lsl r0      	// Set function code in r3 (Shift function code by appropriate offset first)


    
    str 	r3, [r2]        		// Store new function select code in GPFSELx

    mov 	pc, lr          		// Branch back to calling code


    

    
// Value to write to latch in r0
writeLatch:

    mov 	r1, #1					// Move 1 into r1
    mov 	r3, r1, LSL #9			// Shift r1 left by 9 for setting corresponding GPIO Line

    ldr 	r1, =0x3F20001C			// GPSET0
    ldr 	r2, =0x3F200028			// GPCLR0


    cmp 	r0, #0					// Check if we should set line to 0 or 1

    streq   r3, [r2]				// If 0, store 0000 .... 0010 0000 0000 in GPCLR0
    strne   r3, [r1]				// Else, store 0000 .... 0010 0000 0000 in GPSET0

    mov 	r3, #0

	mov 	pc, lr          		// Return to calling code







    
// Value to write to clock in r0
writeClock:

    mov 	r1, #1          		// Move 1 into r1
    mov 	r3, r1, lsl #11     	// Shift r1 left by 11 for setting corresponding GPIO Line 
    
    ldr 	r1, =0x3F20001C     	// GPSET0
    ldr 	r2, =0x3F200028     	// GPCLR0

    cmp 	r0, #0          		// Check if we should set line to 0 or 1

    streq   r3, [r2]        		// If 0, store 0000 .... 1000 0000 0000 in GPCLR1
    strne   r3, [r1]        		// Else, store 0000 .... 1000 0000 0000 in GPSET1
    
    mov 	r3, #0

    mov 	pc, lr          		// Return to calling code






// Value returned in r0
// RETURNS 1 IF THE BUTTON WAS PRESSED !! REVERSES THE SNES LOGIC
readData:   

    mov 	r1, #1          		// Move 1 into r1
    mov 	r3, r1, lsl #10     	// LSL to align with SNES data pin

    
    ldr 	r1, =0x3F200034     	// Address of GPLEV0
    ldr 	r2, [r1]        		// Load current GPLEV0
    
    and 	r3, r2, r3      		// Mask current GPLEV with 0000 .... 0100 0000 0000

    
    cmp 	r3, #0          		// Check if the button was pressed
    
    moveq   r0, #1          		// If it was, Return 1
    movne   r0, #0          		// Otherwise, Return 0
    
    
    mov 	pc, lr          		// Return to calling code











