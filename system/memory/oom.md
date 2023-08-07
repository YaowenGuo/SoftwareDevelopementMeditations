## android内存管理

> 内存溢出和内存泄露的区别：


内存溢出（out of memory）

Android为不同类型的进程分配了不同的内存使用上限，每个应用都在自己的进程中运行，每个进程分配一定的内存空间，这些空间也不是全部都能申请的，申请内存都是在堆空间申请的。内存溢出是指当对象的内存占用已经超出堆中可分配内存的空间大小，这时未经处理的异常就会抛出。

内存泄漏（memory leak）

有些对象只有有限的生命周期。当它们的任务完成之后，它们将被垃圾回收。如果在对象的生命周期本该结束的时候，这个对象还被一系列的引用，这就会导致内存泄漏。随着泄漏的累积，app将消耗完内存。

比如当你向系统申请分配内存进行使用(new)，可是使用完了以后却不归还(delete)，结果你申请到的那块内存你自己也不能再访问（也许你把它的地址给弄丢了），而系统也不能再次将它分配给需要的程序。



1. 内存泄露导致

由于我们程序的失误，长期保持某些资源（如Context）的引用，垃圾回收器以为还在使用而无法回收它，当然该对象占用的内存就无法被使用，这就造成内存泄露。


2. 占用内存较多的对象

保存了多个耗用内存过大的对象（如Bitmap）或加载单个超大的图片，造成内存超出限制。

3. 一次创建过多的对象，而使整体占用空间超过了可分配空间。


## 内存溢出到常见场景

1. 内存泄露导致

    - 比如，在Activity.onDestroy()被调用之后，view树以及相关的bitmap都应该被垃圾回收。如果一个正在运行的后台线程继续持有这个Activity的引用，那么相关的内存将不会被回收，这最终将导致OutOfMemoryError崩溃。 重复进入会再次创建，最终会导致内存溢出。

    - 内部类 handle 延时发送 message 而在关闭 activity 后 context 仍被 messgeQueue 中的 handler 锁引用。无法被销毁所引发泄漏。Handler应该申明为静态对象， 并在其内部类中保存一个对外部类的弱引用。
    - 或者 Activity 中 AsynTask 内部类在 Activity 销毁后还在执行。

    - 内部类的变量被定义为了 static，而没有清空。

    - 资源对象没关闭，如Cursor，File等资源。他们会在finalize中关闭，但这样效率太低。容易造成内存泄漏

    - 使用 Adapter时，没有使用系统缓存的 converView

    - 没有即时调用recycle()释放不再使用的bitmap

    - 静态变量或者单例模式中的变量引用了 Activity.

    - 广播注册没取消造成内存泄露

    - 注册的系统服务监听，眉头在结束时取消监听。SensorManager sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);

2. 占用内存较多的对象

    - 不经缩放的加载 bitmap 对象的溢出，显示像素过高或图片尺寸远远大于显示空间的尺寸时，通常都要将其缩放，减小占用内存。


3. 一次创建过多的对象

    - SQLiteCurost,当数据量大的时候容易泄漏


http://hukai.me/android-performance-oom/

1. 减小对象的内存占用
2. 内存对象的重复利用
3. 避免对象的内存泄露
4. 内存使用策略优化


###  LeakCanary 做不到的(待定)

择 LeakCanary 作为首选的内存泄漏检测工具主要是因为它能实时检测泄漏并以非常直观的调用链方式展示内存泄漏的原因。

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



## 内部类

在使用过程中，内部类本身持有外部类的应用，所以才可以调用外部类的非静态方法。如果内部类的声明周期比外部类长，就会导致外部类占用的内存无法释放。Java 中内部类默认是费静态的，引用更普遍，在 Kotlin 做了改进，默认是静态内部类。

```Java
public class CardMainActivity extends BaseActivity {
    public class CardMainHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            // 不用声明变量，内部类就持有外部类的引用，所以才能自由访问外部类的非静态变量和方法。
            mViewModel.getMatchUsers(null);
        }
    }
```

此时 `CardMainHandler` 是非静态的，自然而然持有外部对象的引用。 此时如果内部类生命周期比外部类长，外部类就无法释放。

```Java
//registerNetReceiver();
((DatingApplication) getApplication()).setCardMainHandler(new CardMainHandler());
```

解决方案： 使用 Activity 销毁时自动解绑的 LiveData 或者 EventBus 处理页面直接的事件传递。禁止使用全局 application 传递事件。

## 静态内部类

静态内部类虽然没有外部类对象的引用，但是却有类的引用，用于访问外部类的静态方法。此时如果外部类声明了静态变量，在静态内部中使用了，也不容易释放掉。这种方式是：1，没有明确的包含关系，少用内部类。2，除了常量和单例，谨慎使用静态变量。

![Thread not destroy](images/thread_no_destroy.jpg)



## 自定义线程

无论是多线程还是多进程，在编程中都是一个难点。在页面退出后，线程没有销毁非常普遍。

关于自定义线程解决的方法多种多样，不同的场景需要使用不同的方式。这里进列举现在遇到的。

1. 一个常见的使用线程的地方就是动画，动画需要在单独的线程计算，然后在 UI 线程中更新 UI。 关于动画的部分，建议使用 Android 更好封装的属性动画。它会在 UI 销毁时，及时的销毁，而不必关系终止问题。

下面是 RadarView 的线程计算动画执行过程

```Java
    private static class RadarThread extends Thread {
        private WeakReference<RadarView> weakReference;

        public RadarThread(RadarView radarView) {
            weakReference = new WeakReference<>(radarView);
        }

        @Override
        public void run() {
            super.run();

            RadarView radarView = weakReference.get();
            if (radarView != null) {
                radarView.beginRunning();
            }
        }
    }

    /**
     * 开始运行
     */
    private void beginRunning() {
        while (threadIsRunning) {
            RadarView.this.post(new Runnable() {
                @Override
                public void run() {
                    start = start + 1;
                    matrix.setRotate(start, 0, 0); //因为我对画笔进行了平移，0，0表示绕圆的中心点转动
                    RadarView.this.invalidate();
                }
            });
            try {
                Thread.sleep(5);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

```

改为系统组件更简单，而且可调节的更多。会在 UI 销毁时，将其一块销毁。

```Java
    public void start() {
        if (mRotateAnim != null && mRotateAnim.isRunning()) {
            return;
        }
        mRotateAnim = ObjectAnimator.ofInt(this, "rotate", start + 360) // 360 度
                .setDuration(2000);
        mRotateAnim.setRepeatMode(ValueAnimator.RESTART);
        mRotateAnim.setRepeatCount(Animation.INFINITE);
        mRotateAnim.setInterpolator(new LinearInterpolator());
        mRotateAnim.start();
    }
```

2. 在 View 组件销毁的时候，将线程终止掉。很麻烦的一点是， Java 的线程没有提供直接终止的方法，一般是单独设置一个标志位，在线程中判断标志位，终止执行。

```
    private static class RadarThread extends Thread {
        @Override
        public void run() {
            if (continue) { // 要判断的标志位
                // ...
            }
        }
    }
```

这种方式并不太好，能不直接使用线程还是避免使用线程，太原始了。深入掌握线程非常重要，但不一定非要处处使用，仿佛一下从机械时代回到了农耕时代。



## 待研究

Fragment 是否需要持有引用，或者如何销毁。


[Android 内存大小限制]https://blog.csdn.net/weixin_39793420/article/details/117498032
