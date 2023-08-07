# 错误和异常处理
异常时程序中发生的一些预测到，或者意外发生的，我们不希望发生的事情。但是这这些事会影响到接下来的程序运行，严重的甚至导致程序无法继续运行。为了以面向对象的方式处理这些意外情况，一些语言中引入了异常概念，用于处理这些情况，使程序能够以一种优雅的方式作出反应，提示用户或者优雅退出。

### python中的异常
在python中，使用被称为异常的对象来管理程序执行过程中发生的错误。每当发生让Python不知所措的错误时，它都会创建一个异常对象。如果你编写了处理该异常的代码，程序将继 续运行;如果你未对异常进行处理，程序将停止，并显示一个traceback，其中包含有关异常的报告。

异常是使用try-except 代码块处理的。try-except 代码块让Python执行指定的操作，同时告诉Python发生异常时怎么办。使用了try-except 代码块时，即便出现异常， 程序也将继续运行:显示你编写的友好的错误消息，而不是令用户迷惑的traceback。

##### 处理ZeroDivisionError 异常
```python
print(5/0)
```
显然，Python无法这样做，因此你将看到一个traceback:
Traceback (most recent call last):
    File "division.py", line 1, in <module>
        print(5/0)
❶ ZeroDivisionError: division by zero

在上述traceback中，❶处指出的错误ZeroDivisionError 是一个异常对象。Python无法按你的要求做时，就会创建这种对象。在这种情况下，Python将停止运行程序，并指出 引发了哪种异常，而我们可根据这些信息对程序进行修改。下面我们将告诉Python，发生这种错误时怎么办;这样，如果再次发生这样的错误，我们就有备无患了。

##### 捕获与处理
当你认为可能发生了错误时，可编写一个try-except 代码块来处理可能引发的异常。你让Python尝试运行一些代码，并告诉它如果这些代码引发了指定的异常，该怎么办。 处理ZeroDivisionError 异常的try-except 代码块类似于下面这样:
```python
try:
    print(5/0)
except ZeroDivisionError:
    print("You can't divide by zero!")
```
如果try 代码块中的代码运行起来没有问题，Python将跳过except 代码块;如果try 代码块中的代码导致了 错误，Python将查找这样的except 代码块，并运行其中的代码，即其中指定的错误与引发的错误相同。
在这个示例中，try 代码块中的代码引发了ZeroDivisionError 异常，因此Python指出了该如何解决问题的except 代码块，并运行其中的代码。这样，用户看到的是一条友 好的错误消息，而不是traceback。

##### else 代码
```python
try:
    answer = int(first_number) / int(second_number)
except ZeroDivisionError:
    print("You can't divide by 0!")
else:
    print(answer)
```
python 的else虽然使结构更加清晰，成功了就会执行else的内容， 异常了执行execpt的内容，但是这并没有java中的finaly有用，这是因为，这些
内容完全可以放在try块中继续执行，一旦异常法伤额

##### 什么都不执行
Python有一个pass 语句，可在代码块中使用它来让Python 什么都不要做:
```python
def count_words(filename):
    """计算一个文件大致包含多少个单词"""
    try:
        --snip--
    except FileNotFoundError:
        pass
    else:
        --snip--

filenames = ['alice.txt', 'siddhartha.txt', 'moby_dick.txt', 'little_women.txt']
for filename in filenames:
    count_words(filename)
    
```
python的pass语句不止能在expect中使用，它能够出现在任何语句块中，如：函数，for，if，else等逻辑块中。
pass 语句还充当了占位符，它提醒你在程序的某个地方什么都没有做，并且以后也许要在这里做些什么。



