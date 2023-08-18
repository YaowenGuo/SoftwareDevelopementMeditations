package base;

import create.abstract_factory.MazeFactory;
import create.builder.MazeBuilder;

import static base.Direction.East;
import static base.Direction.North;
import static base.Direction.South;
import static base.Direction.West;

public class MazeGame {
    public static Maze createMaze(MazeFactory factory) {
        Maze aMaze = factory.makeMaze();
        Room room1 = factory.makeRoom(1);
        Room room2 = factory.makeRoom(2);
        Door aDoor = factory.makeDoor(room1, room2);

        aMaze.addRoom(room1);
        aMaze.addRoom(room2);

        room1.setSide(North, factory.makeWall());
        room1.setSide(East, aDoor);  
        room1.setSide(South, factory.makeWall());
        room1.setSide(West, factory.makeWall());
        
        room1.setSide(North, factory.makeWall());
        room1.setSide(East, factory.makeWall());
        room1.setSide(South, factory.makeWall());
        room1.setSide(West, aDoor);
        
        return aMaze;
    }


    // ------ Builder start ----------
    public Maze createMaze(MazeBuilder builder) {
        builder.buildRoom(1);
        builder.buildRoom(2);
        builder.buildDoor(1, 2);
        return builder.buildMaze();
    }
}
