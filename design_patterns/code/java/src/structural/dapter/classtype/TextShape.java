package structural.dapter.classtype;

import java.awt.Point;

import structural.dapter.Manipulator;
import structural.dapter.Shape;
import structural.dapter.TextView;

/**
 * Class adapter.
 */
public class TextShape extends TextView implements Shape {

    @Override
    public void boundingBox(Point bottomLeft, Point topRight) throws Exception {
        if (bottomLeft == null || topRight == null)
            throw new Exception("Bound params can't be null");
        double left = bottomLeft.getX();
        double top = topRight.getY();
        double right = topRight.getX();
        double bottom = bottomLeft.getX();
        setOrigin((float) left, (float) top);
        setExtent((float)(right - left), (float)(bottom - top));
    }

    @Override
    public Manipulator createManipulator() {
        return new Manipulator();
    }
}
