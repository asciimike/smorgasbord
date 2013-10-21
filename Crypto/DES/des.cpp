/*
 * Mike McDonald
 * CSSE 479 Homework 4
 * DES!
 * Compile: g++ des.cpp -o des or make des
 * Run: ./des desinput.txt
 * The file desinput.txt has 4 things: number of iterations, number of rounds, message (64 bits), and key (64 bits)
 */

#include<iostream>
#include<fstream>
#include<math.h>
#include <stdlib.h>
#include <stdint.h>
#include <string>
#include <bitset>
using namespace std;

//#define DEBUG	//debug macro, comment out if you don't want my annoying messages

uint64_t PermuteLength(uint64_t input, int* constants, int listLength, int bitLength);
uint64_t GetRoundKey(uint64_t key, int round);
uint8_t SBox(uint8_t b, int* s);

//Note that this is 1 indexed...
int IP[64] = {58,50,42,34,26,18,10,2,60,52,44,36,28,20,12,4,62,54,46,38,30,22,14,6,64,56,48,40,32,24,16,8,57,49,41,33,25,17,9,1,59,51,43,35,27,19,11,3,61,53,45,37,29,21,13,5,63,55,47,39,31,23,15,7};
int FP[64] = {40,8,48,16,56,24,64,32,39,7,47,15,55,23,63,31,38,6,46,14,54,22,62,30,37,5,45,13,53,21,61,29,36,4,44,12,52,20,60,28,35,3,43,11,51,19,59,27,34,2,42,10,50,18,58,26,33,1,41,9,49,17,57,25};
int ER[48] = {32,1,2,3,4,5,4,5,6,7,8,9,8,9,10,11,12,13,12,13,14,15,16,17,16,17,18,19,20,21,20,21,22,23,24,25,24,25,26,27,28,29,28,29,30,31,32,1};
int KP[56] = {57,49,41,33,25,17,9,1,58,50,42,34,26,18,10,2,59,51,43,35,27,19,11,3,60,52,44,36,63,55,47,39,31,23,15,7,62,54,46,38,30,22,14,6,61,53,45,37,29,21,13,5,28,20,12,4};
int LS[16] = {1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1};
int KP2[48] = {14,17,11,24,1,5,3,28,15,6,21,10,23,19,12,4,26,8,16,7,27,20,13,2,41,52,31,37,47,55,30,40,51,45,33,48,44,49,39,56,34,53,46,42,50,36,29,32};
int S1[64] = {14,4,13,1,2,15,11,8,3,10,6,12,5,9,0,7,0,15,7,4,14,2,13,1,10,6,12,11,9,5,3,8,4,1,14,8,13,6,2,11,15,12,9,7,3,10,5,0,15,12,8,2,4,9,1,7,5,11,3,14,10,0,6,13};
int S2[64] = {15,1,8,14,6,11,3,4,9,7,2,13,12,0,5,10,3,13,4,7,15,2,8,14,12,0,1,10,6,9,11,5,0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15,13,8,10,1,3,15,4,2,11,6,7,12,0,5,14,9};
int S3[64] = {10,0,9,14,6,3,15,5,1,13,12,7,11,4,2,8,13,7,0,9,3,4,6,10,2,8,5,14,12,11,15,1,13,6,4,9,8,15,3,0,11,1,2,12,5,10,14,7,1,10,13,0,6,9,8,7,4,15,14,3,11,5,2,12};
int S4[64] = {7,13,14,3,0,6,9,10,1,2,8,5,11,12,4,15,13,8,11,5,6,15,0,3,4,7,2,12,1,10,14,9,10,6,9,0,12,11,7,13,15,1,3,14,5,2,8,4,3,15,0,6,10,1,13,8,9,4,5,11,12,7,2,14};
int S5[64] = {2,12,4,1,7,10,11,6,8,5,3,15,13,0,14,9,14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6,4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14,11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3};
int S6[64] = {12,1,10,15,9,2,6,8,0,13,3,4,14,7,5,11,10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8,9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6,4,3,2,12,9,5,15,10,11,14,1,7,6,0,8,13};
int S7[64] = {4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1,13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6,1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2,6,11,13,8,1,4,10,7,9,5,0,15,14,2,3,12};
int S8[64] = {13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7,1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2,7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8,2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11};
int PC[32] = {16,7,20,21,29,12,28,17,1,15,23,26,5,18,31,10,2,8,24,14,32,27,3,9,19,13,30,6,22,11,4,25};

