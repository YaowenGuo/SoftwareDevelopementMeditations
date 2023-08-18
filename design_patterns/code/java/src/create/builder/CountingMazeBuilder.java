package create.builder;//
// Created by Albert on 2020/12/10.
//

import base.Maze;
import javafx.util.Pair;

class CountingMazeBuilder extends MazeBuilder {
    private int doors;
    private int rooms;

    @Override
    public Maze buildMaze() {
        return null;
    }

    @Override
    public void buildRoom(int room) {
        rooms++;
    }

    @Override
    public void buildDoor(int roomFrom, int roomTo) {
        doors += 2;
    }

    public Pair<Integer, Integer> getCounts() {
        return new Pair<Integer, Integer>(doors, rooms);
    }

};