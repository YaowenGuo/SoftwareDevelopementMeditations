# String

无论哪种语言，只要处理的结果是给人看的，都牵涉到字符串的处理，所以字符串的处理是使用最多，也不活缺少的一部分。

## java
1.split()+正则表达式来进行截取。
将正则传入split()。返回的是一个字符串数组类型。不过通过这种方式截取会有很大的性能损耗，因为分析正则非常耗时。
```java
String str = "abc,12,3yy98,0";
String[]  strs=str.split(",");
for(int i=0,len=strs.length;i<len;i++){
    System.out.println(strs[i].toString());
}
```
运行结果:
```
abc
12
3yy98
```
2.通过subString()方法来进行字符串截取。
subString通过不同的参数来提供不同的截取方式
2.1只传一个参数
例如：
```java
    String sb = "bbbdsajjds";
    sb.substring(2);
```
将字符串从索引号为2开始截取，一直到字符串末尾。（索引值从0开始）；
2.2传入2个索引值
```java
String sb = "bbbdsajjds";
sb.substring(2, 4);
````
从索引号2开始到索引好4结束（并且不包含索引4截取在内，也就是说实际截取的是2和3号字符）；
运行结果如下：
```
bdsajjds
bd
```
3.通过StringUtils提供的方法
StringUtils.substringBefore(“dskeabcee”, “e”);
/结果是：dsk/
这里是以第一个”e”，为标准。
```java
StringUtils.substringBeforeLast(“dskeabcee”, “e”)
```
结果为：dskeabce
这里以最后一个“e”为准。
