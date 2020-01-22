********************************
*        XMAS-Demo 2019        *
*                              *
*      BY MARC GOLOMBECK       *
*                              *
*   VERSION 1.00 / XX.12.2019  *
********************************
*
 				DSK hscrn
 				MX 	%11
          		ORG $4000
*
HOME      		EQU $FC58     	; CLEAR SCREEN
COUT      		EQU $FDED     	; PRINT CHARACTER
RDKEY			EQU	$FD0C		; get keyboard input, randomize $4E & $4F
KYBD      		EQU $C000     	; READ KEYBOARD
STROBE    		EQU $C010     	; CLEAR KEYBOARD
BELL      		EQU $FBDD     	; RING BELL
WAIT      		EQU $FCA8     	; WAIT A BIT
LORES			EQU	$FB40		; switch to LORES
HCOLOR    		EQU $F6F0     	; SET HCOLOR
HPOSN     		EQU $F411     	; SET HIRES-CURSOR NO DRAW
HPLOT     		EQU $F457     	; DRAW HIRES-PIXEL
HLIN      		EQU $F53A     	; DRAW HIRES-LINE
VERTBLANK		EQU	$C019		; vertical blanking -> available only IIe and above
MEMCOPY			EQU	$FE2C		; monitor routine for copying RAM
WRITERAM		EQU	$C081		; read ROM write RAM - toggle 2 times
READROM			EQU	$C082		; read ROM no write  - toggle 1 time
READWRITE		EQU	$C083		; read & write RAM   - toggle 2 times
READRAM			EQU	$C080		; read RAM no write  - toggle 1 time
*
*
SNOWX			EQU	$0A00		; snowflakes data area
SNOWY			EQU	$0B00
SNOWFLAG		EQU	$0C00
SNOWMOM			EQU	$0D00		; momentum of a snowflake
ZP_SAVE			EQU	$0E00		; zero page backup space
;
; Vars 
;
*
ASCR			EQU	$30B		; toggle screen byte for chamP-sync
DFREE			EQU	$30C		; free pixel down?
LFREE			EQU	$30D		; free pixel left & down?
RFREE			EQU	$30E		; free pixel right & down?
DRPOS			EQU	$30F
XOFF			EQU	$310
YOFF			EQU	$311
NUMLIN			EQU	$312
NUMTREES		EQU	$313
LIMIT			EQU	$314		; limit number of snowflakes
SNOWCNT			EQU	$315		; + $316 2 bytes snow flake counter 
DSPLOGO			EQU	$317		; show xmas-greeting flag
SNOWINIT		EQU	$318		; start snowfall slowly
TXTACT			EQU	$319		; is the string output active?
TXTDEL			EQU	$320		; is the string delete routine active?
TXTINIT			EQU	$321		; init the TXT output?
TXTWAIT			EQU	$322		; wait counter before deleting text
CHARCOUNT		EQU	$323		; active char in the string being animated
STRCOUNT		EQU	$324		; holds the number of the active display string

TOUTSCR				EQU	$350			; text output on which HIRES screens? 1, 2 or both?
PT3_LOC 			EQU	$6400			; address of PT3-file 
DUMP				EQU	$8000			; logo save space
*         
bMB					EQU	$370			; MockingBoard available? ($00/No | $01 Yes)
bMBSlot				EQU	$371			; slot of MockingBoard ($01..$07)
bMachine			EQU	$372			; auto detect Apple II machine type
bMem				EQU	$373			; 128k? ($00 No | $78 Yes)
bZC					EQU	$374			; ZIPchip installed? ($00/No | $01 Yes)
bFC					EQU	$375			; FastChip installed? ($00/No | $01 Yes)
bLC					EQU	$376			; Language Card available? ($00/No | $01 Yes)
bRefresh			EQU $377   			; byte REFRESH RATE ($00/50Hz | $01/60Hz)
b65C02 				EQU	$378  			; byte CPU ($00/6502 | $01/65C02 | $FF/65816)
bEmu				EQU	$379			; emulator detection ($00/No | $01 Yes)
bFCSPEED			EQU	$37A			; store initial FC speed

* left speaker
MOCK_ORB1			EQU	$C400			; 6522 #1 port b data
MOCK_ORA1			EQU	$C401			; 6522 #1 port a data
MOCK_DDRB1			EQU	$C402			; 6522 #1 data direction port B
MOCK_DDRA1			EQU	$C403			; 6522 #1 data direction port A

* right speaker
MOCK_ORB2			EQU	$C480			; 6522 #2 port b data
MOCK_ORA2			EQU	$C481			; 6522 #2 port a data
MOCK_DDRB2			EQU	$C482			; 6522 #2 data direction port B
MOCK_DDRA2			EQU	$C483			; 6522 #2 data direction port A

* AY-3-8910 commands on port B
										;	RESET BDIR BC1
MOCK_RESET			EQU	$0				; 0 0 0
MOCK_INACT			EQU	$4				; 1 0 0
MOCK_READ			EQU	$5				; 1 0 1
MOCK_WRITE			EQU	$6				; 1 1 0
MOCK_LATCH			EQU	$7				; 1 1 1
*
*
* FastChip constants
*
FC_UNLOCK 			EQU	$6A				; FastChip unlock value
FC_LOCK				EQU $A6				; FastChip lock value
FC_LOCK_REG			EQU	$C06A			; FastChip lock register
FC_EN_REG 			EQU	$C06B			; FastChip enable register
FC_SPD_REG			EQU	$C06D			; FastChip speed register

