#include<iostream>
#include<mpi.h>
#include<math.h>
#include "SCmathlib.h"
#include "stopwatch.h" 
//I compile with mpic++ linearsolver.cpp SCmathlib.cpp stopwatch.cpp -lrt -o linearsolver

//#define DEBUG

//Complete linear solver in parallel!!!
using namespace std;

int main(int argc,char** argv){

	int size,rank;
	MPI_Init(&argc,&argv);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
  
	int MA,NA,MB,NB;

	char* A_file=argv[1];
	char* B_file=argv[2];
	char* x_file=argv[3];

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
	
	SCVector my_x_rows(myWidth,newB);
	SCMatrix my_U_rows(myWidth, NA, newA);
	
	//loop over xi's in my row(s), starting from the bottom
	for(int i = MA-1; i >=0; i--){
		//I'm even more ashamed that I'm still using this code
		int elimProc;	//What processor are we eliminating on?
		for(int r = 0; r < size; r++){
			int myS = (r*MA)/size;
			int myE = ((MA*(r+1))/size) - 1;
			if(myS <= i  && i <= myE){
				elimProc = r;
				break;
			}
		}
		
		//Determine which row we're on on the given processor
		int myRow;
		if(myWidth == 1){
			myRow = 0;
		}
		else myRow = (i - myStart);
		
		#ifdef DEBUG
		if(rank == elimProc){
			cout << "Processor " << elimProc << " getting x" << i << " from my row " << myRow << " my column " << i << " and " << myRow % (MA/size) << endl;
		}
		#endif
		
		bool isEliminating = (myStart <= i && i <= myEnd);
		
		//MPI Receive the xi from below you (unles you're the bottom row)
		//MPI Send the xi from below you to the processor above you
		//Via MPI Broadcast! Note that the broadcast eliminates the final send outside the loop, since this is matched!
		double xi;
		if(isEliminating){
			xi = my_x_rows(myRow % (MA/size));
			//cout << "x" << i << " is " << xi << endl;
		}
		
		MPI_Barrier(MPI_COMM_WORLD);
		MPI_Bcast(&xi,1,MPI_DOUBLE,elimProc,MPI_COMM_WORLD);

		//xi = xi - ai,i+1 * xi,i+1 - ai,i+2 * xi,i+2 - ... 
		//If I'm the processor doing back stubstitution, subtract from all rows above the current row
		if (rank == elimProc){
			for(int j = ((myRow % (MA/size))-1); j >= 0; j--) {
				my_x_rows(j) = my_x_rows(j) - my_U_rows(j,i)*xi;
			}
		}
		
		//If I'm above the processor doing elimination, subtract from ALL my rows
		if (rank < elimProc) {
			for(int j = (myWidth - 1); j >= 0; j--) {
				my_x_rows(j) = my_x_rows(j) - my_U_rows(j,i)*xi;
			}
		}
	}
	
	//prepare x's for sending
	double* my_x_rows_data = new double[myWidth];
	for(int d = 0; d < myWidth; d++){
		my_x_rows_data[d] = my_x_rows(d);
	}
	
	double* solutionVector = new double[NA];
	//gather up all the data
	MPI_Gather(my_x_rows_data, myWidth, MPI_DOUBLE, solutionVector, myWidth, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	  
	if (rank==0){
		#ifdef DEBUG
		for(int i = 0; i < NA i++){
			cout << solutionVector[i] << " ";
		}
		cout << endl;
		#endif
		
		SCVector my_p_rows(NA,permVector);
		#ifdef DEBUG
		my_p_rows.Print();
		#endif
		
		//Re arrange xi's according to permutation vector
		double* permSolVec = new double[NA];
		double temp;
		for(int i = 0; i < NA; i++){
				//look up index from permutation vector p[i] = j
				//find where in the permutation array the thing is
				int index = 0;
				for(int j = 0; j < NA; j++){
					if((my_p_rows(j))==i){
						index = j;
						break;
					}
				}
				
				//swap x[i] and x[index]
				permSolVec[i] = solutionVector[index];
				double t;
				t = solutionVector[i];
				solutionVector[i] = solutionVector[index];
				solutionVector[index] = t;
				
				//swap p[i] and p[index]
				int temp;
				temp = my_p_rows(index);
				my_p_rows(index) = my_p_rows(i);
				my_p_rows(i) = temp;
		}
		//Create a P matrix
		SCMatrix x(NA, 1, permSolVec);
		
		//Print out matrix
		if(NA < 20){
			cout << "x (solution vector):";
			x.Print();
		}
		
		//Deal with file I/O to x.txt
		if(argc < 4){
			x_file = "x.txt";
		}else{
			x_file = argv[3];
		}
		
		x.write(x_file);
		
		cout<<"Elapsed work time: "<<watch.get_time()-work_start<<" s."<<endl;
	}

	//Clean up. 
	MPI_Finalize();
}
