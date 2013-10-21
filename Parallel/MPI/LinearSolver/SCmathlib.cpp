/**************************************************************************
*
* Name:         Scientific Computing Mathematics Library (SCmathlib)
*
* File name:    SCmathlib.cpp (definition file)
* Header file:  SCmathlib.h   (header file)      
*
* Developers:   R.M. Kirby and G.E. Karniadakis
*
* Description:
*
* Available Classes Declarations/Definitions:
*    SCPoint
*    SCVector
*    SCMatrix
*
*************************************************************************/


#include "SCmathlib.h"

SCPoint::SCPoint(int dim){
  dimension = dim;
  data = new double[dimension];

  for(int i=0;i<dimension;i++)
    data[i] = 0.0;
}


SCPoint::SCPoint(const SCPoint &v){
  dimension = v.Dimension();
  data = new double[dimension];

  for(int i=0;i<dimension;i++)
    data[i] = v.data[i];
}


SCPoint::~SCPoint(){
  dimension = 0;
  delete[] data;
  data = NULL;
}


int SCPoint::Dimension() const{
  return(dimension);
}


double SCPoint::operator()(const int i) const{
  if(i>=0 && i<dimension)
    return data[i];

  cerr << "SCPoint::Invalid index " << i << " for SCPoint of dimension " << dimension << endl;
  return(0);
}



double& SCPoint::operator()(const int i){
  if(i>=0 && i<dimension)
    return data[i];

  cerr << "SCPoint::Invalid index " << i << " for SCPoint of dimension " << dimension << endl;
  return(data[0]);
}


SCPoint& SCPoint::operator=(const SCPoint &v) {
  if (dimension!=0){
    delete(data);
  }
  data=new double[v.Dimension()];
  dimension = v.Dimension();

  for(int i=0;i<dimension;i++)
    data[i] = v.data[i];
  return *this;
};

void SCPoint::Print() const{
  cout << endl;
  cout << "[ ";
  if(dimension>0)
    cout << data[0];
  for(int i=1;i<dimension;i++)
    cout << "; " << data[i];
  cout << " ]" << endl;
}

SCVector::SCVector(){
  dimension = 0;
  data = NULL;
}


SCVector::SCVector(int dim){
  dimension = dim;
  data = new double[dimension];

  for(int i=0;i<dimension;i++)
    data[i] = 0.0;
}


SCVector::SCVector(const SCVector &v){
  dimension = v.Dimension();
  data = new double[dimension];

  for(int i=0;i<dimension;i++)
    data[i] = v.data[i];
}

SCVector::SCVector(int dim,double* d){
  data=new double[dim];
  dimension=dim;
  for (int i=0;i<dim;i++){
    data[i]=d[i];
  }

}


SCVector::SCVector(int col, const SCMatrix &A){
  dimension = A.Rows();

  data = new double[dimension];
  
  for(int i=0;i<A.Rows();i++)
    data[i] = A(i,col);

}


SCVector::~SCVector(){
  dimension = 0;
  delete[] data;
  data = NULL;
}


void SCVector::Initialize(int dim){
  if(dimension!=0)
    delete[] data;

  dimension = dim;
  data = new double[dimension];
  
  for(int i=0;i<dimension;i++)
    data[i] = 0.0;
}


int SCVector::Dimension() const{
  return(dimension);
}


double SCVector::operator()(const int i) const{
  if(i>=0 && i<dimension)
    return data[i];

  cerr << "SCVector::Invalid index " << i << " for SCVector of dimension " << dimension << endl;
  return(0);
}



double& SCVector::operator()(const int i){
  if(i>=0 && i<dimension)
    return data[i];

  cerr << "SCVector::Invalid index " << i << " for SCVector of dimension " << dimension << endl;
  return(data[0]);
}


SCVector& SCVector::operator=(const SCVector &v) {
  if (dimension!=0){
    delete(data);
  }
  data=new double[v.Dimension()];
  dimension = v.Dimension();
  for(int i=0;i<dimension;i++)
    data[i] = v.data[i];
  return *this;
};

