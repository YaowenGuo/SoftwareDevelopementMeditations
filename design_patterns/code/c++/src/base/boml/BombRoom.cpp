#include "../../../headers/bomb/bomb_room.h"

RoomWithABomb::RoomWithABomb(int roomNo, bool hasBomb) : Room(roomNo) {
    _hasBomb = hasBomb;
}