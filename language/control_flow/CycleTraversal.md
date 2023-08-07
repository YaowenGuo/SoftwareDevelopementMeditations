# 循环遍历

循环控制用于对一组数据进行逐个操作，这种操作是建立在遍历的基础上的。

### python
Python 中也有 for 循环，只是 for 循环的机制与其他编译型语言有些不同，这使得他的样子也有些不同。
```python
for 元素　in 列表:　＃ 注意这里的冒号“：”，这是循环体开始的标志
    ＃ 对元素进行具体操作
    
magicians = ['alice', 'david', 'carolina']
for magician in magicians:
  print(magician)
```
python 使用缩进进行逻辑块的整理。如果想要在 for 循环之后继续进行一下操作。只需要讲缩进与 for 开始的地方对其，而不是与其子块对其就行了
```python
magicians = ['alice', 'david', 'carolina']
for magician in magicians:
  print(magician.title() + ", that was a great trick!")
  print("I can't wait to see your next trick, " + magician.title() + ".\n")

print("Thank you, everyone. That was a great magic show!")
```
##### 在循环中使用索引访问列表
python 的循环只能使用 in 来遍历列表中的所有元素，没有对某一元素逐渐加一，达到某一临界值结束循环的控制。要想使用索引访问列表，就要自己创建一个索引的
列表，用在　for 的控制结构中,幸运的是 python 提供了快速生成数字列表的方式 range():
range有多种不同的生成方式：
```python
# 从某个数开始，到某个数之前的所有整数
for value in range(1,5):
  print(value)
```
```
1
2
3
4
```
##### 使用 range() 创建数字列表
要创建数字列表,可使用函数 list() 将 range() 的结果直接转换为列表。如果将 range() 作为 list() 的参数,输出将为一个数字列表。
在前一节的示例中,我们打印了一系列数字。要将这些数字转换为一个列表,可使用 list() :
```python
numbers = list(range(1,6))
print(numbers)
```
使用 range 还可以指定步长。
```python
even_numbers = list(range(2,11,2))
print(even_numbers)
```

##### 列表解析
列表解析将 for 循环和创建新元素的代码合成在一起
```python
squares = [value**2 for value in range(1,11)]
print(squares)

# 如下等价的方法
squares = []
for value in range(1,11):
  squares.append(value**2)
```
列表解析允许将一个 for 循环表达式放在列表的方括号中，用于生成你要存储到列表中的值。表达式后跟一个 for 循环来为表达式提供值。这里表达式为value**2，
使用for value in range(1,11)为value提供值，表达式的结果将作为新创建列表的元素。

### 遍历字典
```python
user_0 = {
    'username': 'efermi',
    'first': 'enrico',
    'last': 'fermi',
}
for key, value in user_0.items():
    print("\nKey: " + key)
    print("Value: " + value)
```
要编写用于遍历字典的for 循环，可声明两个变量，用于存储键—值对中的键和值。对于这两个变量，可使用任何名称。
for 语句的第二部分包含字典名和方法items() ，它返回一个键—值对列表。接下来，for 循环依次将每个键—值对存储到指定的两个变量中。在前面的示例中，我 们使用这两个变量来打印每个键及其相关联的值。

*** 注意，即便遍历字典时，键—值对的返回顺序也与存储顺序不同。Python不关心键—值对的存储顺序，而只跟踪键和值之间的关联关系。***

##### 遍历字典中的所有键, 遍历字典中的所有值
在不需要使用字典中的值时，方法keys() 很有用。下面来遍历字典favorite_languages ，并将每个被调查者的名字都打印出来:
```python
favorite_languages = {
    'jen': 'python',
    'sarah': 'c',
    'edward': 'ruby',
    'phil': 'python',
}
for name in favorite_languages.keys():
    print(name.title())
```
值使用 values() 方法。


### while 循环
for 循环用于针对集合中的每个元素都一个代码块，而while 循环不断地运行，直到指定的条件不满足为止。
```python
current_number = 1
while current_number <= 5:
print(current_number) current_number += 1
```

### break 退出循环
要立即退出while 循环，不再运行循环中余下的代码，也不管条件测试的结果如何，可使用break 语句。break 语句用于控制程序流程，可使用它来控制哪些代码行将执行，
哪些代码行不执行，从而让程序按你的要求执行你要执行的代码。 例如，来看一个让用户指出他到过哪些地方的程序。在这个程序中，我们可以在用户输入'quit' 后使用break 语句立即退出while 循环:
```python
prompt = "\nPlease enter the name of a city you have visited:" prompt += "\n(Enter 'quit' when you are finished.) "
while True:
    city = input(prompt)
    if city == 'quit':
        break
    else:
        print("I'd love to go to " + city.title() + "!")
```
### 在循环中使用continue
要返回到循环开头，并根据条件测试结果决定是否继续执行循环，可使用continue 语句，它不像break 语句那样不再执行余下的代码并退出整个循环。例如，来看一个从1数 到10，但只打印其中偶数的循环:
```python
current_number = 0
while current_number < 10:
    current_number += 1
    if current_number % 2 == 0:
        continue
    
    print(current_number)
```

我们首先将current_number 设置成了0，由于它小于10，Python进入while 循环。进入循环后，我们以步长1的方式往上数(见❶)，因此current_number 为1。接下 来，if 语句检查current_number 与2的求模运算结果。如果结果为0(意味着current_number 可被2整除)，就执行continue 语句，让Python忽略余下的代码，并返回 到循环的开头。如果当前的数字不能被2整除，就执行循环中余下的代码，Python将这个数字打印出来:
prompt = "\nTell me something, and I will repeat it back to you:" prompt += "\nEnter 'quit' to end the program. "








