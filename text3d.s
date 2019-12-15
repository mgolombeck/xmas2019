;=======================================================
;
; HIRES text data of the 3D-Engine
;
*
********************************
* TOP & BOTTOM TEXT MESSAGE    *
********************************
*
* PRINT OUT WELCOME TEXT ON SCREEN
*
WLCMTXT			
				LDA	#0					; stop text delete routine
				STA	TXTDEL
				
				LDA	STRCOUNT			; calculate list index for STR adresses
				ASL
				TAY
				
				LDA	STRADR,Y				; prepare text output
				STA	PTEXT
				INY
				LDA	STRADR,Y
				STA	PTEXT+1
				LDA	#1
				STA	TOUTSCR
				
				LDY #0
				LDA	(PTEXT),Y			; read X-position
				STA	CHARCOUNT
				INY
				LDA	(PTEXT),Y			; read Y-position
				STA	YLINENUM
				JSR	SETTXTPTR			; setup pointers for all HIRES lines
				INY
				STY	YDUMMY

				INC	STRCOUNT			; check if we have cycled through all strings
				LDA	STRCOUNT
				CMP	NUMSTRS
				BNE	wlcmRTS
				LDA	#0					; yes -> reset counter
				STA	STRCOUNT
wlcmRTS			RTS
;
; print out HOHOHO
;
PRINTHO

				LDY	#0
				LDA	(PTEXT2),Y			; read X-position
				STA	CHARCOUNT2
				INY
				LDA	(PTEXT2),Y			; read Y-position
				STA	YLINENUM2
				INY
holp1			LDA	(PTEXT2),Y	
				CMP	#$FF				; HOHOHO output done?
				BEQ	HOrts
          		LDX	#0
          		STX	CPOSN2+1				; should be 0
				STA	CPOSN2					; store next character value
				ASL	CPOSN2
				ASL	CPOSN2
				ROL	CPOSN2+1
				ASL CPOSN2
				ROL	CPOSN2+1
				
										; get adress of chosen character
				LDA	#<TCar			; in FONT table
				CLC
				ADC	CPOSN2
				STA	CPOSN2
				
				LDA #>TCar
				ADC	CPOSN2+1
				STA	CPOSN2+1
				
				STY	YDUMMY4
				
GB				LDX	YLINENUM2			; y-line number
				LDY	#$00					; loop over 8 Bytes
G1				CLC							; get base adress of HIRES screen line
				LDA	YLOOKLO,X			; 
				ADC	CHARCOUNT2			; char counter
				STA	CSCRN3					; LO-byte char HIRES adress
				STA	CSCRN4
				LDA	YLOOKHI,X			; 
				ORA	#$20					; create adress for page 1
				STA	CSCRN3+1
				LDA	(CPOSN2),Y
				STY YDUMMY3
				LDY #0
				STA	(CSCRN3),Y
				LDY YDUMMY3
*
TOutDone		INX
				INY
				CPY	#$05					; plot all 4 bytes
				BCC	G1						; loop!
*						
				LDY	YDUMMY4
				INC	CHARCOUNT2			; next char position
				INY
				BNE	holp1				
							
HOrts			RTS
YLINENUM2		DS		1
YDUMMY3			DS		1
YDUMMY4			DS		1
*
*
* HIRES text output routine
*			
TXTOUT
TXTLOOP   		LDY	YDUMMY
				LDA (PTEXT),Y			; pointer to text data
				CMP	#$20				; suppress spaces
				BNE	chkEND
				INC CHARCOUNT			
				INC	YDUMMY				; check next char
				
				BNE	TXTLOOP
chkEND			CMP	#$FF
          		BNE TXTCONT       		; STOP WHEN $00 IS READ
          		LDA	#0					; stop animation
          		STA TXTACT				; we are done with the current string!
          		LDA	#1
          		STA	TXTDEL				; start text delete action
          		RTS
TXTCONT    		
				SEC
          		SBC	#$20				; correct offset for ASCII-values
          		LDX	#0
          		STX	CPOSN+1				; should be 0
				STA	CPOSN					; store next character value
*				DEC	CPOSN
				ASL	CPOSN
				ASL	CPOSN
				ROL	CPOSN+1
				ASL CPOSN
				ROL	CPOSN+1
				
