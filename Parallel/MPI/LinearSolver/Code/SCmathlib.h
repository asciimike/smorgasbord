/**************************************************************************
*
* Name:         Scientific Computing Mathematics Library (SCmathlib)
*
* File name:    SCmathlib.h   (header file)
* Definitions:  SCmathlib.cpp (definition file)
*
* Developers:   R.M. Kirby and G.E. Karniadakis
*
*************************************************************************/


#ifndef _SCMATHLIB
#define _SCMATHLIB

#include <iostream>
#include <iomanip>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
using namespace std;

enum SCstatus {FAIL, SUCCESS};

class SCPoint;
class SCVector;
class SCMatrix;


/********************************/
/*        SCPoint Class        */
/********************************/

class SCPoint{
 private:
  int   dimension;
  double *data;
  
 public:
  SCPoint(int dim);
  SCPoint(const SCPoint& v);
  ~SCPoint();
  
  int    Dimension() const;

  //************************
  // User Defined Operators
  //************************
  int operator==(const SCPoint& v) const;
  int operator!=(const SCPoint& v) const;
  SCPoint & operator=(const SCPoint& v);

  double  operator()(const int i) const;
  double& operator()(const int i);

  void Print() const;
};



/********************************/
/*        SCVector Class        */
/********************************/

class SCVector{
 private:
  int   dimension;
  
 public:
  double *data;
  SCVector();
  SCVector(int dim);
  SCVector(const SCVector& v);
  SCVector(int col, const SCMatrix &A);
  SCVector(int dim,double* data);
  ~SCVector();
  
  void Initialize(int dim);
  int    Dimension() const;
  double Length();     /* Euclidean Norm of the Vector */
  void   Normalize();

  double Norm_l1();
  double Norm_l2();
  double Norm_linf();
  double MaxMod();
  double ElementofMaxMod();
  int MaxModindex();
  
  //************************
  // User Defined Operators
  //************************
  int operator==(const SCVector& v) const;
  int operator!=(const SCVector& v) const;
  SCVector & operator=(const SCVector& v);

  double  operator()(const int i) const;
  double& operator()(const int i);

  void Print() const;
  void Initialize(double a);
  void Initialize(double *v);
};



/********************************/
/*        SCMatrix Class        */
/********************************/

class SCMatrix {
private:
  int rows, columns;
  
public:

  double **data;

  //Instantiate to be 1x1 and 0
  SCMatrix();
  //Instantiate to be dim x dim and all 0
  SCMatrix(int dim);
  //Instantiate to be rows1 x columns1 all 0
  SCMatrix(int rows1, int columns1);
  //Make a new matrix by copying m
  SCMatrix(const SCMatrix& m);
  //Make a new matrix by copying each of the vectors in q into a 
  //column of the new matrix.
  SCMatrix(int num_vectors, const SCVector * q);
  //Make a new matrix that is rows1 x columns1, the data is pointed to by rowptrs
  SCMatrix(int rows1, int columns1, double **rowptrs);
  //Make a new matrix that is rows1 x columns1.  The data is pointed to by data1 
  //and must be in row-major format.
  SCMatrix(int rows1 ,int columns1, double* data1);
  ~SCMatrix();

  //initialize to an m x n matrix full of zeros.
  void Initialize(int m,int n);


  //Copy the data in the data* in to the matrix.  
  //The matrix must already have the correct size to hold the data,
  // which can be done using the constructor or the initialize command.
  void set_data(double* data);
  double * GetData();

  //Write the matrix to file.
  void write(char* filename);

  void fill_random_ints(int min,int max);

  int Rows() const;
  int Columns() const;
  double ** GetPointer();
  void GetColumn(int col, SCVector &x);
  void GetColumn(int col, SCVector &x, int rowoffset);
  void PutColumn(int col, const SCVector &x);
  double Norm_l1();
  double Norm_linf();

  //************************
  // User Defined Operators
  //************************
  SCMatrix& operator=(const SCMatrix& m);
  double operator()(const int i, const int j) const;
  double& operator()(const int i, const int j);

  double MaxModInRow(int row);
  double MaxModInRow(int row, int starting_column);
  int MaxModInRowindex(int row);
  int MaxModInRowindex(int row, int starting_column);
 
  double MaxModInColumn(int column);
  double MaxModInColumn(int column, int starting_row);
  int MaxModInColumnindex(int column);
  int MaxModInColumnindex(int column, int starting_row);

  void RowSwap(int row1, int row2);

  void Print() const;

};


/********************************/
/*   Operator Declarations      */
/********************************/

// Unitary operator -
SCVector operator-(const SCVector& v);
SCMatrix operator-(const SCMatrix& A);

// Binary operator +,-
SCVector operator+(const SCVector& v1, const SCVector& v2);
SCVector operator-(const SCVector& v1, const SCVector& v2);
SCMatrix operator+(const SCMatrix& A, const SCMatrix& B);
SCMatrix operator-(const SCMatrix& A, const SCMatrix& B);


// SCVector Scaling (multiplication by a scaler : defined commutatively)
SCVector operator*(const double s, const SCVector& v);
SCVector operator*(const SCVector& v, const double s);
SCMatrix operator*(const SCMatrix& M, const double s);
SCMatrix operator*(const double s, const SCMatrix& M);


// SCVector Scaling (division by a scaler)
SCVector operator/(const SCVector& v, const double s);

SCVector operator*(const SCMatrix& A, const SCVector& x); 
SCMatrix operator*(const SCMatrix& A,const SCMatrix& B);

/********************************/
/*   Function Declarations      */
/********************************/

int min_dimension(const SCVector& u, const SCVector& v);
double dot(const SCVector& u, const SCVector& v); 
double dot(int N, double *a, double *b);
double dot(int N, const SCVector &u, const SCVector &v); 
void Swap(double &a, double &b);
double Sign(double x);

/* Misc. useful functions to have */
double log2(double x);
double GammaF(double x);
int Factorial(int n);
double ** CreateMatrix(int m, int n);
void DestroyMatrix(double ** mat, int m, int n); 

int ** ICreateMatrix(int m, int n);
void IDestroyMatrix(int ** mat, int m, int n);

void get_dims_textfile(char* filename,int* M,int* N);

double* load_rows(char* filename,int firstrow,int lastrow);
double* load_columns(char* filename,int firtcol,int lastcol);
double* load_block(char* filename,int brow,int bcolumn, int bwidth,int bheight);


#endif

