/**
 * 类适配器
 * 类适配采多重继承适配接。类适配的关键是继承要适配的接口，同时继承被适配的实现。通常 C++中作出这一区分的方法是: 用公共式继承接接口;
 * 用私有方式继承接被适配的实现。
 */
//
// Created by Albert on 1/3/21.
//

#ifndef DESIGN_PATTERNS_C_HEADERS_STRUCTURAL_ADAPTER_CLASS_TEXTSHAP_H
#define DESIGN_PATTERNS_C_HEADERS_STRUCTURAL_ADAPTER_CLASS_TEXTSHAP_H

class TextShape : public Shape, private TextView {
public:
  TextShape();
  virtual void setBouningBox(Point &bottomLeft, Point &topRight) const;
  virtual bool isEmpty() const;
  virtual Manipulator* createManipulator() const;
}
#endif //DESIGN_PATTERNS_C_HEADERS_STRUCTURAL_ADAPTER_CLASS_TEXTSHAP_H