*
										; get adress of chosen character
				LDA	#<FONTTAB			; in FONT table
				CLC
				ADC	CPOSN
				;STA	CPOSN
				STA	fadr_smc1+1			; self-modify adress
				STA	fadr_smc2+1			; self-modify adress
				STA	fadr_smc3+1			; self-modify adress
				STA	fadr_smc4+1			; self-modify adress
				STA	fadr_smc5+1			; self-modify adress
				STA	fadr_smc6+1			; self-modify adress
				STA	fadr_smc7+1			; self-modify adress
				STA	fadr_smc8+1			; self-modify adress
				
				LDA #>FONTTAB
				ADC	CPOSN+1
				;STA	CPOSN+1
				STA	fadr_smc1+2
				STA	fadr_smc2+2
				STA	fadr_smc3+2
				STA	fadr_smc4+2
				STA	fadr_smc5+2
				STA	fadr_smc6+2
				STA	fadr_smc7+2
				STA	fadr_smc8+2
				
*			
				STY	YDUMMY				; store Y
				
				
GETBYTE			LDY	#39					; start on the right
				STY	YDUMMY2
				RTS
;
; animate a single char
;
				
CHAROUT			LDA	TXTACT				; check if we are done with the current string
				BNE	txtLP				; nope -> do animation
				RTS						; yes -> quit immediately!
txtLP			LDY	YDUMMY2				
				LDX	#0
fadr_smc1		LDA	FONTTAB,X
				STA	(TPTR1),Y
				INX
fadr_smc2		LDA	FONTTAB,X
				STA	(TPTR2),Y
				INX
fadr_smc3		LDA	FONTTAB,X
				STA	(TPTR3),Y
				INX
fadr_smc4		LDA	FONTTAB,X
				STA	(TPTR4),Y
				INX
fadr_smc5		LDA	FONTTAB,X
				STA	(TPTR5),Y
				INX
fadr_smc6		LDA	FONTTAB,X
				STA	(TPTR6),Y
				INX
fadr_smc7		LDA	FONTTAB,X
				STA	(TPTR7),Y
				INX
fadr_smc8		LDA	FONTTAB,X
				STA	(TPTR8),Y
				CPY	#39
				BEQ	noDelC			; do not delete last char on first round!
				INY
				LDA	#0
				STA	(TPTR1),Y
				STA	(TPTR2),Y
				STA	(TPTR3),Y
				STA	(TPTR4),Y
				STA	(TPTR5),Y
				STA	(TPTR6),Y
				STA	(TPTR7),Y
				STA	(TPTR8),Y
				;LDA	#60
				;JSR	WAIT
				DEY
noDelC			DEY
				STY	YDUMMY2
				CPY	CHARCOUNT
				BNE TXTDONE				; current char not done
				;CLI
				INC	CHARCOUNT			; next char position
				INC	YDUMMY
				JSR	TXTOUT				; get next char
				;LDY	YDUMMY
				;INY						; next character Y = $FF + 1 = $00 -> end of output
				;STY	YDUMMY
				;JMP	TXTLOOP				; 
TXTDONE   		RTS						; just do 1 character!
				
*
*
SETTXTPTR
				LDX	YLINENUM			; y-line number
				LDA	YLOOKLO,X			; prepare line adress pointers for 7 consecutive
				STA	TPTR1				; HIRES lines
				LDA	YLOOKHI,X
				ORA	#$20
				STA	TPTR1+1
				INX
				LDA	YLOOKLO,X
				STA	TPTR2
				LDA	YLOOKHI,X
				ORA	#$20
				STA	TPTR2+1
				INX
				LDA	YLOOKLO,X
				STA	TPTR3
				LDA	YLOOKHI,X
				ORA	#$20
				STA	TPTR3+1
				INX
				LDA	YLOOKLO,X
				STA	TPTR4
				LDA	YLOOKHI,X
				ORA	#$20
				STA	TPTR4+1
				INX
				LDA	YLOOKLO,X
				STA	TPTR5
				LDA	YLOOKHI,X
				ORA	#$20
				STA	TPTR5+1
				INX
				LDA	YLOOKLO,X
				STA	TPTR6
				LDA	YLOOKHI,X
				ORA	#$20
				STA	TPTR6+1
				INX
				LDA	YLOOKLO,X
				STA	TPTR7
				LDA	YLOOKHI,X
				ORA	#$20
				STA	TPTR7+1
				INX
				LDA	YLOOKLO,X
				STA	TPTR8
				LDA	YLOOKHI,X
				ORA	#$20
				STA	TPTR8+1
				RTS
