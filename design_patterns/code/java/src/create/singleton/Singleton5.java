package create.singleton;

/**
 * 避免了每次都需要获得同步锁，提高了性能，但是不能保证仅创建一个实例。
 * 有一个线程判断为为 null, 此时线程切换到另一个线程，从而导致创建多个对象。
 */
public class Singleton5 {
    protected static volatile Singleton5 INSTANCE;
    protected Singleton5() {
    }

    public static Singleton5 getInstance() {
        if (INSTANCE == null) {
            // <------ 此时切换线程，将可能导致创建多个对象。
            synchronized (Singleton5.class) {
                INSTANCE = new Singleton5();
            }
        }
        return INSTANCE;
    }
}
