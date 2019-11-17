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
VTAB			EQU	$FC22		; VTAB sets vertical cursor position
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
TAB3			EQU	$0F00		; HIRES shift table
TAB4			EQU	$1000		; HIRES shift table
TAB1			EQU	$1100		; HIRES shift table
TAB2			EQU	$1200		; HIRES shift table
;
; sled data area
;
SLED2			EQU	$1300
SLED3			EQU	$139A
SLED4			EQU	$1434
SLED5			EQU	$14CE
SLED6			EQU	$1568
SLED7			EQU	$1602
SLED1A			EQU	$169C
SLED2A			EQU	$1736
SLED3A			EQU	$17D0
SLED4A			EQU	$186A
SLED5A			EQU	$1904
SLED6A			EQU	$199E
SLED7A			EQU	$1A38		; ends $1AD1

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
SLEDCNT			EQU	$325		; counter for sled image being processed
YSLED			EQU	$326		; y pos of sled
XSLED			EQU	$327		; x pos of sled
SLEDFROM		EQU	$328		; draw sled from byte
SLEDTO			EQU	$329		; draw sled to byte
SLEDSTATE		EQU	$330		; state machine index for sled animation
SLEDACT			EQU	$331		; is sled active?
INBYTE			EQU	$332		; HIRES flip in byte
OUTBYTE			EQU	$333		; HIRES flip out byte
SLEDDIR			EQU	$334		; flying direction of sled
WAITVAL			EQU	$335		; slows done text output
HTAB			EQU	$336
VTAB2			EQU	$337
OUTCHAR			EQU	$338
HTAB2			EQU	$339
OUTCHAR2		EQU	$33A

TOUTSCR				EQU	$350			; text output on which HIRES screens? 1, 2 or both?
PT3_LOC 			EQU	$7100			; address of PT3-file 
DUMP				EQU	$8900			; logo save space
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
PSLED1			EQU	$23			; pointer to sled data
PSLED2			EQU	$25

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
* init algorithm
*		
INIT			JSR	DETECTA2			; get machine type
				LDA	#50
				STA	WAITVAL

				JSR	STARTTEXT
				STA	$C057				; HIRES page 1 on
				STA	$C054
				STA	$C050
				STA	$C052

				JSR	LOADSONG			; load PT3-Song into memory
		  		JSR	DETECTCPU
		  		JSR	DETECTZIP
		  		JSR	DETECTFC
				JSR	DETECTLC			; can we also detect a language card?
				JSR	MB_DETECT			; get MockingBoard slot
          		JSR	SAVEzp				; save ZP vars into buffer
				JSR	SETUP				; setup XMAS 2019 vars and bitmaps
*
*
*
* loop forever
*
MAIN
				LDA	#180				; set y-offset for lower limit
				STA	YOFF
				JSR	DRAWHILL			; draw landscape
				JSR DRAWTREE
				
				LDA	bMB					; check for mockingboard
				BNE	INITMB				; no MockingBoard -> sorry, no sound!
				JMP	noMB0				; and no scroll text!
INITMB			JSR	MOCK_INIT			; init MockingBoard
				JSR SET_HANDLER			; hook up interrupt handler 
				JSR	INIT_ALGO			; init ZP + decoders vars	
				JSR	pt3_init_song		; init all variables needed for the player
				CLI						; music
noMB0				
				LDA	#255
				JSR	WAIT
				LDA	#255
				JSR	WAIT
				JSR	WLCMTXT
				JSR	TXTOUT				; init text output
				INC	TXTACT
				LDA	#0					; reset XPOSH
				STA	XPOSH
anim	   		JSR	ANIMATE				; do one animation frame of the snowflakes
initSNOW		LDA	SNOWINIT
				BEQ	kpress
				JSR	WAIT
				DEC	SNOWINIT
				BNE	kpress1

kpress			
kpress1			LDA	KYBD
				BPL	anim
				BIT STROBE
KEYQ      		CMP #$D1       			; KEY 'Q' IS PRESSED
          		BEQ END
