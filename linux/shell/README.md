shell  脚本里的命令执行

1. 在 bash 中，$( )与` `（反引号）都是用来作命令替换的。
　　命令替换与变量替换差不多，都是用来重组命令行的，先完成引号里的命令行，然后将其结果替换出来，再重组成新的命令行。

$( )与｀｀

在操作上，这两者都是达到相应的效果，但是建议使用$( )，理由如下：

｀｀很容易与''搞混乱，尤其对初学者来说，而$( )比较直观。
最后，$( )的弊端是，并不是所有的类unix系统都支持这种方式，但反引号是肯定支持的。

关于命令嵌套：　　

　　$(ps -ef|grep `ps -ef|grep nginx |grep 'ottcache'|grep 'master process'|awk '{print $2}'` |grep 'worker process'|awk '{print $2}')

        里面的命令用 `` 反引号得出 pid， 再替换掉该位置， $()  执行另一个命令。

 

2.  ${ }变量替换
　　一般情况下，$var与${var}是没有区别的，但是用${ }会比较精确的界定变量名称的范围。