*
;CHARCOUNT		DS		1
YLINENUM		DS		1
YDUMMY			DS		1
YDUMMY2			DS		1
*
;
; delete text line
;
DELTXT			LDA	TXTDEL			; text delete active?
				BNE	doDEL
				RTS
				
				;LDA	#182
				;STA	YLINENUM
				
doDEL			LDY	#182
lpYu1			LDA	YLOOKHI,Y
				ORA	#$20
				STA	uto1+2
				LDA	YLOOKLO,Y
				STA	uto1+1
				INY
				LDA	YLOOKHI,Y
				ORA	#$20
				STA	ufr1+2
				LDA	YLOOKLO,Y
				STA	ufr1+1
				
				LDX	#40				; do a complete line
lpXu1			DEX			
ufr1			LDA	$2000,X
uto1			STA	$2000,X	
				CPX	#0
				BNE	lpXu1				
				
				CPY	#190
				BNE	lpYu1					; do for 192 lines -> if X=0 we are done!
				INC TXTDEL
				LDA	TXTDEL
				CMP	#9
				BNE	delTRTS
				LDA	#1
				STA	TXTINIT
				LDA	#0
				STA	TXTDEL
				STA	TXTWAIT
				;JSR	WLCMTXT			; restart text output!
delTRTS			RTS
;
; first text messages on screen
;
STARTTEXT
				STA	$C002
				STA	$C004
				STA $C051      		; SWITCH TO TEXT -> show welcome question
          		STA $C052
          		STA $C054
          		JSR	$FB39			; command TEXT
				JSR	HOME			; clear text screen
				LDA	#0
				STA	WAITVAL
				LDA	#15				; HTAB 14
				STA	$24
				LDX	#<T_SHACK
				LDY	#>T_SHACK
				JSR	printCHAR
				

				LDA	#16
				STA	$24
				LDA	#18
				STA	$25
				JSR	VTAB
				LDX	#<T_OPT1
				LDY	#>T_OPT1
				JSR	printCHAR
							
				LDA	#9
				STA	$24
				LDA	#20
				STA	$25
				JSR	VTAB
				LDX	#<T_OPT2
				LDY	#>T_OPT2
				JSR	printCHAR
							
				LDA	#9
				STA	$24
				LDA	#21
				STA	$25
				JSR	VTAB
				LDX	#<T_OPT3
				LDY	#>T_OPT3
				JSR	printCHAR
							

				LDA	#100
				STA	WAITVAL
				LDA	#11
				STA	$24
				LDA	#10
				STA	$25
				JSR	VTAB
				LDX	#<T_LOAD		
				LDY	#>T_LOAD
				JSR	printCHAR
				JSR	LOADSHACK		; load 8-bit-shack logo
				JSR	LOADLOGO
				LDA	#7
				STA	$24
				LDA	#10
				STA	$25
				JSR	VTAB
				LDX	#<T_SELECT	
				LDY	#>T_SELECT
				JSR	printCHAR
				LDA	#$FF
				STA	LIMIT			; unlimited flakes
getKY			JSR	RDKEY			; press a key
				;always limit number of snowflakes!
				CMP	#$D9			; "Y"?
				BNE	chkY
				LDX	#<T_HERO	
				LDY	#>T_HERO
				LDA	#7
				STA	$24
				JMP	doLIMIT
chkY			CMP	#$F9
				BNE	chkN
				LDX	#<T_HERO	
				LDY	#>T_HERO
				LDA	#7
				STA	$24
				JMP	doLIMIT
				
chkN			CMP	#$CE			; "N"?
				BNE	chkn
				LDX	#<T_WUZZ	
				LDY	#>T_WUZZ
				LDA	#0
				STA	$24
				JMP	doLIMIT
				
chkn			CMP	#$EE
				BNE	getKY
				LDX	#<T_WUZZ	
				LDY	#>T_WUZZ
				LDA	#0
				STA	$24

doLIMIT	
				LDA	#10
				STA	$25
				JSR	VTAB
				JSR	printCHAR
				LDX	#20
