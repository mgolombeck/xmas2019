*=============================================================================
*
* detect slot with MockingBoard
*
MB_DETECT			LDA	#0
					STA	MB_ADDRL
*					
MB_DET_lp			LDA	#$07			; we start in slot 7 ($C7) and go down to 0 ($C0)
					STA	bMBSlot			; slot with MB
					ORA	#$C0			; make it start with C
					STA	MB_ADDRH
					LDY	#04				; $CX04
					LDX	#02				; 2 tries?
MB_CHK_CYC			LDA	(MB_ADDRL),Y	; timer 6522 (Low Order Counter)
*										; count down
					STA	TICKS			; 3 cycles
					LDA	(MB_ADDRL),Y	; + 5 cycles EQU 8 cycles
*										; between the two accesses to the timer
					SEC
					SBC	TICKS			; subtract to see if we had 8 cycles (accepted range 7-9)
					CMP	#$f8			; -8
					BEQ	DEC_X
					CMP	#$F9			; -7 - range is necessary if FastChip is installed
					BEQ	DEC_X
					CMP	#$F7			; -9
					BNE	MB_NOT_SLOT
DEC_X				DEX					; decrement, try one more time
					BNE	MB_CHK_CYC		; loop detection
					INX					; Mockingboard found (XEQU1)
DONE_DET			STX	bMB				; store result to bMB
					RTS					; return
*
MB_NOT_SLOT			DEC	MB_DET_lp+1		; decrement the "slot" (self_modify)
					BNE	MB_DET_lp		; loop down to one
					LDX	#00
					BEQ	DONE_DET				
*
*
*************************************************
* MOCKINGBOARD INIT & RESET                     *
*************************************************
*
MOCK_INIT			LDA	MB_ADDRH		; self-modify the correct MB-slot adress to MB-init opcodes
					STA	mbADR1+2	
					STA	mbADR2+2	
					STA	mbADR3+2	
					STA	mbADR4+2	
					STA	mbADR5+2	
					STA	mbADR6+2	
					STA	mbADR7+2	
					STA	mbADR8+2	
					STA	mbADR9+2	
					STA	mbADRa+2	
					STA	mbADRb+2	
					STA	mbADRc+2	
					STA	mbADRd+2	
					STA	mbADRe+2	
					STA	mbADRf+2	
					STA	mbADRg+2	
					STA	mbADRh+2	
					STA	mbADRi+2	
					STA	mbADRj+2	
					STA	mbADRk+2	
					STA	mbADRl+2	
					STA	mbADRm+2	
					STA	mbADRn+2	
					STA	mbADRo+2	
					STA	mbADRp+2	
					STA	mbADRq+2	
					STA	mbADRr+2	
					STA	mbADRs+2	
					STA	mbADRt+2	
					STA	mbADRu+2	
					STA	mbADRv+2	
					STA	mbADRw+2	
					STA	mbADRx+2	
					STA	mbADRy+2	
					STA	mbADRz+2	
					STA	mbADRA+2	
					STA	WRITE_RIGHT+2
					STA	WRITE_LEFT+2
					STA	MBbitReset+2
*					
					LDA	#$ff				; all output (1)
mbADR1				STA	MOCK_DDRB1
mbADR2				STA	MOCK_DDRA1
mbADR3				STA	MOCK_DDRB2
mbADR4				STA	MOCK_DDRA2
*
RESET_LEFT			LDA	#MOCK_RESET
mbADR5				STA	MOCK_ORB1
					LDA	#MOCK_INACT
mbADR6				STA	MOCK_ORB1
*
RESET_RIGHT			LDA	#MOCK_RESET
mbADR7				STA	MOCK_ORB2
					LDA	#MOCK_INACT
mbADR8				STA	MOCK_ORB2
*
CLEAR_LEFT			LDY	#14					; silence card - left channel
					LDX	#0
CLloop				JSR	WRITE_LEFT
					DEY
					BPL	CLloop
*
CLEAR_RIGHT			LDY	#14					; silence card - right channel
					LDX	#0
CRloop				JSR	WRITE_RIGHT
					DEY
					BPL	CRloop
*
* enable 50 Hz clock
*
startCLK			SEI						; disable interrupts
					LDA	#$40				; continuous interrupts
mbADRj				STA	$C40B				; ACR register
					LDA	#$7F				; clear all interrupt flags
mbADRk				STA	$C40E				; interrupt enable register (IER)
					LDA	#$C0
mbADRl				STA	$C40D				; IFR: 1100, enable interrupt on timer one oflow
mbADRm				STA	$C40E				; IER: 1100, enable timer one interrupt
					LDA	#$E7				; 4fe7 / 1.025e6 EQU 20ms EQU 50 Hz
