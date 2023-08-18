package structural.bridge;

public class WindowSystemFactory {
    public static final String WINDOW_TYPE = "window_type";
    public static final String TYPE_X_WINDOW = "xWindow";
    public static final String TYPE_PM_WINDOW = "PMWindow";

    public static WindowImp getInstance() {
        String type = System.getProperty(WINDOW_TYPE);
        if (TYPE_X_WINDOW.equals(type)) {
            return new XWindowImp();
        } else if (TYPE_PM_WINDOW.equals(type)){
            return new PMWindowImp();
        }
        return null;
    }
}
