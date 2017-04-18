.globl  GameOver
GameOver:
	push	{r4, r5}
	
	//bl 		DrawBlack
	
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

WaitForButtons:
	bl		ReadSNES
	ldr		r0, =ButtonsPressed
	ldr		r1, [r0]
	ldr		r2, =0xFFFFFFFF
	teq 	r1, r2
	beq		WaitForButtons
	

ReturnToTitle:
	
	pop		{r4, r5}
	b		TitleScreen
