//
// Created by Albert on 2020/12/9.
//

#ifndef DESIGN_PATTERNS_C_HEADERS_CREATE_BUILDER_MAZEBUILDER_H
#define DESIGN_PATTERNS_C_HEADERS_CREATE_BUILDER_MAZEBUILDER_H
#include "../../Maze.h"

class MazeBuilder {
public:
  // 现代实践尝尝将 buildMaze 和 getMaze 合并为一个方法。直接由 buildMaze 返回一个 Maze. 因为
  // 构建顺序通常是不确定的，很多时候需要最后才能组装，因此先 创建一个 Maze 的条件不一定能满足。当然
  // 这些细节都随着实际情况而变化，核心就是保证有 Builder 一步一步构建复杂对象。
  virtual void buildMaze() { }
  virtual void buildRoom(int room) { }
  virtual void buildDoor(int roomFrom, int roomTo) { }
  virtual Maze* getMaze() { return 0; }
protected:
  MazeBuilder();
};

#endif //DESIGN_PATTERNS_C_HEADERS_CREATE_BUILDER_MAZEBUILDER_H
