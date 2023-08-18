//
// Created by Albert on 1/3/21.
//

#include <point.h>
#include "../../../../headers/structural/adapter/class/TextShap.h"
#include "../../../../headers/structural/adapter/TextView.h"
#include "../../../../headers/structural/adapter/Manipulator.h"

// BoundingBox操作对TextView的接口进行转换使之匹配 Shape的接 。这里是获取View边界的。
void TextShape::setBouningBox(Point& bottomLeft, Point& topRight) const {
  float bottom = bottomLeft.v, left, width, height;
  setOrigin(bottom, left);
  getExtent(width, height);
  bottomLeft = Point(bottom, left);
  topRight = Point(bottom + height, left + width);
}

bool TextShape::isEmpty() const {
  return parent.isEmpty();
}

// 最后，我们定义 createManipulator(TextView 不支持该操作)，假定我们已经实现支持TextShape操作的类 Manipulator。

Manipulator* TextShape::createManipulator () const {
  return new Manipulator(this);
}