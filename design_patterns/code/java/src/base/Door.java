package base;

public class Door implements MapSite, Cloneable {
    private Room mRoom1, mRoom2;
    public Door(Room room1, Room room2) {
        mRoom1 = room1;
        mRoom2 = room2;
    }


    @Override
    public boolean enter () {
        return true;
    }

    public Room otherSideFrom(Room from) {
        if (from == null) return null;
        if (from == mRoom1) {
            return mRoom2;
        } else if (from == mRoom2) {
            return mRoom1;
        } else {
            return null;
        }
    }

    @Override
    public Door clone() {
        // 或者使用 super.clone();
        return new Door(this.mRoom1, this.mRoom2);
    }
}