KEYP        	CMP	#$D0				; key "P" pressed?
				BNE	KEYS
				LDA	#0					; restart music
				STA	DONE_PLAYING		; keypress -> restart playing
				LDA	bMB
				BEQ	noMB5
				CLI						; enable interrupt
noMB5    		JMP	anim
KEYS			CMP	#$D3				; key 's' is pressed
				BNE	anim				
				LDA	SLEDACT
				BNE stopSLED
				INC SLEDACT
				LDA	DSPLOGO				; logo is active plot the sled at 98
				BNE	plot98
				JSR	SETYSLED
				JMP	anim			
plot98			LDA	#98
				STA	YSLED
				JMP anim
stopSLED		DEC	SLEDACT								
cont1			JMP	anim
*										
END				LDA	STROBE
				STA	$C002
				STA	$C004
				STA $C051      			; SWITCH TO TEXT -> end of program
          		STA $C052
          		STA $C054
          		JSR	$FB39				; command TEXT
				JSR	TCLR
				LDA	#150
				STA	WAITVAL
				JSR	ENDTEXT			
kpress2			LDA	KYBD
				BPL	kpress2
				BIT	STROBE
				JSR	ENDSCROLL
				LDA	#$20
				STA	tByte+1
				JSR	VBLwait
				JSR	TCLR
				LDA	#240
				JSR	WAIT
				LDA	#$A0
				STA	tByte+1
				JSR	VBLwait
				JSR	TCLR
				SEI
          		;LDA	READROM				; language card off
          		JSR	CLEAR_LEFT			; mute MockingBoard
          		JSR	RESTzp				; get back original ZP values
          		LDA	#22
          		STA	$25
          		JSR	VTAB
          		LDA	STROBE
				JMP	$3d0				; exit to DOS

;
; wait for VBLANK
;
VBLwait
_L1				CMP VERTBLANK      	; works with IIGS/IIE      
          		BPL _L1	        	; wait until the end of the vertical blank
                                                
_L2       		CMP VERTBLANK  		; synchronizing counting algorithm      
         		BMI _L2            	; wait until the end of the complete display -> start of vertical blanking
				RTS
;
; flip HIRES byte
;
FLIPBYTE
				LDA	#0
				STA	OUTBYTE				; reset out byte
				LDA	#%00000001			; check for bit 0
				BIT	INBYTE
				BEQ	chkbit2
				LDA	OUTBYTE
				ORA	#%01000000
				STA	OUTBYTE		
chkbit2			LDA	#%00000010			; check for bit 0
				BIT	INBYTE
				BEQ	chkbit3
				LDA	OUTBYTE
				ORA	#%00100000
				STA	OUTBYTE		
chkbit3			LDA	#%00000100			; check for bit 0
				BIT	INBYTE
				BEQ	chkbit4
				LDA	OUTBYTE
				ORA	#%00010000
				STA	OUTBYTE		
chkbit4			LDA	#%00001000			; check for bit 0
				BIT	INBYTE
				BEQ	chkbit5
				LDA	OUTBYTE
				ORA	#%00001000
				STA	OUTBYTE		
chkbit5			LDA	#%00010000			; check for bit 0
				BIT	INBYTE
				BEQ	chkbit6
				LDA	OUTBYTE
				ORA	#%00000100
				STA	OUTBYTE		
chkbit6			LDA	#%00100000			; check for bit 0
				BIT	INBYTE
				BEQ	chkbit7
				LDA	OUTBYTE
				ORA	#%00000010
				STA	OUTBYTE		
chkbit7			LDA	#%01000000			; check for bit 0
				BIT	INBYTE
				BEQ	chkbite
				LDA	OUTBYTE
				ORA	#%00000001
				STA	OUTBYTE		
chkbite			RTS
				
				
				

*				
*
* setup algorithm
*
SETUP			LDA STROBE   	; delete keystrobe
*
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
				STX	WAITVAL
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
				;LDA	#$20
				;STA	HCLRlp+02		

* setup lookup-tables for fast shift
* table 1: 2 x LSR of a byte
nostrip
				LDX	#0
lpLUT1			TXA
				LSR
				LSR
				STA	TAB1,X
				INX
				BNE	lpLUT1
						
