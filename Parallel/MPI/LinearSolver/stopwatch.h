#include<iostream>
#include<stdlib.h>
#include<time.h>

class stopwatch{

 public:
  double get_time();
  double get_resolution();

 private: 
  struct timespec tv;


};
