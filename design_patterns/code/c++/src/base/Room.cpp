#include "../../headers/Room.h"
#include "../../headers/MapSite.h"

Room::Room(int roomNo) {
  _roomNumber = roomNo;
}

Room::Room(const Room & other){
  _roomNumber = other._roomNumber;
  for (int i = 0; i < MAP_SIDE_SIZE; ++i) {
	_side[i] = dynamic_cast<MapSite*>(other._side[i]->clone());
  }
}

MapSite* Room::getSide(Direction direction) const {
  return _side[direction];
}

void Room::setSide(Direction direction, MapSite* mapSite) {
  _side[(int)direction] = mapSite;
}

void Room::setNum(int num) {
  _roomNumber = num;
}

Room* Room::clone() const {
  return new Room(*this);
}