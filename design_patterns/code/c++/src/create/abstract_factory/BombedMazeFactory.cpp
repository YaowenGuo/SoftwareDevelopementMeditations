//
// Created by Albert on 2020/12/4.
//

#include "../../../headers/create/abstract_factory/BombedMazeFactory.h"
#include "../../../headers/Wall.h"
#include "../../../headers/bomb/bomb_room.h"
#include "../../../headers/bomb/BombedWall.h"

BombedMazeFactory::BombedMazeFactory() = default;

Wall* BombedMazeFactory::makeWall() const {
  return new BombedWall;
}

Room* BombedMazeFactory::makeRoom(int num) const {
  return new RoomWithABomb(num, true);
}