*
;
; Hi-res screen constants.
;
BYTES_PER_ROW 	EQU 40
NUM_ROWS 		EQU 192
NUM_COLS 		EQU	280
XFROM			EQU	#$04
XTO				EQU	#$25
YFROM			EQU	#$16
YTO				EQU	#$66

* math zero page variables
TXTPTR    		EQU $00      	; POINTER FOR TEXT OUTPUT
PTR       		EQU $02      	; POINTER FOR DOS COMMAND
PNTCNT    		EQU $03     	; WHICH POINT TO DRAW?
*
TICKS			EQU	$06
G_PAGE    		EQU $06      	; GRAPHIC PAGE TO DRAW TO
charFLAG		EQU	$07				; only uppercase letters?
MB_ADDRL		EQU	$08				; MockingBoard base adress
MB_ADDRH		EQU	$09
XPOSL			EQU	$0A			; pixel coordinates
XPOSH			EQU	$0B
YPOS			EQU	$0C
TPTR1			EQU	$10			; pointer to HIRES line for text
TPTR2			EQU	$12			; pointer to HIRES line for text
TPTR3			EQU	$14			; pointer to HIRES line for text
TPTR4			EQU	$16			; pointer to HIRES line for text
TPTR5			EQU	$18			; pointer to HIRES line for text
TPTR6			EQU	$1A			; pointer to HIRES line for text
TPTR7			EQU	$1C			; pointer to HIRES line for text
TPTR8			EQU	$1E			; pointer to HIRES line for text
PTEXT			EQU	$20
ANDMSK			EQU	$22			; pixel mask

CPOSN			EQU	$40			; character output on HIRES-screen
CSCRN			EQU	$42			; double usage of adresses
CSCRN2			EQU	$44
HBASL			EQU	$50
PIXEL			EQU	$52
PRNG			EQU	$53
XOLD			EQU	$54
YOLD			EQU	$55
RND2			EQU	$56
RND1			EQU	$57

AY_REGISTERS		EQU $65
A_FINE_TONE			EQU $65
A_COARSE_TONE		EQU $66
B_FINE_TONE			EQU $67
B_COARSE_TONE		EQU $68
C_FINE_TONE			EQU $69
C_COARSE_TONE		EQU $6a
NOISE				EQU $6b
ENABLE				EQU $6c
A_VOLUME			EQU $6d
B_VOLUME			EQU $6e
C_VOLUME			EQU $6f
ENVELOPE_FINE		EQU $70
ENVELOPE_COARSE		EQU $71
ENVELOPE_SHAPE  	EQU $72
COPY_OFFSET			EQU $73
DECODER_STATE		EQU $74

PATTERN_L			EQU $75
PATTERN_H			EQU $76
ORNAMENT_L			EQU $77
ORNAMENT_H			EQU $78
SAMPLE_L			EQU $79
SAMPLE_H			EQU $7a

DONE_PLAYING		EQU $7b
DONE_SONG			EQU $7c
LASTKEY				EQU $7d
TEMP				EQU	$7e

; $80 - $F8 reserved for PT3-decoder intermediate note value storage

*
*
INIT			JSR	DETECTA2		; get machine type
				STA	$C002
				STA	$C004
				STA $C051      		; SWITCH TO TEXT -> show welcome question
          		STA $C052
          		STA $C054
          		JSR	$FB39			; command TEXT
				JSR	HOME			; clear text screen
				LDA	#14				; HTAB 14
				STA	$24
				LDX	#<T_SHACK
				LDY	#>T_SHACK
				JSR	printCHAR
				JSR	LFEED
				JSR	LFEED
				JSR	LFEED
				JSR	LFEED
				JSR	LFEED
				JSR	LFEED
				LDA	#11
				STA	$24
				LDA	#4
				STA	$25
				LDX	#<T_LOAD		
				LDY	#>T_LOAD
				JSR	printCHAR
				JSR	LOADSHACK		; load 8-bit-shack logo
				JSR	LOADLOGO
				LDA	#9
				STA	$24
				LDX	#<T_SELECT	
				LDY	#>T_SELECT
				JSR	printCHAR
				LDA	#$FF
				STA	LIMIT			; unlimited flakes
				JSR	RDKEY			; press a key
				CMP	#$D9			; "Y"?
				BEQ	doLIMIT
				CMP	#$F9
				BNE	noLIMIT
doLIMIT			INC	LIMIT			; limit number of snowflakes		
noLIMIT			STA	$C057			; HIRES page 1 on
				STA	$C054
				STA	$C050
				STA	$C052

				JSR	LOADSONG		; load PT3-Song into memory
		  		JSR	DETECTCPU
		  		JSR	DETECTZIP
		  		JSR	DETECTFC
				JSR	DETECTLC		; can we also detect a language card?
				JSR	MB_DETECT		; get MockingBoard slot
          		JSR	SAVEzp			; save ZP vars into buffer
	
*
* init algorithm
*		
				JSR	SETUP			; init XMAS 2019 algorithm
*
*
*
* loop forever
*
MAIN
				LDA	#180			; set y-offset for lower limit
				STA	YOFF
				JSR	DRAWHILL
				JSR DRAWTREE
				
				LDA	bMB				; check for mockingboard
				BNE	INITMB			; no MockingBoard -> sorry, no sound!
				JMP	noMB0
INITMB			JSR	MOCK_INIT		; init MockingBoard
				JSR SET_HANDLER		; hook up interrupt handler 
				JSR	INIT_ALGO			; init ZP + decoders vars	
				JSR	pt3_init_song		; init all variables needed for the player
				CLI
