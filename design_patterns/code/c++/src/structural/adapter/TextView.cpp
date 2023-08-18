//
// Created by Albert on 1/3/21.
//

#include <clocale>
#include "../../../headers/structural/adapter/TextView.h"

TextView::TextView() = default;

// 接口不匹配体现在通过原点和宽，高来定会位置的边界。
void TextView::setOrigin(float x, float y) const {
  // do set
  // ...
}

// 宽， 高
void TextView::setExtent(float width, float height) const {
  // record the width and height.
}

bool TextView::isEmpty() const {
  return _content==NULL || _content.length==0;

}