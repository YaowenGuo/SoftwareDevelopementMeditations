package structural.bridge;

import java.awt.Point;

public abstract class WindowImp {
    protected WindowImp() {
        
    }
    
    public abstract void impTop();
    public abstract void impBottom();
    public abstract void impSetExtent(final Point extent);
    public abstract void impSetOrigin(final Point origin);
    public abstract void deviceRect(float left, float top, float right, float bottom);
    public abstract void deviceLine(float startX, float startY, float endX, float endY);
    public abstract void deviceText(final String content, float x, float y);
    public abstract void deviceBitmap(final String content, float x, float y);
    // lots more functions for drawing on windows...
}
