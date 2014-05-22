class CountToBreak {
    public static void main(String[] args) {
	for (int i = 1; i <= 10; i = i + 1) {
	    if (i == 8) {
		break;
	    } else {
		System.out.println(i);
	    }
	}
    }
}
