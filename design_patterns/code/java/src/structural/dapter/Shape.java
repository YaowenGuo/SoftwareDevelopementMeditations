package structural.dapter;

import java.awt.Point;

/**
 * Target。 客户端的类体系，Adapter 将 Adaptee 转化为 Target
 */
public interface Shape {
    void boundingBox(Point bottomLeft, Point topRight) throws Exception;
    public  Manipulator createManipulator();
}