* table 2: 4 x ROR & AND #%01100000 of a byte
* making the OR-mask for the shifted two bits

				LDX	#0
lpLUT2			TXA
				ROR						; shift them in order to fit in the former byte
				ROR
				ROR
				ROR
				AND	#%01100000			; get only the first two bits
				STA	TAB2,X
				INX
				BNE	lpLUT2

* table 3: 2 x ASL of a byte

				LDX	#0					; HIRES byte shift tables 
lpLUT3			TXA						; shift two pixels to the right
				ASL
				ASL
				AND	#%01111111			; strip-off HI-bit
				STA	TAB3,X
				INX
				BNE	lpLUT3
						
* table 4: 4 x ROL & AND #%00000011 of a byte
* making the OR-mask for the shifted two bits

				LDX	#0
lpLUT4			TXA
				ROL						; shift them in order to fit in the former byte
				ROL
				ROL
				ROL
				AND	#%00000011			; get only the first two bits
				STA	TAB4,X
				INX
				BNE	lpLUT4
;
; setup sled animation frames
;
; shift right
;
				LDA	#0
				STA	SLEDCNT
sl3lp			LDA	SLEDCNT
				ASL
				TAX
				LDA	SLEDADR,X
				STA	PSLED1
				INX
				LDA	SLEDADR,X
				STA	PSLED1+1
				INX
				LDA	SLEDADR,X
				STA	PSLED2
				INX
				LDA	SLEDADR,X
				STA	PSLED2+1
				
				LDA	#152
				STA	YIND
				
sl2lp			LDY	YIND				; outer loop
				TYA
				SEC
				SBC	#8					; next row of 9 bytes
				STA	YIND				; set new offset 
sl1lp			DEY
				LDA	(PSLED1),Y
				TAX
				LDA	TAB4,X
				PHA
				INY
				LDA	(PSLED1),Y
				TAX
				PLA
				ORA	TAB3,X
				BEQ	noHI1				; do not set HI bit in empty bytes
				ORA	#%10000000			; set hi bit
noHI1			STA	(PSLED2),Y
				DEY
				BEQ	lpex1
				CPY	YIND
				BGE sl1lp
lpex1			LDY	YIND				; special treatment first byte
				LDA	(PSLED1),Y
				TAX
				LDA	TAB3,X
				STA	(PSLED2),Y
lpex2			LDA	YIND
				BEQ	yindrts
				DEC	YIND
				JMP sl2lp
										
yindrts			INC	SLEDCNT				; all copies done?
				LDA	SLEDCNT
				CMP	NUMSLED
				BNE sl3lp

;
; shift left
;
				JSR	INVERTSLED
				LDA	#0
				STA	SLEDCNT
sl3lpa			LDA	SLEDCNT
				ASL
				TAX
				LDA	SLEDADR2,X
				STA	PSLED1
				INX
				LDA	SLEDADR2,X
				STA	PSLED1+1
				INX
				LDA	SLEDADR2,X
				STA	PSLED2
				INX
				LDA	SLEDADR2,X
				STA	PSLED2+1
				
				LDA	#153
				STA	YIND
				
sl2lpa			LDY	YIND				; outer loop
				TYA
				SEC
				SBC	#9					; next row of 9 bytes
				STA	YIND				; set new offset 
				DEY
sl1lpa			LDA	(PSLED1),Y
				AND	#%01111111
				TAX
				LDA	TAB1,X
				PHA
				INY
				LDA	(PSLED1),Y
				AND	#%01111111
				DEY
				TAX
				PLA
				ORA	TAB2,X
				BEQ	noHI2				; do not set HI bit in empty bytes
				ORA	#%10000000			; set hi bit
noHI2			STA	(PSLED2),Y
				DEY
				CPY	#$FF
				BEQ	lpex1a
				CPY	YIND
				BEQ	sl1lpa
				BGE sl1lpa
lpex1a			LDA	YIND
				BEQ	yindrtsa
				JMP sl2lpa
										
