uint64_t InitialPermutation(uint64_t plaintext);
uint64_t Permute(uint64_t plaintext, int* constants);

uint64_t InitialPermutation(uint64_t plaintext){
	uint64_t permuted_plaintext = 0;
	int i;
	bool bit = 0;
	for(i = 0; i < 64; i++){
		//Pick off the bit located at the IP value
		bit = plaintext & (1L << (IP[i]-1));
		//Add a bit on on the other side if the bit was a 1
		if(bit) permuted_plaintext |= (1L << i);
		
		bitset<1> b(bit);
		cout << "Bit " << i << " is a " << b << " is from bit " << IP[i] << endl;
		

	}
	bitset<64> a(permuted_plaintext);
	cout << "IP: " << a << endl;
	return permuted_plaintext;
}

uint64_t Permute(uint64_t input, int* constants){
	uint64_t permuted_input = 0;
	int i;
	bool bit = 0;
	for(i = 0; i < 64; i++){
		//Pick off the bit located at the IP value
		bit = input & (1L << (constants[i]-1));
		//Add a bit on on the other side if the bit was a 1
		if(bit) permuted_input |= (1L << i);
		
		bitset<1> b(bit);
		cout << "Bit " << i << " is a " << b << " is from bit " << IP[i] << endl;
		

	}
	bitset<64> a(permuted_input);
	cout << "IP: " << a << endl;
	return permuted_input;
}

THIS WORKS SO DON'T FUCKING TOUCH IT
//Function takes up to a 64 bit argument and returns a 64 bit argument, length is the length of the input list
uint64_t PermuteLength(uint64_t input, int* constants, int listLength, int bitLength){
	uint64_t permuted_input = 0;
	int i;
	bool bit = 0;
	for(i = 0; i < listLength; i++){
		//Pick off the bit located at the IP value
		bit = input & (1LL << (bitLength - constants[i]));
		//Add a bit on on the other side if the bit was a 1
		if(bit == 1){
			permuted_input |= (1LL << (bitLength - 1 - i));
		}
		
		cout << "Bit " << i+1 << " is a " << bit << " is from bit " << constants[i] << endl;
	}
	return permuted_input;
}