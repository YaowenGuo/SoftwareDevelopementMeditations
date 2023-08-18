package create.singleton;

/**
 * 虽然实现了线程安全，但是获得同步锁的机制是非常耗时的，在绝大多数时候，对象都已经被实例化，即使如此，也要先获得锁，性能不够好。
 */
public class Singleton4 {
    protected static volatile Singleton4 INSTANCE;
    protected Singleton4() { }

    public synchronized Singleton4 getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new Singleton4();
        }
        return INSTANCE;
    }
}