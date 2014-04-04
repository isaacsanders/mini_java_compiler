public class MainClass {
  public static int main(String[] args) {
    Facter facter = new Facter();
    System.out.println(facter.fact(5));
    System.out.println(facter.fact(4));
    System.out.println(facter.fact(3));
    System.out.println(facter.fact(2));
    System.out.println(facter.fact(1));
  }
}

public class Facter {
  public int fact(int n) {
    if (n <= 0) {
      return 1;
    }

    int prod = 1;
    while (n > 0) {
      prod = prod * n;
      n = n - 1;
    }
    return prod;
  }
}
