# image 子指令

## 查看 lookup

查找虚函数表：
```
image lookup -r -v -s "vtable for YOUR_CLASS_NAME"
```
例如

```shell
$ image lookup -r -v -s "vtable for C"
1 symbols match the regular expression 'vtable for C' in /Users/albert/project/webrtc/test/C++/.target/memory/virtual_function:
        Address: virtual_function[0x0000000100004020] (virtual_function.__DATA_CONST.__const + 0)
        Summary: virtual_function`vtable for C
         Module: file = "/Users/albert/project/webrtc/test/C++/.target/memory/virtual_function", arch = "x86_64"
         Symbol: id = {0x0000014d}, range = [0x0000000100004020-0x0000000100004058), name="vtable for C", mangled="_ZTV1C"


```
