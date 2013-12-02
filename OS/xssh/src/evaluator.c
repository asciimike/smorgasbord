#include <stdio.h>
#include <stdlib.h>
#include "evaluator.h"
#include "xssh.h"

void evaluateLine(Builtin * command, char* line){

	int i = 0;
	char* current;
	
	clear(command);

	if (*line == '\n') {
		return;
	}
	
	if (*line == '#') {
		return;
	}

	current = strtok(line, " \n");
	
	switch(code(current)){
       case ECHO:
		 command->cmd = ECHO;
		 break;

       case QUIT:
		 command->cmd = QUIT;
		 break;
	   
	   case SET:
		command->cmd = SET;
	    break;
	   
	   case UNSET:
		command->cmd = UNSET;
	   break;

	   case WAIT:
		command->cmd = WAIT;
	   break;
	 
	   case CD:
		command->cmd = CD;
	   break;
	 
	   case CHDIR:
		command->cmd = CHDIR;
	   break;

      case NONE:
		command->cmd = NONE;
		break;
		
		case PWD:
		command->cmd = PWD;
		break;
		
		case WHY:
		command->cmd = WHY;
		break;
		
		case MANUAL:
		command->cmd = MANUAL;
		break;
		 
		default:
		command->cmd = EXEC;
		break;
	 }

	
	while (current != NULL){

		if(i < 10){
			positionals[i] = current;
		}
		
		if(current[0] == '&'){
			printf("Backgrounding process\n");
			command->isBackground = 1;
		}
		
		else if(current[0] == '<'){
			strcpy(command->inFile,&(current[1]));
			printf("Redirecting input file %s\n", command->inFile);
		}
		
		else if(current[0] == '>'){
			strcpy(command->outFile,&(current[1]));
			printf("Redirecting output %s\n", command->outFile);
		}
		
		else{
			command->values[i] = current;
			/* printf("Values: %d, is %s\n", i,  current); */
			i++;
		}
		current = strtok(NULL, " \n");			
		
	}
		
	command->n = i;
		
	return;
}
	
void evaluateFirstLine(int n, char* values[], External* ext){
	ext->isFile = 0;
	
	if(n==1){
		printf("Welcome to XSSH, the friendly shell!\n");
		printf("Use >> manual help for help with XSSH\n");
		return;
	}
	
	int i;
	for(i = 1; i < n; i++){
		
		if(i < 10){
			positionals[i] = values[i];
		}
		
		if(strcmp(values[i],"-x")==0){
				show_cmds = 1;
				printf("Show commands enabled\n");
			}
		else if(strcmp(values[i],"-d")==0){
				/* Check for various debug levels */
				int dl = atoi(values[i+1]);
				if(dl==0){
					debug_level = 0;
				} else if(dl>0){
					debug_level = dl;
				}
				printf("Debug level %d enabled\n", debug_level);
				i++;
			}
		else {
			ext->isFile = 1;
			ext->name = values[i];
			printf("File name is: %s\n", ext->name);
			return;
		}
	}
}

void clear(Builtin* bi){
	bi->cmd = NONE;
	bi->n = 0;
	bi->isBackground = 0;
	bi->inFile[0] = '\0';
	bi->outFile[0] = '\0';
}
void evaluate(Builtin * command, char line[]){
	Builtin * next;
	Builtin * current;
	int length = strlen(line) - 1;
	int offset;
	char* token;
	if(strlen(line) == 1){
		return;
		}
	if(line[0] == '#'){
		return;
		}
	token = strtok(line, "|\n");
	offset = strlen(token) + 2;
	evaluateLine(command, token);
	token = strtok((&(line[0]) + offset), "|\n");
 	current = command;
	while(token != NULL && offset < length) {
		offset += strlen(token) +2;
		next = malloc(sizeof(Builtin));
		evaluateLine(next, token);
		current->next = next;
		current = next;
		next = NULL;
		token = strtok((&(line[0]) + offset), "|\n");
	}
	current->next = NULL;
	
}