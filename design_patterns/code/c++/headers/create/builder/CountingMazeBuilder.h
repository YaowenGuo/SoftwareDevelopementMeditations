//
// Created by Albert on 2020/12/10.
//

#ifndef DESIGN_PATTERNS_C_HEADERS_CREATE_BUILDER_COUNTINGMAZEBUILDER_H
#define DESIGN_PATTERNS_C_HEADERS_CREATE_BUILDER_COUNTINGMAZEBUILDER_H
#include "MazeBuilder.h"

class CountingMazeBuilder : public MazeBuilder {
public:
  CountingMazeBuilder();
  virtual void buildMaze();
  virtual void buildRoom(int);
  virtual void buildDoor(int, int);
  virtual void addWall(int, Direction);
  void getCounts(int&, int&) const;
private:
  int _doors;
  int _rooms;
};

#endif //DESIGN_PATTERNS_C_HEADERS_CREATE_BUILDER_COUNTINGMAZEBUILDER_H
