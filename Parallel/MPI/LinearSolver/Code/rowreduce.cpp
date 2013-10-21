#include<iostream>
#include<mpi.h>
#include<math.h>
#include "SCmathlib.h"
#include "stopwatch.h" 
//I compile with mpic++ rowreduce.cpp SCmathlib.cpp stopwatch.cpp -lrt -o rowreduce

//#define DEBUG

//Performs row reduction on a matrix in parallel.  For best results (meaning any results...), use an evenly divisible number of processors.
using namespace std;

int main(int argc,char** argv){

	int size,rank;
	MPI_Init(&argc,&argv);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
  
	int MA,NA,MB,NB;

	char* A_file=argv[1];
	char* B_file=argv[2];
	char* U_file=argv[3];
	char* v_file=argv[4];
	char* p_file=argv[5];

	stopwatch watch;
	
	double load_start=watch.get_time();
  
	get_dims_textfile(A_file,&MA,&NA);
	get_dims_textfile(B_file,&MB,&NB);
	
	if(NA != MB){
		if(rank == 0){
			cerr << "A and B are of incompatable dimension to be reduced" << endl;
		}
		abort();
	}
	
	if(MA % size != 0){
		if(rank == 0){
			cerr << "Number of rows must be divisible by p" << endl;
		}
		abort();
	}
	
	int myStart = (rank*MA)/size;
	int myEnd = ((MA*(rank+1))/size) - 1;
	int myWidth = myEnd - myStart + 1;
	
	#ifdef DEBUG	
	cout << "Processor " << rank << " has rows " << myStart << " to " << myEnd << endl;
	#endif
	
	double* my_A_rows_data = load_rows(A_file,myStart,myEnd);
	SCMatrix my_A_rows(myWidth,NA,my_A_rows_data);

	double* my_b_rows_data = load_rows(B_file,myStart,myEnd);
	SCVector my_b_rows(myWidth,my_b_rows_data);
	
	#ifdef DEBUG
	//my_A_rows.Print();
	//my_b_rows.Print();
	#endif
	
	MPI_Barrier(MPI_COMM_WORLD);
	double load_end=watch.get_time();
  
	double work_start=watch.get_time();

  
	//Create the permutation vector
	double* permVector = new double[NA];
	if(rank == 0){
		for(int i = 0; i < NA; i++){
			permVector[i] = i;
		}
	}
	
	//Create swap variable to keep track of columns being switched
	int* swap = new int[2];
  
	//Iterate over all rows less than you (change rank to numRows before you) [Possibly add tags to make life easier]
	for(int eStage = 0; eStage < MA; eStage++){
		
		//Honestly, I'm ashamed of myself for coming up with this solution...
		int elimProc;	//What processor are we eliminating on?
		for(int r = 0; r < size; r++){
			int myS = (r*MA)/size;
			int myE = ((MA*(r+1))/size) - 1;
			if(myS <= eStage  && eStage <= myE){
				elimProc = r;
				break;
			}
		}
		
		//Determine which row we're on on the given processor
		int myRow;
		if(myWidth == 1){
			myRow = 0;
		}
		else myRow = (eStage - myStart);
		
		bool isEliminating = (myStart <= eStage && eStage <= myEnd);
		
		//If the elimination row is on my processor
		if(isEliminating){
			#ifdef DEBUG
			cout << "Processor " << rank  << " " << elimProc << " performing elimination " << eStage  << " on my row " << myRow << endl;
			#endif
			
			//Find |max element| in the row
			swap[0] = eStage;	//current column
			swap[1] = eStage;	//if no other colum is larger, swap with itself...
			double max = my_A_rows(myRow,eStage);	//current value
			//cout << "Finding max from " << eStage << " to " << NA-1 << " in row " << myRow  << " on processor " << rank << endl;
			for(int i = eStage+1; i < NA; i++){
				#ifdef DEBUG
				cout << fabs(my_A_rows(myRow,i)) << endl;
				#endif
				if(fabs(my_A_rows(myRow,i)) > max){
					swap[1] = i;
					max = fabs(my_A_rows(myRow,i)); 
				}
			}
			#ifdef DEBUG
			cout << "max in row " << eStage << " is " << max << endl;
			#endif
			}
			
			//Send swap message to all processors
			MPI_Barrier(MPI_COMM_WORLD);
			MPI_Bcast(swap,2,MPI_INT,elimProc,MPI_COMM_WORLD);
			
			//Perform column swap among all rows held on all processors
			double t;
			for(int i = 0; i < myWidth; i++) {
				t = my_A_rows(i, swap[0]);
				my_A_rows(i,swap[0]) = my_A_rows(i,swap[1]);
				my_A_rows(i,swap[1]) = t;
			}
			
			MPI_Barrier(MPI_COMM_WORLD);	//May not be necessary...

			//Swap column values in the permutation array on root processor
			if (rank == 0) {
				t = permVector[swap[0]];
				permVector[swap[0]] = permVector[swap[1]];
				permVector[swap[1]] = t;
			}
			
			#ifdef DEBUG
			if(rank == 0){
				for(int i = 0; i < NA; i++){
					cout << permVector[i] << " "; 
				}
				cout << endl;
			}
			#endif
			
			//Normalize all values in Rk (Rk = Rk/akk)
			if(isEliminating){
				double ak = my_A_rows(myRow, eStage);
				for(int i = eStage; i < MA; i++){
					my_A_rows(myRow, i) = my_A_rows(myRow, i) / ak;		//divide each column in A
				}
				my_b_rows(myRow) = my_b_rows(myRow) / ak;		//divide B row
			}
			
			//Create storage to tx and rx the new rows
			double* normRow = new double[NA];
			double* normB = new double[1];
			//If we just normalized the row, store it appropriatly
			if (isEliminating) {
				for(int i = 0; i < NA; i++) {
					normRow[i] = my_A_rows(myRow,i);
				}
				normB[0] = my_b_rows(myRow);
			}
			
			//Broadcast normalized row 
			MPI_Barrier(MPI_COMM_WORLD);
			MPI_Bcast(normRow,NA,MPI_DOUBLE,elimProc,MPI_COMM_WORLD);
			MPI_Bcast(normB,1,MPI_DOUBLE,elimProc,MPI_COMM_WORLD);
			
			//Do elimination on the remaining rows
			if(isEliminating){
				//eliminate all rows below me by perform the subtraction Rk = Rk - A_k,elimStage * Relimstage
				double leadCoeff;
				for(int i = myRow + 1; i < myWidth; i++) {
					leadCoeff = my_A_rows(i,eStage);
					my_b_rows(i) = my_b_rows(i) - leadCoeff*normB[0];	//subtract off from B
					for(int j = eStage; j < NA; j++) {
						my_A_rows(i,j) = my_A_rows(i,j) - leadCoeff*normRow[j];	//subtract off from A's
					}
				}
			}
			
			if(rank > elimProc){
				//eliminate all my rows b/c I'm below the proc eliminating a row
				double leadCoeff;
				for(int i = 0; i < myWidth; i++) {
					leadCoeff = my_A_rows(i,eStage);
					my_b_rows(i) = my_b_rows(i) - leadCoeff*normB[0];	//subtract off from B
					for(int j = eStage; j < NA; j++) {
						my_A_rows(i,j) = my_A_rows(i,j) - leadCoeff*normRow[j];	//subtract off from A's
					}
				}
			}
	}

	//Gather all data on one processor to create the U matrix and V column
	double* newA = new double[myWidth*NA];
	double* newB = new double[myWidth];
	for(int i = 0; i < myWidth; i++){
		for(int j = 0; j < NA; j++){
			newA[i*NA + j] = my_A_rows(i,j);
		}
		newB[i] = my_b_rows(i);
	}
	
	MPI_Barrier(MPI_COMM_WORLD);
	double* U_data = new double[MA*NA];
	double* V_data = new double[MB];
	MPI_Gather(newA, MA*NA/size, MPI_DOUBLE, U_data, MA*NA/size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Gather(newB, MB/size, MPI_DOUBLE, V_data, MB/size, MPI_DOUBLE, 0, MPI_COMM_WORLD);
 
	if (rank==0){
		
		//Create Matricies
		SCMatrix U(MA,NA,U_data);
		SCMatrix v(MB,1,V_data);
		SCMatrix p(NA,1,permVector);
		
		//Print if small enough
		if(NA < 20){
			cout << "U (upper triangular):";
			U.Print();
			cout << "\nv (solution vector):";
			v.Print();
			cout << "\np (permutation vector):";
			p.Print();
		}
		
		//Deal with File I/O as necessary
		switch(argc){
			case 3:
			U_file = "U.txt";
			v_file = "v.txt";
			p_file = "p.txt";
			break;
			
			case 4:
			U_file=argv[3];
			v_file = "v.txt";
			p_file = "p.txt";
			break;
			
			case 5:
			U_file=argv[3];
			v_file = argv[4];
			p_file = "p.txt";
			break;
			
			case 6:
			U_file=argv[3];
			v_file = argv[4];
			p_file = argv[5];
			break;
		}
		
		U.write(U_file);
		v.write(v_file);
		p.write(p_file);
		
		//Print out work time
		cout<<"Elapsed work time: "<<watch.get_time()-work_start<<" s."<<endl;
	}

	//Clean up. 
	MPI_Finalize();
}
