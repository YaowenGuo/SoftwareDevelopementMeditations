# 代码组织

## Crate



## Moduel

- Modules can also hold definitions for other items, such as structs, enums, constants, traits, or functions.


use: 用于导入 module。
as: 指定新名称用于防止同名冲突。

use 导入的内容默认是 private 的。可以使用 `pub` 修饰重新暴露给外部。此时可以使用当前的包路径访问。就像在当前路径定义的一样。

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

此时可以使用 `hosting::add_to_waitlist` 在外部访问 `add_to_waitlist()` 而不是 `front_of_house::hosting::add_to_waitlist()`。这种方式能够方便暴露给库外部的接口的简化。

使用嵌套路径避免大型使用列表。

```rust
// --snip--
use std::cmp::Ordering;
use std::io;
// --snip--
```

可以使用 `{}` 合并相同的路径。

```rust
// --snip--
use std::{cmp::Ordering, io};
// --snip--
use std::io::{self, Write};
// * match all sub path. it bring all public items defined in a path into scope.
use std::collections::*;
```


## Access control

