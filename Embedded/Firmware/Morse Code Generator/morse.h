/* morse.h */
#ifndef _MORSE_H_
#define _MORSE_H_

#define NUM_CHARS 36
#define REP_LENGTH 5

//enumerated structure for dots, dashes, and spaces, for representing morse code
typedef enum{
  SPACE = 0,
  DOT = 1,
  DASH = 3  
}unit;

//struct to hold an ASCII symbol and it's morse code representation
typedef struct{
  char symbol;
  enum unit representation[REP_LENGTH];  
}morse;

//returns a pointer to the representation for a given ASCII symbol
unit* findRepresentationFromChar(char);

#endif

