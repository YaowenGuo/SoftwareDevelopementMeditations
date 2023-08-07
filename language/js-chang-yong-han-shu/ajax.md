web 的组成部分， server、client、http协议。

Ajax 就是做异步的一中技术


XMLHttpRequest 对象用于向服务器发起请求，但是只刷新局部页面。
XMLHttpRequest只负责发送请求和异步加载数据，出发数据发送和数据返回后的显示，都需要使用JS代码来实现。

### 使用，先创建对象

XMLHttpRequest 也是js代码，使用了面向对象的设计，使用之前首先要创建对象

var request = new XMLHttpRequest();