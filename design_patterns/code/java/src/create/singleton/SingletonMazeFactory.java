package create.singleton;

import create.abstract_factory.BombedMazeFactory;
import create.abstract_factory.EnchantedMazeFactory;
import create.abstract_factory.MazeFactory;

/**
 * 登记式单例类. 也可以使用容器创建保存多个实例的实现方式。甚至可以实现固定数量的实例。
 */
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
