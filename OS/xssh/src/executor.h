#include <stdio.h>
#include <stdlib.h>
#include "xssh.h"

void executeCommand(Builtin* command);
void executeEcho(Builtin* command);
void executeQuit(Builtin* command);
void executeExec(Builtin* command);
void executeWait(Builtin* command);
void executeSet(Builtin* command);
void executeUnset(Builtin* command);
void executePWD(void);
void executeCD(Builtin* command);
void executeCHDIR(Builtin* command);
void executeMan(Builtin* command);
void executeWhy(Builtin* command);
void debugCMD(Builtin* command);
void setPositionals(Builtin* command);
int subVar(Builtin * command);
int checkEnvVarAttribs(char* var);
char* commandToString(Builtin* command);
