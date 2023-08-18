package structural.bridge;

import java.awt.Point;

import javax.swing.text.View;

public abstract class Window {
    private WindowImp imp;
    private View contents; // the window's contents

    public Window(View contents) {

    }

    protected WindowImp getWindowImp() {
        if (imp == null) {
            imp = WindowSystemFactory.getInstance();
        }
        return imp;
    }

    protected View getView() {
        return contents;
    };

    // requests handled by window
    public void drawContents() {
        // Do something draw by contents
        if (imp == null || contents == null) return;
        imp = getWindowImp();
        // call imp to draw contents.
    }

    public void open() {
        // show
    }

    public void close() {
        // close
    }
    // ...

    // requests forwarded to implementation
    public void setOrigin(final Point at) {
        imp.impSetOrigin(at);
    }

    public void setExtent(final Point extent) {
        imp.impSetExtent(extent);
    };

    public void raise() {
        // measure depend on current window
        // getView ...
        imp.impSetExtent(new Point(20, 30));
        imp.impSetOrigin(new Point(0, 0));
    };

    public void drawLine(final Point start, final Point end) {
        // draw line.
        imp.deviceLine(start.x, start.y, end.x, end.y);
    }

    public void drawRect(final Point leftTop, final Point rightBottom) {
        imp.deviceRect(leftTop.x, leftTop.y, rightBottom.x, rightBottom.y);
    }

    public void drawPolygon(final Point[] points) {
        // call imp operation deviceLine() to draw Polygon.
    }

    public void drawText(final char[] chars, final Point start) {
        imp.deviceText(String.valueOf(chars), start.x, start.y);
    }
    // ...
}
