/*
 * Mike McDonald
 * 5/1/2013
 * CSSE 479 Homework 8
 * SHA-1
 * Compile: g++ sha.cpp -o sha
 * Run: ./sha sha_input.txt
 * The file sha_input has one input, the message to be hashed (less than 2^32 bits) and produces a 160 bit digest
 */

#include<iostream>
#include<fstream>
#include<math.h>
#include <stdlib.h>
#include <stdint.h>
#include <string>
#include <bitset>
using namespace std;

uint32_t rotateLeft32(uint32_t word, int n);

//#define DEBUG	//debug macro, comment out if you don't want my annoying messages

#define k0 0x5a827999
#define k1 0x6ed9eba1
#define k2 0x8f1bbcdc
#define k3 0xca62c1d6

int main(int argc, char** argv){
	
	//Process input from command line, check for input file
	if (argc<2){
		cerr<<"Please enter an input file"<<endl;
		return 1;
	}
	
	//Create storage for the message input
	string message;
	
	//Read the message in from the file
	ifstream input;
	input.open(argv[1]);
	if(input.is_open()){
		getline(input, message);
		input.close();
	}
	else{
		cout << "Error opening file: " << argv[1] << endl;
	}
	
	//Calculate the length of the message and remainder, as well as the number of 512 bit chunks
	uint64_t msgLength = message.length();
	uint64_t msgFull = msgLength / 4;
	uint64_t remLength = msgLength % 4;	//mod 4 is for each 32 bit word
	uint64_t msgBits = msgLength * 8;
	uint64_t remBits = remLength * 8;
	uint64_t chunks = (msgBits / 512) + 1;
	
	cout << "Message is: " << message << endl;
	
	#ifdef DEBUG
	cout << "Message is: " << message << " with length " << msgLength << " and remainder (mod 4) " << remLength << endl;
	cout << "It has " << msgBits << " bits with " << remBits << " bits left over\n";
	cout << "There are " << chunks << " chunks, each of 512 bits\n";
	#endif
	
	uint32_t msg[chunks*16];	//Number of 512 bit chunks of 32 bit integers
	
	//Initialize message to zero
	for(int i = 0; i < chunks*16; i++){
		msg[i] = 0;
	}
	
	//Fill message with the correct values (32 bits each)
	for(int i = 0; i < msgLength; i = i+4){
		msg[i/4] = (message[i] << 24) | (message[i+1] << 16) | (message[i+2] << 8) | message[i+3];
		#ifdef DEBUG
		//printf("Message %d is %x\n",i/4,msg[i/4]);
		#endif
	}
	
	//Add the padding (1 and then zero's to 448)
	uint32_t pad;
	switch(remLength){
		case 0:
			pad = 0x80000000;
			break;
	
		case 1:
			pad = 0x00800000;
			break;
			
		case 2:
			pad = 0x00008000;
			break;
	
		case 3:
			pad = 0x00000080;
			break;
	}
	msg[msgFull] |= pad;
	
	//Add length of the message to the last 64 bits (note bit anding is probably redundent)
	msg[chunks*16-2] = (0xFFFFFFFF00000000 & msgBits) >> 32;
	msg[chunks*16-1] = 0x00000000FFFFFFFF & msgBits;
	
	//Print out the completed message in 32 bit words
	#ifdef DEBUG
	for(int i = 0; i < chunks*16; i++){
		printf("Message[%d]=%8x\n",i,msg[i]);
	}
	#endif
	
	//Initialize h0-h4 as their initial constants
	uint32_t h0 = 0x67452301;
	uint32_t h1 = 0xEFCDAB89;
	uint32_t h2 = 0x98BADCFE;
	uint32_t h3 = 0x10325476;
	uint32_t h4 = 0xC3D2E1F0;
	
	//Iterate over the number of chunks
	for(int ch = 0; ch < chunks; ch++){
		int chunkStart = ch*16;	//start location of the current chunk, goes for another 15 words
		uint32_t words[80];
		
		//Create w[0] to w[15]
		for(int i = 0; i < 16; i++){
			words[i] = msg[chunkStart+i];
		}
		
		//Create w[16] to w[79]
		for(int i = 16; i < 80; i++){
			words[i] = rotateLeft32((words[i-3] ^ words[i-8] ^ words[i-14] ^ words[i-16]),1);
		}
		
		//Print out words for the current chunk
		#ifdef DEBUG
		cout << "Words for chunk " << ch << " starting at msg[" << chunkStart << "]\n";
		for(int i = 0; i < 80; i++){
			printf("W[%d]=%8x\n",i,words[i]);
		}
		#endif
		
		//Create and initialize a-e for the current chunk
		uint32_t a,b,c,d,e;
		a = h0;
		b = h1;
		c = h2;
		d = h3;
		e = h4;
		
		//Print initial a-e for the current chunk
		#ifdef DEBUG
		printf("chunk %d a = %8x b = %8x c = %8x d =%8x e = %8x\n", ch, a, b, c, d, e);
		#endif
		
		//Create storage for the nonlinear function and the round keys
		uint32_t f,k;
		
		//Main loop of the program
		for(int i = 0; i < 80; i++){
			//Choose nonlinear function and the key
			if(i >= 0 && i <= 19){
				f = ((b & c) | (~b & d));
				k = k0;
			}else if(i >= 20 && i <= 39){
				f = (b ^ c ^ d);
				k = k1;
			}else if(i >= 40 && i <= 59){
				f = ((b & c) | (b & d) | (c & d));
				k = k2;
			}else if(i >= 60 && i <= 79){
				f = (b ^ c ^ d);
				k = k3;
			}
			
			//Swap values
			uint32_t temp;
			temp = rotateLeft32(a,5) + f + e + k + words[i];
			e = d;
			d = c;
			c = rotateLeft32(b,30);
			b = a;
			a = temp;
			
			//Print out a-e for each round
			#ifdef DEBUG
			printf("i = %d a = %8x b = %8x c = %8x d =%8x e = %8x\n", i, a, b, c, d, e);
			#endif
		}
		
		//Add values on to h0-h4
		h0 += a;
		h1 += b;
		h2 += c;
		h3 += d;
		h4 += e;
		
		//Print out h values for each chunk
		#ifdef DEBUG
		printf("h0 = %8x h1 = %8x h2 = %8x h3 =%8x h4 = %8x\n", h0, h1, h2, h3, h4);
		#endif
	}
	
	//Print the message digest
	printf("Digest is: %08x%08x%08x%08x%08x\n", h0, h1, h2, h3, h4);
	
}

//Function to rotate 32 bit values left by n bits
uint32_t rotateLeft32(uint32_t word, int numBits){
	return ((word << numBits) | (word >> (32 - numBits)));
}