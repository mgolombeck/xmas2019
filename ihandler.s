*
*
*************************************************
* MOCKINGBOARD INTERRUPT HANDLER                *
*************************************************
*

I_HANDLER			
					PHP
					PHA						; save A
					TXA
					PHA						; save X
					TYA
					PHA						; save Y

MBbitReset			BIT	$C404				; clear 6522 interrupt by reading T1C-L	; 4
					LDA	$C08B				; write enable

					LDA	DONE_PLAYING										; 3
					BEQ	pt3_play_music		; if song done, don't play music	; 3/2nt
					JMP	done_interrupt

pt3_play_music								; decode a frame of music
					JSR	pt3_make_frame		; handle song over condition
					LDA	DONE_SONG
					BEQ	mb_write_frame		; if not done, continue
					JSR	INIT_ALGO			; restart song
					JMP	check_keyboard
pt3_loop_smc		
					LDA	#0
mb_write_frame
					TAX						; set up reg count			; 2
mb_write_loop
					LDA	AY_REGISTERS,X		; load register value			; 4

	; special case R13.  If it is 0xff, then don't update
	; otherwise might spuriously reset the envelope settings

					CPX	#13							
					BNE	mb_not_13						
					CMP	#$FF							
					BEQ	mb_skip_13						
								
mb_not_13
					; address
mbADRp				STX	MOCK_ORA1			; put address on PA1		; 4
mbADRq				STX	MOCK_ORA2			; put address on PA2		; 4
					LDY	#MOCK_LATCH			; latch_address for PB1		; 2
mbADRr				STY	MOCK_ORB1			; latch_address on PB1          ; 4
mbADRs				STY	MOCK_ORB2			; latch_address on PB2		; 4
					LDY	#MOCK_INACT			; go inactive			; 2
mbADRt				STY	MOCK_ORB1						; 4
mbADRu				STY	MOCK_ORB2						; 4

        			; value
mbADRv				STA	MOCK_ORA1			; put value on PA1		; 4
mbADRw				STA	MOCK_ORA2			; put value on PA2		; 4
					LDA	#MOCK_WRITE			;				; 2
mbADRx				STA	MOCK_ORB1			; write on PB1			; 4
mbADRy				STA	MOCK_ORB2			; write on PB2			; 4
mbADRz				STY	MOCK_ORB1						
mbADRA				STY	MOCK_ORB2						

mb_no_write			INX						; point to next register	; 2
					CPX	#14					; if 14 we're done		; 2
					BMI	mb_write_loop		; otherwise, loop		; 3/2nt
								
mb_skip_13
check_keyboard		LDA	KYBD				; check for keyboard input
					BPL	no_key							
					CMP	#$D0				; key "P" pressed?
					BNE	no_key
clrSTR				BIT	STROBE				; clear the keyboard buffer
					LDA	#1
					STA	DONE_PLAYING		; keypress -> end of playing
					SEI						; stop interrupt
					JSR	CLEAR_LEFT			; silence MB both channels!
					JMP	save_key

no_key
					LDA	#0					; no key, so save a zero	; 2
save_key
					STA	LASTKEY				; save the key to our buffer	; 2
done_interrupt		
					;LDA	SNOWINIT
					;BNE	done_i_2
					LDA	TXTACT				; check if we need to output text on screen
					BEQ	noTXTout
					JSR	CHAROUT				; output HIRES characters
noTXTout			LDA	TXTDEL				; check if we need to delete the text
					BEQ	doTXTinit					
					INC	TXTWAIT				; wait 128 cycles before deleting the text
					LDA	TXTWAIT
					AND	#%10000000
					BEQ	done_i_2
					JSR	DELTXT
doTXTinit			LDA	TXTINIT
					BEQ	done_i_2
					JSR	WLCMTXT
					JSR TXTOUT
					LDA	#1
					STA	TXTACT
					DEC	TXTINIT			

done_i_2			;LDA	SLEDACT
					;BEQ	done_i_3
					;JSR	SLEDANIM
done_i_3			PLA						; restore Y
					TAY
					PLA						; restore X
					TAX
					PLA						; restore A
					PLP						; restore processor regs					
					RTI	
					
INIT_ALGO			LDX	#0					; init ZP variables
					LDA	#0
					STA	DONE_PLAYING
					STA	DONE_SONG
					STA	LASTKEY
					STA	current_pattern_smc+1		; init player position variables
					STA current_subframe_smc+1
					STA	current_line_smc+1
INIT_lp				STA	AY_REGISTERS,X
					INX
					CPX #22
					BNE	INIT_lp				

					LDX	#0					; reset current note values
INIT_lp2			STA	note_a,X
					INX
					CPX #120
					BNE	INIT_lp2				

					RTS
						