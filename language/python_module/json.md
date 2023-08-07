JSON(JavaScript Object Notation)格式最初是为JavaScript开发的，但随后成了一种常见格式，被包括Python在内的众多语言采用。

#### 
函数json.dump() 接受两个实参:要存储的数据以及可用于存储数据的文件对象。下面演示了如何使用json.dump() 来存储数字列表:
```python
  import json
   numbers = [2, 3, 5, 7, 11, 13]
❶ filename = 'numbers.json'
❷ with open(filename, 'w') as f_obj:
❸     json.dump(numbers, f_obj)

# 打开文件numbers.json，看看其内容。数据的存储格式与Python中一样:
# [2,3,5,7,11,13]

   import json
❶ filename = 'numbers.json'
❷ with open(filename) as f_obj:
❸     numbers = json.load(f_obj)

   print(numbers)
   
 # [2,3,5,7,11,13]
 # 函数json.load() 加载存储在 numbers.json中的信息，并将其存储到变量numbers 中。
 
 
