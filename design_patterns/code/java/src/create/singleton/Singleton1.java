package create.singleton;

/**
 * <h1>饿汉式</h1>
 *
 * 在类加载到内存后，就实例化一个对象，Java 虚拟机保证一个类的类文件仅加载一次。
 * 由 Java 虚拟机保证线程安全，类加载、初始化完成之前，程序会别阻塞。
 * 优点：
 * 简单，线程安全。是最常用的一种方法。
 *
 * 缺点：
 * 1. 一旦引用类，无论是否使用都会创建对象。例如：
 * Class.forName() 或 variable instanceof <Class Name>
 *
 * （关于这点，需要根据应用场景选择。Java 类是懒加载的，不使用加载类文件进内存干啥？况且
 * 不是有 import 语句就加载，而是在访问到类的时候才加载。实际上也是可应用中最简单的一种时间。）
 *
 */
public class Singleton1 {
    protected static final Singleton1 INSTANCE = new Singleton1();

    protected Singleton1() {
    }

    public static Singleton1 getInstance() {
        return INSTANCE;
    }

    public static void main(String[] argus) throws ClassNotFoundException {
        Class className1 = Class.forName("create.singleton.Singleton1");

        Class className2 = Class.forName("create.singleton.Singleton1");

        System.out.println(className1.hashCode() == className2.hashCode());

    }
}
