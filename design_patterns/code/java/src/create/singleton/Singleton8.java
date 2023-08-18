package create.singleton;


/**
 * 静态内部类实现
 */
public class Singleton8 {
    protected Singleton8() { }

    protected static class Instance {
        protected static final Singleton8 SINGLETON = new Singleton8();
    }


    public static Singleton8 getInstance() {
        return Instance.SINGLETON;
    }

    public static void main(String[] argus) throws ClassNotFoundException, IllegalAccessException, InstantiationException {
        Class<Singleton8> singletonClass = (Class<Singleton8>) Class.forName("create.singleton.Singleton8");

        Singleton8 instance = singletonClass.newInstance();
        System.out.println(instance.hashCode());
    }
}