package structural.dapter;

/**
 * Adaptee， 已有的组件，可能是三方的库。能够显示想要的 Text 但是接口与现有的组件不兼容。
 */
public class TextView {
    private String content;

    public void setOrigin(float x, float y) {
        // ...
    }


    public void setExtent(float width, float height) {

    }


    boolean isEmpty() {
        return content == null || content.length() == 0;
    }
}
