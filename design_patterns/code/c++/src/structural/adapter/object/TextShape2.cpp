//
// Created by Albert on 1/3/21.
//

#include "../../../../headers/structural/adapter/object/TextShape2.h"
#include "../../../../headers/structural/adapter/TextView.h"
#include "../../../../headers/structural/adapter/Manipulator.h"

TextShape2::TextShape2(TextView view) {
  textView = view;
}

void TextShape2::getBouningBox(Point& bottomLeft, Point& topRight) const {
  float bottom, left, width, height;
  textView->getOrigin(bottom, left);
  textView->getExtent(width, height);
  bottomLeft = Point(bottom, left);
  topRight = Point(bottom + height, left + width);
}

bool TextShape2::isEmpty() const {
  return textView->isEmpty();
}

/* 对于新增加的功能，类适配器和对象适配器是完全相同的。因为它是从零开始，没有任何已有代码可用 */
Manipulator* TextShape2::createManipulator () const {
  return new Manipulator(this);
}