void SCVector::Print() const{
  cout << endl;
  cout <<setw(5);
  cout << "[ ";
  if(dimension>0)
    cout << data[0];
  for(int i=1;i<dimension;i++)
    cout << "; " << setw(5)<<data[i];
  cout << " ]" << endl;
}


double SCVector::Norm_l1(){
  double sum = 0.0;
  for(int i=0;i<dimension;i++)
    sum += fabs(data[i]);
  return(sum);
}


double SCVector::Norm_l2(){
  double sum = 0.0;
  for(int i=0;i<dimension;i++)
    sum += data[i]*data[i];
  return(sqrt(sum));
}

void SCVector::Normalize(){
  double tmp = 1.0/Norm_l2();
  for(int i=0;i<dimension;i++)
    data[i] = data[i]*tmp;
}


double SCVector::Norm_linf(){
  double maxval = 0.0,tmp;
  
  for(int i=0;i<dimension;i++){
    tmp = fabs(data[i]);
    maxval = (maxval > tmp)?maxval:tmp;
  }
  return(maxval);
}

double SCVector::MaxMod(){
  double maxm = -1.0e+10;

  for(int i=0; i<dimension; i++)
    maxm = (maxm > fabs(data[i]))?maxm:fabs(data[i]);
  
  return maxm;
}

double SCVector::ElementofMaxMod(){
  return(data[MaxModindex()]);
}


int SCVector::MaxModindex(){
  double maxm = -1.0e+10;
  int maxmindex = 0;

  for(int i=0; i<dimension; i++){
    if(maxm<fabs(data[i])){
      maxm = fabs(data[i]);
      maxmindex = i;
    }
  }
  
  return maxmindex;
}

void SCVector::Initialize(double a){
  for(int i=0; i<dimension; i++)
    data[i] = a;
}

void SCVector::Initialize(double *v){
  for(int i=0; i<dimension; i++)
    data[i] = v[i];
}




void SCMatrix::Initialize(int m,int n){
  rows=m; columns = n;
  data=new double*[m];
  for (int i=0;i<m;i++){
    data[i]=new double[n];
    for (int j=0;j<n;j++){
      data[i][j]=0;
    }
  }

}

void SCMatrix::set_data(double* data){
  for (int i=0;i<rows;i++){
    for(int j=0;j<columns;j++){
      this->data[i][j]=data[i*columns+j];
    }
  }

}


double* SCMatrix::GetData(){
	double* out = new double [rows*columns];
	for (int m=0;m<rows;m++){
		for (int n=0; n<columns; n++){
			out[m*columns+n]=data[m][n];
		}
	}
	return out;
}

SCMatrix::SCMatrix(){
  rows=1;
  columns=1;
  data=new double*[1];
  data[0]=new double[1];
  data[0][0]=0;
}

SCMatrix::SCMatrix(int dim){
  rows = dim;
  columns = dim;
  data = new double*[rows];
  for(int i=0;i<rows;i++){
    data[i] = new double[columns];
    for(int j=0;j<columns;j++)
      data[i][j] = 0.0;
  }
}

  
SCMatrix::SCMatrix(int rows1, int columns1){
  rows = rows1;
  columns = columns1;

  data = new double*[rows];
  for(int i=0;i<rows;i++){
    data[i] = new double[columns];
    for(int j=0;j<columns;j++)
      data[i][j] = 0.0;
  }
}

SCMatrix::SCMatrix(const SCMatrix& m){
  rows = m.rows;
  columns = m.columns;

  data = new double*[rows];

  for(int i=0;i<rows;i++){
    data[i] = new double[columns];
    for(int j=0; j<columns; j++)
      data[i][j] = m.data[i][j];
  }
}

SCMatrix::SCMatrix(int num_SCVectors, const SCVector * q){
  rows = q[0].Dimension();
  columns = num_SCVectors;

  data = new double*[rows];

  for(int i=0;i<rows;i++){
    data[i] = new double[columns];
    for(int j=0; j<columns; j++)
      data[i][j] = q[j](i);
  }
}

