#include "../../../headers/create/prototype/MazePrototypeFactory.h"



MazePrototypeFactory::MazePrototypeFactory(Maze* maze, Wall* wall, Room* room, Door* door) {
  _prototypeMaze = maze;
  _prototypeWall = wall;
  _prototypeRoom = room;
  _prototypeDoor = door;
}

Maze* MazePrototypeFactory::makeMaze() const {
  return _prototypeMaze->clone();
}

Wall * MazePrototypeFactory::makeWall() const {
  return _prototypeWall->clone();
}

Room * MazePrototypeFactory::makeRoom() const {
  return _prototypeRoom->clone();
}

Door * MazePrototypeFactory::makeDoor() const {
  return _prototypeDoor->clone();
}