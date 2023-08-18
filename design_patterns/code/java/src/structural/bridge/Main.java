package structural.bridge;

public class Main {
    public static void main(String[] argus) {
        System.setProperty(WindowSystemFactory.WINDOW_TYPE, WindowSystemFactory.TYPE_PM_WINDOW);
        IconWindow window = new IconWindow(null);
        window.drawContents();

    }
}
