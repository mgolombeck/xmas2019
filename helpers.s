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
DRAWHILL		JSR	RNDGEN			; try a littlew randomness
				TAX
				LDA	#$20
				STA	$E6
				LDA	#0
				STA	XPOSH
				STA	DRPOS
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
				ADC	YPOS 			; generate new X
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
				CLC	
				ADC #14				; shift 14 pixel to the right for centering
				STA XPOSL
				LDA	#0
				ADC	#0
				STA	XPOSH			; set HI byte for x-coord > 255
				
				LDY	YPOS
				LDA	XPOSL			; calc new Y for trees
				CLC
				ADC	#1				; offset correction! Trees are always in odd columns!
				CMP	FOREST1+1
				BNE	chktr2
				STY	FOREST1+2			
chktr2			
				CMP	FOREST1+3
				BNE	chktr3
				STY	FOREST1+4			
chktr3			
				CMP	FOREST1+5
				BNE	chktr4
				STY	FOREST1+6			
chktr4			
				CMP	FOREST1+7
				BNE	chktr5
				STY	FOREST1+8			
chktr5			
				CMP	FOREST1+9
				BNE	chktr6
				STY	FOREST1+10			
chktr6			
				CMP	FOREST1+11
				BNE	chktr7
				STY	FOREST1+12			
chktr7			
				CMP	FOREST1+13
				BNE	chktr8
				STY	FOREST1+14			
chktr8			
				CMP	FOREST1+15
				BNE	chktr9
				STY	FOREST1+16
							
chktr9			

				
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
				;TXA
				;PHA
				;TYA	
				;PHA
				;LDA	#100
				;JSR	WAIT
				;PLA	
				;TAY
				;PLA
				;TAX
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
		   	ASC "BLOAD SONG,A$7300"  ; dummy string -> self-modified
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
		   	ASC "BLOAD LOGO,A$8B00"  ; dummy string -> self-modified
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
; patching the sled for reindeer feet animation
;
PATCH1			LDA	#%10000001			; frame 2
				STA	SLED2+$82
				LDA	#%10000001
				STA	SLED2+$83
				LDA	#%10001010
				STA	SLED2+$84
				LDA	#%10000001
				STA	SLED2+$8B
				LDA	#%10000101
				STA	SLED2+$8C
				LDA	#%10100010
				STA	SLED2+$8D
				LDA	#%11000000
				STA	SLED2+$95
				LDA	#%10000000
				STA	SLED2+$96
				
				LDA	#%10000100			; frame 3
				STA	SLED3+$83
				LDA	#%10100000
				STA	SLED3+$84
				LDA	#%10010100
				STA	SLED3+$8C
				LDA	#%10001000
				STA	SLED3+$8D
				LDA	#%10000001
				STA	SLED3+$8E
				LDA	#%10000100
				STA	SLED3+$95
				LDA	#%10000000
				STA	SLED3+$96
				LDA	#%10000001
				STA	SLED3+$97
				
				LDA	#%10010000			; frame 4
				STA	SLED4+$83
				LDA	#%10000000
				STA	SLED4+$84
				LDA	#%10000001
				STA	SLED4+$85
				LDA	#%11000100
				STA	SLED4+$8C
				LDA	#%10000000
				STA	SLED4+$8D
				LDA	#%10000101
				STA	SLED4+$8E
				LDA	#%10000100
				STA	SLED4+$95
				LDA	#%10000000
				STA	SLED4+$96
				LDA	#%10010000
				STA	SLED4+$97
				
				LDA	#%11010000			; frame 5
				STA	SLED5+$83
				LDA	#%10000000
				STA	SLED5+$84
				LDA	#%10000100
				STA	SLED5+$85
				LDA	#%11000100
				STA	SLED5+$8C
				LDA	#%10000000
				STA	SLED5+$8D
				LDA	#%10010100
				STA	SLED5+$8E
				LDA	#%10010000
				STA	SLED5+$95
				LDA	#%10000000
				STA	SLED5+$96
				LDA	#%10000100
				STA	SLED5+$97
				
				LDA	#%11000011			; frame 6
				STA	SLED6+$83
				LDA	#%10000010
				STA	SLED6+$84
				LDA	#%10010100
				STA	SLED6+$85
				LDA	#%11010011
				STA	SLED6+$8C
				LDA	#%10000000
				STA	SLED6+$8D
				LDA	#%11000100
				STA	SLED6+$8E
				LDA	#%10010000
				STA	SLED6+$95
				LDA	#%10000000
				STA	SLED6+$96
				LDA	#%11000001
				STA	SLED6+$97
				
				LDA	#%10001100			; frame 7
				STA	SLED7+$83
				LDA	#%10000010
				STA	SLED7+$84
				LDA	#%10010000
				STA	SLED7+$85
				LDA	#%11001100
				STA	SLED7+$8C
				LDA	#%10001000
				STA	SLED7+$8D
				LDA	#%10010100
				STA	SLED7+$8E
				LDA	#%11000011
				STA	SLED7+$95
				LDA	#%10001000
				STA	SLED7+$96
				LDA	#%10010001
				STA	SLED7+$97
				