noMB0			JSR	WLCMTXT
				JSR	TXTOUT			; init text output
				INC	TXTACT
				LDA	#0				; reset XPOSH
				STA	XPOSH
anim	   		JSR	ANIMATE			; do one animation frame of the snowflakes
				;JSR	TXTLOOP
				LDA	SNOWINIT
				BEQ	kpress
				JSR	WAIT
				DEC	SNOWINIT
				BNE	kpress1

kpress			;JSR	CHAROUT			; do not show in the startup phase
kpress1			LDA	KYBD
				BPL	anim
				BIT STROBE
KEYQ      		CMP #$D1       		; KEY 'Q' IS PRESSED
          		BEQ END
KEYP        	CMP	#$D0			; key "P" pressed?
				BNE	anim
				LDA	#0				; restart music
				STA	DONE_PLAYING	; keypress -> restart playing
				LDA	bMB
				BEQ	noMB5
				CLI					; enable interrupt
noMB5    		JMP	anim
*										
END				LDA	STROBE
				SEI
          		LDA	READROM				; language card off
          		JSR	CLEAR_LEFT			; mute MockingBoard
          		JSR	RESTzp				; get back original ZP values
				STA	$C002
				STA	$C004
				STA $C051      	; SWITCH TO TEXT -> end of program
          		STA $C052
          		STA $C054
          		JSR	$FB39				; command TEXT
				JSR	HOME
				JMP	$3d0				; reset
*				
*
* setup algorithm
*
SETUP			LDA STROBE   	; delete keystrobe
*
				;JSR	WLCMTXT		; prepare text output
*				
          		LDA	#$20
          		STA	G_PAGE
        		LDA	$4E				; get seed value
        		STA	RND2
        		LDA	$4F
        		STA	RND1
          		STA	PRNG			; random gen seed value
          		LDA	#254
          		STA	SNOWINIT
*
				LDX	#0
				STX	SNOWCNT
				STX	SNOWCNT+1
				STX	DSPLOGO
				STX	TXTINIT
				STX	TXTWAIT
				STX	STRCOUNT
				LDA	#123			; snowflake seed value
xslp			JSR	RNDGEN			; init snowflakes value
				STA	SNOWX,X
				INX
				BNE	xslp
yslp			JSR	RNDGEN
ycmp			CMP	#120			; check if Y is off limits!
				BGE	yslp			; yes -> get another RND-number
snys			STA	SNOWY,X
sinx			INX
				BNE	yslp								          		
				LDX	#0
				LDA	#255
flglp			STA	SNOWFLAG,X		; set animation flag ($FF = no drawing)
				INX
				BNE flglp
				LDX	#0
				LDA	#2
flglp2			STA	SNOWMOM,X		; set momentum of flake (= 2) for pure vertical movement
				INX
				BNE flglp2
				
*				
*		
HCLR
				LDX #32				; delete HIRES 1
				LDA #00
				TAY
				LDA	#$00
HCLRlp			STA $2000,Y	
				INY
				BNE HCLRlp
				INC HCLRlp+02
				DEX
				BNE HCLRlp	
				LDA	#$20
				STA	HCLRlp+02			
				RTS
;
;
; basic calculation routine
;
;
; animation
;
ANIMATE			LDX	SNOWINIT		; init counter for first snow flake
dlp				LDA	SNOWX,X
				STA	XOLD
				STA	XPOSL
				LDA	SNOWY,X
				STA	YOLD
				STA	YPOS
				TXA
				PHA
				
				INC	YPOS			; check for free pixels
				JSR	FHSCRN
				
				PLA
				TAX
				LDA	RFREE			; prevent snowflakes from falling through coloured areas!
				BEQ	getrnd2			; when the pixels are set like 101 do not move the flake!
				LDA	LFREE
				BNE	incFlag
getrnd2			JSR RANDOM02	; check if movement also to the left!
				BEQ	state0
				CMP	#3
				BEQ	state2		; if 1 move left, else move down
				BNE	state1
				
state0			LDA	RFREE
				BNE	state1
				JMP	mvRIGHT				
state1			LDA	LFREE
				BNE chkLefta
				JMP mvLEFT
chkLefta		LDA	DFREE
				BNE	chkRight
				JMP	mvDOWN

				
state2			LDA	DFREE
				BNE	chkLeft
				JMP mvDOWN
chkLeft			LDA	LFREE
				BNE	chkRight
				JMP mvLEFT
chkRight		LDA	RFREE
				BNE	incFlag
				JMP	mvRIGHT
incFlag			LDA	SNOWMOM,X		; still momentum available?
				BEQ	incFlag2		; nope
				DEC	SNOWMOM,X
				TXA
				PHA
				JSR	FHSCRN2			; check direct left and right neighbour
				PLA
				TAX
				JSR	RANDOM01
				BNE	state3
				LDA	LFREE
				BNE	state2a	
				JMP mvdLEFT			; direct left free -> move there
state2a			LDA	RFREE
				BNE	incFlag2		; direct right free -> move there
				JMP	mvdRIGHT
state3			LDA	RFREE
				BNE state3a
				JMP	mvdRIGHT		; direct left free -> move there
state3a			LDA	LFREE
				BEQ	mvdLEFT			; direct right free -> move there
incFlag2		INC	SNOWFLAG,X		; check if snow flake has settled entirely
				LDA	SNOWFLAG,X
				CMP	#3
				BEQ	resFlag
				JMP	xlp
resFlag			INC	SNOWCNT			; increment snow counter
				BNE	chkLIM
				INC	SNOWCNT+1
				
