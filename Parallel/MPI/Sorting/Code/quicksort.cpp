#include<iostream>
#include<mpi.h>
#include<math.h>
#include<fstream>
#include<sstream>
#include<vector>
#include<stdlib.h>
//I compile with mpic++ quicksort.cpp-o quicksorts

//#define DEBUG	//Uncomment if you want my debug information (or want some randomly ordered strings)
#define MPI_DEBUG	//MPI barrier debug statements

/*
 * Perform parallel quicksort transposition sort on a given CSV file, return another CSV file with the sorted list.
 * Number of processors must be a power of two.
 * Mike McDonald
 * CSSE 335 HW 9
 * 5/17/2013
*/
using namespace std;

//read a sequence from fname.  Reserve memory and put it in A, which is an int*, put the number of elements read in n. 
//Shamelessly copied from Dr. Eicholz...
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

//Perform a quicksort in place on a. Give it the right bounds (0, length-1) to begin with.
void quicksort(int* a, int l, int r) {
      int i = l;
	  int j = r;
      int t;
      int pivot = a[(l + r) / 2];
 
      //partition
      while (i <= j) {
            while (a[i] < pivot) i++;
            while (a[j] > pivot) j--;
            if (i <= j) {
				//swap values
				t = a[i];
				a[i] = a[j];
				a[j] = t;
				i++;
				j--;
            }
      };
 
      //recurse down a level
      if (l < j)
            quicksort(a, l, j);
      if (i < r)
            quicksort(a, i, r);
}

