#include <cstdlib>
#include <cstring>
#include "../../../headers/create/abstract_factory/MazeFactory.h"
#include "../../../headers/create/abstract_factory/BombedMazeFactory.h"
#include "../../../headers/create/abstract_factory/EnchantedMazeFactory.h"

Maze* MazeFactory::makeMaze() const {
    return new Maze;
}
Wall* MazeFactory::makeWall() const {
    return new Wall;
}
Room* MazeFactory::makeRoom(int number) const {
    return new Room(number);
}

Door* MazeFactory::makeDoor(Room* r1, Room* r2) {
    return new Door(r1, r2);
}

