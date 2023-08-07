# Java 单例的最全讲解

> 整个系统仅需要对某个类实例化一个对象。并且有一个公共的访问点。

从定义中我们就可以看出，只要能保证仅提供一个唯一的实例，即可称为单例。因此才有了如此多的实现方式。

此外，有时候可能需要固定数量的实例，还能实现可控数量的实例化。这种类型也被成为单例。

为了和其他设计模式结合使用，例如，抽象工厂、工厂方法、Builder 常常使用单例实现，也会导致单例表现形式的变化。

**单例的各种写法从来都不是重点，不同的语言，因为语言特性有不同的写法。不应该像孔乙己一样纠结于“回”字有多少种写法。记住核心：保证整个系统中仅有一个（或固定数量的）实例。记住有多少种实现方式并不能让你成为一个技术大牛，根据实际的场景，适当选择，随机应变才能开发出好的软件。**

**我们并不是为了学习单例而学习，而是学习好的软件设计模式。**

## 1. 饿汉式

实现单例的核心要诀是：

1. 将构造方法设置为 `private`，避免随意的实例化。但是也会导致无法扩展子类，降低了可扩展性，因此常用的方式是设置为 `protect`.

2. 声明一个 `protect` 的静态变量，用于保存实例化的对象。

3. 提供一个 `public ` 的静态方法，用于控制对象的实例化，以及提供访问点。

最简单也是最常见的写法，就是懒汉式。

```java
public class Singleton1 {
    protected static final Singleton1 INSTANCE = new Singleton1();
    private Singleton1() {
    }

    public static Singleton1 getInstance() {
        return INSTANCE;
    }
}
```

在类加载到内存后，就实例化一个对象，Java 虚拟机保证一个类的类文件仅加载一次。由 Java 虚拟机保证线程安全，类加载、初始化完成之前，程序会别阻塞。

> 优点：
简单，线程安全。是最常用的一种方法。

> 缺点：
 
1. 一旦引用类，无论是否使用都会创建对象。例如：`Class.forName()` 或 `variable instanceof <Class Name>`
（关于这点，需要根据应用场景选择。Java 类是懒加载的，不使用加载类文件进内存干啥？况且不是有 import 语句就加载，而是在访问到类的时候才加载。实际上也是可应用中最简单的一种时间。）

此外，还有一种静态代码块的写法，这里仅作为展示，不推荐。

```java
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
```
静态代码块，跟第一种一样。多几行代码不干净。不要使用这种写法，直接使用方式一。

其实饿汉式已经能够满足一般场景的需要，同时有 JVM 保证线程安全，同时 class 仅被加载一次。但是总有一些人会各种假设，于是出现了另一种中写法，懒汉式延迟加载。

## 2. 懒汉式

懒汉式为了延迟加载，即仅访问到实例的时候，才实例化。

```java
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
```

这种写法无法保证线程安全，多线程在开发中是很常用的，不能保证线程安全是无法被接受的，不被承认为一种实现方式。

```Java
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
```

这种写法虽然实现了线程安全，但是获得同步锁的机制是非常耗时的，在绝大多数时候，对象都已经被实例化，即使如此，也要先获得锁，性能不够好。

为了避免每次都要获得同步锁，我们先判空。
```java
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
```

避免了每次都需要获得同步锁，提高了性能，但是不能保证仅创建一个实例。有一个线程判断为为 null, 此时线程切换到另一个线程，从而导致创建多个对象。

为了避免这种情况，于是出现了 Java 中一种常见的实现方式 `DCL （Double Check Lock 双重检查锁)`。

```java
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
```

### 几点问题

1. `volatile` 关键字防止指令重排

除了双重检查外，变量还要加 `volatile` 关键字防止指令重排，这是因为 Java 的编译方式和 JVM 的运行方式导致的。

Java 的实例化过程 `INSTANCE = new Singleton6();` 在 Java 代码中仅一行代码，但是它不是一个原子操作（要么全部执行完，要么全部不执行，不能执行一半），这行代码被编译成8条汇编指令，大致做了3件事情：

1.给 Singleton6 的实例分配内存。

2.初始化 Singleton6 的构造器

3.将 INSTANCE 对象指向分配的内存空间（注意到这步完成 INSTANCE 就非null了）。

