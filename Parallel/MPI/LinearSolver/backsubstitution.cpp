#include<iostream>
#include<mpi.h>
#include "SCmathlib.h"
#include "stopwatch.h"

//#define DEBUG	//debug definition, comment out to get rid of my dumb output

//Back solver in parallel
using namespace std;

int main(int argc,char** argv){

	int size,rank;
	MPI_Init(&argc,&argv);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	  
	int MU, NU, MV, NV, MP, NP;

	char* U_file=argv[1];
	char* v_file=argv[2];
	char* p_file=argv[3];
	char* x_file=argv[4];

	stopwatch watch;

	double load_start=watch.get_time();
	
	get_dims_textfile(U_file,&MU,&NU);
	get_dims_textfile(v_file,&MV,&NV);
	
	if(MU % size != 0){
		if(rank==0){
		  cerr<<"The number of rows is not evenly divisible by the number of processors"<<endl;
		}
		abort();
	}
	
	int myStart = (rank*MU)/size;
	int myEnd = ((MU*(rank+1))/size) - 1;
	int myWidth = myEnd - myStart + 1;

	//Load U and v appropriately
	double* my_U_rows_data=load_rows(U_file, myStart, myEnd);
	SCMatrix my_U_rows(myWidth,NU,my_U_rows_data);
	double* my_v_rows_data=load_rows(v_file, myStart, myEnd);
	SCVector my_v_rows(myWidth,my_v_rows_data);
	
	//Set xi = bi, that is x(rank) = b(rank), over all values that we have on this processor
	double* my_x_rows_data=load_rows(v_file, myStart, myEnd);
	SCVector my_x_rows(myWidth,my_x_rows_data);
	
	#ifdef DEBUG
	my_U_rows.Print();
	my_v_rows.Print();
	#endif

	MPI_Barrier(MPI_COMM_WORLD);
	double load_end=watch.get_time();

	double work_start=watch.get_time();
	
	//Create swap variable to keep track of columns being switched
	int* swap = new int[2];
	
	//loop over xi's in my row(s), starting from the bottom
	for(int i = MU-1; i >=0; i--){
		//I'm even more ashamed that I'm still using this code
		int elimProc;	//What processor are we eliminating on?
		for(int r = 0; r < size; r++){
			int myS = (r*MU)/size;
			int myE = ((MU*(r+1))/size) - 1;
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
			cout << "Processor " << elimProc << " getting x" << i << " from my row " << myRow << " my column " << i << " and " << myRow % (MU/size) << endl;
		}
		#endif
		
		bool isEliminating = (myStart <= i && i <= myEnd);
		
		//MPI Receive the xi from below you (unles you're the bottom row)
		//MPI Send the xi from below you to the processor above you
		//Via MPI Broadcast! Note that the broadcast eliminates the final send outside the loop, since this is matched!
		double xi;
		if(isEliminating){
			xi = my_x_rows(myRow % (MU/size));
			//cout << "x" << i << " is " << xi << endl;
		}
		
		MPI_Barrier(MPI_COMM_WORLD);
		MPI_Bcast(&xi,1,MPI_DOUBLE,elimProc,MPI_COMM_WORLD);

		//xi = xi - ai,i+1 * xi,i+1 - ai,i+2 * xi,i+2 - ... 
		//If I'm the processor doing back stubstitution, subtract from all rows above the current row
		if (rank == elimProc){
			for(int j = ((myRow % (MU/size))-1); j >= 0; j--) {
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
	for(int d = 0; d < myWidth; d++){
		my_x_rows_data[d] = my_x_rows(d);
	}
	
	double* solutionVector = new double[NU];
	//gather up all the data
	MPI_Gather(my_x_rows_data, myWidth, MPI_DOUBLE, solutionVector, myWidth, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	  
	if (rank==0){
		#ifdef DEBUG
		for(int i = 0; i < NU; i++){
			cout << solutionVector[i] << " ";
		}
		cout << endl;
		#endif
		
		get_dims_textfile(p_file,&MP,&NP);
		double* my_p_rows_data = load_rows(p_file,0,MP-1);		//load entire P matrix 
		SCVector my_p_rows(MP,my_p_rows_data);
		#ifdef DEBUG
		my_p_rows.Print();
		#endif
		
		//Re arrange xi's according to permutation vector
		double* permSolVec = new double[MP];
		double temp;
		for(int i = 0; i < MP; i++){
				//look up index from permutation vector p[i] = j
				//find where in the permutation array the thing is
				int index = 0;
				for(int j = 0; j < MP; j++){
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
				double temp;
				temp = my_p_rows(index);
				my_p_rows(index) = my_p_rows(i);
				my_p_rows(i) = temp;
		}
		//Create a P matrix
		SCMatrix x(MP, 1, permSolVec);
		
		//Print out matrix
		if(MP < 20){
			cout << "x (solution vector):";
			x.Print();
		}
		
		//Deal with file I/O to x.txt
		if(argc < 5){
			x_file = "x.txt";
		}
		
		x.write(x_file);
		
		cout<<"Elapsed work time: "<<watch.get_time()-work_start<<" s."<<endl;
	}

	//Clean up. 
	MPI_Finalize();
}
