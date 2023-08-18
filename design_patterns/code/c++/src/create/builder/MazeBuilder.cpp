//
// Created by Albert on 2020/12/9.
//

#include "../../../headers/create/builder/MazeBuilder.h"
#include "../../../headers/MazeGame.h"

MazeBuilder::MazeBuilder() = default;

Maze* MazeGame::createMaze (MazeBuilder& builder) {
  builder.buildMaze();
  builder.buildRoom(1);
  builder.buildRoom(2);
  builder.buildDoor(1, 2);
  return builder.getMaze();
}

Maze* MazeGame::createComplexMaze (MazeBuilder& builder) {
  builder.buildRoom(1);
	// ...
  builder.buildRoom(1001);
  return builder.getMaze();
}