yindrtsa		INC	SLEDCNT				; all copies done?
				LDA	SLEDCNT
				CMP	NUMSLED
				BNE sl3lpa
				
				LDA	#7					; re-init sled counter
				STA	SLEDCNT
				LDA	#98
				STA	YSLED
				LDA	#5
				STA	XSLED
				LDA	#0
				STA	SLEDFROM
				STA	SLEDSTATE
				STA	SLEDDIR				; first round to the right
				LDA	#161
				STA	SLEDACT
				LDA	#8
				STA	SLEDTO
				LDA	#>SLEDADR			; set the bitmap adress in draw routine
				STA	slaHI+2
				STA	slaLO+2
				LDA	#<SLEDADR
				STA	slaLO+1
				STA	slaHI+1
				RTS
YIND			DS	1				; y-index	

;
; invert sled
;
INVERTSLED
				
				LDA	#152
				STA	YIND
				
in2lp			LDY	YIND				; outer loop
				TYA
				SEC
				SBC	#8					; next row of 9 bytes
				STA	YIND				; set new offset 
				STA	YIND2
in1lp			LDA	SLED1,Y
				STA	INBYTE				; store byte to flip
				JSR	FLIPBYTE
				TYA
				PHA
				LDY	YIND2				; use the inverted index
				LDA	OUTBYTE
				ORA	#%10000000			; set HI bit
				STA	SLED1A,Y			; to store the new byte
				PLA
				TAY
				DEY
				CPY	#$FF
				BEQ	yinvrts
				INC	YIND2
				CLC
				CPY	YIND
				BGE in1lp
inlpex2			LDA	YIND
				BEQ	yinvrts
				DEC	YIND
				JMP in2lp
yinvrts			RTS
				
YIND2			DS	1					; second index
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

xlp				TXA
				PHA
				AND #%00111111
				CMP	#%00111111
				BNE	xlp1
				LDA	SLEDACT
				BEQ	xlp1
				LDA	SNOWINIT		; do not show sled in init phase
				BNE	xlp1
				LDA	SLEDDIR
				BEQ	dirlft
dirrght			JSR	SLEDANIM
				JMP	xlp1				
dirlft			JSR	SLEDANIM2
				
xlp1			PLA
				TAX
				INX
				BEQ chkLOGO	
				JMP	dlp

chkLOGO			LDA	SLEDACT
				BNE	anRTS
				LDA	DSPLOGO
				BNE	anRTS
				LDA	SNOWCNT+1
				CMP	#6			; when to show the LOGO?
				BNE	anRTS
				LDA	#1
				STA DSPLOGO
				JSR	RESTORE

anRTS			LDA	SLEDACT		; trigger sled
				BNE	anRTS2
				LDA	SNOWCNT
				AND	#%00111111
				CMP	#%00111111
				BNE	anRTS2
				INC	SLEDACT
				LDA	DSPLOGO			; logo is active plot the sled at 98
				BNE	plot98b
				JSR	SETYSLED
				RTS			
plot98b			LDA	#98
				STA	YSLED
anRTS2			RTS
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

SETYSLED
setylp			JSR	RNDGEN			; get a random y-position for the sled
				CMP	#80				; check if Y is off limits!
				BGE	setylp			; yes -> get another RND-number
				CLC
				ADC	#20
				STA	YSLED
				RTS

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
; sled animation from left to right
;
; SLEDCNT:  0..6 -> 7 sled states in two bytes
; YSLED:    ypos of sled
; XSLED:    xpos (0..39) byte number
; SLEDFROM: draw sled from byte (0..7)
; SLEDTO:   draw sled to byte (1..8) interpret -1
SLEDANIM
				LDA	SLEDSTATE
				CMP	#7
				BLT	step1
				CMP	#14
				BLT	step2
				CMP	#21
				BLT	js3
				CMP	#28
				BLT	js4
				BEQ	js5a
				CMP	#133
				BLT	js5
				CMP	#140
				BLT	js6
				BEQ	js7a
				CMP	#147
				BLT	js7
				BEQ	js8a
				CMP	#154
				BLT	js8
				BEQ	js9a
				CMP	#161
				BLT	js9
				LDA	#161
				STA	SLEDSTATE
				LDA	#0
				STA	SLEDCNT
				STA	SLEDACT			; deactivate sled after one round
				STA	SLEDDIR			; next fly to the left
				LDA	#>SLEDADR2			; set the bitmap adress in draw routine
				STA	slaHI+2
				STA	slaLO+2
				LDA	#<SLEDADR2
				STA	slaLO+1
				STA	slaHI+1
				RTS
				
