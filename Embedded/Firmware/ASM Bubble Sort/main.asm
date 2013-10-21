
;Homework #3 Bubble Sort & Passing Parameters via Stack
       		XDEF Entry                
        		ABSENTRY Entry   
        		ORG $0400
RESULT_RAM:	RMB 10	;Reserve 10 RAM bytes where data list to be sorted 
                      		;will be placed. Sorted data will reside here as well
                     		;once the sorting subroutine has run.
SWAP_FLAG:    	RMB 1  	;Used to keep track of whether a swap was made
			ORG $4000
DATLIST:		FCB $2C,$84,$55,$00,$A5,$FE,$72,$84,$32,$2C   ;Data List in ROM
NR_ELEMENTS:	EQU 10
Entry:		LDS #$1000		;Initialize the Stack at 1 location above where RAM ends	
			LDX #RESULT_RAM
			LDY #DATLIST
			LDAA #NR_ELEMENTS-1
MOVE_NXT:		
      		MOVB A,Y, A,X  		;copy data to be sorted to RESULT_RAM array
			DECA
			BPL MOVE_NXT
      		LDAA #10	
			PSHA			;Push number of bytes to sort.
			LDD #RESULT_RAM
			PSHD			;Push starting addr of data list.
			JSR UNSIGNED_SORT
			LEAS 3,SP		;Clean input arguments off stack (Increment SP by 3)      
DYNHLT:		BRA DYNHLT		;by adding 3 to SP.  
;******** Start of Your Subroutine "UNSIGNED_SORT" ***************
UNSIGNED_SORT:
     LDX 2, SP      ;Load address of result RAM int X
     LDY 3, SP      ;Load total number of values into Y
     DEY            ;Decrease Y by 1 because N-1 comparisons are made, not N    
     CLR SWAP_FLAG  ;Clear the swap flag
     
COMPARE:      
      LDAA 0,X
      CMPA 1,X
      BHI SWAP  ;Branch if X+1 < X, Use BGT for signed sort
      
CONTINUE:
      INX           ;Increment X
      DEY           ;Decrement the number of values left
      CPY #0
      BNE COMPARE
      
      LDAA SWAP_FLAG    ;If swap flag has been set, branch to the beginning
      CMPA #0
      BNE UNSIGNED_SORT ;Otherwise, fall through and finish
      RTS
      
SWAP:
      LDAB 1,X    ;Load X+1 into B
      STAA 1,X    ;Store X into X+1
      STAB 0,X    ;Store B (X+1) into X
      
      LDAA SWAP_FLAG
      INCA            ;Increment the swap flag
      STAA SWAP_FLAG
      BRA CONTINUE