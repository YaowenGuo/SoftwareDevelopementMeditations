package create.prototype;

import base.Door;
import base.Maze;
import base.MazeGame;
import base.Room;
import base.Wall;

public class Main {

    public static void main(String[] argus) {
        MazePrototypeFactory simpleMazeFactory = new MazePrototypeFactory(new Maze(), new Wall(), new Room(0), new Door(null, null));
        Maze maze = MazeGame.createMaze(simpleMazeFactory);

        // Another type maze game.
        MazePrototypeFactory bombedMazeFactory = new MazePrototypeFactory(new Maze(), new Wall(), new Room(0), new Door(null, null));
        maze = MazeGame.createMaze(bombedMazeFactory);
    }

}
