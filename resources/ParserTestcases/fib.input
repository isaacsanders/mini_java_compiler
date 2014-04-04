public class MainClass {
  public static int main (String[] args) {
    Fibber fibber = new Fibber();
    System.out.println(fibber.fib(5));
    System.out.println(fibber.fib(4));
    System.out.println(fibber.fib(3));
    System.out.println(fibber.fib(2));
    System.out.println(fibber.fib(1));
  }
}

public class Fibber {
  public int fib(int n) {
    if (n <= 1) {
      return 1;
    }
    return fib(n - 1) + fib(n - 2);
  }
}
