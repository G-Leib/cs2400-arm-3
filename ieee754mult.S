				;		ARM Programming Assignment #3: 32 bit IEEE 754 single-precision multiplier
				;
				;		Write a 32-bit floating point multiplier. The numbers will be represented
				;		in the single-precision IEEE 754 floating-point standard. The result should
				;		also be in IEEE 754 binary32. Assume you only have normalized numbers, i.e.
				;		the exponent is never 0b00000000.
				;		Write the result in the provided "fill" word.
				
				;		Your code here
				
floats			DCD		0xa0bcff0d, 0x13c0adea
result			FILL		8
				
main
				ADR		r0, floats
				LDR		r2, [r0], #4
				LDR		r1, [r0]
				MOV		r6, r1
				BL		extract_exponent
				MOV		r3, r6
				MOV		r6, r2
				BL		extract_exponent
				MOV		r4, r6
				MOV		r8, #0			;sign tracker
				MOV		r5, r1
				CMP		r1,	#0			;check if first number is negative
				BLlt		sign_track
				MOV		r1, r5
				MOV		r5, r2
				CMP		r2,	#0			;check if second number is negative
				BLlt		sign_track
				MOV		r2, r5
				MOV		r7, r1
				BL		isolate_fraction
				MOV		r1, r7
				MOV		r7, r2
				BL		isolate_fraction
				MOV		r2, r7
				MOV		r0, #0
				BL		multiply
				MOV		r5, #1
				LSL		r5, r5, #23
				MOV		r6, r0
				BL		check_msb
				MOV		r0, r6
				ADD		r1, r3, r4		;add exponents
				SUB		r1, r1, #127
				MOV		r5, #1
				LSL		r5, r5, #7
				MOV		r6, r1
				BL		check_msb
				MOV		r1, r6
				LSL		r1, r1, #23
				CMP		r8, #1
				BLeq		negater
				ORR		r1, r0, r1
				ADR		r0, result
				STR		r1, [r0]
				END
				
sign_track
				EOR		r8, r8, #1
				MOV		pc, lr
extract_exponent
				LSL		r6, r6, #1
				LSR		r6, r6, #24
				MOV		pc, lr
isolate_fraction
				LSL		r7, r7, #9
				LSR		r7, r7, #9
				MOV		pc, lr
multiply
				AND		r5, r1, #1
				CMP		r5, #1
				ADDeq	r0, r0, r2
				LSL		r2, r2, #1
				LSR		r1, r1, #1
				CMP		r1, #0
				Bne		multiply
				MOV		pc, lr
check_msb
				CMP		r6, r5
				MOVlt	pc, lr
				LSR		r6, r6, #1
				B		check_msb
negater
				RSB		r0, r0, #0			;negate fraction
				MOV		r5, #255				;create 8bit mask
				LSL		r5, r5, #23			;move mask to exponent bits
				EOR		r0, r0, r5			;remove exponent bits
				MOV		pc, lr
