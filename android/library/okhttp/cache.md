# 缓存

重复不变的内容减少或者避免重复请求。

缓存分为：

- 客户端缓： 用户本地缓存
- 服务器端缓存：
    - 代理服务器缓存：CDN 缓存。
    - 单项带阿里服务器缓存（也叫网关缓存，比如 Nginx 反向代理、 Squid 等。）

## 控制缓存的方式

1. HTML meta 标签。

```html
<meta http-equiv="pragram" content="no-cache"> 
禁止浏览器从本地缓存中调阅页面。 
网页不保存在缓存中，每次访问都刷新页面。 
<meta http-equiv="cache-control" content="no-cache, must-revalidate"> 
同上面意思差不多，必须重新加载页面 
<meta http-equiv="expires" content="0"> 
网页在缓存中的过期时间为0，一旦网页过期，必须从服务器上重新订阅。
```

2. HTTP 头信息。

利用 http 的返回头中的 Expires 或者 Cache-Control 两个字段来控制的，用来表示资源的缓存时间。


浏览器缓存分为强缓存和协商缓存，浏览器加载一个页面的简单流程如下：

- 浏览器先根据这个资源的 http 头信息来判断是否命中强缓存。如果命中则直接加在缓存中的资源，并不会将请求发送到服务器。

- 如果未命中强缓存，则浏览器会将资源加载请求发送到服务器。服务器来判断浏览器本地缓存是否失效。若可以使用，则服务器发送响应码 304 且不会返回资源信息，浏览器继续从缓存加载资源。

- 如果未命中协商缓存，则服务器会将完整的资源返回给浏览器，浏览器加载新资源，并更新缓存。

> 强缓存

命中强缓存时，浏览器并不会将请求发送给服务器。在Chrome的开发者工具中看到 http 的返回码是200，但是在Size列会显示为(from cache)。
![](picture/use_cache.png)

### Expires

指定缓存过期时间，例如 `Expires:Thu,31 Dec 2037 23:59:59 GMT` 就是到这个时间点过期。在这个时间之前，浏览器可以直接从本地缓存取，而不必发送请求。即命中缓存。这有一个缺点，因为这个时间是服务器发送过来的，是服务器的时间，如果客户端时间和服务器不一致。很容易导致失效时间跟设置的不一致。于是就有了 Cache-Control，***同时启用的时候Cache-Control优先级高***。


### Cache-Control

Cache-Control是一个相对时间，例如 `Cache-Control:3600`，代表着资源的有效期是3600秒。由于是相对时间，并且都是与客户端时间比较，所以服务器与客户端时间偏差也不会导致问题。

Cache-Control与Expires可以在服务端配置同时启用或者启用任意一个，同时启用的时候Cache-Control优先级高。

Cache-Control 可以由多个字段组合而成，主要有以下几个取值：

> 缓存位置：

- public 表明响应可以被任何对象（发送请求的客户端、代理服务器等等）缓存。

- private 表明响应只能被单个用户（可能是操作系统用户、浏览器用户）缓存，是非共享的，不能被代理服务器缓存。

> 缓存时间

- max-age 指定一个时间长度，在这个时间段内缓存是有效的，单位是s。例如设置 Cache-Control:max-age=31536000，也就是说缓存有效期为（31536000 / 24 / 60 / 60）天。

- s-maxage 同 max-age，覆盖 max-age、Expires，但仅适用于共享缓存，在私有缓存中被忽略。（可以和 max-age 一起使用？）

- no-cache 强制所有缓存了该响应的用户，在使用已缓存的数据前，发送带验证器的请求到服务器。不是字面意思上的不缓存。

- no-store 禁止缓存，浏览器不存储缓存，每次请求都要向服务器重新获取数据。

- must-revalidate 指定如果页面是过期的，则去服务器进行获取。告诉缓存必须遵循所有你给予副本的新鲜度的，HTTP允许缓存在某些特定情况下返回过期数据，指定了这个属性，你告诉缓存，你希望严格的遵循你的规则。

