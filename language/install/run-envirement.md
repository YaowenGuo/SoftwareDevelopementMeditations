# Java Script

作为轻量级的解释语言，js的运行场景并不多，但是却很广泛。任何流行的浏览器都带有js的解释器。为了运行js代码，

1，可以将js嵌入到网页中，并将其写入到&lt;script&gt;&lt;/script&gt;标签中。

```html
<!DOCTYPE html>
<html>
<head>
	<title>js测试</title>
</head>
<body>
	<pre><script type="text/javascript" > document.writeln('Hello Word!');</script></pre>

</body>
</html>
```

pre 元素可定义预格式化的文本。被包围在 pre 元素中的文本通常会保留空格和换行符。而文本也会呈现为等宽字体。

`<pre>` 标签的一个常见应用就是用来表示计算机的源代码。

2，有时候js很长，你并不想要将js直接写在一个html中，况且为了能够重用js代码，也应该讲js独立出来，这时候可以新建一个文件，将嵌入改成引入的形式

```html
<pre><script type="text/javascript" src="js的文件名.js"/></pre>

```
js 文件中可以直接写代码，不必再加任何标签。
```
document.writeln('Hello Word!');
```

3，有时候你并不是想要保留代码，只是想要测试一个特性，那么你可以直接在浏览器的终端中运行。

开发者选项 -> Console 直接输入代码就可以运行。如 a = 5;

# PHP

- 嵌入式的风格比完成生成html的其他语言效率要高。
- 可以执行编译后的代码，具有加密和效率高的特点。
- 支持几乎所有主流数据库。
- 可以使用 C、C++ 进行扩展。


PHP (Hypertext Preprocessor 超文本预处理语言)作为HTML 内嵌式的语言，最初的写法，就是直接写在 HTML 文档中。
此时需要一个标签来标识 PHP 代码。

```
XML 风格的php标识标签。建议使用的
<?php
php 代码
?>  如果整个文件只有 PHP 代码，建议不要写改封闭括号

如果文件内容是纯 PHP 代码，最好在文件末尾删除 PHP 结束标记。这可以避免在 PHP 结束标记之后万一意外加入了空格或者换行符，会导致 PHP 开始输出这些空白，而脚本中此时并无输出的意图。 

短风格，很少使用，知道就行
需要单独设置 php.ini 将short_open_tags设置为打开，默认情况下是关闭的。而这种标识方法与XML的表示方法冲突，所以不建议使用。 
<?
php 代码
?>

javascript 风格，也不常用

<script language="php">
echo "JS 风格"；
</script>

ASP 风格，这是为了兼容 ASP 使用者的习惯而设定的。
<%
echo "ASP 风格的语言表示";
%>
```
与js代码不同，PHP 是在服务器端执行的，PHP解释器会将代码中使用 PHP 标签标识的PHP 代码全部执行为结果，然后输出一个纯 HTML 文件，转交给服务器，然后服务器响应客户端的请求，所以在客户端根本看不到PHP代码。

另外，我强烈建议使用新版本的 PHP 的解释器，新的解释器能够将PHP像脚本一样执行，这为开发一些脚本程序和测试语言特性带来非常大的方便。

### 像 python 一样交互执行
php -a 将打开一个交互式的终端环境，非常方便的测试语言的特性。

### 脚本文件
如果想要写一个算法，或者一个命令行程序，只在交互环境中编写显得不合时宜，可以在文件中编写 PHP 代码，例如
```
echo  "PHP word!";
```
php 文件名 就能执行 PHP 代码。当然我建议使用 PHP 文件 的规范写法。
```
<?php
// 导入类

echo "PHP word!";

```


## Python

在解释器中执行 Python 文件

```python
>>> exec(open("filename.py").read())

# or

>>> from pathlib import Path

>>> exec(Path("filename.py").read_text())
```