int main(int argc, char** argv){
	//Variable declarations
	string iterations, rounds, message, key;
	int ITERATION, ROUND;
	uint64_t MESSAGE, KEY;
	
	//Process input from command line, check for input file
	if (argc<2){
		cerr<<"Please enter an input file"<<endl;
		return 1;
	}
	
	//Deal with file input (reading the four values from the input file)
	ifstream input;
	input.open(argv[1]);
	if(input.is_open()){
		getline(input, iterations);
		getline(input, rounds);
		getline(input, message);
		getline(input, key);
		input.close();
	}
	else{
		cout << "Error opening file: " << argv[1] << endl;
	}
	
	//Convert from string to respective integer and 64 bit integer types
	char* end;
	ITERATION = atoi(iterations.c_str());
	ROUND = atoi(rounds.c_str());
	MESSAGE = strtol(message.c_str(), &end, 2);
	KEY = strtol(key.c_str(), &end, 2);
	
	//Print out the number of iterations and number of rounds per iteration
	cout << "There will be " << ITERATION << " iterations in each of " << ROUND << " rounds\n";
	
	//Print out the 64 bit binary representations of the values M and K
	bitset<64> m(MESSAGE);
	bitset<64> k(KEY);
	cout << "The message is: " << m << "\nThe key is: " << k << endl;
	
	if(ITERATION < 1){
		cout << "You should probably run this more than zero times...\n";
		return 0;
	}
	
	//Loop over I iterations
	int iteration, round;
	uint64_t p = 0;
	uint64_t L = 0;
	uint64_t R = 0;
	uint64_t C = 0;	//C0 is zero
	for(iteration = 0; iteration < ITERATION; iteration++){
		//XOR on previous C for CBC
		p = MESSAGE ^ C;
		
		//Initial permutation
		C = PermuteLength(p,IP,64,64);
		
		#ifdef DEBUG
		bitset<64> InitPerm(C);
		cout << "IP: " << InitPerm << endl;
		#endif
		
		//Set up L0 and R0
		L = C >> 32;
		R = C & 0x00000000FFFFFFFFL;
		
		//Iterate through rounds
		for(round = 0; round < ROUND; round++){

			#ifdef DEBUG
			bitset<32> l(L);
			bitset<32> r(R);
			cout << "L" << round << ": " << l << endl;
			cout << "R" << round << ": " << r << endl;
			#endif
			
			//Store R for later use
			uint64_t temp = R;
			
			//Expand R
			R = PermuteLength(R,ER,48,32);
			
			#ifdef DEBUG
			bitset<48> e(R);
			cout << "E(R)" << round << ": " << e << endl;
			#endif
			
			//XOR with the Key
			uint64_t RK = GetRoundKey(KEY, round+1);
			R = R ^ RK;
			
			#ifdef DEBUG
			bitset<48> xrk(R);
			cout << "E(R) (+) RK" << round << ": " << xrk << endl;
			#endif
			
			//Chunk into 8 6-bit sections B1...B8 via bit masks and shifts
			uint8_t B[8];
			B[0] = (R & 0xFC0000000000L) >> 42;
			B[1] = (R & 0x03F000000000L) >> 36;
			B[2] = (R & 0x000FC0000000L) >> 30;
			B[3] = (R & 0x00003F000000L) >> 24;
			B[4] = (R & 0x000000FC0000L) >> 18;
			B[5] = (R & 0x00000003F000L) >> 12;
			B[6] = (R & 0x000000000FC0L) >> 6;
			B[7] = (R & 0x00000000003FL);
			
			//Put sections through S-boxes
			B[0] = SBox(B[0], S1);
			B[1] = SBox(B[1], S2);
			B[2] = SBox(B[2], S3);
			B[3] = SBox(B[3], S4);
			B[4] = SBox(B[4], S5);
			B[5] = SBox(B[5], S6);
			B[6] = SBox(B[6], S7);
			B[7] = SBox(B[7], S8);
			
			//Permute 8 4-bit sections into C1...C8, this becomes R(round+1)
			C = (B[0] << 28) | (B[1] << 24) | (B[2] << 20) | (B[3] << 16) | (B[4] << 12) | (B[5] << 8) | (B[6] << 4) | B[7];
			
			#ifdef DEBUG
				bitset<32> printBC(C);
				cout << "Before Permutation C" << round << ": " << printBC << endl;
			#endif
			
			C = PermuteLength(C,PC,32,32);
			
			#ifdef DEBUG
				bitset<32> printC(C);
				cout << "f(R,K)" << round << ": " << printC << endl;
			#endif
			
			//Swap sides and get ready for another go
			R = C ^ L;
			L = temp;
		}
		
		//Iteration has ended so compute the final C before looping back
		bitset<32> alL(L);
		bitset<32> alR(R);
		
		#ifdef DEBUG
		cout << "L" << ROUND << ": " << alL << endl;
		cout << "R" << ROUND << ": " << alR << endl;
		#endif
		
		uint64_t almost = (R << 32) | L;
		#ifdef DEBUG
			bitset<64> alm(almost);
			cout << "almost: " << alm << endl;
		#endif
			
		//Final permutation
		C = PermuteLength(almost,FP,64,64);
	}
	
	//Print out the ([not]pen)ultimate permutation
	bitset<64> FinPerm(C);
	cout << "FP: " << FinPerm << endl;

	return 0;
}

