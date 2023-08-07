# error in Python3

[TOC]

## Excecption

> 格式 except MySQLdb.Error, e:

File "project\pipelines.py", line 18
except MySQLdb.Error, e:
     ^
SyntaxError: invalid syntax

> You are running your code with Python 3.x, but your code scheme for try.. except section is for Python 2.X.

If you want to run your code with Python 3.x, then change this line:

    except MySQLdb.Error, e:

To:

    except MySQLdb.Error as e:

And if you want this section of code works with Python 2.x and also Python 3.x, then change it to:

    except MySQLdb.Error:
        e = sys.exc_info()[1]

Read more.

But according to your print statement, you write your script for Python 2.x, so it's better to run your code with Python 2.x, instead of Python 3.x

Also this sys.path.append("../python2.7/site-packages") line is strange in first line of your script.

Also your indention of your first code that you pasted was wrong, and i think your are still using that, please use current edited version that is now in your question.

# range()

python3 中返回的是一个 range 对象(range(0, 3))，而不再是一个列表（[0, 1, 2]）。
