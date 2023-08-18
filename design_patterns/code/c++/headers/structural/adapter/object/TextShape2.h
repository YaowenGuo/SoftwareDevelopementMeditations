/** --------------------------------- 对象适配器 ----------------------------*/
/**
 * 对象适配器采用对象组合的方法将不同的接口和类组合在一起。 在该方法中，适配器TextShape维护一个指向
 * TextView的指针。
 */

//
// Created by Albert on 1/3/21.
//
#ifndef DESIGN_PATTERNS_C_HEADERS_STRUCTURAL_ADAPTER_OBJECT_TEXTSHAP2_H
#define DESIGN_PATTERNS_C_HEADERS_STRUCTURAL_ADAPTER_OBJECT_TEXTSHAP2_H

class TextShape2 {
public:
  TextShape2(TextView*);
  virtual void setBouningBox(Point &bottomLeft, Point &topRight) const;
  virtual bool isEmpty() const;
  virtual Manipulator* createManipulator() const;
private:
  TextView* textView{};
};

#endif //DESIGN_PATTERNS_C_HEADERS_STRUCTURAL_ADAPTER_OBJECT_TEXTSHAP2_H
