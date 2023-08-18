package create.singleton;

/**
 * 但是无法保证线程安全，不建议使用。多线程是很常用的，不能保证线程安全是无法被接受的，不被承认为一种实现方式。
 */
public class Singleton3 {
    protected static Singleton3 INSTANCE;
    protected Singleton3() { }

    public Singleton3 getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new Singleton3();
        }
        return INSTANCE;
    }
}
