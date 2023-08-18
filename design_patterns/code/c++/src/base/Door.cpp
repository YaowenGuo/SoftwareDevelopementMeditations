#include "../../headers//Door.h"

Door::Door(Room* from, Room* to) {
    _room1 = from;
    _room2 = to;
    _isOpen = true;
}

Door::Door(const Door & other) {
  _room1 = other._room1;
  _room2 = other._room2;
}

Room* Door::otherSideFrom(Room* from) {
    if (from == _room1 && _isOpen) {
        return _room2;
    }
    if (from == _room2 && _isOpen) {
        return _room1;
    }
    return 0;
}

Door* Door::setRoom(Room* from, Room* to) {
  _room1 = from;
  _room2 = to;
  return this;
}

Door* Door::clone() const {
  return new Door(*this);
}


