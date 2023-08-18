package create.singleton;


/**
 * 线程安全，调用效率高，不能延时加载，可以天然的防止反射和反序列化调用
 */
public enum Singleton9 {
    INSTANCE("Hello");
    private String name;
    Singleton9(String name) {
        this.name = name;
    }

    public static void main(String[] argus) throws ClassNotFoundException, IllegalAccessException, InstantiationException {
//        Class<Singleton9> singletonClass = (Class<Singleton9>) Class.forName("create.singleton.Singleton9");
//        Singleton9 instance = singletonClass.newInstance();

        Class clazz = Class.forName("create.singleton.Singleton9");

        Singleton9 obj = (Singleton9) Enum.valueOf(clazz, String.valueOf(Singleton9.INSTANCE));
        System.out.println(Singleton9.INSTANCE.hashCode());
        System.out.println(obj.hashCode());
    }
}