SCMatrix::SCMatrix(int rows1, int columns1, double **rowptrs){
  rows = rows1;
  columns = columns1;

  data = new double*[rows];

  for(int i=0;i<rows;i++)
    data[i] = rowptrs[i];
}

SCMatrix::SCMatrix(int rows,int columns, double* data){
  this->rows=rows;
  this->columns=columns;
  this->data=new double*[rows];
  for (int i=0;i<rows;i++){
    this->data[i]=new double[columns];
    for (int j=0;j<columns;j++){
      this->data[i][j]=data[i*columns+j];
    }
  }

}


SCMatrix::~SCMatrix(){
  for(int i=0;i<rows;i++)
    delete[] data[i];

  rows = 0;
  columns = 0;
  delete[] data;
}

int SCMatrix::Rows() const{
  return(rows);
}  

int SCMatrix::Columns() const{
  return(columns);
}  


double **SCMatrix::GetPointer(){
  return(data);
}

void SCMatrix::GetColumn(int col, SCVector &x){
  x.Initialize(0.0);
  for(int i=0;i<rows;i++)
    x(i) = data[i][col];
}

void SCMatrix::GetColumn(int col, SCVector &x, int rowoffset){
  x.Initialize(0.0);
  for(int i=0;i<rows-rowoffset;i++)
    x(i) = data[i+rowoffset][col];
}

void SCMatrix::PutColumn(int col, const SCVector &x){
  for(int i=0;i<rows;i++)
    data[i][col] = x(i);
}


double SCMatrix::Norm_linf(){
  double maxval = 0.0,sum;
  
  for(int i=0;i<rows;i++){
    sum = 0.0;
    for(int j=0;j<columns;j++)
      sum += fabs(data[i][j]);
    maxval = (maxval > sum)?maxval:sum;
  }
  return(maxval);
}


double SCMatrix::Norm_l1(){
  double maxval = 0.0,sum;

  for(int j=0;j<columns;j++){
    sum = 0.0;
    for(int i=0;i<rows;i++)
      sum += fabs(data[i][j]);
    maxval = (maxval > sum)?maxval:sum;
  }
  return(maxval);
}



SCMatrix& SCMatrix::operator=(const SCMatrix &m){
  if( (rows == m.rows) && (columns == m.columns)){
    for(int i=0; i<rows; i++)
      for(int j=0;j<columns;j++){
	data[i][j] = m.data[i][j];
      }
  }
  else
    cerr << "SCMatrix Error: Cannot equate matrices of different sizes\n";
  return *this;
}

  
double SCMatrix::operator()(const int i, const int j) const {
  if( (i>=0) && (j>=0) && (i<rows) && (j<columns))
    return(data[i][j]);  
  else
    cerr << "SCMatrix Error: Invalid SCMatrix indices (" << i << "," << j << 
      "), for SCMatrix of size " << rows << " X " << columns << endl;
  return((double)0);
}
  

double& SCMatrix::operator()(const int i, const int j) {
  if( (i>=0) && (j>=0) && (i<rows) && (j<columns))
    return(data[i][j]);  
  else
    cerr << "SCMatrix Error: Invalid SCMatrix indices (" << i << "," << j << 
      "), for SCMatrix of size " << rows << " X " << columns << endl;;
  return(data[0][0]);
}


void SCMatrix::Print() const{
  cout << endl;
  for(int i=0;i<rows;i++){
    cout <<setw(8)<<setprecision(4)<<data[i][0];
    for(int j=1;j<columns;j++)
      //cout << " " << setw(8)<<setprecision(4)<<data[i][j];
      printf(" %8.4g",data[i][j]);
    if(i!=(rows-1))
      cout << ";\n";
  }
  cout<<endl;
 
}




