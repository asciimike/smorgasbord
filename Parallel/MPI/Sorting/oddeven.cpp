#include<iostream>
#include<mpi.h>
#include<math.h>
#include<fstream>
#include<sstream>
#include<vector>
#include<stdlib.h>
//I compile with mpic++ oddeven.cpp-o oddeven

//#define DEBUG	//Uncomment if you want my debug information (or want some randomly ordered strings)

/*
 * Perform parallel odd even transposition sort on a given CSV file, return another CSV file with the sorted list.
 * Data must be distributed evenly across all processors.
 * Mike McDonald
 * CSSE 335 HW 9
 * 5/14/2013
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
	
	//determine some things about my processor
	bool isEven = !(rank % 2);	//is my rank even?
	bool evenProcs = !(size % 2);	//are there an even number of procs?
	
	#ifdef DEBUG
	cout << "Rank " << rank << " is " << isEven << endl;
	#endif

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
	
	int* A;		//list of integers to be sorted
	int n;		//size of the list of integers
	
	//read in the file to one processor
	if(rank == 0){
		cdf_intreader(argv[1],&A,&n);
	}
	
	//check to see if it will fit evenly on all processors
	if(rank == 0){
		if(n % size != 0){
			cerr << "N is not evenly divisible by P, please change N or P to conform so that the data can be evenly distributed across all processors.\n";
			abort();
		}
	}
	
	//print out the input file if the length isn't absurd
	if(rank == 0){
		if(n < 20){
			cout << "Input list is: ";
			for(int i = 0; i < n-1; i++){
				cout << A[i] << ",";
			}
			cout << A[n-1] << endl;
		}
	}
	
	//broadcast the size of n to all processors (they need to know it...)
	MPI_Bcast(&n,1,MPI_INT,0,MPI_COMM_WORLD);
	
	//calculate how many pieces of data each processor will have
	int width = n/size;
		
	//create storage for the data I will recieve
	int* myData = new int[width];
	
	//distibute proper chunks to each processor
	if(rank == 0){
		//for each other processor
		for(int p = 1; p < size; p++){
			//pack up it's correct data
			for(int i = 0; i < width; i++){
				myData[i] = A[p*width + i];
			}
			//send it to the correct processor
			MPI_Send(myData, width, MPI_INT, p, 0, MPI_COMM_WORLD);
		}
	}else{
		//recieve data from root processor
		MPI_Recv(myData, width, MPI_INT, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
	}
	
	//processor 0 gets it's data
	if(rank == 0){
		for(int i = 0; i < width; i++){
			myData[i] = A[i];
		}
	}
	
	//sort data locally (data is stored in myData)
	if(width > 1){
		quicksort(myData,0,width-1);
	}
	
	//create storage for recieved data
	int* yourData = new int[width];
	int* ourData = new int[2*width];
	
	//if we're on one processor, we're done, otherwise, perform parallel odd even transposition
	if(size > 1){
		//perform swaps
		for(int p = 0; p < size; p++){
			bool isEvenSwap = !(p % 2);
			int swapTo = rank;
			
			//if we're on an even stage and I'm even
			if(isEvenSwap && isEven){
				bool rxed = false;
				
				//you'll be sending data to your left
				if(swapTo-1 < 0){
					#ifdef DEBUG
					cout << "Processor " << rank << " is not sending on swap stage " << p << endl;
					#endif
				}else{
					#ifdef DEBUG
					cout << "Processor " << rank << " is sending to processor " << swapTo-1 << " on swap stage " << p << endl;
					#endif
					MPI_Send(myData, width, MPI_INT, swapTo-1, 0, MPI_COMM_WORLD);
				}
				
				//you'll be recieving data from your left
				if(swapTo-1 < 0){
					#ifdef DEBUG
					cout << "Processor " << rank << " is not recieving on swap stage " << p << endl;
					#endif
				}else{
					#ifdef DEBUG
					cout << "Processor " << rank << " is recieving from processor " << swapTo-1 << " on swap stage " << p << endl;
					#endif
					MPI_Recv(yourData, width, MPI_INT, swapTo-1, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
					rxed = true;
				}
				
				//if we recieved data, we need to merge it and then sort it
				if(rxed){
					#ifdef DEBUG
					cout << "Processor " << rank << " is merging data on swap stage " << p << endl;
					#endif
					//merge data together
					for(int i = 0; i < width; i++){
						ourData[i] = myData[i];
					}
					for(int i = 0; i < width; i++){
						ourData[i+width] = yourData[i];
					}
					
					//sort data
					quicksort(ourData,0,2*width-1);
					
					//keep the appropriate half of your data
					if(swapTo-1 < 0){
						#ifdef DEBUG
						cout << "Processor " << rank << " is keeping what it has on swap stage " << p << endl;
						#endif
						//myData remained unchanged
					}else{
						#ifdef DEBUG
						cout << "Processor " << rank << " keeping the high half on swap stage " << p << endl;
						#endif
						for(int i = 0; i < width; i++){
							myData[i] = ourData[i+width];
						}
					}
				}
				
			//if we're on an odd stage and I'm odd	
			}else if(!isEvenSwap && !isEven){
				bool rxed = false;
				//you'll be sending data to your left
				if(swapTo-1 < 0){
					#ifdef DEBUG
					cout << "Processor " << rank << " is not sending on swap stage " << p << endl;
					#endif
				}else{
					#ifdef DEBUG
					cout << "Processor " << rank << " is sending to processor " << swapTo-1 << " on swap stage " << p << endl;
					#endif
					MPI_Send(myData, width, MPI_INT, swapTo-1, 0, MPI_COMM_WORLD);
				}
				
				//you'll be recieving data from your left
				if(swapTo-1 < 0){
					#ifdef DEBUG
					cout << "Processor " << rank << " is not recieving on swap stage " << p << endl;
					#endif
				}else{
					#ifdef DEBUG
					cout << "Processor " << rank << " is recieving from processor " << swapTo-1 << " on swap stage " << p << endl;
					#endif
					MPI_Recv(yourData, width, MPI_INT, swapTo-1, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
					rxed = true;
				}
				
				//if we recieved data, we need to merge it and then sort it
				if(rxed){
					#ifdef DEBUG
					cout << "Processor " << rank << " is merging data on swap stage " << p << endl;
					#endif
					//merge data together
					for(int i = 0; i < width; i++){
						ourData[i] = myData[i];
					}
					for(int i = 0; i < width; i++){
						ourData[i+width] = yourData[i];
					}
					
					//sort data
					quicksort(ourData,0,2*width-1);
					//keep the appropriate half of your data
					if(swapTo-1 < 0){
						#ifdef DEBUG
						cout << "Processor " << rank << " is keeping what it has on swap stage " << p << endl;
						#endif
					}else{
						#ifdef DEBUG
						cout << "Processor " << rank << " keeping the high half on swap stage " << p << endl;
						#endif
						for(int i = 0; i < width; i++){
							myData[i] = ourData[i+width];
						}
					}
				}
			
			//if we're on an odd stage and I'm even
			}else if(!isEvenSwap && isEven){
				bool rxed = false;
				//you'll be recieving data from your right
				if(swapTo+1 >= size){
					#ifdef DEBUG
					cout << "Processor " << rank << " is not recieving on swap stage " << p << endl;
					#endif
				}else{
					#ifdef DEBUG
					cout << "Processor " << rank << " is recieving from processor " << swapTo+1 << " on swap stage " << p << endl;
					#endif
					MPI_Recv(yourData, width, MPI_INT, swapTo+1, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
					rxed = true;
				}
				
				//you'll be sending data to your right
				if(swapTo+1 >= size){
					#ifdef DEBUG
					cout << "Processor " << rank << " is not sending on swap stage " << p << endl;
					#endif
				}else{
					#ifdef DEBUG
					cout << "Processor " << rank << " is sending to processor " << swapTo+1 << " on swap stage " << p << endl;
					#endif
					MPI_Send(myData, width, MPI_INT, swapTo+1, 0, MPI_COMM_WORLD);
				}
				
				//if we recieved data, we need to merge it and then sort it
				if(rxed){
					#ifdef DEBUG
					cout << "Processor " << rank << " is merging data on swap stage " << p << endl;
					#endif
					//merge data together
					for(int i = 0; i < width; i++){
						ourData[i] = myData[i];
					}
					for(int i = 0; i < width; i++){
						ourData[i+width] = yourData[i];
					}
					
					//sort data
					quicksort(ourData,0,2*width-1);
					
					//keep the appropriate half of your data
					if(swapTo+1 >= size){
						#ifdef DEBUG
						cout << "Processor " << rank << " is keeping what it has on swap stage " << p << endl;
						#endif
					}else{
						#ifdef DEBUG
						cout << "Processor " << rank << " keeping the low half on swap stage " << p << endl;
						#endif
						for(int i = 0; i < width; i++){
							myData[i] = ourData[i];
						}
					}
				}
			
			//if we're on an even stage and I'm odd
			}else if(isEvenSwap && !isEven){
				bool rxed = false;
				
				//you'll be recieving data from your right
				if(swapTo+1 >= size){
					#ifdef DEBUG
					cout << "Processor " << rank << " is not recieving on swap stage " << p << endl;
					#endif
					
				}else{
					#ifdef DEBUG
					cout << "Processor " << rank << " is recieving from processor " << swapTo+1 << " on swap stage " << p << endl;
					#endif
					MPI_Recv(yourData, width, MPI_INT, swapTo+1, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
					rxed = true;
				}
				
				//you'll be sending data to your right
				if(swapTo+1 >= size){
					#ifdef DEBUG
					cout << "Processor " << rank << " is not sending on swap stage " << p << endl;
					#endif
				}else{
					#ifdef DEBUG
					cout << "Processor " << rank << " is sending to processor " << swapTo+1 << " on swap stage " << p << endl;
					#endif
					MPI_Send(myData, width, MPI_INT, swapTo+1, 0, MPI_COMM_WORLD);
				}
				
				//if we recieved data, we need to merge it and then sort it
				if(rxed){
					#ifdef DEBUG
					cout << "Processor " << rank << " is merging data on swap stage " << p << endl;
					#endif
					//merge data together
					for(int i = 0; i < width; i++){
						ourData[i] = myData[i];
					}
					for(int i = 0; i < width; i++){
						ourData[i+width] = yourData[i];
					}
					
					//sort data
					quicksort(ourData,0,2*width-1);
					
					//keep the appropriate half of your data
					if(swapTo+1 >= size){
						#ifdef DEBUG
						cout << "Processor " << rank << " is keeping what it has on swap stage " << p << endl;
						#endif
					}else{
						#ifdef DEBUG
						cout << "Processor " << rank << " keeping the low half on swap stage " << p << endl;
						#endif
						for(int i = 0; i < width; i++){
							myData[i] = ourData[i];
						}
					}
				}
			}
		}
	}
	
	

	#ifdef DEBUG
	cout << "Rank " << rank << "'s data (post odd even transposition): " << endl;
	for(int i = 0; i < width; i++){
		cout << myData[i] << " ";
	}
	cout << endl;
	#endif
	
	//gather all the data up (it's sorted already)
	int* sortedList = new int[n];
	MPI_Gather(myData,width,MPI_INT,sortedList,width,MPI_INT,0,MPI_COMM_WORLD);
	
	if(rank == 0){
		//print it out if it's a reasonable length
		if(n < 20){
			cout << "Sorted list is: ";
			for(int i = 0; i < n-1; i++){
				cout << sortedList[i] << ",";
			}
			cout << sortedList[n-1] << endl;
		}
		//write it to a file
		cdf_write_seq(out_file,sortedList,n);
	}

	//Clean up. 
	MPI_Finalize();
}