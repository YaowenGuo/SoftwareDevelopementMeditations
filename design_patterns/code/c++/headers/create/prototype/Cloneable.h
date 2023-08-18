//
// Created by Albert on 2020/12/4.
//

#ifndef DESIGN_PATTERNS_C_HEADERS_CREATE_PROTOTYPE_CLONEABLE_H
#define DESIGN_PATTERNS_C_HEADERS_CREATE_PROTOTYPE_CLONEABLE_H
class Cloneable {
public:
  virtual Cloneable* clone() const = 0;

  virtual ~Cloneable() = default;
};
#endif //DESIGN_PATTERNS_C_HEADERS_CREATE_PROTOTYPE_CLONEABLE_H