js3				JMP	step3
js4				JMP	step4
js5a			JMP	step5a	
js5				JMP	step5
js6a			JMP	step6a	
js6				JMP	step6			
js7a			JMP	step7a	
js7				JMP	step7			
js8a			JMP	step8a	
js8				JMP	step8			
js9a			JMP	step9a	
js9				JMP	step9			
step1			LDA	#7
				STA	SLEDFROM
				LDA	#9
				STA	SLEDTO
				LDA	#1
				STA	XSLED
				JSR	SLEDCTRL
				INC	SLEDSTATE
				RTS
				
step2			LDA	#5
				STA	SLEDFROM
				JSR SLEDCTRL
				INC	SLEDSTATE
				RTS
				
step3			LDA	#3
				STA	SLEDFROM
				JSR SLEDCTRL
				INC	SLEDSTATE
				RTS
				
step4			LDA	#1
				STA	SLEDFROM
				JSR SLEDCTRL
				INC	SLEDSTATE
				RTS

step5a			INC	XSLED
step5			LDA	#0
				STA	SLEDFROM
				JSR SLEDCTRL
				LDA	SLEDCNT
				BNE step5rts
				INC	XSLED		
				INC	XSLED		
step5rts		INC	SLEDSTATE
				RTS				
				
step6a			INC XSLED
step6			LDA	#7
				STA	SLEDTO
				JSR	SLEDCTRL
				INC	SLEDSTATE
				RTS
				
step7a			INC XSLED
				INC	XSLED
step7			LDA	#5
				STA	SLEDTO
				JSR	SLEDCTRL
				INC	SLEDSTATE
				RTS
				
step8a			INC XSLED
				INC	XSLED
step8			LDA	#3
				STA	SLEDTO
				JSR	SLEDCTRL
				INC	SLEDSTATE
				RTS

step9a			INC XSLED
				INC	XSLED
step9			LDA	#1
				STA	SLEDTO
				JSR	SLEDCTRL
				INC	SLEDSTATE
				RTS

SLEDCTRL		JSR	DRAWSLED		; internal animation loop
				INC	SLEDCNT
				LDA	SLEDCNT
				CMP	#7
				BNE	slanrts
				LDA	#0
				STA	SLEDCNT
slanrts			RTS		

;
; move sled from right to left 
;
SLEDANIM2
				LDA	SLEDSTATE
				CMP	#154
				BEQ	step2ba
				BGE	step1b
				CMP	#147
				BEQ	js3ba
				BGE	js2b
				CMP	#140
				BEQ	js5ba
				BGE	js3b
				CMP	#35
				BEQ	js6ba
				BGE	js5b
				CMP	#29
				BGE	js6b
				CMP	#22
				BGE	js7b
				CMP	#15
				BGE	js8b
				CMP	#8
				BGE	js9b
e1				LDA	#0
				STA	SLEDSTATE
				LDA	#0
				STA	SLEDCNT
				STA	SLEDACT			; deactivate sled after one round
				INC	SLEDDIR			; fly to the right
				LDA	#>SLEDADR			; set the bitmap adress in draw routine
				STA	slaHI+2
				STA	slaLO+2
				LDA	#<SLEDADR
				STA	slaLO+1
				STA	slaHI+1
				RTS

js2b			JMP	step2b
js3ba			JMP	step3ba		
js3b			JMP	step3b		
js4b			JMP	step4b
js5ba			JMP	step5ba
js5b			JMP	step5b
js6ba			JMP	step6ba	
js6b			JMP	step6b			
js7b			JMP	step7b			
js8b			JMP	step8b			
js9b			JMP	step9b			
step1b			LDA	#0
				STA	SLEDFROM
				LDA	#3
				STA	SLEDTO
				LDA	#36
				STA	XSLED
				JSR	SLEDCTRL2
				DEC	SLEDSTATE
				RTS
				
step2ba			DEC	XSLED
				DEC	XSLED