chkLIM			LDA	LIMIT			; check if number of flakes is limited
				BMI	noInc3
				BEQ	noLimFl		
				TXA
				PHA
				JSR	DELPIXEL
				PLA
				TAX
				JMP	noInc3
noLimFl			LDA	SNOWCNT+1
				CMP #20				; 20 * 256 snowflakes drawn -> activate limit
				BNE	noInc3
				LDA	#1
				STA	LIMIT
noInc3				
				LDA	#0
				STA	SNOWY,X
				STA	SNOWFLAG,X
				LDA	#2
				STA	SNOWMOM,X
				LDA	SNOWX,X
				JSR	RNDGEN
				STA	SNOWX,X
				JMP xlp										
				

mvDOWN			LDA	SNOWX,X
				STA	XPOSL
				JMP	doanim
				
mvLEFT			LDA	SNOWX,X		; check if snow flake is at the left border
				SEC
				SBC	#1
				STA	SNOWX,X
				STA	XPOSL	
				JMP	doanim

mvdLEFT			LDA	SNOWX,X
				SEC
				SBC	#1
				STA	SNOWX,X
				STA	XPOSL	
				DEC	YPOS		; move directly to the left
				JMP	doanim
											
mvRIGHT			LDA	SNOWX,X		; check if snow flake is at the left border
				CLC
				ADC	#1
				STA	SNOWX,X
				STA	XPOSL
				JMP	doanim												
								
mvdRIGHT		LDA	SNOWX,X		; check if snow flake is at the left border
				CLC
				ADC	#1
				STA	SNOWX,X
				STA	XPOSL
				DEC	YPOS												
								
doanim			LDA	YPOS
				STA	SNOWY,X
				LDA	SNOWFLAG,X	; shall we draw the snowflake?
				BMI	xlp			; do not draw snowflakes initially!
				TXA
				PHA
				JSR	SETPIXEL	; delete and redraw
				PLA
				TAX

xlp				INX
				BEQ chkLOGO	
				JMP	dlp

chkLOGO			LDA	DSPLOGO
				BNE	anRTS
				LDA	SNOWCNT+1
				CMP	#8			; when to show the LOGO?
				BNE	anRTS
				LDA	#1
				STA DSPLOGO
				JSR	RESTORE

anRTS			RTS
;
; random number generation
;
; -----------------------------------------------------------------------------
RANDOM01        					; changes Accu
        		LDA 	RND1
        		ASL
        		BCC 	noEor2R1
doEor2R1 		EOR 	#$1D
noEor2R1		STA 	RND1
        		AND 	#%1      	; between 0 and 1
        		RTS

RANDOM02        					; changes Accu
        		LDA 	RND2
        		ASL
        		BCC 	noEor2R2
doEor2R2 		EOR 	#$1D
noEor2R2		STA 	RND2
        		AND 	#%11      	; between 0 and 3
        		RTS

RNDGEN			;LDA	PRNG
				ASL						; input value in A
				BEQ	noEOR1
				BCC	noEOR1
				INC	PRNG
				EOR	PRNG				; pseudo random number generation
noEOR1			BNE	noFIX1				; avoid zero value
				ADC	PRNG
noFIX1			RTS						; return new value in A

; 
; check if pixel is set
;	
FHSCRN     		
          		LDX	YPOS			; ypos of pixel to check
				LDA YLOOKLO,X
          		STA HBASL
          		LDA YLOOKHI,X
          		ORA G_PAGE
          		STA HBASL+1

				LDX XPOSL			; xpos of pixel to check
				DEX					; left position
		   		LDY DIV7LO,X
          		LDA MOD7LO,X
		  		TAX
          		LDA ANDMASK,X
          		AND	#%01111111
          		STA ANDMSK	       		          		
          		LDA (HBASL),Y		; get HIRES-byte
          		AND	ANDMSK			; check if pixel is set
				STA	LFREE			; if 0 pixel is NOT set
				
				LDX XPOSL			; xpos of pixel to check
		   		LDY DIV7LO,X
          		LDA MOD7LO,X
		  		TAX
          		LDA ANDMASK,X
          		AND	#%01111111
          		STA ANDMSK	       		          		
          		LDA (HBASL),Y		; get HIRES-byte
          		AND	ANDMSK			; check if pixel is set
				STA	DFREE			; if 0 pixel is NOT set

				LDX XPOSL			; xpos of pixel to check
				INX					; left position
		   		LDY DIV7LO,X
          		LDA MOD7LO,X
		  		TAX
          		LDA ANDMASK,X
          		AND	#%01111111
          		STA ANDMSK	       		          		
          		LDA (HBASL),Y		; get HIRES-byte
          		AND	ANDMSK			; check if pixel is set
				STA	RFREE			; if 0 pixel is NOT set
				RTS	

FHSCRN2     						; check to the direct left and right of the pixel
          		LDX	YPOS			; ypos of pixel to check
          		DEX
				LDA YLOOKLO,X
          		STA HBASL
          		LDA YLOOKHI,X
          		ORA G_PAGE
          		STA HBASL+1

				LDX XPOSL			; xpos of pixel to check
				DEX					; left position
		   		LDY DIV7LO,X
          		LDA MOD7LO,X
		  		TAX
          		LDA ANDMASK,X
          		AND	#%01111111
          		STA ANDMSK	       		          		
          		LDA (HBASL),Y		; get HIRES-byte
          		AND	ANDMSK			; check if pixel is set
				STA	LFREE			; if 0 pixel is NOT set
				
				LDX XPOSL			; xpos of pixel to check
				INX					; left position
		   		LDY DIV7LO,X
          		LDA MOD7LO,X
		  		TAX
          		LDA ANDMASK,X
          		AND	#%01111111
          		STA ANDMSK	       		          		
          		LDA (HBASL),Y		; get HIRES-byte
          		AND	ANDMSK			; check if pixel is set
				STA	RFREE			; if 0 pixel is NOT set
				RTS	
