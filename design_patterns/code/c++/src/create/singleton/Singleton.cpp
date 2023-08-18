//
// Created by Albert on 2020/12/8.
//

#include "../../../headers/create/singleton/Singleton.h"
using namespace std;

Singleton* Singleton::_instance = nullptr;
map<string, Singleton>* Singleton::_registry = nullptr;
//Singleton::Singleton() = default;

/*Singleton* Singleton::instance() {
  if (_instance==nullptr) {
	_instance = new Singleton;
  }
  return _instance;

}*/

Singleton::Singleton() {
  Singleton::registerInstance("Singleton", *this);
}

Singleton* Singleton::lookup(const string &name) {
  if (_registry==nullptr) {
	_registry = new map<string, Singleton>();
  }
  return &(_registry->at(name));
}

void Singleton::registerInstance(const string &name, Singleton &instance) {
  if (_registry==nullptr) {
	_registry = new map<string, Singleton>();
  }
  if (lookup(name)!=nullptr) {
	_registry->insert(pair<string, Singleton>("name", instance));
  }
}

Singleton* Singleton::instance(const string &name) {
  if (_instance==nullptr) {
	_instance = lookup(name);
	if (_instance ==nullptr) {

	}
	// Lookup returns 0 if there's no such singleton
  }
  return _instance;
}