所有的永久性的数据都是以文件的形式保存的。计算机中的文件也是现实世界中的概念在计算机中的一个迁移表示。如果你想要时数据能够“永久化”保存，你就不最好
将它写入文件，这样在电脑挂机或者掉电时，你的数据才不会丢失。当然，对于保存了的数据想要知道其内容，就需要读取文件。


# 读取文件

### python

```python
with open('pi_digits.txt') as file_object:
    contents = file_object.read()
    print(contents)
```

在这个程序中，第1行代码做了大量的工作。我们先来看看函数open() 。要以任何方式使用文件——哪怕仅仅是打印其内容，都得先打开 文件，这样才能访问它。函数open() 接受一个参数:要打开的文件的名称。Python在当前执行的文件所在的目录中查找指定的文件。在这个示例中，当前运行的是file_reader.py，因此Python在file_reader.py所在的目录中 查找pi_digits.txt。函数open() 返回一个表示文件的对象。在这里，open('pi_digits.txt') 返回一个表示文件pi_digits.txt 的对象;Python将这个对象存储在我们将 在后面使用的变量中。

关键字with 在不再需要访问文件后将其关闭。在这个程序中，注意到我们调用了open() ，但没有调用close() ;你也可以调用open() 和close() 来打开和关闭文件，但 这样做时，如果程序存在bug，导致close() 语句未执行，文件将不会关闭。这看似微不足道，但未妥善地关闭文件可能会导致数据丢失或受损。如果在程序中过早地调 用close() ，你会发现需要使用文件时它已关闭 (无法访问)，这会导致更多的错误。并非在任何情况下都能轻松确定关闭文件的恰当时机，但通过使用前面所示的结构，可 让Python去确定:你只管打开文件，并在需要时使用它，Python自会在合适的时候自动将其关闭。

有了表示pi_digits.txt的文件对象后，我们使用方法read() (前述程序的第2行)读取这个文件的全部内容，并将其作为一个长长的字符串存储在变量contents 中。这样，通过 打印contents 的值，就可将这个文本文件的全部内容显示出来:

相比于原始文件，该输出唯一不同的地方是末尾多了一个空行。为何会多出这个空行呢?因为read() 到达文件末尾时返回一个空字符串，而将这个空字符串显示出来时就是一 个空行。要删除多出来的空行，可在print 语句中使用rstrip() :
```python
with open('pi_digits.txt') as file_object:
    contents = file_object.read()
    print(contents.rstrip())
```

##### 逐行读取
读取文件时，常常需要检查其中的每一行:你可能要在文件中查找特定的信息，或者要以某种方式修改文件中的文本。例如，你可能要遍历一个包含天气数据的文件，并使用天气描述中包含字样sunny的行。在新闻报道中，你可能会查找包含标签<headline> 的行，并按特定的格式设置它。 要以每次一行的方式检查文件，可对文件对象使用for 循环:

```python
❶ filename = 'pi_digits.txt'
❷ with open(filename) as file_object:
❸     for line in file_object:
           print(line)
           
# 这时候你会发现print每次输出都会附加一个换行，如果你不想要这个换行，可以指定print的结束为空字符串
# 到了python3中，print变成一个函数，这种语法便行不通了。用2to3工具转换了下，变成这样了：
print(line, end=' ')


# 注意，如果文件已经读取到末尾，继续读就不会返回数据。例如下面的内容不会获得任何内容
with open("pi.txt") as file_object:
    contain = file_object.read()
    #print(contain)
    for line in file_object:
        print(line)
# 这是因为读取contain时，已经读取到末尾了，这时候file_object中指向的是文件末尾，这时候继续读取，就读不到内容了


# 如果想要将读取的文件内容创建一个列表。可以使用 readlines()
with open(filename) as file_object:
❶  lines = file_object.readlines()


❷ for line in lines:
       print(line， end='')

# ❶处的方法readlines() 从文件中读取每一行，并将其存储在一个列表中;接下来，该列表被存储到变量lines 中;在with 代码块外，我们依然可以使用这个变量。在
# ❷ 处，我们使用一个简单的for 循环来打印lines 中的各行。由于列表lines 的每个元素都对应于文件中的一行，因此输出与文件内容完全一致。    
```
在❶处，我们将要读取的文件的名称存储在变量filename 中，这是使用文件时一种常见的做法。由于变量filename 表示的并非实际文件——它只是一个让Python知道到哪里 去查找文件的字符串，因此可轻松地将'pi_digits.txt' 替换为你要使用的另一个文件的名称。调用open() 后，将一个表示文件及其内容的对象存储到了变 量file_object 中(见❷)。这里也使用了关键字with ，让Python负责妥善地打开和关闭文件。为查看文件的内容，我们通过对文件对象执行循环来遍历文件中的每一行(见 ❸)。


### 写入文件

```python
  filename = 'programming.txt'
❶ with open(filename, 'w') as file_object:
❷ file_object.write("I love programming.")
```

在这个示例中，调用open() 时提供了两个实参(见❶)。第一个实参也是要打开的文件的名称;第二个实参('w' )告诉Python，我们要以写入模式 打开这个文件。打开文件 时，可指定读取模式 ('r' )、写入模式 ('w' )、附加模式 ('a' )或让你能够读取和写入文件的模式('r+' )。如果你省略了模式实参，Python将以默认的只读模式打 开文件。
如果你要写入的文件不存在，函数open() 将自动创建它。然而，以写入('w' )模式打开文件时千万要小心，因为如果指定的文件已经存在，Python将在返回文件对象前清空 该文件。
在❷处，我们使用文件对象的方法write() 将一个字符串写入文件。

***Python只能将字符串写入文本文件。要将数值数据存储到文本文件中，必须先使用函数str() 将其转换为字符串格式。***

- 函数write() 不会在你写入的文本末尾添加换行符，因此如果你写入多行时没有指定换行符，文件看起来可能不是你希望的那样:
- 如果你要给文件添加内容，而不是覆盖原有的内容，可以附加模式 打开文件。你以附加模式打开文件时，Python不会在返回文件对象前清空文件，而你写入到文件的行都将添加到文件末尾。如果指定的文件不存在，Python将为你创建一个空文件。
