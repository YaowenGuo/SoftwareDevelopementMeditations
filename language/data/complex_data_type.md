这里至只记录语言内置的一些高级数据类型。

# 列表

**列表** 由一系列按特定顺序排列的元素组成。你可以创建包含字母表中所有字母、数字 0~9 或所有家庭成员姓名的列表;也可以将任何东西加入列表中,其中的元素之间可以没有
任何关系。鉴于列表通常包含多个元素,给列表指定一个表示复数的名称(如 letters 、 digits 或 names )是个不错的主意。

### python中的列表

在 Python 中,用方括号( [] )来表示列表,并用逗号来分隔其中的元素。超出列表长度将引起索引越界错误。

```python
bicycles = ['trek', 'cannondale', 'redline', 'specialized']
print(bicycles)
```

如果你让 Python 将列表打印出来, Python 将打印列表的内部表示,包括方括号:

> ['trek', 'cannondale', 'redline', 'specialized']

也可以只打印某个元素, 索引从 0 而不是 1 开始.
> print(bicycles[0])

python为从后向前访问元素做了优化，使用-n表示直接访问从后向前数的第n个元素。
```python
print(bicycles[-1])
```
python中的列表是动态的元素，这意味着程序运行中可以动态的修改、添加、删除元素。

###### 修改
bicycles[0] = 'ducati'
###### 添加
- .append(元素) 末尾添加
- .insert(0, 'ducati') 插入元素
###### 删除
使用 del 语句删除元素
如果知道要删除的元素在列表中的位置,可使用 del 语句。
```python
del motorcycles[1]
```
方法 pop() 可删除列表末尾的元素,并让你能够接着使用它。术语弹出 ( pop )源自这样的类比:列表就像一个栈,而删除列表末尾的元素相当于弹出栈顶元素。
```python
popped_motorcycle = motorcycles.pop()
# 实际上,你可以使用 pop() 来删除列表中任何位置的元素,只需在括号中指定要删除的元素的索引即可。
first_owned = motorcycles.pop(0)
```
根据值删除元素
```python
motorcycles = ['honda', 'yamaha', 'suzuki', 'ducati']
print(motorcycles)
motorcycles.remove('honda')

too_expensive = 'ducati'
motorcycles.remove(too_expensive)
```
注意  方法 remove() 只删除第一个指定的值。如果要删除的值可能在列表中出现多次,就需要使用循环来判断是否删除了所有这样的值。

##### 排序
使用方法 sort() 对列表进行永久性排序,再也无法恢复到原来的排列顺序:
```
# 按字母表排序
cars = ['bmw', 'audi', 'toyota', 'subaru']
cars.sort()
print(cars)
# 倒叙　只需向 sort() 方法传递参数 reverse=True
cars.sort(reverse=True)
```
使用函数 sorted() 对列表进行临时排序。函数 sorted() 让你能够按特定顺序显示列表元素,同时不影响它们在列表中的原始排
列顺序。
```python
cars = ['bmw', 'audi', 'toyota', 'subaru']
print("Here is the original list:")
print(cars)
print("\nHere is the sorted list:")
print(sorted(cars))
print("\nHere is the original list again:")
print(cars)
```
也可向函数 sorted() 传递参数 reverse=True 。

注意  在并非所有的值都是小写时,按字母顺序排列列表要复杂些。决定排列顺序时,有多种解读大写字母的方式,要指定准确的排列顺序,可能比我们这里所做的
要复杂。然而,大多数排序方式都基于本节介绍的知识。

##### 倒着打印列表
要反转列表元素的排列顺序,可使用方法 reverse() 。假设汽车列表是按购买时间排列的,可轻松地按相反的顺序排列其中的汽车:
```python
cars = ['bmw', 'audi', 'toyota', 'subaru']
print(cars)
cars.reverse()
print(cars)
```
方法 reverse() 永久性地修改列表元素的排列顺序,但可随时恢复到原来的排列顺序,为此只需对列表再次调用 reverse() 即可。

##### 确定列表的长度
使用函数 len() 可快速获悉列表的长度。
```python
len(cars)
```

