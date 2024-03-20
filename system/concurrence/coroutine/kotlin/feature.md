# 特性

1. 结构化并发
2. `async` 和 `await` 作为函数，而非关键字。
3. 


## 

一个协程是一个可挂起单元的实例。从某种意义上说，它需要运行与其他代码并发执行的代码块。然而，协程不绑定到任何特定的线程。它可以在一个线程中暂停执行，在另一个线程中继续执行。


- 协程生成器: launch is a coroutine builder

**协程遵循结构化并发的原则，这意味着新的协程只能在特定的CoroutineScope中启动，该CoroutineScope限定了协程的生存期。**
在实际应用程序中，您将启动大量协程。结构化并发确保它们不会丢失，也不会泄漏。外部作用域在其所有子协程完成之前不能完成。结构化并发性还确保正确报告代码中的任何错误，并且永远不会丢失。

挂起协程不会阻塞底层线程，但允许其他协程运行并使用底层线程执行其代码。**挂起线程会阻塞线程，将导致触发挂起情况的协程一同挂起。** 因为线程是昂贵的资源，阻塞它们是低效的，通常是不需要的。



- Job
- Scope
- Coroutine
- Channel


除了由不同的构建器提供的协程 scope 外，还可以使用coroutineScope构建器声明自己的作用域。它创建一个协程作用域，并且在所有已启动的子程序完成之前不会完成。

```Kotlin
fun main() = runBlocking {
    doWorld()
}

suspend fun doWorld() = coroutineScope {  // this: CoroutineScope
    launch {
        delay(1000L)
        println("World!")
    }
    println("Hello")
}
```
runBlocking和coroutineScope构建器可能看起来很相似，因为它们都等待它们的主体及其所有子主体完成。主要区别在于runBlocking方法阻塞当前线程以等待，而coroutineScope只是挂起，释放底层线程以供其他用途。由于这种差异，runBlocking是一个常规函数，而coroutineScope是一个挂起函数。

**当需要一个协程等待多个子任务执行完之后再恢复时，可以使用 coroutineScope**
```
// Sequentially executes doWorld followed by "Done"
fun main() = runBlocking {
    doWorld()
    println("Done")
}

// Concurrently executes both sections
suspend fun doWorld() = coroutineScope { // this: CoroutineScope
    launch {
        delay(2000L)
        println("World 2")
    }
    launch {
        delay(1000L)
        println("World 1")
    }
    println("Hello")
}
```

**同样的功能也可以使用 Job 的 join 功能实现。**
```Kotlin
val job = launch { // launch a new coroutine and keep a reference to its Job
    delay(1000L)
    println("World!")
}
println("Hello")
job.join() // wait until child coroutine completes
println("Done") 
```

```

  override fun load(
    loadType: LoadType,
    start: Int,
    pageSize: Int,
    pageLoadCallback: PageLoadCallback<ThemeItem>
  ) {
    val loadPage = if (loadType == LoadType.INIT) 0 else lastLoadPage + 1
    CookHomeApi.instance
      .themeList(if (isPrePublishMode) "pre" else "", loadPage, pageSize)
//      .flatMap {
//        val themes = it.dataWhenSuccess
//        if (themes.list.isNullOrEmpty()) return@flatMap Observable.just(it)
//        val collectMete = Observable.fromIterable(themes.list)
//          .flatMap{ theme ->
//            Log.e("CookThemeListViewModel", "flatmap: ${theme.themeId}")
//            CookCourseApis.getApis().isCollected(CookCourseApis.COLLECT_THEME, theme.themeId)
//          }
//          .map { collectRsp ->
//            Log.e("CookThemeListViewModel", "flatmap: ${collectRsp.dataWhenSuccess}")
//            collectRsp.dataWhenSuccess }
//          .collect(Callable<ArrayList<Boolean>> { ArrayList() }) { list, collected -> list.add(collected) }
//        Observable.zip(Observable.just(it), collectMete.toObservable()) { themesRsp, collectList ->
//          Log.e("CookThemeListViewModel", "resutlt: ${collectList}")
//          for (index in themesRsp.dataWhenSuccess.list!!.indices) {
//            themesRsp.dataWhenSuccess.list!![index].collected = collectList[index]
//          }
//          themesRsp
//        }
//      }
      .subscribe(
        object : BaseRspObserver<ThemeRspData>() {
          override fun onSuccessResult(data: ThemeRspData) {
            lastLoadPage = data.pageInfo.currentPage
            val theme = data.list?.filter { it.themeType <= ThemeData.THEME_TYPE_VIDEO }
            pageLoadCallback.onPageLoad(theme?.toMutableList())
          }

          override fun onErrorResult(code: Int, e: Throwable?) {
            if (handleAccountError(code, e)) return
            pageLoadCallback.onPageLoadFailed(e)
          }
        }
      )
  }

```