double SCMatrix::MaxModInRow(int row){
  double maxv = -1.0e+10;
  for(int i=0;i<columns;i++)
    maxv = (fabs(data[row][i])>maxv)?fabs(data[row][i]):maxv;

  return maxv;
}

double SCMatrix::MaxModInRow(int row, int starting_column){
  double maxv = -1.0e+10;
  for(int i=starting_column;i<columns;i++)
    maxv = (fabs(data[row][i])>maxv)?fabs(data[row][i]):maxv;

  return maxv;
}

int SCMatrix::MaxModInRowindex(int row){
  int maxvindex = 0;
  double maxv = -1.0e+10;
  
  for(int i=0;i<columns;i++){
    if(maxv < fabs(data[row][i])){
      maxv = fabs(data[row][i]);
      maxvindex = i;
    }
  }

  return maxvindex;
}

int SCMatrix::MaxModInRowindex(int row, int starting_column){
  int maxvindex = 0;
  double maxv = -1.0e+10;

  for(int i=starting_column;i<columns;i++){
    if(maxv < fabs(data[row][i])){
      maxv = fabs(data[row][i]);
      maxvindex = i;
    }
  }
  
  return maxvindex;
}

double SCMatrix::MaxModInColumn(int column){
  double maxv = -1.0e+10;
  for(int i=0;i<rows;i++)
    maxv = (fabs(data[i][column])>maxv)?fabs(data[i][column]):maxv;

  return maxv;
}

double SCMatrix::MaxModInColumn(int column, int starting_row){
  double maxv = -1.0e+10;
  for(int i=starting_row;i<rows;i++)
    maxv = (fabs(data[i][column])>maxv)?fabs(data[i][column]):maxv;

  return maxv;
}

int SCMatrix::MaxModInColumnindex(int column){
  int maxvindex = 0;
  double maxv = -1.0e+10;
  
  for(int i=0;i<rows;i++){
    if(maxv < fabs(data[i][column])){
      maxv = fabs(data[i][column]);
      maxvindex = i;
    }
  }

  return maxvindex;
}

int SCMatrix::MaxModInColumnindex(int column, int starting_column){
  int maxvindex = 0;
  double maxv = -1.0e+10;

  for(int i=starting_column;i<rows;i++){
    if(maxv < fabs(data[i][column])){
      maxv = fabs(data[i][column]);
      maxvindex = i;
    }
  }
  
  return maxvindex;
}

void SCMatrix::RowSwap(int row1, int row2){
  double * tmp = data[row1];
  data[row1] = data[row2];
  data[row2] = tmp;
}

void ___skip_to_eol(FILE* f){
  char c='a';
  while (c!='\n'&&c!=EOF){
    c=fgetc(f);
  }
}

void __skip_n_doubles(FILE* f,int n){
  int i;
  for (i=0;i<n;i++){
    fscanf(f," %*lf");
  }
}

void ___skip_n_rows(FILE* f,long int n){
  int i;
  for (i=0;i<n;i++){
    ___skip_to_eol(f);
  }

}

void ___read_line(FILE* f, char** l){
  long int buffer_inc=1000;
  long int buffer_size=buffer_inc;
  char* buffer=new char[buffer_size];
  char* oldbuffer;
  long int linelen=0;
  char c;
  int success=0;
  while (!success){
    if (linelen==buffer_size){
      buffer=(char*)realloc(buffer,(buffer_size+buffer_inc)*sizeof(char));
      buffer_size+=buffer_inc;
    }
    buffer[linelen]=fgetc(f);
    if (buffer[linelen]=='\n'||buffer[linelen]==EOF){
      success=1;
    }
    linelen++;
  }
  *l=buffer;
}



void SCMatrix::write(char* filename){
  FILE* f=fopen(filename,"w");
  if (f==NULL){
    cerr<<"Error opening file "<<filename<<endl;
    abort();
  }
  fprintf(f,"%d %d\n",rows,columns);
  for (int i=0;i<rows;i++){
    for (int j=0;j<columns;j++){
      fprintf(f,"%lf ",data[i][j]);
    }
    fprintf(f,"\n");
  }
  fclose(f);

}