; 
; delete pixel 
;	
DELPIXEL   		LDX XOLD			; xpos of pixel to check
   				LDY DIV7LO,X
          		LDA MOD7LO,X
		   		TAX
          		LDA ANDMASK,X
          		EOR	#255			; invert mask
          		STA ANDMSK
          		
          		LDX	YOLD			; ypos of pixel to check
				LDA YLOOKLO,X
          		STA HBASL
          		LDA YLOOKHI,X
          		ORA G_PAGE
          		STA HBASL+1
          		
          		LDA (HBASL),Y		; get HIRES-byte
          		AND	ANDMSK			; get pixel mask
				STA	(HBASL),Y		; delete pixel
				RTS	
; 
; 
; delete & set pixel 
;	
SETPIXEL   		LDX XOLD			; xpos of pixel to check
   				LDY DIV7LO,X
          		LDA MOD7LO,X
		   		TAX
          		LDA ANDMASK,X
          		EOR	#255			; invert mask
          		STA ANDMSK
          		
          		LDX	YOLD			; ypos of pixel to check
				LDA YLOOKLO,X
          		STA HBASL
          		LDA YLOOKHI,X
          		ORA G_PAGE
          		STA HBASL+1
          		
          		LDA (HBASL),Y		; get HIRES-byte
          		AND	ANDMSK			; get pixel mask
				STA	(HBASL),Y		; delete pixel

SETONLY  		LDX XPOSL			; xpos of pixel to check
LOTABLL2   		LDY DIV7LO,X
          		LDA MOD7LO,X
GOTTAB3   		TAX
          		LDA ANDMASK,X
          		STA ANDMSK
          		
          		LDX	YPOS			; ypos of pixel to set
				LDA YLOOKLO,X
          		STA HBASL
          		LDA YLOOKHI,X
          		ORA G_PAGE
          		STA HBASL+1
          		
          		LDA (HBASL),Y		; get HIRES-byte
          		ORA	ANDMSK			; get pixel mask
				STA	(HBASL),Y		; set pixel
				RTS	
;
; draw bottom line in white
;
WHITELINE
          		;LDX	YPOS			; ypos of pixel to check
				LDA YLOOKLO,X
          		STA HBASL
          		LDA YLOOKHI,X
          		ORA G_PAGE
          		STA HBASL+1

				LDY	#0
				LDA	#255
wlp				STA	(HBASL),Y
				INY
				CPY	#40
				BNE	wlp				
				RTS
;
; draw Hill
;
DRAWHILL
				LDA	#$20
				STA	$E6
				LDX	#0
				STX	XPOSH
				STX	DRPOS
sm1				INX
hllp			LDA	SINTAB,X
				BPL	gotplus
				SEC
				SBC	#1
				EOR	#$FF
gotplus			LSR
				LSR
				SEC
				SBC	#180
				EOR	#$FF
				STA	YPOS
				;LDA	DRPOS
				;STA	XPOSL
				TXA
				PHA
				ASL
				CLC
				ADC	YPOS ; generate new X
				TAX
				
				LDA	COSTAB,X
				BPL	gotplus2
				SEC
				SBC	#1
				EOR	#$FF
gotplus2		LSR
				LSR
				LSR
				;SEC
				;SBC	#180
				EOR	#$FF
				CLC
				ADC	YPOS
				STA	YPOS
				LDA	DRPOS
				;STA	XPOSL
				CLC	
				ADC #14				; shift 14 pixel to the right for centering
				STA XPOSL
				LDA	#0
				ADC	#0
				STA	XPOSH			; set HI byte for x-coord > 255
				
				LDX	#6
				JSR	HCOLOR			; set HCOLOR=6
				LDX	XPOSL
				LDY	XPOSH
				LDA	YPOS
				JSR	HPOSN
				LDA	XPOSL
				LDX	XPOSH
				LDY	YOFF
				JSR	HLIN
				LDA	DRPOS			; workaround get DRPOS back to XPOSL
				STA	XPOSL
				JSR SETONLY
				INC	DRPOS
				LDA	DRPOS
				CLC	
				ADC #14				; shift 14 pixel to the right for centering
				STA XPOSL
				LDA	#0
				ADC	#0
				STA	XPOSH			; set HI byte for x-coord > 255

				LDX	XPOSL
				LDY	XPOSH
				LDA	YPOS
				JSR	HPOSN
				LDA	XPOSL
				LDX	XPOSH
				LDY	YOFF
				JSR	HLIN
				LDA	DRPOS			; workaround get DRPOS back to XPOSL
				STA	XPOSL
				JSR	SETONLY
				PLA
				TAX
				INX
				INC	DRPOS
				LDA	DRPOS
				BEQ	hillRTS	
				JMP	hllp
hillRTS			RTS
;
; draw trees
;
DRAWTREE
				LDA	#$20
				STA	$E6
				
				LDA	FOREST1			; get number of trees to plot
				STA	NUMTREES
				LDY	#0
forestlp		INY
				LDA FOREST1,Y
				STA	XOFF
				INY
				LDA	FOREST1,Y
				STA YOFF
				TYA
				PHA				
				
				LDX	#1
				JSR	HCOLOR			; set HCOLOR=1
				LDX	#0
				LDA	TREE1,X			; get number of lines of the tree
				STA	NUMLIN	
