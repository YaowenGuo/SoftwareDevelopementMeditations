#include <iostream>
#include "../../headers/Maze.h"
#include "../../headers/create/abstract_factory/MazeFactory.h"
#include "../../headers/MazeGame.h"

#include "../../headers/create/abstract_factory/BombedMazeFactory.h"
#include "../../headers/create/abstract_factory/EnchantedMazeFactory.h"
#include "../../headers/create/prototype/MazePrototypeFactory.h"
#include "../../headers/create/builder/StandardMazeBuilder.h"
#include "../../headers/create/builder/CountingMazeBuilder.h"

using namespace std;

/**
 * Abstract factory
 */
/*int main() {
  MazeGame game;
  EnchantedMazeFactory mazeFactory;
  Maze* maze = game.createMaze(mazeFactory);
  cout << "End." << endl;

  // AbstractFactory
  BombedMazeFactory factory;
  maze = game.createMaze(factory);
  cout << "Abstract Factory end." << endl;

  return 0;
}*/


/**
 * Builder
 */
int main() {
  Maze* maze;
  MazeGame game;
  StandardMazeBuilder builder;
  game.createMaze(builder);
  maze = builder.getMaze();
  cout << "End." << endl;

  int rooms, doors;
  CountingMazeBuilder countBuilder;
  maze = game.createMaze(countBuilder);
  countBuilder.getCounts(rooms, doors);
  cout << "The maze has "
	   << rooms << " rooms and "
	   << doors << " doors" << endl;

  return 0;
}



/**
 * Prototype
 */
/*int main() {
  MazeGame game;
  MazePrototypeFactory simpleMazeFactory(new Maze, new Wall, new Room(0), new Door);
  Maze* maze = game.createMaze(simpleMazeFactory);

  // Another type maze game.
  MazePrototypeFactory bombedMazeFactory(new Maze, new Wall, new Room(0), new Door);
  maze = game.createMaze(bombedMazeFactory);
  return 0;
}*/


/**
 * Singleton
 */
/*int main() {
  MazeGame game;
  setenv("MAZESTYLE", "bombed", 1);
  MazeFactory* mazeFactory = MazeFactory::instance();
  Maze* maze = game.createMaze(*mazeFactory);
  cout << "End." << endl;

  // AbstractFactory
  setenv("MAZESTYLE", "enchanted", 1);
  MazeFactory* factory = MazeFactory::instance();
  maze = game.createMaze(*factory);
  cout << "Singleton Factory end." << endl;

  return 0;
}*/


