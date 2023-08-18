package base;

public class Room implements MapSite {

    protected int mRoomNo;
    MapSite[] mSide;
    public Room(int num) {
        mRoomNo = num;
        mSide = new MapSite[4];
    }

    public boolean enter() {
        return true;
    }

    public void setSide(Direction direction, MapSite site) {
        switch(direction) {
            case East:
                mSide[0] = site;
                break;
            case South:
                mSide[1] = site;
                break;
            case West:
                mSide[2] = site;
                break;
            case North:
                mSide[3] = site;
                break;
        }
    }

    public MapSite getSide(Direction direction) {
        switch(direction) {
            case East:
                return mSide[0];
            case South:
                return mSide[1];
            case West:
                return mSide[2];
            case North:
                return mSide[3];
            default:
                return null;
        }
    }

    @Override
    public Room clone() {
        return new Room(this.mRoomNo);
    }

    public boolean isSameRoom(int num) {
        return mRoomNo == num;
    }
}
