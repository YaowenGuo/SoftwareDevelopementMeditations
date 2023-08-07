# 条件语句

说条件判断是程序中最重要的部分一点不为过，各种各样的事件都需要使用条件判断得到不同的结果。

### python

##### if 判断

```python
if <condation> :
    条件为ture时要执行的代码。


if <condation> :
   条件为真执行的代码
else:
    条件为false执行的代码

if <condation1> :
    condation1为true执行的代码
elif <condation2> :
    condation2为true执行的代码
elif <condation3> :
...
else:
    剩余情况执行的代码
    
requested_toppings = []
if requested_toppings:
    for requested_topping in requested_toppings:
        print("Adding " + requested_topping + ".")
    print("\nFinished making your pizza!")
else:
    print("Are you sure you want a plain pizza?")
```
Python将在列表至少包含一个元素时返回True ，并在列表为空时返回False 。

Python中的条件测试使用 True 和 False 来决定是否执行语句块中的代码。

> 条件运算符

| 运算符 | 表示   |
|-------|-------|
|   ==  | 相等，可以直接对字符串使用 |
|  !=   | 不等，
<, <=, >, >=

> 逻辑运算符

and or xor

> 成员操作符

in， not in
用与判断一个元素是否在列表，元组，map中


### javascript 
和java没有什么不同
if(条件1)
{ 条件1成立时执行的代码}
else  if(条件2)
{ 条件2成立时执行的代码}
...
else  if(条件n)
{ 条件n成立时执行的代码}
else
{ 条件1、2至n不成立时执行的代码}

包括switch 语句也是一样的。