mbADRn				STA	$C404				; write to low-order latch
					LDA	#$4F
mbADRo				STA	$C405				; write to high-order latch
*
					RTS
*
					; register in Y
					; value in X
WRITE_RIGHT			STY	MOCK_ORA1			; put address on PA
					LDA	#MOCK_LATCH			; latch_address on PB
mbADR9				STA	MOCK_ORB1
					LDA	#MOCK_INACT			; go inactive
mbADRa				STA	MOCK_ORB1
mbADRb				STX	MOCK_ORA1			; put value on PA
					LDA	#MOCK_WRITE			; write on PB
mbADRc				STA	MOCK_ORB1
					LDA	#MOCK_INACT			; go inactive
mbADRd				STA	MOCK_ORB1
					RTS
*
WRITE_LEFT			STY	MOCK_ORA2			; put address on PA
					LDA	#MOCK_LATCH			; latch_address on PB
mbADRe				STA	MOCK_ORB2
					LDA	#MOCK_INACT			; go inactive
mbADRf				STA	MOCK_ORB2
mbADRg				STX	MOCK_ORA2			; put value on PA
					LDA	#MOCK_WRITE			; write on PB
mbADRh				STA	MOCK_ORB2
					LDA	#MOCK_INACT			; go inactive
mbADRi				STA	MOCK_ORB2
					RTS
*
*
*************************************************
* MOCKINGBOARD SET HANDLER & TIMER              *
*************************************************
*
SET_HANDLER			LDA	bMachine
					CMP	#$FF				; //gs?
					BEQ	SET_IIgs			; yes
					CMP #$EA				; II+?
					BEQ	SET_IIplus			; yes
					CMP #$38				; II?
					BEQ	SET_IIplus			; same as II+
					
*											; //e or //c
					LDA	#<I_HANDLER			; for FastCHip set adress of interrupt handler routine
					STA	$03FE				; which is the playing algorithm
					LDA	#>I_HANDLER
					STA	$03FF
					RTS
*
SET_IIplus					
					lda	READWRITE				; disable ROM (enable language card) Apple II+
					lda	READWRITE
					LDA	#<I_HANDLER			; for FastCHip set adress of interrupt handler routine
					sta	$fffe				; apple II+
					LDA	#>I_HANDLER
					sta	$ffff
					RTS
					
*					
SET_IIgs			LDA #$C0				; set special adresses at IIgs
					STA $3FE
					LDA #$03
					STA $3FF
					LDA	#$AD
					STA	$3C0
					LDA	#$83
					STA	$3C1
					LDA	#$C0
					STA	$3C2
					LDA	#$AD
					STA	$3C3
					LDA	#$83
					STA	$3C4
					LDA	#$C0
					STA	$3C5
					LDA	#$4C
					STA	$3C6
					LDA	#<I_HANDLER
					STA	$3C7
					LDA	#>I_HANDLER
					STA	$3C8
					RTS
*					


*=============================================================================
*
* detect type of Apple 2 computer
*
DETECTA2
					LDA	#$FF
					STA	charFLAG		; allow lower case output
        			LDA $FBB3
        			CMP #$06        	; IIe/IIc/IIGS = 06 
        			BEQ checkII	   		; if not II ($38) or II+ ($EA)
_G22PLUS  			STA	bMachine    	; save $38 or $EA as machine byte
					LDA	#%11011111		; convert lowercase chars to uppercase
					STA	charFLAG
        			RTS       
*        								
checkII	  			LDA $FBC0       	; detect IIc
        			BEQ _G2C        	; 0 = IIc / Other = no IIc
*				
        			SEC					; IIgs or IIe ? 
        			JSR $FE1F       	; test for GS 
        			BCS _G2E        	; if carry flag is set -> IIE
*        	
        			LDA #$FF        	; IIGS -> $FF
        			STA bMachine
*=============================================================================
*
* condition some IIgs settings
*        
					LDA $C036			; put IIgs in 8-bit-mode
 					AND #$7F
 					STA $C036 			; slow speed for Mockingboard detection
* 	
 					LDA $C034 			;
					AND #$F0
 					STA $C034 			; black  border
*
					LDA $C022
					AND #$F0			; bit 0-3 at 0 = background black
					ORA #$F0			; bit 7-4 at 1 = text white
					STA $C022			; background black/text white	
        			RTS
*        
_G2E    			LDA	#$7F        	; IIE -> $7F
    				STA bMachine    
        			RTS
*        	
_G2C    			STA bMachine    	; IIc -> $00
        			RTS
