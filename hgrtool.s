********************************
*         HGR-Tool 2019        *
*                              *
*      BY MARC GOLOMBECK       *
*                              *
*   VERSION 1.00 / XX.12.2019  *
********************************
*
 				DSK hgrtool
 				MX 	%11
          		ORG $0A00
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

HGRORIG			EQU	$2000
DUMP			EQU	$4000

XFROM			EQU	$300
XTO				EQU	$301
YFROM			EQU	$302
YTO				EQU	$303

PTR				EQU	$06
HBASL			EQU	$08


;
; reading HIRES data and dump lines to dumpspace
;
MAIN
				LDA	#<DUMP			; set pointer for dump space
				STA	PTR
				LDA	#>DUMP
				STA	PTR+1
				
				LDX	YFROM

ylp				LDA YLOOKLO,X		; get base adress
          		STA HBASL
          		LDA YLOOKHI,X
          		ORA #$20
          		STA HBASL+1
						
				LDY	XFROM
xlp				LDA	(HBASL),Y
				STA	(PTR)			; save byte
				INC	PTR				; increment adress
				BNE	noInc
				INC	PTR+1	

noInc			INY
				CPY	XTO				; limit reached?
				BLT	xlp
				INX
				CPX	YTO
				BLT	ylp				
								
				RTS

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
