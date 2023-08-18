package base.bomb;

import base.Room;

public class RoomWithABomb extends Room {
    protected boolean hasBomb;
    public RoomWithABomb(int num, boolean hasBomb) {
        super(num);
        this.hasBomb = hasBomb;
    }
}
