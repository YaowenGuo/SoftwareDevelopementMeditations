//
// Created by Albert on 2020/12/8.
//

#ifndef DESIGN_PATTERNS_C_HEADERS_CREATE_SINGLETON_SINGLETON_H
#define DESIGN_PATTERNS_C_HEADERS_CREATE_SINGLETON_SINGLETON_H
#include <iostream>
#include <map>

using namespace std;
class Singleton {
public:
  static Singleton* instance(const string &name);

  static void registerInstance(const string& name,Singleton& instance);
protected:
  Singleton();
  static Singleton* lookup(const string &name);
  string _name;

private:
  static map<string, Singleton>* _registry;
  static Singleton* _instance;
};

#endif //DESIGN_PATTERNS_C_HEADERS_CREATE_SINGLETON_SINGLETON_H
