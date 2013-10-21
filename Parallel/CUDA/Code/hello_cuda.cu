#include <stdio.h>
#include <stdlib.h>
#include "cuPrintf.cu"

__global__ void kernel(void){
	//Print a greeting from the GPU core
	cuPrintf("Hello from GPU processor %d thread %d\n", blockIdx.x, threadIdx.x);
}

int main(int argc, char** argv){
	//How many blocks and how many threads per block will we use?
	int blocks = 2;
	int threadsPerBlock = 2;
	
	//Say Hi from the CPU
	printf("Hello from the CPU\n");
	
	//Initialize printing from GPU cores
	cudaPrintfInit();
	
	//Instruct each GPU core to run its kernel section
	kernel<<<blocks,threadsPerBlock>>>();
	
	//Display the greetings gathered from the GPU cores
	cudaPrintfDisplay();
	
	//End the CUDA printing
	cudaPrintfEnd();
	
	//Exit from the calling program
	return 0;
}