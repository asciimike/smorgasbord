#include "stopwatch.h"

using namespace std;
double stopwatch::get_time(){
  int status;
  double time_in_secs;
  status=clock_gettime(CLOCK_MONOTONIC_RAW, &tv);
  if (status==-1){
    cerr<<"Error getting time. Abort."<<endl;
    exit;
  }
  time_in_secs=tv.tv_sec+(double)(tv.tv_nsec)/1e9;
  return time_in_secs;
}

double stopwatch::get_resolution(){
  int status;
  double resolution;
  status=clock_getres(CLOCK_MONOTONIC_RAW, &tv);
  if (status==-1){
    cerr<<"Error getting time resolution. Abort."<<endl;
    exit;
  }
  resolution=tv.tv_sec+(double)(tv.tv_nsec)/1e9;
  return resolution;
  

}
