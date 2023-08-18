#include "../../headers/Maze.h"

Maze::Maze(const Maze &) {
}

void Maze::addRoom(Room* room) {
    // Add a room.
}

Room* Maze::roomNo(int roomNum) const {
    // a search function to find room.
    return 0;
};

Maze* Maze::clone() const {
  return new Maze(*this);
}
Maze::Maze() {

}