//Main code to perform odd even sort
int main(int argc,char** argv){

	//MPI boilerplate
	int size,rank;
	MPI_Init(&argc,&argv);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Status status;

	//input and output file checking
	char* in_file=argv[1];
	char* out_file=argv[2];
	
	//do some input argument checking (make sure that both files are specified...)
	if(rank == 0){
		if(argc < 3){
			cerr << "Please provide input and output filenames\n";
			abort();
		}
	}
	
	//check if P will form a perfect tree
	if(rank == 0){
		if(exp2(floor(log2(size)))!=size){
			cerr << "Please select P to be a power of 2^i, so as to form a perfect tree structure\n";
			abort();
		}
	}
	
	int* myData;		//list of integers to be sorted
	int* keepData;
	int* sendData;
	int n;		//size of the list of integers
	
	//read in the file to one processor
	if(rank == 0){
		cdf_intreader(argv[1],&myData,&n);
	}
	
	//print out the input file if the length isn't absurd
	if(rank == 0){
		if(n < 20){
			cout << "Input list is: ";
			for(int i = 0; i < n-1; i++){
				cout << myData[i] << ",";
			}
			cout << myData[n-1] << endl;
		}
	}
	
	//what is the size of my array
	int mySize;
	if(rank == 0){
		mySize = n;
	}else{
		mySize = 0;
	}
	
	//Spread data around to each processor
	for(int l = 1; l <= (int) log2(size); l++){
	
		int pivot;
		int sendSize;
		//pivoting occurs if you're going to send
		if(rank < floor(exp2(l-1))){
			if(mySize > 1){
			#ifdef DEBUG
			cout << "Processor " << rank << " is pivoting and arranging data on level " << l << endl;
			#endif
			
			//Pick a pivot
			pivot = myData[0];
			
			//Arrange data into low and high halves
			int left, right, temp = 0, keepSize = 0;
			
				for(left = 1, right = mySize-1; left < right; )
				{
					if(myData[left] > pivot && myData[right] <= pivot)
					{
						temp = myData[left];
						myData[left] = myData[right];
						myData[right] = temp;
					}
					if(myData[left] <= pivot) left++;
					if(myData[right] > pivot) right--;
				}
			
			keepSize = 0;
			for(int n = 0; n < mySize; n++){
				if(myData[n] < pivot){
					keepSize++;
				}
			}
			
			sendSize = mySize - keepSize - 1;	//subtract off the pivot
			
			
			//create arrays to keep and send
			if(keepSize <= sendSize){
				keepSize++;
				keepData = new int[keepSize];
				if(keepSize > 1){
					for(int j = 0; j < keepSize-1; j++){
							keepData[j] = myData[j+1];
					}
					keepData[keepSize-1] = pivot;
				}else{
					keepData[0] = pivot;
				}
				
				sendData = new int[sendSize];
				for(int j = 0; j < sendSize; j++){
						sendData[j] = myData[keepSize+j];
				}
			}
			
			if(keepSize > sendSize){
				keepData = new int[keepSize];
				for(int j = 0; j < keepSize; j++){
						keepData[j] = myData[j+1];
				}

				sendSize = sendSize++;
				sendData = new int[sendSize];
				for(int j = 0; j < sendSize; j++){
						sendData[j+1] = myData[keepSize+j+1];
				}
				sendData[0] = pivot;
			}
			#ifdef DEBUG
			cout << "Keep size " << keepSize << " send size " << sendSize << " on level " << l << endl;
			#endif
			
			mySize = keepSize;
			myData = new int[mySize];
			myData = keepData;

			
			#ifdef DEBUG
			cout << "Procesor " << rank << " keeping data on level " << l << " : ";
			for(int i = 0; i < mySize-1; i++){
				cout << myData[i] << ",";
			}
			cout << myData[mySize-1] << endl;	
			#endif
			
			//If I have no data to send
			}else{
				sendSize = 0;
			}
			

		}
		
		#ifdef MPI_DEBUG
		MPI_Barrier(MPI_COMM_WORLD);
		#endif
		
		//Sending
		if(rank < floor(exp2(l-1))){
			MPI_Send(&sendSize, 1, MPI_INT, rank + floor(exp2(l-1)), 0, MPI_COMM_WORLD);
			if(sendSize > 0){
				#ifdef DEBUG
				cout << "Procesor " << rank << " sending data on level " << l << " : ";
				for(int i = 0; i < sendSize-1; i++){
					cout << sendData[i] << ",";
				}
				cout << sendData[sendSize-1] << endl;
				#endif
				MPI_Send(sendData, sendSize, MPI_INT, rank + floor(exp2(l-1)), 0, MPI_COMM_WORLD);
				#ifdef DEBUG
				cout << "Processor " << rank << " sending size " << sendSize << " to processor " << rank + floor(exp2(l-1)) << " on level " << l << endl;
				#endif
			}
			
		//Recieving		
		}else if(rank < floor(exp2(l))){
			MPI_Recv(&mySize, 1, MPI_INT, rank - floor(exp2(l-1)), MPI_ANY_TAG, MPI_COMM_WORLD, &status);
		
			if(mySize > 0){
				myData = new int[mySize];
				MPI_Recv(myData, mySize, MPI_INT, rank - floor(exp2(l-1)), MPI_ANY_TAG, MPI_COMM_WORLD, &status);
				#ifdef DEBUG
				cout << "Processor " << rank << " recieved size " << mySize << " from processor " << rank - floor(exp2(l-1)) << " on level " << l << endl;
				#endif
				
				#ifdef DEBUG
				cout << "Just Revieved : ";
				for(int i = 0; i < mySize-1; i++){
					cout << myData[i] << ",";
				}
				cout << myData[mySize-1] << endl;
				#endif
			}

		//doing nothing
		}else{
			#ifdef DEBUG
			cout << "Processor " << rank << " is doing nothing on level " << l << endl;
			#endif
		}
		
		#ifdef MPI_DEBUG
		MPI_Barrier(MPI_COMM_WORLD);
		#endif
	}
	
	//run a serial quicksort as the base case
	#ifdef DEBUG
	cout << "Processor " << rank << " is running a serial quicksort as the base case\n";
	#endif
	
	if(mySize > 1){
		quicksort(myData,0,mySize-1);
	}
	#ifdef DEBUG
	cout << "After sorting on rank " << rank << " : ";
	for(int i = 0; i < mySize-1; i++){
		cout << myData[i] << ",";
	}
	cout << myData[mySize-1] << endl;
	#endif
	
	#ifdef MPI_DEBUG
	MPI_Barrier(MPI_COMM_WORLD);
	#endif

	//collect the data and merge it
	//do a for loop in the opposite direction as above, merging along the way
	for(int l = (int) log2(size); l >= 1; l--){
		int rxSize;
		int* rxData;
		if(rank >= floor(exp2(l-1)) && rank < floor(exp2(l))){
			MPI_Send(&mySize, 1, MPI_INT, rank - floor(exp2(l-1)), 0, MPI_COMM_WORLD);
			if(mySize > 0){
				#ifdef DEBUG
				cout << "Sending : ";
				for(int i = 0; i < mySize-1; i++){
					cout << myData[i] << ",";
				}
				cout << myData[mySize-1] << endl;
				#endif
				
				#ifdef DEBUG
				cout << "Processor " << rank << " sending size " << mySize << " to processor " << rank - floor(exp2(l-1)) << " on gather level " << l << endl;
				#endif
				MPI_Send(myData, mySize, MPI_INT, rank - floor(exp2(l-1)), 0, MPI_COMM_WORLD);
			}
		}else if(rank < floor(exp2(l-1))){
			MPI_Recv(&rxSize, 1, MPI_INT, rank + floor(exp2(l-1)), MPI_ANY_TAG, MPI_COMM_WORLD, &status);
			if(rxSize > 0){
				#ifdef DEBUG
				cout << "Processor " << rank << " recieved size " << rxSize << " from processor " << rank + floor(exp2(l-1)) << " on gather level " << l << endl;
				#endif
				rxData = new int[rxSize];
				MPI_Recv(rxData, rxSize, MPI_INT, rank + floor(exp2(l-1)), MPI_ANY_TAG, MPI_COMM_WORLD, &status);
				
				#ifdef DEBUG
				cout << "Just Recieved : ";
				for(int i = 0; i < rxSize-1; i++){
					cout << rxData[i] << ",";
				}
				cout << rxData[rxSize-1] << endl;
				#endif
			}
			int tempSize = mySize + rxSize;
			
			//Append it to the end of the current array
			int* tempData = new int[tempSize];
			for(int t = 0; t < mySize; t++){
				tempData[t] = myData[t];
			}
			for(int t = mySize; t < tempSize; t++){
				tempData[t] = rxData[t-mySize];
			}
			
			#ifdef DEBUG
			cout << "Merged array : ";
			for(int i = 0; i < tempSize-1; i++){
				cout << tempData[i] << ",";
			}
			cout << tempData[tempSize-1] << endl;
			#endif
			
			mySize += rxSize;
			myData = tempData;
		}
	
	}
	
	//Deal with file I/O and other junk
	if(rank == 0){
		//print it out if it's a reasonable length
		if(n < 20){
			cout << "Sorted list is: ";
			for(int i = 0; i < mySize-1; i++){
				cout << myData[i] << ",";
			}
			cout << myData[mySize-1] << endl;
		}
		
		//write it to a file
		cdf_write_seq(out_file,myData,mySize);
	}

	//Clean up. 
	MPI_Finalize();
}