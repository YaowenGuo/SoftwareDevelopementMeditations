package create.abstract_factory;

import base.Room;
import base.Wall;
import base.bomb.BombedWall;
import base.bomb.RoomWithABomb;

public class BombedMazeFactory extends MazeFactory {

    @Override
    public Wall makeWall() {
        return new BombedWall();
    }

    @Override
    public Room makeRoom(int num) {
        return new RoomWithABomb(num, true);
    }

}
