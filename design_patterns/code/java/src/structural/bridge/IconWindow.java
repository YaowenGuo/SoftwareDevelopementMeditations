package structural.bridge;

import javax.swing.text.View;

public class IconWindow extends Window {
    private String bitmapName;

    public IconWindow(View contents) {
        super(contents);
    }

    /**
     * Draw self image.
     */
    @Override
    public void drawContents() {
        super.drawContents();
        getWindowImp().deviceBitmap(bitmapName, 0, 0);
    }
}
