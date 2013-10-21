import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.Comparator;
import java.util.PriorityQueue;
import java.util.Scanner;

public class DecryptionBox {
	private File input;
	private File output;
	private Boolean affine;
	private final int affineInverses[] = {1,9,21,15,3,19,7,23,11,5,17,25}; //1,3,5,7,11,15,17,19,21,23,25

	public DecryptionBox(File inputFile, File outputFile, Boolean isAffine) {
		this.input = inputFile;
		this.output = outputFile;
		this.affine = isAffine;
	}
	
	public boolean decrypt(){
		
		Comparator<String> frequencyE = new FrequencyComparator("e");
		PriorityQueue<String> pq = new PriorityQueue<String>(26, frequencyE);
		boolean goodFile = false;
		Scanner reader = null;
		while(!goodFile){
			try {
				reader = new Scanner(this.input);
				PrintWriter writer = null;
				while (!goodFile){
					try {
						writer = new PrintWriter(this.output);
						while (reader.hasNext()) {
							String line = reader.nextLine();
							String changeLine;
							line = line.trim();
							line.replaceAll("\\s", "");
							line = line.toUpperCase();
							System.out.println("Ciphertext is: " + line);
							//For Caesar chipers
							if(!this.affine){
								for(int i = 1; i < 26; i++){
									changeLine = decryptLine(line, i);
									changeLine = changeLine.toLowerCase();
									System.out.println("Plaintext guess for k = " + i + " is: " + changeLine);
									pq.offer(changeLine);
								}
							//For Affine ciphers
							}else if(this.affine){
								for(int i : affineInverses){
									for(int j = 1; j < 26; j++){
										changeLine = decryptAffineLine(line, i, j);
										changeLine = changeLine.toLowerCase();
										System.out.println("Plaintext guess with alpha = " + i + " and beta = " + j + " is: " + changeLine);
										pq.offer(changeLine);
									}
								}
							}
							while(pq.size() != 0){
								writer.println(pq.poll());
							}
						}
						goodFile = true;
					} catch (FileNotFoundException exception) {
						System.out.println("File " + this.output.toString() + " not found.");
						return false;
					} finally {
						writer.close();
					}
				}
			} catch (FileNotFoundException exception) {
				System.out.println("File " + this.input.toString() + " not found.");
				return false;
				
			} finally {
				try {
					reader.close();
					System.out.println("File closed");
				} catch (NullPointerException exception) {
					System.out.println("File not closed because file was not found.");
					return false;
				}
			}
			goodFile = true;  //ends the loop after the reader closes, or after the reader fails to close due to a null pointer exception.
		}
		return true;
	}

	private String decryptLine(String line, int keyGuess) {
		String newLine = "";
		int read;
		for(int i = 0; i < line.length(); i++){
			read = line.charAt(i);
			read = read - 65 + keyGuess;
			read = read % 26;
			read = read + 65;
			newLine += (char) read;
		}
		return newLine;
	}	
	
	private String decryptAffineLine(String line, int alpha, int beta) {
		String newLine = "";
		int read;
		for(int i = 0; i < line.length(); i++){
			read = line.charAt(i);
			read = (read - beta)*alpha;
			read = read % 26;
			read = read + 65;
			newLine += (char) read;
		}
		return newLine;
	}	
}
