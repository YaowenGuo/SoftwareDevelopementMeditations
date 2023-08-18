package create.abstract_factory;/*
* The MazeFactory not only as to abstract factroy but also
* as a concret factory. So it is not a abstract class. It
* can reduce the number of classes.
*/

import base.Door;
import base.Maze;
import base.Room;
import base.Wall;

public class MazeFactory {
    public Maze makeMaze() {
        return new Maze();
    }

    public Wall makeWall() {
        return new Wall();
    }

    public Room makeRoom(int num) {
        return new Room(num);
    }

    public Door makeDoor(Room r1, Room r2) {
        return new Door(r1, r2);
    }

}