treelp			INX
				LDA	TREE1,X			; get XMIN
				CLC	
				ADC	XOFF			; add offset
				STA	xlow
				INX
				LDA	TREE1,X			; get XMAX
				CLC	
				ADC	XOFF
				STA	xhigh			; 
				INX
				LDA	YOFF
				SEC
				SBC	TREE1,X			; get YPOS
				STA	ypos
				TXA					; save X-reg
				PHA
				
				LDX	xlow			; draw green line
				LDY	#0
				LDA	ypos
				JSR	HPOSN
				LDA	xhigh
				LDX	#0
				LDY	ypos
				JSR	HLIN
				
				PLA
				TAX
				DEC	NUMLIN
				LDA	NUMLIN
				BNE	treelp

				TXA
				PHA
				LDX	#5
				JSR	HCOLOR			; set HCOLOR=5
				PLA
				TAX
				INX
				LDA	TREE1,X			; get XMIN
				CLC	
				ADC	XOFF			; add offset
				STA	xlow
				INX
				LDA YOFF
				SEC
				SBC	TREE1,X	
				STA	xhigh			; 
				INX
				LDA	YOFF
				SEC
				SBC	TREE1,X			; get YPOS
				STA	ypos
				
				LDX	xlow			; draw orange line
				LDY	#0
				LDA	xhigh
				JSR	HPOSN
				LDA	xlow
				LDX	#0
				LDY	ypos
				JSR	HLIN
				
				PLA
				TAY
				DEC	NUMTREES
				LDA	NUMTREES
				BEQ	treeRTS
				JMP	forestlp
				
treeRTS			RTS
xlow			DFB 1
xhigh			DFB	1
ypos			DFB	1				
	
LOADSONG  	LDA #$8D       			; LOAD songfile INTO MEMORY
          	JSR COUT				; print CTRL-D
			JSR PRINT
          	HEX 84
		   	ASC "BLOAD SONG,A$6400"  ; dummy string -> self-modified
          	HEX 8D00
          	RTS
*
LOADSHACK  	LDA #$8D       			; LOAD songfile INTO MEMORY
          	JSR COUT				; print CTRL-D
			JSR PRINT
          	HEX 84
		   	ASC "BLOAD SHACK,A$2000"  ; dummy string -> self-modified
          	HEX 8D00
          	RTS
*
LOADLOGO  	LDA #$8D       			; LOAD songfile INTO MEMORY
          	JSR COUT				; print CTRL-D
			JSR PRINT
          	HEX 84
		   	ASC "BLOAD LOGO,A$8000"  ; dummy string -> self-modified
          	HEX 8D00
          	RTS
*
PRINT     	PLA
          	STA PTR
          	PLA
          	STA PTR+1
          	LDY #$01
P0        	LDA (PTR),Y
          	BEQ PFIN
          	JSR COUT
          	INY
          	BNE P0
*
PFIN      	CLC
          	TYA
          	ADC PTR
         	STA PTR
          	LDA PTR+1
          	ADC #$00
          	PHA
          	LDA PTR
          	PHA
PEXIT     	RTS
*
;
; Save initial zero page 
;
SAVEzp			LDX	#0
zplp1			LDA	$0,X					; get ZP value
				STA	ZP_SAVE,X				; store it into save buffer
				INX
				BNE	zplp1
				RTS
				
;
; Restore initial zero page 
;
RESTzp			LDX	#0
zplp2			LDA	ZP_SAVE,X				; get buffer value
				STA	$0,X					; store it back into zero page
				INX
				BNE	zplp2
				RTS
				
;
; restore logo
;
RESTORE
				LDA	#<DUMP			; set pointer for dump space
				STA	PTR
				LDA	#>DUMP
				STA	PTR+1
				
				LDX	YFROM

ylp2			LDA YLOOKLO,X		; get base adress
          		STA HBASL
          		LDA YLOOKHI,X
          		ORA #$20
          		STA HBASL+1
						
				LDY	XFROM
xlp2			LDA	(PTR)
				STA	(HBASL),Y		; save byte
				INC	PTR				; increment adress
				BNE	noInc2
				INC	PTR+1	

noInc2			INY
				CPY	XTO				; limit reached?
				BLT	xlp2
				INX
				CPX	YTO
				BLT	ylp2				
								
				RTS
				
;
; subroutines
;
				PUT mbdetect.s
				PUT ihandler.s
				PUT pt3lib.s
				PUT	text3d.s			; text output routines
;
; text strings
;
		
NUMSTRS			EQU	#8				; number of strings to display
STRADR	
				DFB #<STR1,#>STR1,#<STR2,#>STR2,#<STR3,#>STR3
				DFB #<STR4,#>STR4,#<STR5,#>STR5,#<STR6,#>STR6
				DFB #<STR7,#>STR7,#<STR8,#>STR8
STR1
		HEX	03B6	; x,y
		ASC 'Welcome to the XMAS-Demo 2019...' 
		HEX	FF
STR2
		HEX	03B6
		ASC	'for the Apple ][ by 8-Bit-Shack!'
		HEX	FF
STR5
		HEX	04B6
		ASC	'Special thx to Dr. N. H. Cham!'
		HEX	FF
STR3
		HEX	08B6
		ASC	'Code & Gfx: SingleMalt'
		HEX	FF
STR4
		HEX	0AB6
		ASC	'Music: Cj Splinter'
		HEX	FF
STR6
		HEX	02B6
		ASC	'Greetings: BrutalDeluxe, Deater...'
		HEX	FF
STR7
		HEX	06B6
		ASC	'French Touch, Jackasser... '
		HEX	FF