协商缓存主要是 `no-cache` 类型。

### 协商缓存

若未命中强缓存，则浏览器会将请求发送至服务器。服务器根据http头信息中的Last-Modify/If-Modify-Since或Etag/If-None-Match来判断是否命中协商缓存。如果命中，则http返回码为304，浏览器从缓存中加载资源。

#### Last-Modify/If-Modify-Since

1. 浏览器第一次请求一个资源的时候，服务器返回的header中会加上Last-Modify，Last-modify是一个时间标识该资源的最后修改时间，例如Last-Modify: Thu,31 Dec 2037 23:59:59 GMT。

2. 当浏览器再次请求该资源时，发送的请求头中会包含If-Modify-Since，该值为缓存之前返回的Last-Modify。服务器收到If-Modify-Since后，根据资源的最后修改时间判断是否命中缓存。

3. 如果命中缓存，则返回http304，并且不会返回资源内容，并且不会返回Last-Modify。


由于对比的服务端时间，所以客户端与服务端时间差距不会导致问题。但是有时候通过最后修改时间来判断资源是否修改还是不太准确（资源变化了最后修改时间也可以一致）。于是出现了ETag/If-None-Match。


#### ETag/If-None-Match

Etag/If-None-Match返回的是一个校验码（ETag: entity tag）。ETag可以保证每一个资源是唯一的，资源变化都会导致ETag变化*。ETag值的变更则说明资源状态已经被修改。服务器根据浏览器上发送的If-None-Match值来判断是否命中缓存。

首次返回的响应头带 `ETag`，再次请求的请求头将发送 `If-None-Match: 上次请求的 ETag 值` 发送到服务器，用于验证。

> ETag扩展说明

我们对ETag寄予厚望，希望它对于每一个url生成唯一的值，资源变化时ETag也发生变化。神秘的Etag是如何生成的呢？以Apache为例，ETag生成靠以下几种因子

- 文件的i-node编号，此i-node非彼iNode。是Linux/Unix用来识别文件的编号。是的，识别文件用的不是文件名。使用命令’ls –I’可以看到。

- 文件最后修改时间

- 文件大小

生成Etag的时候，可以使用其中一种或几种因子，使用抗碰撞散列函数来生成。所以，理论上ETag也是会重复的，只是概率小到可以忽略。

> 既生Last-Modified何生Etag？
你可能会觉得使用Last-Modified已经足以让浏览器知道本地的缓存副本是否足够新，为什么还需要Etag（实体标识）呢？HTTP1.1中Etag的出现主要是为了解决几个Last-Modified比较难解决的问题：

1. Last-Modified标注的最后修改只能精确到秒级，如果某些文件在1秒钟以内，被修改多次的话，它将不能准确标注文件的修改时间

2. 如果某些文件会被定期生成，当有时内容并没有任何变化，但Last-Modified却改变了，导致文件没法使用缓存

3.有可能存在服务器没有准确获取文件修改时间，或者与代理服务器时间不一致等情形

Etag是服务器自动生成或者由开发者生成的对应资源在服务器端的唯一标识符，能够更加准确的控制缓存。Last-Modified与ETag是可以一起使用的，服务器会优先验证ETag，一致的情况下，才会继续比对Last-Modified，最后才决定是否返回304。


### 用户行为与缓存
浏览器缓存行为还有用户的行为有关！！！

| 用户操作     | Expires/Cache-Control |  Last-Modified/Etag |
| ----------- | ------- | ----- |
| 地址栏回车    | 有效 |  有效 |
| 页面链接跳转  | 有效 | 有效 |
| 新开窗口     | 有效  | 有效 |
| 前进、后退   | 有效  | 有效 |
| F5刷新      | 无效  | 有效 |
| Ctrl+F5刷新 | 无效  | 无效 |


浏览器第一次请求：

![](picture/first_request.png)

浏览器再次请求时：

![](picture/request_time_again.png)


博客
https://www.cnblogs.com/ranyonsue/p/8918908.html