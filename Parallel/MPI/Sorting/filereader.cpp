#include<iostream>
#include<fstream>
#include<sstream>
#include<vector>
#include<stdlib.h>

using namespace std;

//read a sequence from fname.  Reserve memory and put it in 
//A, which is an int*, put the number of elements read in n. 
//See main for usage.
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
    }
    else{
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

//write n random ints to fname
void cdf_write_rand_seq(char* fname,int num){
  srand(time(NULL));
  ofstream F(fname);

  for (int i=0;i<num-1;i++){
    F<<rand()%1000<<",";
  }
  F<<rand()%1000<<endl;

}

//Write seq, which has length n, to fname.
void cdf_write_seq(char* fname, int* seq, int n){
  ofstream F(fname);
  for (int i=0;i<n-1;i++){
    F<<seq[i]<<",";
  }
  F<<seq[n-1]<<endl;

}

int main(int argc, char** argv){

  int* A; int n;

  if (argc<4){
    cerr<<"Please enter input file and output file and output file."<<endl;
    exit(1);
  }
  cdf_intreader(argv[1],&A,&n);

  cout<<"Read "<<n<<" elements.  They are"<<endl;
  for (int i=0;i<n;i++){
    cout<<A[i]<<" ";
  }
  cout<<endl;


  //Write 200 random ints to the file argv[2]
  cdf_write_rand_seq(argv[2],200);


  //Write the sequence in A back out to file in argv[3];
  cdf_write_seq(argv[3],A,n);

  delete(A);
}