void SCMatrix::fill_random_ints(int min,int max){
  int i,j;
  srand(time(NULL));
  for (i=0;i<rows;i++){
    for(j=0;j<columns;j++){
      data[i][j]=rand()%(max-min+1)+min;
    }
  }
}



/****************************************************************/
/*                 Operator Definitions                         */
/****************************************************************/


SCVector operator-(const SCVector& v){
  SCVector x(v.Dimension());
  for(int i=0;i<v.Dimension();i++)
    x(i) = -v(i);
  return x;
}

SCMatrix operator-(const SCMatrix& A){
  SCMatrix B(A.Rows(),A.Columns());
  for (int i=0;i<A.Rows();i++){
    for (int j=0;j<A.Columns();j++){
      B.data[i][j]=-A.data[i][j];
    }
  }
  return B;
}


SCVector operator+(const SCVector& v1, const SCVector& v2){
  int min_dim = min_dimension(v1,v2);
  SCVector x(min_dim);
  for(int i=0;i<min_dim;i++)
    x(i) = v1(i) + v2(i);
  return x;
}

SCMatrix operator+(const SCMatrix& M1,const SCMatrix& M2){
  if (M1.Rows() != M2.Rows() || M1.Columns() != M2.Columns()){
    cerr<<"Incompatible dimensions for matrix addition."<<endl;
    exit(1);
  }
  SCMatrix M3(M1.Rows(),M1.Columns());
  for (int i=0;i<M1.Rows();i++){
    for (int j=0;j<M1.Columns();j++){
      M3.data[i][j]=M1.data[i][j]+M2.data[i][j];
    }
  }
  return M3;
}


SCVector operator-(const SCVector& v1, const SCVector& v2){
  int min_dim = min_dimension(v1,v2);
  SCVector x(min_dim);
  for(int i=0;i<min_dim;i++)
    x(i) = v1(i) - v2(i);
  return x;
}

SCMatrix operator-(const SCMatrix& M1,const SCMatrix& M2){
  if (M1.Rows() != M2.Rows() || M1.Columns() != M2.Columns()){
    cerr<<"Incompatible dimensions for matrix addition."<<endl;
    exit(1);
  }
  SCMatrix M3(M1.Rows(),M1.Columns());
  for (int i=0;i<M1.Rows();i++){
    for (int j=0;j<M1.Columns();j++){
      M3.data[i][j]=M1.data[i][j]-M2.data[i][j];
    }
  }
  return M3;
}




SCVector operator/(const SCVector& v, const double s) {
  SCVector x(v.Dimension());
  for(int i=0;i<v.Dimension();i++)
    x(i) = v(i)/s;
  return x;
}



SCVector operator*(const double s, const SCVector &v) {
  SCVector x(v.Dimension());
  for(int i=0;i<v.Dimension();i++)
    x(i) = s*v(i);
  return x;
}


SCMatrix operator*(const double s, const SCMatrix& M){
  SCMatrix M1(M);
  for (int i=0;i<M.Rows();i++){
    for (int j=0;j<M.Columns();j++){
      M1.data[i][j]=s*M.data[i][j];
    }
  }
  return M1;
}

SCVector operator*(const SCVector& v, const double s) {
  SCVector x(v.Dimension());
  for(int i=0;i<v.Dimension();i++)
    x(i) = s*v(i);
  return x;
}

SCMatrix operator*(const SCMatrix& M, const double s){
  return s*M;
}

SCVector operator*(const SCMatrix& A, const SCVector& x){
  int rows = A.Rows(), columns = A.Columns();
  int dim = A.Rows();
  SCVector b(dim);
  
  if(columns != x.Dimension()){
    cerr << "Invalid dimensions given in matrix-vector multiply" << endl;
    return(b);
  }
  
  for(int i=0;i<rows;i++){
    b(i) = 0.0;
    for(int j=0;j<columns;j++){
      b(i) += A(i,j)*x(j);
    }
  }
  
  return b;
}

