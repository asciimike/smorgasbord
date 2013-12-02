#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "xssh.h"

void evaluateLine(Builtin* command, char* line);
void evaluateFirstLine(int n, char* values[], External* ext);
void clear(Builtin* bi);
void evaluate(Builtin * command, char line[]);