import java.util.Comparator;


public class FrequencyComparator implements Comparator<String> {
	private String letter;
	
	public FrequencyComparator(String l){
		this.letter = l;
	}

	@Override
	public int compare(String x, String y) {
		if(numberOfLetters(x, this.letter) < numberOfLetters(y, this.letter)){
			return 1;
		}else if(numberOfLetters(x, this.letter) > numberOfLetters(y, this.letter)){
			return -1;
		}else{
			return 0;
		}
	}
	
	private int numberOfLetters(String s, String l){
		int num = 0;
		for(int i = 0; i < s.length(); i++){
			if(s.charAt(i) == l.charAt(0)){
				num++;
			}
		}
		return num;
	}

}
