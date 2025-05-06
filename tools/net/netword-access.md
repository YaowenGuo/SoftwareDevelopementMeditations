wget

# curl

https://www.cnblogs.com/hbzyin/p/7224338.html


HEAD 请求并不是像其他请求一样是用 -X 指定。如果只使用 `-I` 不使用 `-X` 则会是一个 HEAD 请求。 加上 `-X <request type>` 则会显示请求头和结果头。 -v 可以显示请求的全过程，也就是能够显示请求头。

```
curl -v -X GET -I -H "Testing: Test header so you see this works" http://stackoverflow.com/
```

## 下载文件 -o/O

curl 默认的将请求结果用于标准输出，想要将内容输出到文件，可以使用 `-O <url>`, 将保存为和远端同名的文件。

```
curl -O <url>
```

如果想要自己命名，可以使用 `-o <file name>` 来自定义文件名。

```
curl <url> -o <file name>
```
