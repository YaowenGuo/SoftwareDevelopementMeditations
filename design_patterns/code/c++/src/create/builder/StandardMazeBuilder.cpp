//
// Created by Albert on 2020/12/9.
//

#include "../../../headers/create/builder/StandardMazeBuilder.h"
#include "../../../headers/Wall.h"
#include "../../../headers/Door.h"
#include "../../../headers/create/builder/MazeBuilder.h"

StandardMazeBuilder::StandardMazeBuilder() {
  _currentMaze = 0;
}

void StandardMazeBuilder::buildMaze() {
  _currentMaze = new Maze;
}
Maze* StandardMazeBuilder::getMaze() {
  return _currentMaze;
}

void StandardMazeBuilder::buildRoom(int n) {
  if (!_currentMaze->roomNo(n)) {
	Room* room = new Room(n);
	_currentMaze->addRoom(room);
	room->setSide(North, new Wall);
	room->setSide(South, new Wall);
	room->setSide(East, new Wall);
	room->setSide(West, new Wall);
  }
}

void StandardMazeBuilder::buildDoor(int n1, int n2) {
  Room* r1 = _currentMaze->roomNo(n1);
  Room* r2 = _currentMaze->roomNo(n2);
  Door* d = new Door(r1, r2);
  if (r1!=0) {
	r1->setSide(commonWall(r1, r2), d);
  }
  if (r2!=0) {
	r2->setSide(commonWall(r2, r1), d);
  }
}
Direction StandardMazeBuilder::commonWall(Room*, Room*) {
  return West;
}
