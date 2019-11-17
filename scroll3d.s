;=======================================================
;
; text scroller of the 3D-Engine
;
xsTO			EQU	#39						; define scroll window size - just a plain row of text!
xsFROM			EQU	#0
ysTO			EQU	#176
ysFROM			EQU	#168
*	
nxtCHAR										; shift for two pixels every update cycle
Off1			LDX StringHGR				; get current character
				BPL _cont					; HI-bit set (=$FF)? if yes restart the text
				LDA	STRCOUNT				; display which string?
				BNE	str2					; 		
				LDA #>StringSong				; restore intial string adress
				STA Off1+2
				LDA #<StringSong
				STA Off1+1
				INC STRCOUNT				; increment string counter
				JMP	Off1
				
str2			CMP	#1
				BNE	str3					; display last string	
				LDA #>StringHGR2				; restore intial string adress
				STA Off1+2
				LDA #<StringHGR2
				STA Off1+1
				INC	STRCOUNT
				JMP Off1
				
str3			LDA #>StringHGR				; restore intial string adress
				STA Off1+2
				LDA #<StringHGR
				STA Off1+1
				LDA #0
				STA	STRCOUNT				; reset counter
				JMP Off1
				
_cont			TXA
				SEC
				SBC #$20
				
				STA	CPOSN					; calculate next character position in array
				LDA	#0
          		STA	CPOSN+1					; should be 0
				ASL	CPOSN
				ASL	CPOSN
				ROL	CPOSN+1
				ASL CPOSN
				ROL	CPOSN+1
*
				CLC							; get FONT base adress
fadr1			LDA	#<FONTTAB			
				ADC	CPOSN
				STA	CPOSN
fadr2			LDA #>FONTTAB
				ADC	CPOSN+1
				STA	CPOSN+1

				LDX #7						; font is 8 pixels high!
				LDY	#7
		
yloop			LDA (CPOSN),Y
				AND INBITS
				BEQ sb1						; no pixel to set!
				LDA	BENCHM
				BEQ	noSHL
				LDA	#$20
				BNE	sb1						; branch always
noSHL			LDA #$40					; 
sb1				ORA TSBIT,X		
				STA	TSBIT,X
				DEY
				DEX
				BPL yloop
		
				LDA INBITS
				ASL						; 
				BPL s1					; 
				INC Off1+1				; increment string adress to next character 
				BNE	s2					; do we need to change the HI-byte? 
				INC Off1+2				; yes
s2				LDA #$01				; reset bit maks to position #1
s1				STA INBITS				; save  
*
_cont3			RTS


clrTS
				LDX #7					; clear BIT mask if more than one pixel
				LDA	#0					; of a character is set
TSloop			STA	TSBIT,X
				DEX
				BPL TSloop
				RTS
*
*
* shift left
*
SHleft1
				LDA bMachine				; try to synchronize scrolling with vertical blanking
        		BEQ _badguy    		; IIc -> another refresh detection method is necessary
          		CMP #$EA
          		BEQ _badguy        	; II+ -> no detection possible
          		CMP #$38
          		BEQ _badguy        	; II -> no detection possible
                                                            
_L1       		CMP VERTBLANK      	; works with IIGS/IIE      
          		BPL _L1            	; wait until the end of the vertical blank
                                                
_L2       		CMP VERTBLANK  		; synchronizing counting algorithm      
          		BMI _L2            	; wait until the end of the complete display -> start of vertical blanking

_badguy			LDX	ysTO
lpY				DEX
				LDA YLOOKHI,X			; get line base adress HI-byte
          		ORA #$20					; HIRES page #1
          		STA	fr1+2
          		STA	fr2+2
          		STA	fr3+2
          		STA	fr4+2
          		STA	to3+2
          		STA	to4+2

				AND	#%11011111
          		ORA #$40					; HIRES page #2
          		STA	to1+2
          		STA	to2+2
          	
				LDA YLOOKLO,X			; get line base adress LO-byte
				STA	fr1+1
          		STA	fr3+1
          		STA	fr4+1
          		STA	to1+1
          		STA	to2+1
          		STA	to3+1
          		STA	to4+1
          		CLC
          		ADC	#1							; special treatment -> avoid DEY/INY opcodes
          		STA	fr2+1

cc1				LDY	xsFROM
				STX	Temp					; save X-reg
				TXA
				AND	#%00000111			; cycle through 0 .. 7
				STA	savb+1				; self-modifying
lpX
fr1				LDX	$2000,Y			; get the first byte of the new line
				;LSR
				;LSR
				LDA	TAB1,X			; get LUT value from TAB1
fr2				LDX	$2000,Y			; get byte + 1
				ORA	TAB2,X			; ORA with LUT value from TAB2
to1				STA	$2000,Y
to3				STA	$2000,Y
		
				INY
				CPY	xsTO
				BNE	lpX

fr3				LDX	$2000				; special treatment last byte for wrap-around effect!
				LDA	TAB2,X
				LDY	xsTO
fr4				LDX	$2000,Y
				ORA	TAB1,X
				AND	#%10011111			; was 10111111
savb			ORA	TSBIT
to2				STA	$2000,Y		
to4				STA	$2000,Y
					
				LDX	Temp					; retrieve X-reg
				CPX	ysFROM
				BEQ	jmRTS
				JMP	lpY					; do for 192 lines -> if X=0 we are done!
jmRTS			RTS
	

StringHGR
		ASC 	'Welcome to the 3D-ENGINE-Demo for Apple ][ computers by 8-Bit-Shack! '
		HEX	FF
StringHGR2
		ASC		' - Have you ever thought this '
		ASC		'could be possible on an Apple ][ with a 6502 CPU at 1 MHz & 64 kB RAM??? '
		ASC		'Greetings & further credits: Brutal Deluxe, French Touch, '
		ASC		'Deater of VMW-Software & qkumba and to all '
		ASC		'Apple ][ enthusiasts out there! Visit '
		ASC		'www.golombeck.eu and check my Apple ][ section. Enjoy!!! - '
		HEX	FF	; end of text	
StringSong
		ASC		'Now playing: '
StringSong2
		HEX	FFFFFFFFFFFFFFFF				 
		HEX	FFFFFFFFFFFFFFFF				 
		HEX	FFFFFFFFFFFFFFFF				 
		HEX	FFFFFFFFFFFFFFFF				 
		HEX	FFFFFFFFFFFFFFFF				 
		HEX	FFFFFFFFFFFFFFFF				 
		HEX	FFFFFFFFFFFFFFFF				 
		HEX	FFFFFFFFFFFFFFFF				 
		HEX	FFFFFFFFFFFFFFFF				 
		HEX	FFFFFFFFFFFFFFFF				 
		HEX	FFFFFFFFFFFFFFFF				 
		HEX	FFFFFFFFFFFFFFFF				 
		HEX	FFFFFFFFFFFFFFFF				 

		;DS \
;TSBIT 	DFB 00,00,00,00,00,00,00,00
