package create.singleton;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

public class Singleton7 implements Serializable {
    protected static volatile Singleton7 INSTANCE;

    protected Singleton7() { }

    public static Singleton7 getInstance() {
        if (INSTANCE == null) {
            synchronized (Singleton7.class) {
                if (INSTANCE == null) {
                    INSTANCE = new Singleton7();
                }
            }
        }
        return INSTANCE;
    }

    protected Object readResolve() {
        System.out.println("调用了readResolve方法");
        return Singleton7.getInstance();
    }

    public static void main(String[] argus) throws IOException, ClassNotFoundException {
        Singleton7 obj1 = Singleton7.getInstance();
        System.out.println(obj1.hashCode());
        //序列化
        FileOutputStream fo = new FileOutputStream("singleton");
        ObjectOutputStream oo = new ObjectOutputStream(fo);
        oo.writeObject(obj1);
        oo.close();
        fo.close();

        //反序列化
        FileInputStream fi = new FileInputStream("singleton");
        ObjectInputStream oi = new ObjectInputStream(fi);
        Singleton7 obj2 = (Singleton7) oi.readObject();
        oi.close();
        fi.close();
        System.out.println(obj2.hashCode());
    }
}
