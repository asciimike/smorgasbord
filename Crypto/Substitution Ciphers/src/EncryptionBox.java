import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.Scanner;


public class EncryptionBox {
	
	private File input;
	private File output;
	private int alpha;
	private int beta;

	public EncryptionBox(File inputFile, File outputFile, int alpha, int beta) {
		this.input = inputFile;
		this.output = outputFile;
		this.alpha = alpha;
		this.beta = beta;
	}
	
	public boolean encrypt(){
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
							line = line.trim();
							line = line.replaceAll("\\s", "");
							line = line.toLowerCase();
							System.out.println("Plaintext is: " + line);
							line = encryptLine(line);
							line = line.toUpperCase();
							System.out.println("Ciphertext is: " + line);
							writer.println(line);
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

	private String encryptLine(String line) {
		String newLine = "";
		int read;
		for(int i = 0; i < line.length(); i++){
			read = line.charAt(i);
			read = this.alpha*(read - 97) + this.beta;
			read = read % 26;
			read = read + 97;
			newLine += (char) read;
		}
		return newLine;
	}	
}
