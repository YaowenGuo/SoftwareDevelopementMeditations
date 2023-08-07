# 函数
函数，是对一组逻辑紧密相关代码的组织（封装),在编程中，总会有许多相同的逻辑或显示要处理，理想的情况是，在一处编写改代码，就能够
到处使用。函数就是处理一项功能或逻辑的封装。你可以通过一个名字来随时使用该代码块。有的人将其分为过程和函数，将没有任何返回值的代码
称为过程。这是基于数学上的严谨定义老考虑的。在面向对象语言中，函数又被称为方法。（人嘛，总会形形色色的想法。）

### javascript 
使用function 关键字定义
```script
function 函数名(x, y, ...)
{
     函数代码;
     return 值;
}
```
函数的调用也要写在<script></sctipt>标签内部。
还可以使用html标签的onclick属性调用。
<input type="button"  value="点点我" onclick="tcon()"> 

函数不需要声明返回，直接return即可，这也是弱类型语言的好处。


### python
```python
❶ def greet_user():
❷     """显示简单的问候语"""
❸     print("Hello!")

❹ greet_user()


def greet_user(username):
    """显示简单的问候语"""
    print("Hello, " + username.title() + "!")

greet_user('jesse')

```
这个示例演示了最简单的函数结构。❶处的代码行使用关键字def 来告诉Python你要定义一个函数。这是函数定义 ，向Python指出了函数名，
还可能在括号内指出函数为完成其 任务需要什么样的信息。在这里，函数名为greet_user() ，它不需要任何信息就能完成其工作，因此括号
是空的(即便如此，括号也必不可少)。最后，定义以冒号结尾。
紧跟在def greet_user(): 后面的所有缩进行构成了函数体。❷处的文本是被称为文档字符串 (docstring)的注释，描述了函数是做什么的。
文档字符串用三引号括 起，Python使用它们来生成有关程序中函数的文档。
代码行print("Hello!") (见❸)是函数体内的唯一一行代码，greet_user() 只做一项工作:打印Hello! 。
要使用这个函数，可调用它。函数调用 让Python执行函数的代码。要调用 函数，可依次指定函数名以及用括号括起的必要信息，如❹处所示。
由于这个函数不需要任何信息，因 此调用它时只需输入greet_user() 即可。和预期的一样，它打印Hello! 

##### 默认值
编写函数时，可给每个形参指定默认值 。在调用函数中给形参提供了实参时，Python将使用指定的实参值;否则，将使用形参的默认值。因此，
给形参指定默认值后，可在函数调用中省略相应的实参。使用默认值可简化函数调用，还可清楚地指出函数的典型用法。
1. 可以只给一部分参数指定默认值，但是一定要将没有给出默认值的放在前面，有默认值的放在后面。这是为了在实际调用函数是只给出一部分
参数时，按顺序赋值给前面的实参。保证前面的实参优先获得默认值而后面的参数也能够使用默认值。
2. 如果给出实参，默认值将被忽略

```python
def describe_pet(pet_name, animal_type='dog'):
    """显示宠物的信息"""
    print("\nI have a " + animal_type + ".")
    print("My " + animal_type + "'s name is " + pet_name.title() + ".")
    
describe_pet(pet_name='willie')
```
这里修改了函数describe_pet() 的定义，在其中给形参animal_type 指定了默认值'dog' 。这样，调用这个函数时，如果没有给animal_type
指定值，Python将把这个 形参设置为'dog'

##### 传递参数
python 对参数的传递做了优化，不仅能够按顺序传递参数，还能够通过形参名字指定实参，而不必按照原来的循序。这对于有多个参数的函数特别有用。
###### 通过顺序传递参数
Python必须将函数调用中的每个实参都关联到函数定义中的一个形参。为此，最简单的关联方式是基于实参的顺序。这种关联方式被称为位置实参 。
```python
❶ def describe_pet(animal_type, pet_name):
      """显示宠物的信息"""
      print("\nI have a " + animal_type + ".")
      print("My " + animal_type + "'s name is " + pet_name.title() + ".")
❷ describe_pet('hamster', 'harry')
```
这个函数的定义表明，它需要一种动物类型和一个名字(见❶)。调用describe_pet() 时，需要按顺序提供一种动物类型和一个名字。例如，在前面的
函数调用中，实 参'hamster' 存储在形参animal_type 中，而实参'harry' 存储在形参pet_name 中(见❷)。在函数体内，使用了这两个形参来
显示宠物的信息。

###### 关键字实参
关键字实参 是传递给函数的名称—值对。你直接在实参中将名称和值关联起来了，因此向函数传递实参时不会混淆(不会得到名为Hamster的harry这样
的结果)。关键字实参让你无需考虑函数调用中的实参顺序，还清楚地指出了函数调用中各个值的用途。
```python
describe_pet(animal_type='hamster', pet_name='harry')
```
*** 关键字形参能够让你不按照定义的顺序来传递参数，这对于已经给出默认值的参数特别有个。我们可以省略一个已经有默认值的参数而对其后面的
参数进行赋值。但是，使用参数名也就意味着你需要明确知道形参的名字，不能出错。***
*** 可以混合的使用顺序实参，形参值指定，默认值的形式赋值，