;
; animate Santa cap
;
				LDA	#%11110000			; frame 2
				STA	SLED2+$13
				LDA	#%11101010			; frame 2
				STA	SLED2+$14
				LDA	#%10000000
				STA	SLED2+$1C
							
				LDA	#%11000000			; frame 3
				STA	SLED3+$0A
				LDA	#%10100001			; frame 3
				STA	SLED3+$0B
				LDA	#%10000000
				STA	SLED3+$13
				LDA	#%10101010
				STA	SLED3+$14
				LDA	#%10000000
				STA	SLED3+$1C
				LDA	#%10100000
				STA	SLED3+$1D
					
				LDA	#%10000000			; frame 4
				STA	SLED4+$13
				LDA	#%10101110
				STA	SLED4+$14
				LDA	#%10111101
				STA	SLED4+$15
				LDA	#%10000000
				STA	SLED4+$1D
							
				LDA	#%10011000			; frame 5
				STA	SLED5+$0B
				LDA	#%10000000
				STA	SLED5+$13
				LDA	#%10100000
				STA	SLED5+$14
				LDA	#%11110101
				STA	SLED5+$15
				LDA	#%10000000
				STA	SLED5+$1D
							
				LDA	#%10000000			; frame 6
				STA	SLED6+$13
				LDA	#%11100000
				STA	SLED6+$14
				LDA	#%11010101
				STA	SLED6+$15
				LDA	#%10000000
				STA	SLED6+$1D
				LDA	#%11010000
				STA	SLED6+$1E
							

				RTS				

PATCH2			LDA	#%11000000			; frame 2
				STA	SLED2A+$82
				LDA	#%11000000
				STA	SLED2A+$81
				LDA	#%10101000
				STA	SLED2A+$80
				LDA	#%11000000
				STA	SLED2A+$8B
				LDA	#%11010000
				STA	SLED2A+$8A
				LDA	#%10100010
				STA	SLED2A+$89
				;LDA	#%10000001
				;STA	SLED2A+$92
				LDA	#%10000000
				STA	SLED2A+$91
				;STA	SLED2A+$90
				
				LDA	#%10010000			; frame 3
				STA	SLED3A+$81
				LDA	#%10000010
				STA	SLED3A+$80
				LDA	#%10000000
				STA	SLED3A+$7F
				LDA	#%10010100
				STA	SLED3A+$8A
				LDA	#%10001000
				STA	SLED3A+$89
				LDA	#%11000000
				STA	SLED3A+$88
				LDA	#%10010000
				STA	SLED3A+$93
				LDA	#%10000000
				STA	SLED3A+$92
				LDA	#%11000000
				STA	SLED3A+$91
				
				LDA	#%10000100			; frame 4
				STA	SLED4A+$81
				LDA	#%10000000
				STA	SLED4A+$80
				LDA	#%11000000
				STA	SLED4A+$7F
				LDA	#%10010001
				STA	SLED4A+$8A
				LDA	#%10000000
				STA	SLED4A+$89
				LDA	#%11010000
				STA	SLED4A+$88
				LDA	#%10010001
				STA	SLED4A+$93
				LDA	#%10000000
				STA	SLED4A+$92
				LDA	#%10000100
				STA	SLED4A+$91
				
				LDA	#%10000101			; frame 5
				STA	SLED5A+$81
				LDA	#%10000000
				STA	SLED5A+$80
				LDA	#%10010000
				STA	SLED5A+$7F
				
				LDA	#%10010001
				STA	SLED5A+$8A
				LDA	#%10000000
				STA	SLED5A+$89
				LDA	#%10010100
				STA	SLED5A+$88
				
				LDA	#%10000100
				STA	SLED5A+$93
				LDA	#%10000000
				STA	SLED5A+$92
				LDA	#%10010000
				STA	SLED5A+$91
				

				LDA	#%11100001			; frame 6
				STA	SLED6A+$81
				LDA	#%10100000
				STA	SLED6A+$80
				LDA	#%10010100
				STA	SLED6A+$7F
				
				LDA	#%11100101
				STA	SLED6A+$8A
				LDA	#%10000000
				STA	SLED6A+$89
				LDA	#%10010001
				STA	SLED6A+$88
				
				LDA	#%10000100
				STA	SLED6A+$93
				LDA	#%10000000
				STA	SLED6A+$92
				LDA	#%11000001
				STA	SLED6A+$91
				
				LDA	#%10011000			; frame 7
				STA	SLED7A+$81
				LDA	#%10100000
				STA	SLED7A+$80
				LDA	#%10000100
				STA	SLED7A+$7F
				
				LDA	#%10011001
				STA	SLED7A+$8A
				LDA	#%10001000
				STA	SLED7A+$89
				LDA	#%10010100
				STA	SLED7A+$88
				
				LDA	#%11100001
				STA	SLED7A+$93
				LDA	#%10001000
				STA	SLED7A+$92
				LDA	#%11000100
				STA	SLED7A+$91

				LDA	#%10000111			; SANTA cap frame 2
				STA	SLED2A+$19
				LDA	#%10101011			; frame 2
				STA	SLED2A+$18
				LDA	#%10000000
				STA	SLED2A+$22
				LDA	#%10000010
				STA	SLED3A+$21
				
				LDA	#%10000001			; frame 3
				STA	SLED3A+$10
				LDA	#%11000010			; frame 3
				STA	SLED3A+$0F
				LDA	#%10000000
				STA	SLED3A+$19
				LDA	#%10101010
				STA	SLED3A+$18
				LDA	#%10000010
				STA	SLED3A+$21
							
				LDA	#%10111010			; frame 4
				STA	SLED4A+$18
				LDA	#%10000000
				STA	SLED4A+$21

				LDA	#%10001100			; frame 5
				STA	SLED5A+$0F
				LDA	#%10000010
				STA	SLED5A+$18
				LDA	#%10000000
				STA	SLED5A+$21
				
				LDA	#%10000011			; frame 6
				STA	SLED6A+$18
				LDA	#%11010101
				STA	SLED6A+$17
				LDA	#%10000000
				STA	SLED6A+$21
				LDA	#%10000101
				STA	SLED6A+$20
				
				RTS				
;
; flip HIRES byte, HI-bit set to 0
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
				