iniWT2			LDA	#255
				JSR	WAIT
				DEX
				BNE	iniWT2
				INC	LIMIT			; limit number of snowflakes		
noLIMIT			RTS
		
;
; end text messages on screen
;
ENDTEXT
				STA	$C002
				STA	$C004
				STA $C051      		; SWITCH TO TEXT -> show welcome question
          		STA $C052
          		STA $C054
          		JSR	$FB39			; command TEXT
				JSR	HOME			; clear text screen
				LDA	#80
				STA	WAITVAL
				LDA	#14				; HTAB 14
				STA	HTAB
				LDA	#24
				STA	HTAB2
				LDA	#0
				STA	VTAB2
				LDX	#<T_SHACK
				LDY	#>T_SHACK
				LDA	#<T_SHACKa
				STA	PTR
				LDA	#>T_SHACKa
				STA	PTR+1
				JSR	printANIM

				LDA	#12
				STA	HTAB
				LDA	#26
				STA	HTAB2
				LDA	#4
				STA	VTAB2
				LDX	#<T_END1
				LDY	#>T_END1
				LDA	#<T_END1b
				STA	PTR
				LDA	#>T_END1b
				STA	PTR+1
				JSR	printANIM
							
				LDA	#8
				STA	HTAB
				LDA	#30
				STA	HTAB2
				LDA	#7
				STA	VTAB2
				LDX	#<T_END2
				LDY	#>T_END2
				LDA	#<T_END2a
				STA	PTR
				LDA	#>T_END2a
				STA	PTR+1
				JSR	printANIM
							
				LDA	#10
				STA	HTAB
				LDA	#28
				STA	HTAB2
				LDA	#10
				STA	VTAB2
				LDX	#<T_END3
				LDY	#>T_END3
				LDA	#<T_END3a
				STA	PTR
				LDA	#>T_END3a
				STA	PTR+1
				JSR	printANIM
							
				LDA	#255
				STA	HTAB
				LDA	#38
				STA	HTAB2
				LDA	#16
				STA	VTAB2
				LDA	#20
				STA	WAITVAL
				LDX	#<T_END4
				LDY	#>T_END4
				LDA	#<T_END4a
				STA	PTR
				LDA	#>T_END4a
				STA	PTR+1
				JSR	printANIM
				
				LDA	#100
				STA	WAITVAL			
				LDA	#12
				STA	HTAB
				LDA	#31
				STA	HTAB2
				LDA	#22
				STA	VTAB2
				LDX	#<T_END5
				LDY	#>T_END5
				LDA	#<T_END5a
				STA	PTR
				LDA	#>T_END5a
				STA	PTR+1
				JSR	printANIM

				LDA	#70
				STA	WAITVAL			
				LDA	#12
				STA	HTAB
				LDA	#31
				STA	HTAB2
				LDA	#21
				STA	VTAB2
				LDX	#<T_MARQ
				LDY	#>T_MARQ
				LDA	#<T_MARQa
				STA	PTR
				LDA	#>T_MARQa
				STA	PTR+1
				JSR	printANIM

				LDA	#12
				STA	HTAB
				LDA	#31
				STA	HTAB2
				LDA	#23
				STA	VTAB2
				LDX	#<T_MARQ
				LDY	#>T_MARQ
				LDA	#<T_MARQa
				STA	PTR
				LDA	#>T_MARQa
				STA	PTR+1
				JSR	printANIM
				RTS

;
; Marquee setup
;
MARQUEESET		LDX	#21
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#13
				LDA	#$A0
				STA	(TXTPTR),Y
				INY
				STA	(TXTPTR),Y
				
				LDX	#23
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#27
				LDA	#$A0
				STA	(TXTPTR),Y
				DEY
				STA	(TXTPTR),Y
				
				LDA	#1
				STA	MSTATE
				STA	MCOUNT
				DEC	MCOUNT
				RTS
				