##### 传递副本
有时候，需要禁止函数修改列表。例如，假设像前一个示例那样，你有一个未打印的设计列表，并编写了一个将这些设计移到打印好的模型列表中
的函数。你可能会做出这样的决定:即便打印所有设计后，也要保留原来的未打印的设计列表，以供备案。但由于你将所有的设计都移出了
unprinted_designs ，这个列表变成了空的，原来的列表没有 了。为解决这个问题，可向函数传递列表的副本而不是原件;这样函数所做的任
何修改都只影响副本，而丝毫不影响原件。要将列表的副本传递给函数，可以像下面这样做:
```python
function_name(list_name[:])
```
切片表示法[:] 创建列表的副本。在print_models.py中，如果不想清空未打印的设计列表，可像下面这样调用print_models() :
```python
print_models(unprinted_designs[:], completed_models)
```
这样函数print_models() 依然能够完成其工作，因为它获得了所有未打印的设计的名称，但它使用的是列表unprinted_designs 
的副本，而不是列 表unprinted_designs 本身。像以前一样，列表completed_models 也将包含打印好的模型的名称，但函数所做的修改不
会影响到列表unprinted_designs 。虽然向函数传递列表的副本可保留原始列表的内容，但除非有充分的理由需要传递副本，否则还是应该将原
始列表传递给函数，因为让函数使用现成列表可避免花时间和内存创建副本，从而提高效率，在处理大型列表时尤其如此。

##### 传递任意数量的参数（元组）
有时候，你预先不知道函数需要接受多少个实参，好在Python允许函数从调用语句中收集任意数量的实参。
```python
def make_pizza(*toppings):
    """打印顾客点的所有配料"""
    print(toppings)
    
make_pizza('pepperoni')
make_pizza('mushrooms', 'green peppers', 'extra cheese')
```
形参名*toppings 中的星号让Python创建一个名为toppings 的空元组，并将收到的所有值都封装到这个元组中。函数体内的print 语句通过
生成输出来证明Python能够处理 使用一个值调用函数的情形，也能处理使用三个值来调用函数的情形。它以类似的方式处理不同的调用，注意，
Python将实参封装到一个元组中，即便函数只收到一个值也如此

##### 结合使用位置实参和任意数量实参 如果要让函数接受不同类型的实参，必须在函数定义中将接纳任意数量实参的形参放在最后。Python
先匹配位置实参和关键字实参，再将余下的实参都收集到最后一个形参中。
例如，如果前面的函数还需要一个表示比萨尺寸的实参，必须将该形参放在形参*toppings 的前面:
```python
def make_pizza(size, *toppings):
    """概述要制作的比萨"""
    print("\nMaking a " + str(size) + "-inch pizza with the following toppings:")
    for topping in toppings:
        print("- " + topping)
        
make_pizza(16, 'pepperoni')
make_pizza(12, 'mushrooms', 'green peppers', 'extra cheese')
```

##### 使用任意数量的关键字实参
有时候，需要接受任意数量的实参，但预先不知道传递给函数的会是什么样的信息。在这种情况下，可将函数编写成能够接受任意数量的键—值对——调
用语句提供了多少就接 受多少。一个这样的示例是创建用户简介:你知道你将收到有关用户的信息，但不确定会是什么样的信息。在下面的示例中，函
数build_profile() 接受名和姓，同时还接受 任意数量的关键字实参:

```python
def build_profile(first, last, **user_info):
    """创建一个字典，其中包含我们知道的有关用户的一切"""
    profile = {}
    profile['first_name'] = first
    profile['last_name'] = last
    
    for key, value in user_info.items():
        profile[key] = value
    return profile
    
user_profile = build_profile('albert', 'einstein', location='princeton', field='physics')
print(user_profile)
```

##### 返回值
函数并非总是直接显示输出，相反，它可以处理一些数据，并返回一个或一组值。函数返回的值被称为返回值 。在函数中，可使用return 语句将值
返回到调用函数的代码行。
返回值让你能够将程序的大部分繁重工作移到函数中去完成，从而简化主程序。

因为python是弱数据类型的语言，你不需要指定任何返回值的类型，这是与其他强数据类型不同的地方。只需要在函数需要返回结果的地方，使用
return 关键字将数据返回就行了。当程序执行了 return 语句时，如果后面还有其他代码，程序并不会执行这部分代码，这对于快速结束函数的
执行和跳出深层逻辑循环都很有帮助。
```python
def get_formatted_name(first_name, last_name):
    """返回整洁的姓名"""
    full_name = first_name + ' ' + last_name
    return full_name.title()
```



