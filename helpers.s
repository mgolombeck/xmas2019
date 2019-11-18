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
		   	ASC "BLOAD SONG,A$7100"  ; dummy string -> self-modified
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
		   	ASC "BLOAD LOGO,A$8900"  ; dummy string -> self-modified
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
				