;
; Marquee animation
;
MARQUEEANIM		
				LDA	MSTATE
				CMP #1
				BNE Mstate2
				;LDY	MCOUNT
				LDX	#21
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDA	MCOUNT
				CLC
				ADC	#13
				TAY
				LDA	#$BA
				STA	(TXTPTR),Y
				INY	
				INY
				LDA	#$A0
				STA	(TXTPTR),Y
				LDX	#23
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDA	#27
				SEC
				SBC	MCOUNT
				TAY
				LDA	#$BA
				STA	(TXTPTR),Y
				DEY	
				DEY
				LDA	#$A0
				STA	(TXTPTR),Y
				
				INC	MCOUNT
				LDA	MCOUNT
				CMP	#13				; all done?
				BNE	Mstate1e
				INC	MSTATE			; incement state
				LDA	#0
				STA	MCOUNT			; reset MCOUNT
Mstate1e		JMP	MArts
								
Mstate2			CMP	#2
				BNE	Mstate3
				LDX	#21
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#26
				LDA	#$BA
				STA	(TXTPTR),Y
				LDX	#22
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#27
				LDA	#$A0
				STA	(TXTPTR),Y
				LDY	#13
				STA	(TXTPTR),Y
				LDX	#23
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#14
				LDA	#$BA
				STA	(TXTPTR),Y
				INC	MSTATE
				JMP MArts		

Mstate3			CMP	#3
				BNE	Mstate4
				LDX	#21
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#27
				LDA	#$BA
				STA	(TXTPTR),Y
				LDY	#13
				LDA	#$A0
				STA	(TXTPTR),Y
				
				LDX	#23
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#13
				LDA	#$BA
				STA	(TXTPTR),Y
				LDY	#27
				LDA	#$A0
				STA	(TXTPTR),Y

				INC	MSTATE
				JMP MArts		

Mstate4			CMP	#4
				BNE	MArts
				LDX	#21
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#14
				LDA	#$A0
				STA	(TXTPTR),Y
				LDX	#22
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#27
				LDA	#$BA
				STA	(TXTPTR),Y
				LDY	#13
				STA	(TXTPTR),Y
				LDX	#23
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#26
				LDA	#$A0
				STA	(TXTPTR),Y
				LDA	#1
				STA	MSTATE
				;JMP MArts		


MArts			LDA	#120
				JSR	WAIT
				RTS
MSTATE			DS	1				
MCOUNT			DS	1
				
;
; end scroller effect
;
ENDSCROLL
				LDA	#80
				STA	WAITVAL
				LDX	#0
elp1			LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#0
				LDA	#$20			; white block
elp2			STA	(TXTPTR),Y
				INY
				CPY	#40
				BNE	elp2
				CPX	#1
				BLT	eincx			; do not undelete line if we are at the first line
				DEX
				LDA	YTLOOKLO,X		; undelete last line
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#0
				LDA	#$A0			; space block
elp2a			STA	(TXTPTR),Y
				INY
				CPY	#40
				BNE	elp2a
				INX
eincx			TXA					; draw the line on the lower screen
				PHA
				
				SEC
				SBC #24
				EOR	#$FF
				;STA	Y2
				TAX
				LDA	YTLOOKLO,X
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#0
				LDA	#$20			; white block
elp2b			STA	(TXTPTR),Y
				INY
				CPY	#40
				BNE	elp2b
				CPX	#23
				BGE	eincx2
				INX
				LDA	YTLOOKLO,X		; undelete last line
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#0
				LDA	#$A0			; space block
elp2c			STA	(TXTPTR),Y
				INY
				CPY	#40
				BNE	elp2c
				;DEX
				
eincx2			PLA
				TAX
				LDA	WAITVAL
				JSR	WAIT
				INX
				CPX	#12
				BNE	elp1
				
				DEX
				LDA	YTLOOKLO,X		; undelete last line
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#0
				LDA	#$A0			; space block
elp2d			STA	(TXTPTR),Y
				INY
				CPY	#40
				BNE	elp2d
				
				INX					; shrink last line	
				LDA	YTLOOKLO,X		; undelete last line
				STA	TXTPTR
				LDA	YTLOOKHI,X
				STA	TXTPTR+1
				LDY	#0
elp3			LDA	#$A0			; space block
				STA	(TXTPTR),Y
				TYA					; shrink from the right side
				PHA
				
				SEC
				SBC #40
				EOR	#$FF
				TAY
				LDA	#$A0
				STA	(TXTPTR),Y
				LDA	#60
				JSR	WAIT
				PLA
				TAY
				INY
				CPY	#20
				BNE	elp3
				
ekey			RTS
		