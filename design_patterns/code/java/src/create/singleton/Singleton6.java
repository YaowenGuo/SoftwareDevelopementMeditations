package create.singleton;

/**
 * 也被称为 DCL （Double Check Lock） 实现。
 * 由于JVM底层模型原因，偶尔会出问题，不建议使用
 */
public class Singleton6 {
    protected static volatile Singleton6 INSTANCE;

    protected Singleton6() { }

    public static Singleton6 getInstance() {
        if (INSTANCE == null) {
            synchronized (Singleton6.class) {
                if (INSTANCE == null) {
                    INSTANCE = new Singleton6();
                }
            }
        }
        return INSTANCE;
    }
}