### 切片
要创建切片,可指定要使用的第一个元素和最后一个元素的索引。与函数 range() 一样, Python 在到达你指定的第二个索引前面的元素后停止。要输出列表中的前三个元素,需
要指定索引 0~3 ,这将输出分别为 0 、 1 和 2 的元素。
下面的示例处理的是一个运动队成员列表:
```python
players = ['charles', 'martina', 'michael', 'florence', 'eli']
print(players[0:3])

# 如果你没有指定第一个索引, Python 将自动从列表开头开始:
players = ['charles', 'martina', 'michael', 'florence', 'eli']
print(players[:4])

# 要让切片终止于列表末尾,也可使用类似的语法。例如,如果要提取从第 3 个元素到列表末尾的所有元素,可将起始索引指定为 2 ,并省略终止索引:
players = ['charles', 'martina', 'michael', 'florence', 'eli']
print(players[2:])

# 无论列表多长,这种语法都能够让你输出从特定位置到列表末尾的所有元素。本书前面说过,负数索引返回离列表末尾相应距离的元素,因此你可以输出列表末尾的任何切片。
# 例如,如果你要输出名单上的最后三名队员,可使用切片 players[-3:] :
players = ['charles', 'martina', 'michael', 'florence', 'eli']
print(players[-3:])

# 要复制列表,可创建一个包含整个列表的切片,方法是同时省略起始索引和终止索引( [:] )。这让 Python 创建一个始于第一个元素,终止于最后一个元素的切片,即复制整个列表。

# 元组
元组是有序的不可变数据集合。元组一旦创建，元素的值将不可修改。python 将不能修改的值称为不可变的。元组则是不可变的列表。
元组的定义和使用和列表非常相似，元组使用圆括号来定义，同样使用索引来访问元素:
```python
dimensions = (200, 50)
print(dimensions[0])
print(dimensions[1])
```
下面来尝试修改元组 dimensions 中的一个元素,看看结果如何:
```python
dimensions = (200, 50)
dimensions[0] = 250
## 处的代码试图修改第一个元素的值,导致 Python 返回类型错误消息。由于试图修改元组的操作是被禁止的,因此 Python 指出不能给元组的元素赋值:
Traceback (most recent call last):
  File "dimensions.py", line 3, in <module>
    dimensions[0] = 250
TypeError: 'tuple' object does not support item assignment
```
##### 修改元组变量
虽然不能修改元组的元素,但可以给存储元组的变量赋值。因此,如果要修改前述矩形的尺寸,可重新定义整个元组:
```python
dimensions = (200, 50)
print("Original dimensions:")
for dimension in dimensions:
  print(dimension)

dimensions = (400, 100)
print("\nModified dimensions:")
for dimension in dimensions:
  print(dimension)
```
***除了修改元素的值，列表中的所有操作都可以用于元组上***

# 字典 Map

Python 将键-值对应的数据组织方式称为字典。这跟其他语音中的 Map 使用时一样的。每个键都和一个值相关联，可以通过键来访问与之关联的值。

### python
可以将任何 Python 中的对象作为字典中的值。但是键则必须是基本数据类型。

##### 创建
在Python中，字典用放在花括号{} 中的一系列键—值对表示，如前面的示例所示:
```python
alien_0 = {'color': 'green', 'points': 5}
```

##### 获取
要获取与键相关联的值，可依次指定字典名和放在方括号内的键，如下所示:
```python
alien_0 = {'color': 'green'}
print(alien_0['color'])
```
> get() 方法和 `[]` 下标获取值的异同

- 当 key 不存在时，下标获取会抛出异常，而 get() 返回空值。
- get() 可以给出第二个参数，在 key 不存在时作为默认值。 


##### 添加
字典是一种动态结构，可随时在其中添加键—值对。要添加键—值对，可依次指定字典名、用方括号括起的键和相关联的值。
```python
alien_0 = {'color': 'green', 'points': 5}
print(alien_0)
alien_0['x_position'] = 0
alien_0['y_position'] = 25
print(alien_0)
```
*** 注意，键—值对的排列顺序与添加顺序不同。Python不关心键—值对 的添加顺序，而只关心键和值之间的关联关系。***

##### 修改值
要修改字典中的值，可依次指定字典名、用方括号括起的键以及与该键相关联的新值。

##### 删除键—值对
对于字典中不再需要的信息，可使用del 语句将相应的键—值对彻底删除。使用del 语句时，必须指定字典名和要删除的键。 例如，下面的代码从字典alien_0 中删除键'points' 及其值:
```python
alien_0 = {'color': 'green', 'points': 5}
print(alien_0)
del alien_0['points']
print(alien_0)
```
##### 嵌套
列表的值可以是任意对象，所以也可以是字典。字典的值可以是任何对象，所以也可以是列表，甚至是字典。这都是合法的。


### javascript 中的数组
