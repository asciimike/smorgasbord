#include <iostream>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include<fstream>
#include<sstream>
#include<vector>

using namespace std;

void cdf_intreader(char* fname,int** A, int* n){
	ifstream F(fname);
	stringstream buf;
	buf<< F.rdbuf();
	string S(buf.str());
	
	int lastidx=-1;
	int nextidx=string::npos+1;
	int nread=0;
	string toinsert;
	vector<int> Av;

	int i=0;
	while (nextidx!=string::npos){
		nextidx=S.find(',',lastidx+1);
		if (nextidx!=string::npos){
			toinsert=S.substr(lastidx+1,nextidx-lastidx-1);
			lastidx=nextidx;
		}else{
			toinsert=S.substr(lastidx+1,S.length()-lastidx-1);
		}
		Av.push_back(atoi(toinsert.c_str()));
		i++;
	}

	*n=Av.size();
	*A=new int[Av.size()];
	for (i=0;i<Av.size();i++){
	(*A)[i]=Av[i];
	}
}

//Write seq, which has length n, to fname.
//Also hamelessly copied from Dr. Eicholz...
void cdf_write_seq(char* fname, int* seq, int n){
	ofstream F(fname);
	for (int i=0;i<n-1;i++){
		F<<seq[i]<<",";
	}
	F<<seq[n-1]<<endl;

}

//This section runs on the GPUs
__global__ void kernel(int* arr, int length){
	//What is my ID?
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	
	//If we're going to access something outside the array, exit
	if(id >= length-1) return;
	
	//Odd/even transpose elements in the list, in parallel (avoiding accessing the same memory)
	for(int j = 0; j < length; j++){
		int temp;
		//If I'm going to perform a swap this round, swap!
		if((j % 2 == 0 && id % 2 == 0) || (j % 2 != 0 && id % 2 != 0)){
			if(arr[id] > arr[id+1]){
				temp = arr[id];
				arr[id] = arr[id+1];
				arr[id+1] = temp;
			}
		}
	}
}

//Main program
int main(int argc, char** argv){
	//Process input files
	if(argc < 3){
		cerr << "Please provide input and output filenames\n";
		abort();
	}
	char* in_file=argv[1];
	char* out_file=argv[2];

	int* A;		//list of integers to be sorted
	int n;		//size of the list of integers
	
	//Bring data in from txt file
	cdf_intreader(in_file,&A,&n);
	
	//Print out initial data if small enough
	if(n < 20){
		cout << "Input list is: ";
		for(int i = 0; i < n-1; i++){
			cout << A[i] << ",";
		}
		cout << A[n-1] << endl;
	}
	
	//How much data is in each thread?
	int bytes = n * sizeof(int);

	//Create pointer to device array
	int *deviceArray;

	//Create the array on the GPU and copy data to it's memory
	cudaMalloc((void**)&deviceArray, bytes);
	cudaMemcpy(deviceArray, A, bytes, cudaMemcpyHostToDevice);
	
	//How many threads and blocks per thread will we have?
	int threads = n/2;
	
	//Launch kernel on the GPU
	kernel<<<n/threads+1,threads>>>(deviceArray,n);
	
	//Gather data back from processors
	cudaMemcpy(A, deviceArray, bytes, cudaMemcpyDeviceToHost);
	
	//Print output
	if(n < 20){
		cout << "Sorted list is: ";
		for(int i = 0; i < n-1; i++){
			cout << A[i] << ",";
		}
		cout << A[n-1] << endl;
	}
	
	//Write to output file
	cdf_write_seq(out_file,A,n);
	
	//Deallocate the two arrays
	cudaFree(deviceArray);
	
	//Exit from the calling program
	return 0;
}