step2b			LDA	#5
				STA	SLEDTO
				JSR SLEDCTRL2
				DEC	SLEDSTATE
				RTS
				
step3ba			DEC	XSLED
				DEC	XSLED
step3b			LDA	#7
				STA	SLEDTO
				JSR SLEDCTRL2
				DEC	SLEDSTATE
				RTS
				
step4b			LDA	#8
				STA	SLEDTO
				JSR SLEDCTRL2
				DEC	SLEDSTATE
				RTS

step5ba			DEC	XSLED
				DEC	XSLED
step5b			LDA	#9
				STA	SLEDTO
				JSR SLEDCTRL2
				LDA	SLEDCNT
				BNE step5brts
				DEC	XSLED		
				DEC	XSLED		
step5brts		DEC	SLEDSTATE
				RTS				
				
step6ba			INC XSLED
				INC XSLED
step6b			LDA	#2
				STA	SLEDFROM
				JSR	SLEDCTRL2
				DEC	SLEDSTATE
				RTS
				
step7b			LDA	#4
				STA	SLEDFROM
				JSR	SLEDCTRL2
				DEC	SLEDSTATE
				RTS
				
step8b			LDA	#6
				STA	SLEDFROM
				JSR	SLEDCTRL2
				DEC	SLEDSTATE
				RTS

step9b			LDA	#8
				STA	SLEDFROM
				JSR	SLEDCTRL2
				DEC	SLEDSTATE
				RTS

SLEDCTRL2		JSR	DRAWSLED		; internal animation loop
				INC	SLEDCNT
				LDA	SLEDCNT
				CMP	#7
				BNE	slanbrts
				LDA	#0
				STA	SLEDCNT
slanbrts		RTS		
				
;
; draw sled on HIRES screen
;
DRAWSLED
				LDA	SLEDCNT
				ASL
				TAX
slaHI			LDA	SLEDADR2,X			; self-modify adress
				STA	psl1+1
				INX
slaLO			LDA	SLEDADR2,X			; self-modify adress
				STA	psl1+2
				
				LDA	YSLED
				STA	SLEDYCT
				TAX
				CLC
				ADC	#17
				STA	SLEDALL				; get end Y-line
				LDA YLOOKLO,X
          		STA HBASL
          		LDA YLOOKHI,X
          		ORA G_PAGE
          		STA HBASL+1
          		
sledlp     		LDX	SLEDFROM			; draw sled from which byte?
	     		LDY	XSLED				; SLED X position
psl1     		LDA	$2000,X				; get HIRES byte
          		STA	(HBASL),Y
          		INX
          		INY
          		CPX	SLEDTO
          		BNE	psl1

          		INC	SLEDYCT
          		LDX	SLEDYCT
				CPX	SLEDALL
				BEQ	sledRTS				; all done
 				LDA YLOOKLO,X
          		STA HBASL
          		LDA YLOOKHI,X
          		ORA G_PAGE
          		STA HBASL+1
          		
          		LDA	psl1+1				; correct offset into bitmap dataset
          		CLC						; each sled line occupies 9 bytes
          		ADC	#9
          		STA	psl1+1
          		LDA	psl1+2
          		ADC	#0
          		STA	psl1+2
          		
          		JMP	sledlp

sledRTS    		RTS
SLEDYCT			DS	1
SLEDALL			DS	1					; y-end adress = YSLED + 17
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
				CMP	#$80
				BNE	res1
				AND	#%01111111
res1			STA	(HBASL),Y		; save byte
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
				PUT	helpers.s			; helper routines
				PUT mbdetect.s			; hardware detection routines
				PUT ihandler.s			; mockingboard interrupt handler
				PUT pt3lib.s			; PT3-file decoder and player
				PUT	text3d.s			; text output routines

TCLR
				LDX #04					; delete Text 1
				LDA #00
				TAY
tByte			LDA	#$20
TCLRlp			STA $0400,Y	
				INY
				BNE TCLRlp
				INC TCLRlp+02
				DEX
				BNE TCLRlp	
				LDA	#$04
				STA	TCLRlp+02	
				RTS	

;
; animated text output
;