STR8
		HEX	01B6
		ASC	'Visit www.golombeck.eu for more info!'
		HEX	FF
;digarok, fenarinarsa

*
* math tables
*
*
* AND mask for the 7 pixel positions, high bit set
* for the color shift.
;ANDMASK   DFB $81,$82,$84,$88,$90,$a0,$c0
ANDMASK   DFB $01,$02,$04,$08,$10,$20,$40

          	DS 	\

*
* Hi-res Y lookup, low part (192 bytes).
*
YLOOKLO   		HEX 0000000000000000
          		HEX 8080808080808080
                HEX   0000000000000000
                HEX   8080808080808080
                HEX   0000000000000000
                HEX   8080808080808080
                  HEX   0000000000000000
                  HEX   8080808080808080
                  HEX   2828282828282828
                  HEX   a8a8a8a8a8a8a8a8
                  HEX   2828282828282828
                  HEX   a8a8a8a8a8a8a8a8
                  HEX   2828282828282828
                  HEX   a8a8a8a8a8a8a8a8
                  HEX   2828282828282828
                  HEX   a8a8a8a8a8a8a8a8
                  HEX   5050505050505050
                  HEX   d0d0d0d0d0d0d0d0
                  HEX   5050505050505050
                  HEX   d0d0d0d0d0d0d0d0
                  HEX   5050505050505050
                  HEX   d0d0d0d0d0d0d0d0
                  HEX   5050505050505050
                  HEX   d0d0d0d0d0d0d0d0

          	DS 	\
*                  
* Hi-res Y lookup, high part (192 bytes).
* OR with $20 or $40.
YLOOKHI   HEX 0004080c1014181c
                  HEX   0004080c1014181c
                  HEX   0105090d1115191d
                  HEX   0105090d1115191d
                  HEX   02060a0e12161a1e
                  HEX   02060a0e12161a1e
                  HEX   03070b0f13171b1f
                  HEX   03070b0f13171b1f
                  HEX   0004080c1014181c
                  HEX   0004080c1014181c
                  HEX   0105090d1115191d
                  HEX   0105090d1115191d
                  HEX   02060a0e12161a1e
                  HEX   02060a0e12161a1e
                  HEX   03070b0f13171b1f
                  HEX   03070b0f13171b1f
                  HEX   0004080c1014181c
                  HEX   0004080c1014181c
                  HEX   0105090d1115191d
                  HEX   0105090d1115191d
                  HEX   02060a0e12161a1e
                  HEX   02060a0e12161a1e
                  HEX   03070b0f13171b1f
                  HEX   03070b0f13171b1f

*                  
DIV7HI    HEX   2424242525252525
                  HEX   2525262626262626
                  HEX   2627272727272727
MOD7HI    HEX   0405060001020304
                  HEX   0506000102030405
                  HEX   0600010203040506
          	DS 	\
DIV7LO    		  ;HEX 	0000000000000001
                  ;HEX   010101010101
                  HEX	0202				; shift 2 bytes = 14 pixels to the right
                  HEX   0202020202030303
                  HEX   0303030304040404
                  HEX   0404040505050505
                  HEX   0505060606060606
                  HEX   0607070707070707
                  HEX   0808080808080809
                  HEX   0909090909090a0a
                  HEX   0a0a0a0a0a0b0b0b
                  HEX   0b0b0b0b0c0c0c0c
                  HEX   0c0c0c0d0d0d0d0d
                  HEX   0d0d0e0e0e0e0e0e
                  HEX   0e0f0f0f0f0f0f0f
                  HEX   1010101010101011
                  HEX   1111111111111212
                  HEX   1212121212131313
                  HEX   1313131314141414
                  HEX   1414141515151515
                  HEX   1515161616161616
                  HEX   1617171717171717
                  HEX   1818181818181819
                  HEX   1919191919191a1a
                  HEX   1a1a1a1a1a1b1b1b
                  HEX   1b1b1b1b1c1c1c1c
                  HEX   1c1c1c1d1d1d1d1d
                  HEX   1d1d1e1e1e1e1e1e
                  HEX   1e1f1f1f1f1f1f1f
                  HEX   2020202020202021
                  HEX   2121212121212222
                  HEX   2222222222232323
                  HEX   2323232324242424
                  HEX   2424242525252525
				  HEX	2525262626262626
				  HEX	262626262626
* ORG $8700
          
MOD7LO    HEX 0001020304050600
                  HEX   0102030405060001
                  HEX   0203040506000102
                  HEX   0304050600010203
                  HEX   0405060001020304
                  HEX   0506000102030405
                  HEX   0600010203040506
                  HEX   0001020304050600
                  HEX   0102030405060001
                  HEX   0203040506000102
                  HEX   0304050600010203
                  HEX   0405060001020304
                  HEX   0506000102030405
                  HEX   0600010203040506
                  HEX   0001020304050600
                  HEX   0102030405060001
                  HEX   0203040506000102
                  HEX   0304050600010203
                  HEX   0405060001020304
                  HEX   0506000102030405
                  HEX   0600010203040506
                  HEX   0001020304050600
                  HEX   0102030405060001
                  HEX   0203040506000102
                  HEX   0304050600010203
                  HEX   0405060001020304
                  HEX   0506000102030405
                  HEX   0600010203040506
                  HEX   0001020304050600
                  HEX   0102030405060001
                  HEX   0203040506000102
                  HEX   0304050600010203
*
*
* SINETABLE
*
				;DS \
SINTAB	HEX FF0306090C0F1215
			HEX 181B1E2124272A2D
			HEX 303336393B3E4143
			HEX 46494B4E50525557
			HEX 595B5E6062646667
			HEX 696B6C6E70717274
			HEX 75767778797A7B7B
			HEX 7C7D7D7E7E7E7E7E
