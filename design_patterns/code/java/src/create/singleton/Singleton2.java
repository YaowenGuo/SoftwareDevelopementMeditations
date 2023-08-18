package create.singleton;

/**
 * 静态代码块，跟第一种一样。<strong>多几行代码不干净。不要使用这种写法，直接使用方式一。</>
 */
public class Singleton2 {
    protected static volatile Singleton2 SINGLETON;
    static {
        SINGLETON = new Singleton2();
    }

    protected Singleton2() {
    }

    protected static Singleton2 getInstance() {
        if (SINGLETON == null) {
            SINGLETON = new Singleton2();
        }
        return SINGLETON;
    }
}
