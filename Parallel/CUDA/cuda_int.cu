#include <stdio.h>
#include <math.h>
#include <stdlib.h>

//Note that any functions that want to be called from the kernel must be preceeded with __device__

//Function we are integrating
__device__ float myFunction(float x){
  return pow(x,4);
}

//Trapezoidal rule calculation
__device__ float trapezoidal(float a, float b){
	return (b-a)*((myFunction(a)+myFunction(b))/2);
}

//Composite trap rule calculation
__device__ float composite_trapezoidal(float a, float b, int n){
	float h=(b-a)/(n);
	float total=0;
	int i;
	for (i=0;i<n;i++){
		total=total+trapezoidal(a+i*h,a+(i+1)*h); 
	}
	return total;
}

//This section runs on the GPUs
__global__ void kernel(float* arr, float A, float B, int P, int N){
	//Who am I?
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	
	//calculate number of intervals, where they start, and where they end, and what interval this processor will use
	float intervalWidth = (B-A)/(P);
	float intervalStart = A+(intervalWidth)*(id);
	float intervalEnd = intervalStart+intervalWidth;

	//calculate the partial sum of this interval
	arr[id] = composite_trapezoidal(intervalStart,intervalEnd,N);
}

int main(int argc, char** argv){
	//Process input from command line
	if (argc<3){
		printf("Please enter a,b,N\n");
		return 1;
	}
	
	float A=atof(argv[1]);
	float B=atof(argv[2]);
	int N=atoi(argv[3]);
	
	printf("Integrating x^4 from %.3f to %.3f with %d points\n", A, B, N);
	
	//How many threads will we use and how much data is in each thread?
	int elements = 512;
	int bytes = elements * sizeof(float);

	//Create pointers to host and device arrays
	float *hostArray = 0;
	float *deviceArray = 0;

	//Create the array on the host and on the GPU
	hostArray = (float*) malloc(bytes);
	cudaMalloc((void**)&deviceArray, bytes);

	int blockSize = 128;
	int gridSize = elements / blockSize;

	//Instruct each GPU core to run its kernel section
	kernel<<<gridSize,blockSize>>>(deviceArray, A, B, elements, N);

	//Gather all the partial sums
	cudaMemcpy(hostArray, deviceArray, bytes, cudaMemcpyDeviceToHost);

	//Reduce the partial sums to a single integral
	float sum = 0;
	for(int i=0; i < elements; ++i){
		sum += hostArray[i];
	}
	
	//Print result
	printf("Integrating x^4 from %.3f to %.3f with %d points is: %.3f\n", A, B, N, sum);

	//Deallocate the two arrays
	free(hostArray);
	cudaFree(deviceArray);
	
	//Exit from the calling program
	return 0;
}