class CountToNot3 {
    public static void main(String[] args) {
	for (int i = 1; i <= 10; i = i + 1) {
	    if (i == 3) {
		continue;
	    } else {
		System.out.println(i);
	    }
	}
    }
}
