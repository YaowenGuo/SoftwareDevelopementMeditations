package structural.dapter.object;

import java.awt.Point;

import structural.dapter.Manipulator;
import structural.dapter.Shape;
import structural.dapter.TextView;

/**
 * Object adapter.
 */
public class TextShape implements Shape {
    private TextView textView;

    @Override
    public void boundingBox(Point bottomLeft, Point topRight) throws Exception {
        if (bottomLeft == null || topRight == null)
            throw new Exception("Bound params can't be null");
        double left = bottomLeft.getX();
        double top = topRight.getY();
        double right = topRight.getX();
        double bottom = bottomLeft.getX();
        textView.setOrigin((float) left, (float) top);
        textView.setExtent((float)(right - left), (float)(bottom - top));
    }

    @Override
    public Manipulator createManipulator() {
        return new Manipulator();
    }
}