SCMatrix operator*(const SCMatrix& A, const SCMatrix& B){
  if (A.Columns() != B.Rows()){
    cerr<<"Invalid dimensions for matrix-matrix product.\n";
    exit(1);
  }
  SCMatrix C(A.Rows(),B.Columns());
  for (int i=0;i<C.Rows();i++){
      for (int k=0;k<A.Columns();k++){
	for (int j=0;j<C.Columns();j++){
   	C.data[i][j]+=A.data[i][k]*B.data[k][j];
      }
    }
  }

  return C;
}

/****************************************************************/
/*                 Function Definitions                         */
/****************************************************************/

int min_dimension(const SCVector& v1, const SCVector& v2){
  int min_dim = (v1.Dimension()<v2.Dimension())?v1.Dimension():v2.Dimension();
  return(min_dim);
}


double dot(const SCVector& u, const SCVector& v){
  double sum = 0.0;
  int min_dim = min_dimension(u,v);

  for(int i=0;i<min_dim;i++)
    sum += u(i)*v(i);
  
  return sum; 
}


double dot(int N, const SCVector& u, const SCVector& v){
  double sum = 0.0;

  for(int i=0;i<N;i++)
    sum += u(i)*v(i);
  
  return sum;
}


double dot(int N, double *a, double *b){
  double sum = 0.0;
  
  for(int i=0;i<N;i++)
    sum += a[i]*b[i];

  return sum;
}


/*******************************/
/*   Log base 2 of a number    */
/*******************************/

double log2(double x){
  return(log(x)/log(2.0));
}

void Swap(double &a, double &b){
  double tmp = a;
  a = b;
  b = tmp;
}

double Sign(double x){
  double xs;

  xs = (x>=0.0)?1.0:-1.0;

  return xs;
}

//GammaF function valid for x integer, or x (integer+0.5)
double GammaF(double x){
  double gamma = 1.0;
  
  if (x == -0.5) 
    gamma = -2.0*sqrt(M_PI);
  else if (!x) return gamma;
  else if ((x-(int)x) == 0.5){ 
    int n = (int) x;
    double tmp = x;
    
    gamma = sqrt(M_PI);
    while(n--){
      tmp   -= 1.0;
      gamma *= tmp;
    }
  }
  else if ((x-(int)x) == 0.0){
    int n = (int) x;
    double tmp = x;
    
    while(--n){
      tmp   -= 1.0;
      gamma *= tmp;
    }
  }  
  
  return gamma;
}


int Factorial(int n){
  int value=1;
  for(int i=n;i>0;i--)
    value = value*i;

  return value;
}

double ** CreateMatrix(int m, int n){
  double ** mat;
  mat = new double*[m];
  for(int i=0;i<m;i++){
    mat[i] = new double[n];
    for(int j=0;j<m;j++)
      mat[i][j] = 0.0;
  }
  return mat;
}

int ** ICreateMatrix(int m, int n){
  int ** mat;
  mat = new int*[m];
  for(int i=0;i<m;i++){
    mat[i] = new int[n];
    for(int j=0;j<m;j++)
      mat[i][j] = 0;
  }
  return mat;
}

void DestroyMatrix(double ** mat, int m, int n){
  for(int i=0;i<m;i++)
    delete[] mat[i];
  delete[] mat;
}

void IDestroyMatrix(int ** mat, int m, int n){
  for(int i=0;i<m;i++)
    delete[] mat[i];
  delete[] mat;
}

void get_dims_textfile(char* filename,int* M,int* N){
  FILE* f=fopen(filename,"r");
  if (f==NULL){
    cerr<<"Error opening "<<filename<<endl;
    abort();
  }
  if (fscanf(f,"%d %d",M,N)!=2){
    cerr<<"Error getting dimensions of matrix in file "<<filename<<endl; 
   abort();
  }

}




