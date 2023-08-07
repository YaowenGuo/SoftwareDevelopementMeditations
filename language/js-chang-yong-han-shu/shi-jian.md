### 什么是事件

事件是可以被 JavaScript 侦测到的行为。 网页中的每个元素都可以产生某些可以触发 JavaScript 函数或程序的事件。

比如说，当用户单击按钮或者提交表单数据时，就发生一个鼠标单击（onclick）事件，需要浏览器做出处理，返回给用户一个结果。

主要事件表：
![](/assets/53e198540001b66404860353.jpg)

注意这些都是html的属性例如
<input name="password" type="password" onmouseover="message()">


### JS 内置对象

什么是对象
JavaScript 中的所有事物都是对象，如:字符串、数值、数组、函数等，每个对象带有属性和方法。

对象的属性：反映该对象某些特定的性质的，如：字符串的长度、图像的长宽等；

对象的方法：能够在对象上执行的动作。例如，表单的“提交”(Submit)，时间的“获取”(getYear)等；

JavaScript 提供多个内建对象，比如 String、Date、Array 等等，使用对象前先定义，如下使用数组对象：

  var objectName =new Array();//使用new关键字定义对象
或者
  var objectName =[];
访问对象属性的语法:

objectName.propertyName
如使用 Array 对象的 length 属性来获得数组的长度：

var myarray=new Array(6);//定义数组对象
var myl=myarray.length;//访问数组长度length属性
以上代码执行后，myl的值将是：6

访问对象的方法：

objectName.methodName()
如使用string 对象的 toUpperCase() 方法来将文本转换为大写：

var mystr="Hello world!";//创建一个字符串
var request=mystr.toUpperCase(); //使用字符串对象方法
以上代码执行后，request的值是：HELLO WORLD!


返回星期方法
getDay() 返回星期，返回的是0-6的数字，0 表示星期天。如果要返回相对应“星期”，通过数组完成，代码如下:

<script type="text/javascript">
  var mydate=new Date();//定义日期对象
  var weekday=["星期日","星期一","星期二","星期三","星期四","星期五","星期六"];
//定义数组对象,给每个数组项赋值
  var mynum=mydate.getDay();//返回值存储在变量mynum中
  document.write(mydate.getDay());//输出getDay()获取值
  document.write("今天是："+ weekday[mynum]);//输出星
  
###### 返回/设置时间方法
get/setTime() 返回/设置时间，单位毫秒数，计算从 1970 年 1 月 1 日零时到日期对象所指的日期的毫秒数。

如果将目前日期对象的时间推迟1小时，代码如下:

<script type="text/javascript">
  var mydate=new Date();
  document.write("当前时间："+mydate+"<br>");
  mydate.setTime(mydate.getTime() + 60 * 60 * 1000);
  document.write("推迟一小时时间：" + mydate);
</script>
结果:

当前时间：Thu Mar 6 11:46:27 UTC+0800 2014

推迟一小时时间：Thu Mar 6 12:46:27 UTC+0800 2014

注意:1. 一小时 60 分，一分 60 秒，一秒 1000 毫秒

      2. 时间推迟 1 小时,就是: “x.setTime(x.getTime() + 60 * 60 * 1000);”

