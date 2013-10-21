#include <hidef.h>            // common defines and macros
#include "derivative.h"       // derivative-specific definitions
#include "morse.h"

// Define constants
#define BUFFERLENGTH 200

// Prototype Functions
void RIEint(void);  // VECTOR 20 RIEint
void RTI_ISR(void); // VECTOR 7 RTI_ISR
void IRTSC0(void);  // VECTOR 8 IRTSC0
void IRTSC1(void);  // VECTOR 9 IRTSC1
char validInput(char);
void updateTime(unsigned int);
void makeDot(void);
void makeDash(void);
void makeSpace(void);
void makeLetterSpace(void);
void makeWordSpace(void);
void initialize(void);

// Declare Global Variables
int addIndex = 0;
int MCindex = 0;
char sentence[BUFFERLENGTH];
int saveSignal = 0;
int timeLength = 0;

int dotLength = 0;
int spaceLength = 0;
int dashLength = 0;
int letterSpaceLength = 0;
int wordSpaceLength = 0;

int pause = 0;

// Main
void main(void) {
  int loop;
  unit * rxa_rep;
  unit rxed;
    
  initialize();
     
  for(;;){
    //check to see the curent input character is a space
    if (sentence[MCindex] == ' '){
      makeWordSpace();
      sentence[MCindex] = '*';  //mark as read  
      MCindex++;
      if (MCindex == BUFFERLENGTH){
        MCindex = 0; 
      }
    }
    
    //if not a space, make its morse code representation
    else if (sentence[MCindex] != '*'){
      rxa_rep = findRepresentationFromChar(sentence[MCindex]);  //rxa_rep is a pointer
      sentence[MCindex] = '*';  //mark as read
      MCindex++;
      if (MCindex == BUFFERLENGTH){
        MCindex = 0; 
      }

      for (loop = 0; loop < REP_LENGTH; loop++){
      
        rxed = *(rxa_rep + loop); //get enumerated value representation
        
        //exit because character is done
        if(rxed == SPACE){ 
          makeLetterSpace();
          break;
        }
        
        //make dots and dashes
        switch(rxed){
            
          case DOT:
            makeDot();
            break;
            
          case DASH:
            makeDash();
            break;
        }
        
        makeSpace();
      }
    }
    

  }
}

void initialize(void){
  int k = 0;

  SCIBDL = 13; // SCI Baud Rate = 2 MHz/(16*SCIBDL)
  SCIBDH = 0;  // Note: 9600 = 2 MHz/(16*13)
  SCICR1 = 0;  // 1 start bit, 8-bit data, 1 stop bit, no parity
  SCICR2 = 0x24;  // Enables receiver and receiver interrupt
  
  ATDCTL2=0x80;  // Gives power to A/D converter
  ATDCTL3=0x08;  // 1 conversion per sequence (A to D)
  ATDCTL4 = 0x01; // 10-bit conversion, 2-clock sample time, 1/4 ATD clock prescaling value
  ATDDIEN=0x7F;//Make PTAD6:0 digital I/O lines
  DDRAD=0x70;  //Make PTAD7 an analog input and PTAD3:0 digital inputs
  CRGINT=0x80; //Enable RTI interrupts
  RTICTL=0x7F; //Make interrupts occur every 262.1 ms
  CRGFLG=0x80; //Clear RTI interrupt flag 
  PERAD=0x00;  //Disable pull-up resistor
  
  DDRM = 0x04;  // Set PTM2 as output (LED)
  DDRT = 0x01;  // Set PTT0 as output (Buzzer)
  TSCR2 = 0x03; // Set prescalar bits to 7 so TCNT increments every 5.333 us
  TSCR1 = 0x80; // Enable Timer TCNT to start counting
  TIE = 0x01;   // Locally enable TC0 interrupts
  TIOS = 0x03;  // Make TC0,1 an Output Compare register
  TCTL2 = 0x00; // Don't toggle bits
  TC0 = TCNT + 250; // Cause interrupt to occur in 1ms
  TFLG1 = 0x03; // Make sure TC0,1 interrupt flag is clear
  
  //fill buffer with empty characters
  for (k = 0; k < BUFFERLENGTH; k++){
    sentence[k] = '*'; 
  }
  
  EnableInterrupts;
}

interrupt void RIEint(void){
  char in = SCIDRL; // Read data
  in = validInput(in);
  
  if (in != -1){    
    if (saveSignal == 0){  
      sentence[addIndex] = in;  
      
      addIndex++;
      saveSignal = 1;
      if (addIndex == BUFFERLENGTH){
        addIndex = 0;
      }
      if (addIndex == MCindex){
        addIndex--; 
      }
      if (addIndex == -1){
        addIndex = BUFFERLENGTH - 1;
      }
    }else{
      saveSignal = 0;
    }
  }
  
  SCISR1_RDRF = 0;  // Clear flag 
}

interrupt void IRTSC0(void){
  TC0 = TC0 + 250;	// Sets next interrupt in tick_length milliseconds
  TFLG1 = 0x01; // Make sure TC0 interrupt flag is clear  
}

interrupt void IRTSC1(void){
  pause = 0;
  TIE = 0x01;  // Disable this interrupt
  TCTL2 = 0x00;
  TFLG1 = 0x02; // Make sure TC0 interrupt flag is clear  
}

interrupt void RTI_ISR(void){
  unsigned int var = 0;
    
	ATDCTL5 = 0x87;
	while(ATDSTAT0_SCF == 0); 	  
	var = ATDDR0*50 + 25;
	updateTime(var/737+30);
	CRGFLG=0x80;
}

void updateTime(unsigned int n){
  timeLength = n;
  dotLength = timeLength;
  spaceLength = 3*timeLength;
  dashLength = 3*timeLength;
  letterSpaceLength = 3*timeLength;
  wordSpaceLength = 7*timeLength;   
}

char validInput(char n){  // Check if n is a valid input
  char output = -1;
  int k;
  char goodInput[] = {' ', '!', '.', ',', '?'};
  
  if ((n>47 && n<58) || (n>96 && n<123)){ //checks if valid lower case character
    output = n;
  }else if(n>64 && n<91){ //converts to lower case
    output = n + 32;
  }else{   
    for (k = 0; k < sizeof(goodInput); k++){  //checks if special character
      if(n == goodInput[k]){
        output = n;
        break;
      }
    }
    if(k == sizeof(goodInput)){
      output = -1;
    }
  }
  
  return output;
}

void makeDot(){
  TCTL2 = 0x01;
  PTM_PTM2 = 1;
  TIE = 0x03;
  pause = 1;
  TC1 = TCNT + dotLength*250;
  
  while(pause);
}

void makeDash(){
  TCTL2 = 0x01;
  PTM_PTM2 = 1;
  TIE = 0x03;
  pause = 1;
  TC1 = TCNT + dashLength*250;
  
  while(pause);
}

void makeSpace(){
  TCTL2 = 0x00;
  PTM_PTM2 = 0;
  TIE = 0x03;
  pause = 1;
  TC1 = TCNT + spaceLength*250;
  
  while(pause);
}

void makeLetterSpace(){
  TCTL2 = 0x00;
  PTM_PTM2 = 0;
  TIE = 0x03;
  pause = 1;
  TC1 = TCNT + letterSpaceLength*250;
  
  while(pause);
}

void makeWordSpace(){
  TCTL2 = 0x00;
  PTM_PTM2 = 0;
  TIE = 0x03;
  pause = 1;
  TC1 = TCNT + wordSpaceLength*250;
  
  while(pause);
}