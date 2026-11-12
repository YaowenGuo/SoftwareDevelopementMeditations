# Leak Canary

###  LeakCanary 做不到的(待定)

选择 LeakCanary 作为首选的内存泄漏检测工具主要是因为它能实时检测泄漏并以非常直观的调用链方式展示内存泄漏的原因。

虽然 LeakCanary 有诸多优点，但是它也有做不到的地方，比如说检测申请大容量内存导致的OOM问题、Bitmap内存未释放问题，Service 中的内存泄漏可能无法检测等。


# OOM 引起问题和解决方案

添加 leakcanary 的依赖。2.0 版本做了一些改动，只需要添加依赖就能自动向项目中注入代码，不用再在 application 中开启检测。

```
debugImplementation 'com.squareup.leakcanary:leakcanary-android:2.0-alpha-3'
```

此时只会在 debug 版本中添加检测，其他版本都不会添加加测。测试发现 `debugImplementation` 是和 `buildTypes` 中的分渠道打包名关联的。

```
buildTypes {
        debug {
           ...
        }

        product {
            ...
        }

        pre_relese {
            ...
        }

        release {
            ...
        }
    }
```

因此，想要添加 `product` 版本的检测，需要添加。这在官方文档上并没有提到。

```
productImplementation 'com.squareup.leakcanary:leakcanary-android:2.0-alpha-3'

```

leakcanary 对混淆敏感，混淆会导致其无法启动，也没有在官网上找到取消混淆的文档，这个可以理解，在 release 版本上带 leakcanary 的需求本身就很奇怪。


[Leak Canary 自定义配置以及线上使用](https://mp.weixin.qq.com/s/4DFUjs9xx9DM55zB_NjByA)

https://mp.weixin.qq.com/s/JRZf1zW0xS38OruJG2KmEw
https://mp.weixin.qq.com/s/0bO5BZ4CMYJbRuY_xf_osw
https://mp.weixin.qq.com/s/199QL7OgR8c0GIMEBsIZFA