//
// Created by Albert on 2020/12/10.
//

#include "../../../headers/create/builder/CountingMazeBuilder.h"

CountingMazeBuilder::CountingMazeBuilder() {
  _rooms = _doors = 0;
}

void CountingMazeBuilder::buildRoom(int) {
  _rooms++;
}
void CountingMazeBuilder::buildDoor(int, int) {
  _doors++;
}
void CountingMazeBuilder::getCounts(int &rooms, int &doors) const {
  rooms = _rooms;
  doors = _doors;
}

void CountingMazeBuilder::buildMaze() {

}
void CountingMazeBuilder::addWall(int, Direction) {

}