printANIM
					STX ba2+1 
					STY ba2+2
					LDX	VTAB2
					LDA	YTLOOKLO,X
					STA	TXTPTR
					LDA	YTLOOKHI,X
					STA	TXTPTR+1
					
					LDX #00
ba2					LDA $1000,X
					STA	OUTCHAR
					BEQ rtsprintANIM
					CMP #$E1			; "a" char in lower case range?
					BCC	doANIMchar		; no -> direct output
					CMP	#$FB			; "z"
					BCS	doANIMchar		; no -> direct output
					AND	charFLAG		; lowercase conversion if necessary
					STA	OUTCHAR
doANIMchar			DEC	PTR
					LDA	(PTR)
					STA	OUTCHAR2
					CMP #$E1			; "a" char in lower case range?
					BCC	doANIMchar2		; no -> direct output
					CMP	#$FB			; "z"
					BCS	doANIMchar2		; no -> direct output
					AND	charFLAG		; lowercase conversion if necessary
					STA	OUTCHAR2
					;JSR COUT			; output ASCII on screen
doANIMchar2			LDY	#20
animlp				LDA	OUTCHAR
					STA	(TXTPTR),Y
					TYA					; save YREG
					PHA
					SEC
					SBC #41
					EOR	#$FF
					STA	Y2
					TAY
					LDA	OUTCHAR2
					STA	(TXTPTR),Y
					PLA					; restore Y-reg
					TAY
					
					LDA	WAITVAL
					BEQ	INCx2
					TXA
					PHA
					LDA	WAITVAL
					JSR	WAIT
					PLA
					TAX
					DEY
					CPY	HTAB
					BEQ	endANIM
					INY
INCx2				LDA	#$A0
					STA	(TXTPTR),Y
					TYA
					PHA
					LDA	Y2
					TAY
					LDA	#$A0
					STA	(TXTPTR),Y
					PLA
					TAY
					DEY
					JMP animlp
					
endANIM				INC	HTAB
					LDA	HTAB
					CMP	#20
					BEQ rtsprintANIM
					
					INX
					BNE ba2
rtsprintANIM		RTS
Y2					DS	1


;
; text strings
;
		
NUMSTRS			EQU	#23					; number of strings to display
STRADR	
				DFB #<STR1,#>STR1,#<STR2,#>STR2,#<STR3,#>STR3
				DFB #<STR4,#>STR4,#<STR5,#>STR5,#<STR6,#>STR6
				DFB #<STR7,#>STR7,#<STR8,#>STR8,#<STR9,#>STR9
				DFB #<STR10,#>STR10,#<STR11,#>STR11,#<STR12,#>STR12
				DFB #<STR13,#>STR13,#<STR14,#>STR14,#<STR15,#>STR15
				DFB #<STR16,#>STR16,#<STR17,#>STR17,#<STR18,#>STR18
				DFB #<STR19,#>STR19,#<STR20,#>STR20,#<STR21,#>STR21
				DFB #<STR22,#>STR22,#<STR23,#>STR23,#<STR24,#>STR24
				

NUMSLED			EQU	#6				
SLEDADR			DFB	#<SLED1,#>SLED1,#<SLED2,#>SLED2,#<SLED3,#>SLED3
				DFB	#<SLED4,#>SLED4,#<SLED5,#>SLED5,#<SLED6,#>SLED6
				DFB	#<SLED7,#>SLED7
SLEDADR2		DFB	#<SLED1A,#>SLED1A,#<SLED2A,#>SLED2A,#<SLED3A,#>SLED3A
				DFB	#<SLED4A,#>SLED4A,#<SLED5A,#>SLED5A,#<SLED6A,#>SLED6A
				DFB	#<SLED7A,#>SLED7A

STR1
		HEX	03B6	; x,y
		ASC 'Welcome to the XMAS-Demo 2019...' 
		HEX	FF
STR2
		HEX	03B6
		ASC	'for the Apple ][ by 8-Bit-Shack!'
		HEX	FF
STR3
		HEX	01B6
		ASC	'Fresh from the Ore Mountains/Germany'
		HEX	FF
STR4
		HEX 06B6
		ASC	'Have you seen Santa Claus?'
		HEX	FF