*
*=============================================================================
*
* detect CPU type
*
DETECTCPU
          			LDA	#00
        			BRA _is65C02		; results in a BRA +4 if 65C02/65816 or NOPs if 6502
         			BEQ _contD  		; a 6502 drops through directly to the BEQ here 
_is65C02  			INC	A				; 65C02/65816 arrives here
*										; some 65816 code here
        			XBA               	; .byte $eb, put $01 in B accu -> equals a NOP for 65C02
        			DEC	A            	; .byte $3a, A=$00 if 65C02
        			XBA               	; .byte $eb, get $01 back if 65816
        			INC A            	; .byte $1a, make $01/$02
_contD    			STA b65C02
    				RTS    
        	
*=============================================================================
*
* detect and disable a ZIPchip
*
DETECTZIP
					LDA #$5A			; unlock ZC
					STA $C05A
					STA $C05A
					STA $C05A
					STA $C05A

					LDX	#$00
CACHE				LDA	ALTER,X			; put altering part of the code in the cache!
					INX
					BNE	CACHE				
			
ALTER				LDA $C05C         	; Get the slot delay status
        			EOR #$FF          	; Flip it
        			STA $C05C         	; Save it
        			CMP $C05C         	; Correct?
        			BNE NOZIP        	; No, ZIP CHIP not found.

        			EOR #$FF          	; Get back old status
        			STA $C05C         	; Save it
        			CMP $C05C         	; Correct?
        			BNE NOZIP         	; No, ZIP CHIP not found.
	
					LDA #$00			; other value as $5A or $A5
					STA $C05A			; will disable ZC
					LDA	#$A5			; lock ZC
					STA	$C05A
					LDA #01
					STA bZC
					RTS
			
NOZIP   			LDA #00
					STA	bZC
					RTS							
*=============================================================================
*
* detect a FastChip and set speed to 1 MHz
*
DETECTFC			LDA	bMachine		; get machine type byte
        			LDX	#$00
        			CMP	#$7F          	; Apple IIe
        			BEQ	chk_slot
					BNE	not_found
chk_slot			LDY	#$04			; loop 4 times
        			LDA	#FC_UNLOCK    	; load the unlock value
unlock_lp			STA	FC_LOCK_REG   	; store in lock register
        			DEY
        			BNE unlock_lp
        			LDA	#$00			; MegaAudio check
        			STA	FC_EN_REG 		; enable the Fast Chip
        			LDY	FC_EN_REG 		; bit 7 will be high when enabled
        			CPY	#$80
        			BNE	not_found
found				LDA	FC_SPD_REG
					STA bFCSPEED		; store FC speed
					LDA	#$80			; reset speed register
					STA	FC_SPD_REG
					LDA	#$09			; set FC speed to 1.10 MHz 
					STA	FC_SPD_REG		; necessary for correct MB-detection!
					LDA	#FC_LOCK
        			STA	FC_LOCK_REG   	; lock the registers again
        			LDA	#$01
					STA	bFC
					RTS
not_found			TXA
					STA	bFC
					RTS
*=============================================================================
*
* detect Language Card
*
DETECTLC
					LDA	$C083			; turn on LC
					LDA	$C083
					LDA	$D000
					INC	$D000
				
					CMP	$D000
					BEQ	noLCARD
					DEC	$D000
					LDA	#1				; language card positive
					STA	bLC				; -> might be an emulator!
					JMP	exitLC
noLCARD				LDA	#0
					STA bLC
exitLC				LDA	$C081			; turn off LC
					RTS				

*==============================================================
*
* printCHAR detection results on screen
*
PRTRES				LDA	#7				; set cursor position - line 7
resRTS				RTS
*
*
* text output routines
*
LFEED				LDA	#$8D			; printCHAR a line feed
					JSR	COUT
					RTS
*				
printCHAR									; x = LO-Byte Text, y = HI-Byte Text
					STX ba+1 
					STY ba+2
		
					LDX #00
ba					LDA $1000,X
					BEQ rtsprintCHAR
					CMP #$E1			; "a" char in lower case range?
					BCC	doCOUT			; no -> direct output
					CMP	#$FB			; "z"
					BCS	doCOUT			; no -> direct output
					AND	charFLAG		; lowercase conversion if necessary
doCOUT				JSR COUT			; output ASCII on screen
					LDA	WAITVAL
					BEQ	INCx
					TXA
					PHA
					LDA	WAITVAL
					JSR	WAIT
					PLA
					TAX
INCx				INX
					BNE ba
rtsprintCHAR		RTS



*=============================================================================
*
*
* text output data
*
*
* end of file
*
