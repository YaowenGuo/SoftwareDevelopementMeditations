文档对象模型DOM（Document Object Model）定义访问和处理HTML文档的标准方法。DOM 将HTML文档呈现为带有元素、属性和文本的树结构（节点树）。

先来看看下面代码:

![](/assets/5375ca640001c67307860420.jpg)

将HTML代码分解为DOM节点层次图:

![](/assets/5375ca7e0001dd8d04830279.jpg)

HTML文档可以说由节点构成的集合，DOM节点有:

1. 元素节点：上图中<html>、<body>、<p>等都是元素节点，即标签。

2. 文本节点:向用户展示的内容，如<li>...</li>中的JavaScript、DOM、CSS等文本。

3. 属性节点:元素属性，如<a>标签的链接属性href="http://www.imooc.com"。

节点属性:

![](/assets/5375c953000117ee05240129.jpg)

遍历节点树:
![](/assets/53f17a6400017d2905230219.jpg)


以上图ul为例，它的父级节点body,它的子节点3个li,它的兄弟结点h2、P。

DOM操作:
![](/assets/538d29da000152db05360278.jpg)


注意:前两个是document方法。