STR5
		HEX	03B6
		ASC	'He seems to be very busy tonight!'	
		HEX	FF
STR6			
		HEX	08B6
		ASC	'Code & Gfx: SingleMalt'
		HEX	FF
STR7
		HEX	0AB6
		ASC	'Music: Cj Splinter'
		HEX	FF
STR8
		HEX	0EB6
		ASC	'Greetings:'
		HEX	FF
STR9
		HEX	0DB6
		ASC	'BrutalDeluxe'
		HEX	FF
STR10	
		HEX	10B6
		ASC	'Deater'
		HEX	FF
STR11	
		HEX	10B6
		ASC	'digarok'
		HEX	FF
STR12	
		HEX	0EB6
		ASC	'fenarinarsa'
		HEX	FF
STR13	
		HEX	0DB6
		ASC	'French Touch'
		HEX	FF
STR14	
		HEX	0FB6
		ASC	'Jackasser'
		HEX	FF
STR15	
		HEX	0EB6
		ASC	'Ninjaforce'
		HEX	FF
STR16
		HEX	01B6
		ASC	'Visit www.golombeck.eu for more info!'
		HEX	FF
STR17
		HEX	02B6
		ASC	'And yes - this demo uses AppleSoft!'
		HEX	FF
STR18
		HEX	04B6
		ASC	'Special thx to Dr. N. H. Cham!'
		HEX	FF
STR19		
		HEX	05B6
		ASC	'Press <Q> to quit this demo!'
		HEX	FF
STR20		
		HEX	01B6
		ASC	'That is all folks! See you next year!'
		HEX	FF
STR21		
		HEX	12B6
		ASC	'...'
		HEX	FF
STR22		
		HEX	00B6
		ASC	'This line was intentionally left blank'
		HEX	FF
STR23		
		HEX	12B6
		ASC	'...'
		HEX	FF
STR24		

;		DS	\ 
SLED1
		DFB	%00000000,%10000000,%10001010,%10000000,%10000000,%10000000,%10000000,%10000000,%10000000
		DFB	%00000000,%10000000,%11101010,%10000000,%10000000,%10000000,%10000000,%10000000,%10000000
		DFB	%00000000,%11000000,%11111010,%10000000,%10000000,%10000000,%10000000,%10000000,%10000000
		DFB	%00000000,%10110000,%11111010,%10000000,%10000000,%10000000,%10000000,%10000000,%10000000
		DFB	%00000000,%10000000,%10101010,%10000001,%10000000,%10110000,%11100000,%10000000,%10000000
		DFB	%00000000,%10000000,%10101010,%10000010,%10000000,%11000000,%10011001,%10000000,%10000000
		DFB	%00000000,%11000000,%10001010,%10001000,%10000000,%10000000,%10000110,%10000000,%10000000
		DFB	%00000000,%11000000,%10001010,%10100000,%11010101,%10001010,%10101000,%10000000,%10000000
		DFB	%00000000,%10000000,%10001010,%10000000,%10000000,%10100000,%10101001,%10000000,%10000000
		DFB	%00000000,%10000011,%10001010,%10000000,%10000000,%10000000,%10010100,%10000000,%10000000
		DFB	%00000000,%11111111,%10001111,%10000000,%10000000,%11000101,%10001010,%10000000,%10000000
		DFB	%00000000,%11010111,%10001111,%10000000,%10000000,%11010101,%10000010,%10000000,%10000000
		DFB	%00000000,%11010111,%11111010,%10000011,%10100000,%11010101,%10000000,%10000000,%10000000
		DFB	%00000000,%11011100,%10101010,%10001111,%10100000,%11010001,%10000010,%10000000,%10000000
		DFB	%00000000,%11111100,%11111111,%10110011,%10001000,%10000000,%10001000,%10000000,%10000000
		DFB	%00000000,%10110000,%11100000,%10110000,%10000010,%10000000,%10000010,%10000000,%10000000
		DFB	%00000000,%11111111,%11111111,%10001111,%10000000,%11000000,%10000000,%10000000,%10000000
;
; data tables
;
		PUT	tables.s
		
		
* EOF
*          	