COSTAB	HEX 7E7E7E7E7E7E7D7D
			HEX 7C7B7B7A79787776
			HEX 75747271706E6C6B
			HEX 6967666462605E5B
			HEX 59575552504E4B49
			HEX 4643413E3B393633
			HEX 302D2A2724211E1B
			HEX 1815120F0C090603
			HEX FFFCF9F6F3F0EDEA
			HEX E7E4E1DEDBD8D5D2
			HEX CFCCC9C6C4C1BEBC
			HEX B9B6B4B1AFADAAA8
			HEX A6A4A19F9D9B9998
			HEX 969493918F8E8D8B
			HEX 8A89888786858484
			HEX 8382828181818181
			HEX 8181818181818282
			HEX 8384848586878889
			HEX 8A8B8D8E8F919394
			HEX 9698999B9D9FA1A4
			HEX A6A8AAADAFB1B4B6
			HEX B9BCBEC1C4C6C9CC
			HEX CFD2D5D8DBDEE1E4
			HEX E7EAEDF0F3F6F9FC
			HEX 000306090C0F1215
			HEX 181B1E2124272A2D
			HEX 303336393B3E4143
			HEX 46494B4E50525557
			HEX 595B5E6062646667
			HEX 696B6C6E70717274
			HEX 75767778797A7B7B
			HEX 7C7D7D7E7E7E7E7E
			HEX 7E7E7E7E7E7E7D7D
			HEX 7C7B7B7A79787776
			HEX 75747271706E6C6B
			HEX 6967666462605E5B
			HEX 59575552504E4B49
			HEX FF
*
* tree definition data
*
TREE1		HEX	0E					; 10 lines of green
			HEX 000004				; trunk of the tree in orange
			HEX	FA0605
			HEX	FA0606
			HEX	FB0507				; xleft, xright, YPOS
			HEX	FB0508				; xleft, xright, YPOS
			HEX	FC0409
			HEX	FC040A
			HEX	FD030B
			HEX	FD030C
			HEX	FE020D
			HEX	FE020E
			HEX	FF010F
			HEX	FF0110
			HEX	000011
			HEX 000004				; trunk of the tree in orange

FOREST1		DFB	8					; number of trees in the forest
			DFB	105,134				; xoffset, yoffset of the tree
			DFB	121,133
			DFB	133,132
			DFB	147,135
			DFB	161,139
			DFB	179,148
			DFB	197,147
			DFB	79,145

T_SHACK		ASC "8-Bit-Shack"
			HEX	00
T_SELECT	ASC	"Limit snowflakes (Y/N)? "
			HEX	00		
T_LOAD		ASC	"Loading demo data..."
			HEX	00		
T_OPT1		ASC	"Options:"
			HEX	00
T_OPT2		ASC	"<P>: Pause/Resume Music"
			HEX	00
T_OPT3		ASC	"<Q>: Quit XMAS-Demo"
			HEX	00
								
			DS	\
;
; standard FONT to display text in the 3D-Engine
;
FONTTAB 
 HEX 000000000000000038383838003800003636241200000000
 HEX 80247E247E248000083E023E203E08004225120824522100
 HEX 0C1602042A122C001818100800000000381C0E0E0E1C3800
 HEX 0E1C3838381C0E00221C361C220000000008083E08080000
 HEX 00000000181810080000007E7E0000000000000018180000
 HEX 6070381C0E0600001E333B3F37331E000C0E0F0C0C0C3F00
 HEX 1E3330180C063F001E33301C30331E00383C36333F303000
 HEX 3F03031F30331E001C06031F33331E003F33180C0C0C0C00
 HEX 1E33331E33331E001E33333E30180C000018180018180000
 HEX 001818001818100810181C1E1C18100000007E007E000000
 HEX 040C1C3C1C0C04003C7E6230180018009088B6FFFFFFBEB6
 HEX 1E33333F333333001F33331F33331F001E33030303331E00
 HEX 0F1B3333331B0F001E33031F03331E001E33031F03030300
 HEX 1E33033B33331E003333333F333333003F0C0C0C0C0C3F00
 HEX 3030303033331E00331B0F070F1B33000303030303033F00
 HEX 333F3333333333003333373B333333001E33333333331E00
 HEX 1F33331F030303001E3333373B331E001F33331F0F1B3300
 HEX 1E33031E30331E003F0C0C0C0C0C0C003333333333331E00
 HEX 33333333331E0C0033333333333F330033331E0C1E333300
 HEX 3333331E0C0C0C003F30180C06033F001E1E06061E1E0000
 HEX 060E1C38706000007878606078780000081C3E7F00000000
 HEX 0000000000007F00181808100000000000001E303E333E00
 HEX 03031F3333331F0000001E3303331E0030303E3333333E00
 HEX 00001E333F031E001C36061F0606060000001E33333E301E
 HEX 03031F33333333000C000C0C0C0C0C00300030303030331E
 HEX 0303331B0F1B33000C0C0C0C0C0C0C0000003E6B6B636300
 HEX 00001E333333330000001E3333331E0000001E33331F0303
 HEX 00001E33333E303000001E330303030000003E031E301F00
 HEX 06061F0606361C000000333333331E0000003333331E0C00
 HEX 000063636B6B3E000000331E0C1E330000003333333E301E
 HEX 00003F180C063F00F098989C9898F0801818181818181818
 HEX 0E18183818180E0000000000000000000000000000000000

* EOF
*          	


