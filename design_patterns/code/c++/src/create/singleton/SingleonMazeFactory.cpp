//
// Created by Albert on 2020/12/9.
//

#include <cstdlib>
#include <cstring>
#include "../../../headers/create/abstract_factory/MazeFactory.h"
#include "../../../headers/create/abstract_factory/BombedMazeFactory.h"
#include "../../../headers/create/abstract_factory/EnchantedMazeFactory.h"

MazeFactory::MazeFactory() = default;
MazeFactory* MazeFactory::_instance = nullptr;
/**
 * 这种实现方式被称为 登记式单例*
 */

MazeFactory* MazeFactory::instance() {
  if (_instance==nullptr) {
	const char* mazeStyle = getenv("MAZESTYLE");
	if (strcmp(mazeStyle, "bombed")==0) {
	  _instance = new BombedMazeFactory;
	} else if (strcmp(mazeStyle, "enchanted")==0) {
	  _instance = new EnchantedMazeFactory;
	  // ... other possible subclasses
	} else {
	  // default
	  _instance = new MazeFactory;
	}
  }
  return _instance;
}