由于Java编译器允许处理器乱序执行（out-of-order），以及JDK1.5之前JMM（Java Memory Medel）中Cache、寄存器到主内存回写顺序的规定，上面的第二点和第三点的顺序是无法保证的，也就是说，执行顺序可能是1-2-3也可能是1-3-2，如果是后者，并且在3执行完毕、2未执行之前，被切换到线程二上，这时候 INSTANCE 因为已经在线程一内执行过了第三点，INSTANCE 已经是非空了，所以线程二直接拿走 INSTANCE，然后使用，然后顺理成章地报错，而且这种难以跟踪难以重现的错误估计调试上一星期都未必能找得出来。

DCL的写法来实现单例是很多技术书、教科书（包括基于JDK1.4以前版本的书籍）上推荐的写法，实际上是不完全正确的。的确在一些语言（譬如C语言）上DCL是可行的，取决于是否能保证2、3步的顺序。在JDK1.5之后，官方已经注意到这种问题，因此调整了JMM、具体化了volatile关键字，因此如果JDK是1.5或之后的版本，只需要将INSTANCE 的定义加上 `volatile` 关键字，就可以保证每次都去 INSTANCE 都从主内存读取，并且可以禁止重排序，就可以使用DCL的写法来完成单例模式。当然volatile或多或少也会影响到性能，最重要的是我们还要考虑JDK1.42以及之前的版本，所以单例模式写法的改进还在继续。

2. 防止反序列化

其实当JVM从内存中反序列化地"组装"一个新对象时，就会自动调用这个 readResolve 方法来返回我们指定好的对象了, 单例规则也就得到了保证。readResolve()的出现允许程序员自行控制通过反序列化得到的对象。

```Java
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
```

3. 网上有种说法，这种懒加载的方式可以避免反射实例化，这种说法是不正确的，反射可以动态的将方法设置为可访问的。

可以看到，这种方法代码实现比较多，比较麻烦。下面介绍两种比较简洁的实现。

## 3. 静态内部类

DCL 的实现方式主要为了实现懒加载，为了简化代码，因此提出来静态内部类的方式。JVM 加载一个类时，其内部类不会同时被加载。一个类被加载，当且仅当其某个静态成员（静态域、构造器、静态方法等）或 class 被调用时发生。

```java
public class Singleton8 {
    protected Singleton8() {
    }

    protected static class Instance {
        private static final Singleton8 SINGLETON = new Singleton8();
    }


    public static Singleton8 getInstance() {
        return Instance.SINGLETON;
    }
}
```

这种方式能够实现简化，JVM 保证了线程安全，也实现了懒加载。是比较好的一种实现方式。

## 4. 枚举类实现

内部类已经很好的实现了懒加载，是常用的一种实现方式。除此之外，还有一种枚举类的实现方式，这种方式不仅能够实现线程安全，还能够避免反射。

```java
public enum  Singleton9 {
    INSTANCE;
}
```

1. 枚举类之所以能够避免反射，是因为 Java 语言的实现方式，枚举类没有默认的构造函数，构造函数是虚函数，无法被实例化。即使定义了构造方法，也不是通常类的构造方法，所以依旧不能调用，依旧不能初始化。

2. 虽然反射可以通过 `Enum.valueOf(clazz, String.valueOf(Singleton9.INSTANCE))` 创建对象，但是依旧是指向已有的枚举对象，而不是创建新的对象。

Java 通过编译器和 JVM 联手来防止enum 产生超过一个class：不能利用 new、clone()、de-serialization、以及 Reflection API 来产生 enum 的 instance。 


有种说法：

但是枚举类实现单例，缺点在于属性写起来麻烦，方法不容易添加，序列化保存的文件不好升级

**这种说法毫无道理，枚举单例的问题在于，不能实现延迟初始化，因为很多时候对象的实例化需要一依赖条件需要在运行时才能确定。因此，延迟实例化很多时候是因为依赖条件的问题。**

## 5. 注册方式

注册方式一般是为了实现多个对象的实例化。1. 固定数量的对象。 2. 多种类的实例化。

```java
public class SingletonMazeFactory  extends MazeFactory {
    protected static volatile MazeFactory instance;
    MazeFactory instance(String className) {
        if (instance == null) {
            if (BombedMazeFactory.class.getName().equals(className)) {
                instance = new BombedMazeFactory();
            } else if (EnchantedMazeFactory.class.getName().equals(className)) {
                instance = new EnchantedMazeFactory();
                // ... other possible subclasses
            } else {
                // default
                instance = new MazeFactory();
            }
        }
        return instance;
    }
}
```

这种方式仅实现多种类的实例化，如果想要实现固定数量对象的实例化，可以定义一个容器来保存对象。根据对象数量来判断是否实例化新对象。

