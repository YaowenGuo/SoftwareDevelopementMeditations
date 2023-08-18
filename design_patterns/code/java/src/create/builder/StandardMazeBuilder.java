package create.builder;//
// Created by Albert on 2020/12/9.
//


import java.util.ArrayList;
import java.util.List;

import base.Maze;
import base.Room;
import javafx.util.Pair;

class StandardMazeBuilder extends MazeBuilder {
    private List<Room> roomList = new ArrayList<>();
    private List<Pair<Integer, Integer>> doorList = new ArrayList<>();

    public Maze buildMaze() {
        Maze maze = new Maze();
        // 将 RoomList 和  DoorList 中的设置根据地图算法拼装 Maze
        return maze;
    }

    @Override
    public void buildRoom(int num) {
        boolean hasRoom = false;
        for (Room room: roomList) {
            if (room.isSameRoom(num)) {
                hasRoom = true;
                break;
            }
        }
        if (!hasRoom) {
            roomList.add(new Room(num));
        }
    }

    @Override
    public void buildDoor(int roomFrom, int roomTo) {
        doorList.add(new Pair<>(roomFrom, roomTo));
    }
}
