## 语法高亮

syntax off //关闭语法高亮模式
syntax on

## 显示行号

set number


在.vimrc中添加以下代码后，重启vim即可实现按TAB产生4个空格：
set ts=4  (注：ts是tabstop的缩写，设TAB宽4个空格)
set expandtab

对于已保存的文件，可以使用下面的方法进行空格和TAB的替换：
TAB替换为空格：
:set ts=4
:set expandtab
:%retab!

空格替换为TAB：
:set ts=4
:set noexpandtab
:%retab!

加!是用于处理非空白字符之后的TAB，即所有的TAB，若不加!，则只处理行首的TAB。



## 显示空白符


在Linux中，cat -A file可以把文件中的所有可见的和不可见的字符都显示出来，在Vim中，如何将不可见字符也显示出来呢？当然，如果只是想在Vim中查看的话，可以这样:%!cat -A在Vim中调用cat转换显示。这样的做法不便于编辑，其实Vim本身是可以设置显示不可见字符的。

只需要:set invlist即可以将不可见的字符显示出来，例如，会以^I表示一个tab符，$表示一个回车符等。

或者，你还可以自己定义不可见字符的显示方式：
```
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set list
```
最后，:set nolist可以回到正常的模式。



## 插件

vim 的插件管理器特别多，这里使用 vim-plug

https://github.com/junegunn/vim-plug

[配置文件 demo，重命名为 .vimrc, 放到用户 home 目录即可](vimrc)

## 配置文件编写

