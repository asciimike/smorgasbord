#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <pthread.h>
#include "xssh.h"
#include "evaluator.h"
#include "executor.h"

/* This is the shell you must fill in or replace in order to complete
   this project.  Do not forget to include your team number and each 
   team member's name in the initial comments of this file.

   You are strongly advised to use top-down design in the form of 
   functional decomposition as you design and implement this shell.

   Pay close attention to the naming hints given in the provided
   Makefile.
*/



int main(int argc, char *argv[]){
	
   char line[MAX_INPUT];
   
   /* Check first line (argc and argv's) for -x, -d, or files */
   External * firstCommand = malloc(sizeof(External));
	evaluateFirstLine(argc, argv, firstCommand);
	
	processManagementCreator();
   
   if(firstCommand->isFile){
   	runFile(firstCommand);
   }
   
   Builtin * command = malloc(sizeof(Builtin));

   while(1){
	 printf(">> ");
	 fgets(line, MAX_IN, stdin);

	 strcpy(currentCMD, line);

	 evaluateLine(command, line);
	 
	 if (command->cmd != NONE) {
	 	executeCommand(command);
	 	/* debugCMD(command); */
	 }
	 
   }
   
 return exit_status;
 
}

int code(char *string){
  int i;
  for(i=0; i<sizeof(table)/sizeof(table[0]); i++){
	if(strcmp(table[i].command, string) == 0) {
		return table[i].code;
	}
  } return EXEC;
}

void runFile(External * ext){
	FILE * f = fopen(ext->name, "r");
	char line[MAX_IN];
	Builtin * command = malloc(sizeof(Builtin));
	
	if(f == NULL){
		printf("File %s does not exist!\n", ext -> name);
		return;
	}
	
	while(!feof(f)){
	 fgets(line, MAX_IN, f);
	 evaluate(command, line);
	 if (command->cmd != NONE) {
	 	executeCommand(command);
	 	/* debugCMD(command); */
	 }
	}
	free(command);
}

void processManagementCreator(){
	pthread_t t;
	
	if(pthread_create(&t, NULL, manager, NULL)){
		exit(exit_status);		
	}
}

void* manager (void * args){
	pid_t pid;
	int statLoc;
	while(1){
		sleep(10);
		pid = waitpid(-1, &statLoc, 0);
		if(g_list_length(backgroundedProcesses)!=0){
			cmd_exit_status = WEXITSTATUS(&statLoc);
			backgroundedProcesses = g_list_remove(backgroundedProcesses, GINT_TO_POINTER(pid));
		}
	}
}


