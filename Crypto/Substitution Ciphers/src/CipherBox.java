import java.io.File;
import java.io.PrintWriter;
import java.util.Scanner;


public class CipherBox {
	private static String inputFileName;
	private static String operation;
	private static File inputFile;
	private static String outputFileName;
	private static File outputFile;
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		

		Boolean validInput = false;
		
		Scanner console = new Scanner(System.in);
		System.out.println("Welcome to CipherBox, a Substitution Cipher Based Encryption and Decryption tool.\n");
		System.out.println("Do you wish to encrypt or decrypt (E/D): ");
		operation = console.next();
		while(!validInput){
			if(operation.equals("E")){
				validInput = true;
				System.out.println("Please enter the name of a .txt file for the plaintext input: ");
				inputFileName = console.next();
			    inputFile = new File(inputFileName);
			    
			    System.out.println("Please enter the name of a .txt file for the ciphertext output: ");
				outputFileName = console.next();
			    outputFile = new File(outputFileName);
				
				System.out.println("Caesar chipher or Affine cipher? (C/A)");
				EncryptionBox encryption = null;
			    boolean validIn = false;
			    while(!validIn){
			    	String type = console.next();
				    if(type.equals("A")){
				    	System.out.println("Please enter your chosen alpha key: ");
						String alphaIn = console.next();
						int alpha = Integer.parseInt(alphaIn);
						
						System.out.println("Please enter your chosen beta key: ");
						String betaIn = console.next();
						int beta = Integer.parseInt(betaIn);
				    	
				    	encryption = new EncryptionBox(inputFile, outputFile, alpha, beta);
						System.out.println("Decryption of Affine cipher in progress...\n");
						validIn = true;
				    }else if(type.equals("C")){
					    System.out.println("Please enter your chosen encryption key: ");
						String keyIn = console.next();
						int key = Integer.parseInt(keyIn);
				    	encryption = new EncryptionBox(inputFile, outputFile, 1, key);	//caesar chipers are just affine ciphers with alpha = 1
						System.out.println("Decryption of Caesar cipher in progress...\n");
						validIn = true;
				    }else{
				    	System.out.println("Please choose to decrypt either a Caesar chipher or an Affine cipher (C/A)");
				    }
			    }
			    
				
				System.out.println("Encryption in progress...\n");
				boolean success = encryption.encrypt();
				if(success){
					System.out.println("Encryption finished!\n");
				}else{
					System.out.println("Encryption failed!\n");
				}
				
				//encrypt message
			}else if(operation.equals("D")){
				validInput = true;
				
				System.out.println("Please enter the name of a .txt file for the ciphertext input: ");
				inputFileName = console.next();
			    inputFile = new File(inputFileName);
			    
			    System.out.println("Please enter the name of a .txt file for the plaintext output: ");
				outputFileName = console.next();
			    outputFile = new File(outputFileName);
			    
			    System.out.println("Caesar chipher or Affine cipher? (C/A)");
			    DecryptionBox decryption = null;
			    boolean validIn = false;
			    while(!validIn){
			    	String type = console.next();
				    if(type.equals("A")){
				    	 decryption = new DecryptionBox(inputFile, outputFile, true);
						System.out.println("Decryption of Affine cipher in progress...\n");
						validIn = true;
				    }else if(type.equals("C")){
				    	decryption = new DecryptionBox(inputFile, outputFile, false);
						System.out.println("Decryption of Caesar cipher in progress...\n");
						validIn = true;
				    }else{
				    	System.out.println("Please choose to decrypt either a Caesar chipher or an Affine cipher (C/A)");
				    }
			    }
			    
				boolean success = decryption.decrypt();
				if(success){
					System.out.println("Decryption finished!\n");
				}else{
					System.out.println("Decryption failed!\n");
				}
				//decrypt message
			}else{
				System.out.println("Please enter a valid operation (E/D): ");
				operation = console.next();
			}
		}
	}
}