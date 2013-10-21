/* morse.c */

#include "morse.h"

//lookup table of the characters in our alphabet
morse codeLookup[NUM_CHARS] = {
{'a',{DOT,DASH,SPACE,SPACE,SPACE}},
{'b',{DASH,DOT,DOT,DOT,SPACE}},
{'c',{DASH,DOT,DASH,DOT,SPACE}},
{'d',{DASH,DOT,DOT,SPACE,SPACE}},
{'e',{DOT,SPACE,SPACE,SPACE,SPACE}},
{'f',{DOT,DOT,DASH,DOT,SPACE}},
{'g',{DASH,DASH,DOT,SPACE,SPACE}},
{'h',{DOT,DOT,DOT,DOT,SPACE}},
{'i',{DOT,DOT,SPACE,SPACE,SPACE}},
{'j',{DOT,DASH,DASH,DASH,SPACE}},
{'k',{DASH,DOT,DASH,SPACE,SPACE}},
{'l',{DOT,DASH,DOT,DOT,SPACE}},
{'m',{DASH,DASH,SPACE,SPACE,SPACE}},
{'n',{DASH,DOT,SPACE,SPACE,SPACE}},
{'o',{DASH,DASH,DASH,SPACE,SPACE}},
{'p',{DOT,DASH,DASH,DOT,SPACE}},
{'q',{DASH,DASH,DOT,DASH,SPACE}},
{'r',{DOT,DASH,DOT,SPACE,SPACE}},
{'s',{DOT,DOT,DOT,SPACE,SPACE}},
{'t',{DASH,SPACE,SPACE,SPACE,SPACE}},
{'u',{DOT,DOT,DASH,SPACE,SPACE}},
{'v',{DOT,DOT,DOT,DASH,SPACE}},
{'w',{DOT,DASH,DASH,SPACE,SPACE}},
{'x',{DASH,DOT,DOT,DASH,SPACE}},
{'y',{DASH,DOT,DASH,DASH,SPACE}},
{'z',{DASH,DASH,DOT,DOT,SPACE}},
{'1',{DOT,DASH,DASH,DASH,DASH}},
{'2',{DOT,DOT,DASH,DASH,DASH}},
{'3',{DOT,DOT,DOT,DASH,DASH}},
{'4',{DOT,DOT,DOT,DOT,DASH}},
{'5',{DOT,DOT,DOT,DOT,DOT}},
{'6',{DASH,DOT,DOT,DOT,DOT}},
{'7',{DASH,DASH,DOT,DOT,DOT}},
{'8',{DASH,DASH,DASH,DOT,DOT}},
{'9',{DASH,DASH,DASH,DASH,DOT}},
{'0',{DASH,DASH,DASH,DASH,DASH}}
};

//function for converting a character to a morse code representation
unit* findRepresentationFromChar(char c){
  int count;
  for(count = 0; count < NUM_CHARS; count++){
    if(c == codeLookup[count].symbol){
      return &(codeLookup[count].representation);  
    }
  } 
}
