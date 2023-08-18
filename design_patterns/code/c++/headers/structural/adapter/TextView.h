//
// Created by Albert on 1/3/21.
//

/* 被适配的接口（已经实现了功能，但是又和自己项目接口不匹配的类
*  TextView 是其它项目中的接口实现。已经实现了功能，可以使用。但是接口和自己项目的接口不匹配。
* 需要适配。
*/

#ifndef DESIGN_PATTERNS_C_HEADERS_STRUCTURAL_ADAPTER_TEXTVIEW_H
#define DESIGN_PATTERNS_C_HEADERS_STRUCTURAL_ADAPTER_TEXTVIEW_H
#include <string.h>

class TextView {
  TextView();
  void setOrigin(float x, float y) const; // 接口不匹配体现在通过原点和宽，高来定会位置的边界。
  void setExtent(float width, float height) const;// 宽， 高
  bool isEmpty() const;

private:
  string _content;
};

#endif //DESIGN_PATTERNS_C_HEADERS_STRUCTURAL_ADAPTER_TEXTVIEW_H
