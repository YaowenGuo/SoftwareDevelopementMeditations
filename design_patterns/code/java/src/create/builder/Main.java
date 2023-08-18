package create.builder;

import base.Maze;
import base.MazeGame;
import javafx.util.Pair;

public class Main {
    public static void main(String[] argus) {
        Maze maze;
        MazeGame game = new MazeGame();
        StandardMazeBuilder builder = new StandardMazeBuilder();
        game.createMaze(builder);
        maze = builder.buildMaze();

        System.out.println("End.");

        CountingMazeBuilder countBuilder = new CountingMazeBuilder();
        game.createMaze(countBuilder);
        Pair<Integer, Integer> counts = countBuilder.getCounts();
        System.out.println("The maze has " + counts.getKey() + " rooms and " + counts.getValue() +" doors");
    }
}