double* load_rows(char* filename,int firstrow,int lastrow){
  FILE* f=fopen(filename,"r");
  if (f==NULL){
    cerr<<"Error opening file "<<filename<<endl;
    abort();
  }
  int i;
  int status;
  int M,N;
  double* data;
  status=fscanf(f,"%i %i",&M,&N);
  ___skip_to_eol(f);
  if (status!=2){
    cerr<<"Error reading file "<<filename<<endl;
    abort();
  }
  if (firstrow<0||firstrow>M-1||lastrow<0||lastrow>M-1||lastrow<firstrow){
    cerr<<"Requested rows "<<firstrow <<"-"<<lastrow<<" of a "<<M<<"x"<<N<<" matrix."<<endl;
    abort();
  }
  data=new double[(lastrow-firstrow+1)*N];
  ___skip_n_rows(f,firstrow);

  for (i=0;i<=lastrow-firstrow;i++){
    for (int j=0;j<N;j++){
      if (fscanf(f," %lf",&(data[i*N+j]))!=1){
	cerr<<"Error reading element "<<i<<" "<<j<<endl;
	abort();
      }
    }
  }
  
  return data;

}


double* load_columns(char* filename,int firstcolumn,int lastcolumn){
  FILE* f=fopen(filename,"r");
  if (f==NULL){
    cerr<<"Error opening file "<<filename<<endl;
    abort();
  }
  int i,j;
  int status;
  int M,N;
  double* data;
  status=fscanf(f,"%i %i",&M,&N);
  ___skip_to_eol(f);
  if (status!=2){
    cerr<<"Error reading file "<<filename<<endl;
    abort();
  }
  if (firstcolumn<0||firstcolumn>N-1||lastcolumn<0||lastcolumn>N-1||lastcolumn<firstcolumn){
    cerr<<"Requested columns "<<firstcolumn <<"-"<<lastcolumn<<" of a "<<M<<"x"<<N<<" matrix."<<endl;
    abort();
  }
  data=new double[(lastcolumn-firstcolumn+1)*M];
  for (i=0;i<M;i++){
    __skip_n_doubles(f,firstcolumn);
    for (j=0;j<lastcolumn-firstcolumn+1;j++){
      if (fscanf(f," %lf",&(data[i*(lastcolumn-firstcolumn+1)+j]))!=1){
	cerr<<"Error reading element "<<i<<" "<<j<<endl;
	abort();
      }
    }
    ___skip_to_eol(f);
  }
  
  return data; 

}


double* load_block(char* filename,int brow, int bcol, int bwidth, int bheight){
 FILE* f=fopen(filename,"r");
  if (f==NULL){
    cerr<<"Error opening file "<<filename<<endl;
    abort();
  }
  int i,j;
  int status;
  int M,N;
  int total_block_cols;
  int total_block_rows;
  double* data;
  status=fscanf(f,"%i %i",&M,&N);
  ___skip_to_eol(f);
  if (status!=2){
    cerr<<"Error reading file "<<filename<<endl;
    abort();
  }
  if (M % bheight!=0 || N%bwidth !=0){
    cerr<<"It is not possible to partition a "<<M <<"x"<<N<<" matrix in to blocks of size "<<bheight <<"x"<<bwidth<<endl;
    abort();
  }
  total_block_rows=M/bheight;
  total_block_cols=N/bwidth;

  if (bcol<0||bcol>total_block_cols-1||brow<0||brow>total_block_rows-1){
    cerr<<"Requested block "<<brow <<","<<bcol<<" of a matrix with block dimensions"<< total_block_rows<<"x"<<total_block_cols<<"."<<endl;
    abort();
  }
  data=new double[bheight*bwidth];
  for (i=0;i<bheight*brow;i++){
    ___skip_to_eol(f);
  }
  for (i=0;i<bheight;i++){
    __skip_n_doubles(f,bwidth*bcol);
    for (j=0;j<bwidth;j++){
      fscanf(f,"%lf",data+i*bwidth+j);
    }
    ___skip_to_eol(f);
  }
  
  return data;

}
