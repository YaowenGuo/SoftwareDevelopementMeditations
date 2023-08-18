package create.prototype;

import base.Door;
import base.Maze;
import base.Room;
import base.Wall;
import create.abstract_factory.MazeFactory;

/**
 * Prototype 的核心是使用使用对象复制创建新对象，语言要么是原型类语言，可以直接扩展，要么是使用 clone 函数，自己创建
 * 并拷贝数据。**难点主要在深拷贝。**
 *
 * 该类并不是 Prototype 的部件，而是使用 Prototype 实现的 Abstract Factory.
 * 对比 Abstract Factory 的 MazeFactory 和其子类，减少了类的定义。
 */

public class MazePrototypeFactory extends MazeFactory {
    private final Maze maze;
    private final Wall wall;
    private final Room room;
    private final Door door;

    MazePrototypeFactory(Maze maze, Wall wall, Room room, Door door) {
        this.maze = maze;
        this.wall = wall;
        this.room = room;
        this.door = door;
    }

    public Maze makeMaze() {
        return maze.clone();
    }

    public Wall makeWall() {
        return wall.clone();
    }

    public Room makeRoom() {
        return room.clone();
    }

    public Door makeDoor() {
        return door.clone();
    }
}
