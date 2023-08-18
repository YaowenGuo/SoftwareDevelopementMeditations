package base;

public class Wall implements MapSite, Cloneable {
    @Override
    public boolean enter() {
        return false;
    }

    @Override
    public Wall clone() {
        return new Wall();
    }
}
