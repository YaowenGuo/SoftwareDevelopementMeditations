package create.builder;//
// Created by Albert on 2020/12/9.
//

import base.Maze;

public abstract class MazeBuilder {
    public abstract Maze buildMaze();

    public abstract void buildRoom(int room);

    public abstract void buildDoor(int roomFrom, int roomTo);
}

