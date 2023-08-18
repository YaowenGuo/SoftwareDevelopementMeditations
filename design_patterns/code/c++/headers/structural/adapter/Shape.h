//
// Created by Albert on 1/3/21.
//

/** ----------------------- 两个需要匹配的接口 -----------------------*/
/** 要适配的接口
* Shape 是自己拥有的接口，可以理解为自己项目中的接口。
*/

#ifndef DESIGN_PATTERNS_C_HEADERS_STRUCTURAL_ADAPTER_SHAPE_H
#define DESIGN_PATTERNS_C_HEADERS_STRUCTURAL_ADAPTER_SHAPE_H

class Shape {
public:
  Shape();
  virtual void getBouningBox(Point& bottomLeft, Point& topRight) const; // 常成员函数，不会修改任何类的成员数据的值
  virtual Manipulator* CreateManipulator() const;

};

#endif //DESIGN_PATTERNS_C_HEADERS_STRUCTURAL_ADAPTER_SHAPE_H
