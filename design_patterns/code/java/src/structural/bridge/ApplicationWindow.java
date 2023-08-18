package structural.bridge;



import javax.swing.text.View;

public class ApplicationWindow extends Window {
    public ApplicationWindow(View contents) {
        super(contents);
    }

    @Override
    public void drawContents() {
        super.drawContents();
        // draw some self content.
    }
}
