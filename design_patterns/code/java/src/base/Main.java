package base;

import create.abstract_factory.MazeFactory;

public class Main {
    public static void main(String[] args) {
        Maze maze = MazeGame.createMaze(new MazeFactory());
        System.out.println("End");
    }
}
