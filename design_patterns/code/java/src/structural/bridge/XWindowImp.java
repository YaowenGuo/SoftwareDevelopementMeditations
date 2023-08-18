package structural.bridge;

import java.awt.Point;

/**
 * 根据具体平台，编写平台相关代码。其中的耦合被内聚在该类中，而不会扩散到系统中。
 */
public class XWindowImp extends WindowImp {
    public XWindowImp() {
        System.out.println("XWindow .....");
    }

    @Override
    public void impTop() {

    }

    @Override
    public void impBottom() {

    }

    @Override
    public void impSetExtent(Point extent) {

    }

    @Override
    public void impSetOrigin(Point origin) {

    }

    @Override
    public void deviceRect(float left, float top, float right, float bottom) {

    }

    @Override
    public void deviceLine(float startX, float startY, float endX, float endY) {

    }

    @Override
    public void deviceText(String content, float x, float y) {

    }

    @Override
    public void deviceBitmap(String content, float x, float y) {

    }
}
