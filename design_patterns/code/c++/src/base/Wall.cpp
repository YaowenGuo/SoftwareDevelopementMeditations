#include "../../headers/Wall.h"

Wall* Wall::clone() const {
  return new Wall(*this);
}
Wall::Wall(const Wall &) {

}
Wall::Wall() {

}
