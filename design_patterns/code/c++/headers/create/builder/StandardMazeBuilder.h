//
// Created by Albert on 2020/12/9.
//

#ifndef DESIGN_PATTERNS_C_HEADERS_CREATE_BUILDER_STANDARDMAZEBUILDER_H
#define DESIGN_PATTERNS_C_HEADERS_CREATE_BUILDER_STANDARDMAZEBUILDER_H
#include "../../Maze.h"
#include "MazeBuilder.h"

class StandardMazeBuilder: public MazeBuilder {
public:
  StandardMazeBuilder();
  virtual void buildMaze();
  virtual void buildRoom(int);
  virtual void buildDoor(int, int);
  virtual Maze* getMaze();
private:
  Direction commonWall(Room*, Room*);
  Maze* _currentMaze;
};

#endif //DESIGN_PATTERNS_C_HEADERS_CREATE_BUILDER_STANDARDMAZEBUILDER_H