//This function is magic.  Honestly, I have no idea how it works.  I wrote it at 2AM in a moment of clarity that I will probably never relive, and I consider it one of my finest works in computer science.

//Function takes up to a 64 bit argument and returns a 64 bit argument, length is the length of the input list
//Note that the indexing is "reversed" in that DES indexes 1-64 L-R, while C++ indexes 0-63 R-L.  This function handles that perfectly.
uint64_t PermuteLength(uint64_t input, int* constants, int listLength, int bitLength){
	uint64_t permuted_input = 0L;
	int i;
	bool bit = 0;
	for(i = 0; i < listLength; i++){
		//Pick off the bit located at the IP value
		bit = input & (1L << (bitLength - (constants[i])));
		//Add a bit on on the other side if the bit was a 1
		if(bit > 0){
			permuted_input |= (1L << (listLength - 1 - i));
		}
	}
	return permuted_input;
}

//Returns 48 bits of a round key given the 64-bit input key and the round
uint64_t GetRoundKey(uint64_t key, int round){
	uint64_t roundKey = 0L;
	
	//Permute key according to KP
	roundKey = PermuteLength(key, KP, 56, 64);
	
	#ifdef DEBUG
	bitset<56> hsh(roundKey);
	cout << "Permuted initial key is: " << hsh << endl;
	#endif
	
	uint64_t C0 = roundKey >> 28;
	uint64_t D0 = roundKey & 0x000000000FFFFFFF;
	
	//Shift bits in C and D around according to LS
	int j,sum = 0;
	for(j = 0; j < round; j++){
		sum += LS[j];
	}
	
	//Rotations, basically a shift, mask, and addition of the part that "overflowed" back to the beginning
	uint64_t CR = C0 << sum;
	uint32_t Cextra = (CR & 0xFFFFFFFFF0000000) >> 28;
	CR = (CR & 0x000000000FFFFFFF) | Cextra;
	
	uint64_t DR = D0 << sum;
	uint32_t Dextra = (DR & 0xFFFFFFFFF0000000) >> 28;
	DR = (DR & 0x000000000FFFFFFF) | Dextra;
	
	#ifdef DEBUG
	bitset<28> cr(CR);
	cout << "C" << round << ": " << cr << endl;
	bitset<28> dr(DR);
	cout << "D" << round << ": " << dr << endl;
	#endif
	
	//Choose 48 bits from 56 bits from KP2
	roundKey = ((CR & 0x000000000FFFFFFF) << 28) | (DR & 0x000000000FFFFFFF);
	
	#ifdef DEBUG
	bitset<56> bk2(roundKey);
	cout << "Before KP2 key is: " << bk2 << endl;
	#endif
	
	roundKey = PermuteLength(roundKey, KP2, 48, 56);
	
	#ifdef DEBUG
	bitset<48> ak2(roundKey);
	cout << "After KP2 key is: " << ak2 << endl;
	#endif
	
	return roundKey;
}

//Takes a 6-bit input and runs it through a given S box
uint8_t SBox(uint8_t b, int* s){
	unsigned int row, column;
	row = ((b & 0b00100000) >> 4) | (b & 0b00000001);	//pick off row from b1 and b6
	column = (b & 0b00011110) >> 1;	//pick off column from b2-b5
	int c = s[row*16+column];	//look it up in the S-box
	return c;
}