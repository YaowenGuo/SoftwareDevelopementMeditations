1. 华为扫码库错误

79a936a000-79a95d6000 r-xp 00000000 103:3a 378950                        /data/user_de/0/com.huawei.android.hsf/modules/external/huawei_module_scankit/21100301/arm64-v8a/libscannative.so
79a95d6000-79a95e6000 ---p 00000000 00:00 0 
79a95e6000-79a95f5000 r--p 0026c000 103:3a 378950                        /data/user_de/0/com.huawei.android.hsf/modules/external/huawei_module_scankit/21100301/arm64-v8a/libscannative.so
79a95f5000-79a95f6000 rw-p 0027b000 103:3a 378950                        /data/user_de/0/com.huawei.android.hsf/modules/external/huawei_module_scankit/21100301/arm64-v8a/libscannative.so
79a95f6000-79a97f3000 rw-p 00000000 00:00 0                              [anon:.bss]


76b9e13000-76b9e8a000 r-xp 00000000 08:0e 313897                         /data/app/~~CY2f6g3v_PiTFkQYo8hZjQ==/com.fenbi.android.servant-Bs2v6wM1kVehegb2xcmp7g==/lib/arm64/libscannative.so
76b9e8a000-76b9e99000 ---p 00000000 00:00 0 
76b9e99000-76b9e9e000 r--p 00076000 08:0e 313897                         /data/app/~~CY2f6g3v_PiTFkQYo8hZjQ==/com.fenbi.android.servant-Bs2v6wM1kVehegb2xcmp7g==/lib/arm64/libscannative.so
76b9e9e000-76b9e9f000 rw-p 0007b000 08:0e 313897                         /data/app/~~CY2f6g3v_PiTFkQYo8hZjQ==/com.fenbi.android.servant-Bs2v6wM1kVehegb2xcmp7g==/lib/arm64/libscannative.so

同时 so 库的 build ID 不一致
```
#00 pc 000000000009da08 /data/user_de/0/com.huawei.android.hsf/modules/external/huawei_module_scankit/21100301/arm64-v8a/libscannative.so (_Z20adaptiveThresholdHMSPKhPhiiidi+1044) [arm64-v8a::acc8fa4b3a648f350e257c7e14afd109]
#01 pc 000000000009dc24 /data/user_de/0/com.huawei.android.hsf/modules/external/huawei_module_scankit/21100301/arm64-v8a/libscannative.so (Java_com_huawei_hms_scankit_util_OpencvJNI_adaptiveBinary+340) [arm64-v8a::acc8fa4b3a648f350e257c7e14afd109]
#02 pc 0000000000222244 /apex/com.android.art/lib64/libart.so (art_quick_generic_jni_trampoline+148) [arm64-v8a::8326843c55885ddfa0f5ea99ed4cf5ef]
#03 pc 000000009efc05a4 <unknown>

```

2. truman FD_SET() 报错


1. 

```
修复 Feed 流视频线程没有销毁的问题。不停滑页面会有很多这样的线程：
u0_a588        9772 11184    804 26020008 534460 0                  0 S ExoPlayer:Playb
u0_a588        9772 11213    804 26020008 534460 0                  0 S ExoPlayer:Playb
u0_a588        9772 11237    804 26020008 534460 0                  0 S ExoPlayer:Playb
u0_a588        9772 11259    804 26020008 534460 0                  0 S ExoPlayer:Playb
```
2. 

```
u0_a588       19415 19944    804 24562740 347984 0                  0 S android.servant
u0_a588       19415 19945    804 24562740 347984 0                  0 S android.servant
u0_a588       19415 19946    804 24562740 347984 0                  0 S android.servant
u0_a588       19415 19947    804 24562740 347984 0                  0 S android.servant
u0_a588       19415 19948    804 24562740 347984 0                  0 S android.servant
u0_a588       19415 19949    804 24562740 347984 0                  0 S android.servant
u0_a588       19415 19950    804 24562740 347984 0                  0 S android.servant
u0_a588       19415 19951    804 24562740 347984 0                  0 S android.servant
```

监控线程的数量，以及线程

```
未进入 feed 流之前。
```
$ adb shell ps -T -p 1308 | wc -l
     138
```
进入之后
```
$ adb shell ps -T -p 1308 | wc -l
     153
```
前后不停滑动
```
$ adb shell ps -T -p 1308 | wc -l
     235
$ adb shell ps -T -p 1308 | wc -l
     232
```

查看线程
```
adb shell ps -T -p 1308
USER            PID   TID   PPID     VSZ    RSS WCHAN            ADDR S CMD
u0_a588        1308  1308    804 26151264 418112 0                  0 S android.servant
u0_a588        1308  1319    804 26151264 418112 0                  0 S Signal Catcher
u0_a588        1308  1320    804 26151264 418112 0                  0 S perfetto_hprof_
u0_a588        1308  1322    804 26151264 418112 0                  0 S ADB-JDWP Connec
u0_a588        1308  1323    804 26151264 418112 0                  0 S Jit thread pool
u0_a588        1308  1325    804 26151264 418112 0                  0 S HeapTaskDaemon
u0_a588        1308  1326    804 26151264 418112 0                  0 S ReferenceQueueD
u0_a588        1308  1327    804 26151264 418112 0                  0 S FinalizerDaemon
u0_a588        1308  1328    804 26151264 418112 0                  0 S FinalizerWatchd
u0_a588        1308  1329    804 26151264 418112 0                  0 S Binder:1308_1
u0_a588        1308  1330    804 26151264 418112 0                  0 S Binder:1308_2
u0_a588        1308  1332    804 26151264 418112 0                  0 S Binder:1308_3
u0_a588        1308  1340    804 26151264 418112 0                  0 S Profile Saver
u0_a588        1308  1341    804 26151264 418112 0                  0 S Timer-0
u0_a588        1308  1350    804 26151264 418112 0                  0 S LeakCanary-Heap
u0_a588        1308  1351    804 26151264 418112 0                  0 S plumber-android
u0_a588        1308  1366    804 26151264 418112 0                  0 S RxSchedulerPurg
u0_a588        1308  1367    804 26151264 418112 0                  0 S RxCachedWorkerP
u0_a588        1308  1368    804 26151264 418112 0                  0 S RxCachedThreadS
u0_a588        1308  1369    804 26151264 418112 0                  0 S RxCachedThreadS
u0_a588        1308  1370    804 26151264 418112 0                  0 S RxCachedThreadS
u0_a588        1308  1372    804 26151264 418112 0                  0 S RxCachedThreadS
u0_a588        1308  1373    804 26151264 418112 0                  0 S RxCachedThreadS
u0_a588        1308  1374    804 26151264 418112 0                  0 S RxComputationTh
u0_a588        1308  1375    804 26151264 418112 0                  0 S RxCachedThreadS
u0_a588        1308  1380    804 26151264 418112 0                  0 S arch_disk_io_0
u0_a588        1308  1383    804 26151264 418112 0                  0 S glide-active-re
u0_a588        1308  1392    804 26151264 418112 0                  0 S RxCachedThreadS
u0_a588        1308  1393    804 26151264 418112 0                  0 S RxCachedThreadS
u0_a588        1308  1394    804 26151264 418112 0                  0 S RxComputationTh
u0_a588        1308  1396    804 26151264 418112 0                  0 S queued-work-loo
u0_a588        1308  1398    804 26151264 418112 0                  0 S TaskQueueThread
u0_a588        1308  1399    804 26151264 418112 0                  0 S skExecuteThread
u0_a588        1308  1400    804 26151264 418112 0                  0 S Messages.Worker
u0_a588        1308  1401    804 26151264 418112 0                  0 S SENSORS_DATA_TH
u0_a588        1308  1403    804 26151264 418112 0                  0 S ConnectivityThr
u0_a588        1308  1408    804 26151264 418112 0                  0 S OkHttp TaskRunn
u0_a588        1308  1411    804 26151264 418112 0                  0 S BuglyThread-1
u0_a588        1308  1412    804 26151264 418112 0                  0 S Okio Watchdog
u0_a588        1308  1415    804 26151264 418112 0                  0 S BuglyThread-2
u0_a588        1308  1416    804 26151264 418112 0                  0 S BuglyThread-3
u0_a588        1308  1427    804 26151264 418112 0                  0 S Bugly-ThreadMon
u0_a588        1308  1428    804 26151264 418112 0                  0 S FileObserver
u0_a588        1308  1433    804 26151264 418112 0                  0 S RxCachedThreadS
u0_a588        1308  1434    804 26151264 418112 0                  0 S RxComputationTh
u0_a588        1308  1435    804 26151264 418112 0                  0 S RxComputationTh
u0_a588        1308  1446    804 26151264 418112 0                  0 S TcmReceiver
u0_a588        1308  1448    804 26151264 418112 0                  0 S work_thread
u0_a588        1308  1453    804 26151264 418112 0                  0 S NetWorkSender
u0_a588        1308  1469    804 26151264 418112 0                  0 S ZIDThreadPoolEx
u0_a588        1308  1470    804 26151264 418112 0                  0 S pool-5-thread-1
u0_a588        1308  1472    804 26151264 418112 0                  0 S io-pool-2-threa
u0_a588        1308  1487    804 26151264 418112 0                  0 S OkHttp Connecti
u0_a588        1308  1507    804 26151264 418112 0                  0 S Thread-20
u0_a588        1308  1509    804 26151264 418112 0                  0 S Thread-4206
u0_a588        1308  1510    804 26151264 418112 0                  0 S RxCachedThreadS
u0_a588        1308  1512    804 26151264 418112 0                  0 S pool-7-thread-1
u0_a588        1308  1517    804 26151264 418112 0                  0 S RxComputationTh
u0_a588        1308  1523    804 26151264 418112 0                  0 S Okio Watchdog
u0_a588        1308  1536    804 26151264 418112 0                  0 S Chrome_ProcessL
u0_a588        1308  1549    804 26151264 418112 0                  0 S GoogleApiHandle
u0_a588        1308  1595    804 26151264 418112 0                  0 S ThreadPoolServi
u0_a588        1308  1597    804 26151264 418112 0                  0 S ThreadPoolForeg
u0_a588        1308  1599    804 26151264 418112 0                  0 S ThreadPoolForeg
u0_a588        1308  1601    804 26151264 418112 0                  0 S ThreadPoolForeg
u0_a588        1308  1603    804 26151264 418112 0                  0 S Chrome_IOThread
u0_a588        1308  1606    804 26151264 418112 0                  0 S MemoryInfra
u0_a588        1308  1626    804 26151264 418112 0                  0 S ThreadPoolForeg
u0_a588        1308  1633    804 26151264 418112 0                  0 S ThreadPoolForeg
u0_a588        1308  1634    804 26151264 418112 0                  0 S AudioThread
u0_a588        1308  1637    804 26151264 418112 0                  0 S VideoCaptureThr
u0_a588        1308  1638    804 26151264 418112 0                  0 S ThreadPoolForeg
u0_a588        1308  1644    804 26151264 418112 0                  0 S ThreadPoolSingl
u0_a588        1308  1645    804 26151264 418112 0                  0 S NetworkService
u0_a588        1308  1646    804 26151264 418112 0                  0 S CookieMonsterCl
u0_a588        1308  1647    804 26151264 418112 0                  0 S CookieMonsterBa
u0_a588        1308  1649    804 26151264 418112 0                  0 S ThreadPoolSingl
u0_a588        1308  1650    804 26151264 418112 0                  0 S PlatformService
u0_a588        1308  1659    804 26151264 418112 0                  0 S Chrome_DevTools
u0_a588        1308  1662    804 26151264 418112 0                  0 S ThreadPoolSingl
u0_a588        1308  1664    804 26151264 418112 0                  0 S RenderThread
u0_a588        1308  1688    804 26151264 418112 0                  0 S FrameMetricsAgg
u0_a588        1308  1695    804 26151264 418112 0                  0 S pool-8-thread-1
u0_a588        1308  1701    804 26151264 418112 0                  0 S SVGAParser-Thre
u0_a588        1308  1721    804 26151264 418112 0                  0 S glide-disk-cach
u0_a588        1308  1729    804 26151264 418112 0                  0 S Thread-24
u0_a588        1308  1730    804 26151264 418112 0                  0 S Thread-1943
u0_a588        1308  1731    804 26151264 418112 0                  0 S RxCachedThreadS
u0_a588        1308  1732    804 26151264 418112 0                  0 S RxComputationTh
u0_a588        1308  1733    804 26151264 418112 0                  0 S glide-source-th
u0_a588        1308  1762    804 26151264 418112 0                  0 S InsetsAnimation
u0_a588        1308  1781    804 26151264 418116 0                  0 S RxComputationTh
u0_a588        1308  1784    804 26151264 418116 0                  0 S Binder:1308_4
u0_a588        1308  1869    804 26151264 418116 0                  0 S OkHttp TaskRunn
u0_a588        1308  1878    804 26151264 418116 0                  0 S t.fenbi.com/...
u0_a588        1308  1968    804 26151264 418116 0                  0 S hwuiTask0
u0_a588        1308  1984    804 26151264 418116 0                  0 S hwuiTask1
u0_a588        1308  2050    804 26151264 418116 0                  0 S arch_disk_io_1
u0_a588        1308  2095    804 26151264 418116 0                  0 S Thread-1938
u0_a588        1308  2096    804 26151264 418116 0                  0 S RxCachedThreadS
u0_a588        1308  2097    804 26151264 418116 0                  0 S Thread-50
u0_a588        1308  2099    804 26151264 418116 0                  0 S RxComputationTh
u0_a588        1308  2103    804 26151264 418116 0                  0 S glide-source-th
u0_a588        1308  2105    804 26151264 418116 0                  0 S glide-animation
u0_a588        1308  2107    804 26151264 418116 0                  0 S glide-animation
u0_a588        1308  2110    804 26151264 418116 0                  0 S glide-source-th
u0_a588        1308  2111    804 26151264 418116 0                  0 S glide-source-th
u0_a588        1308  2222    804 26151264 418116 0                  0 S RxCachedThreadS
u0_a588        1308  2223    804 26151264 418116 0                  0 S RxCachedThreadS
u0_a588        1308  2224    804 26151264 418116 0                  0 S RxCachedThreadS
u0_a588        1308  2225    804 26151264 418116 0                  0 S RxCachedThreadS
u0_a588        1308  2226    804 26151264 418116 0                  0 S RxCachedThreadS
u0_a588        1308  2227    804 26151264 418116 0                  0 S RxCachedThreadS
u0_a588        1308  2228    804 26151264 418116 0                  0 S RxCachedThreadS
u0_a588        1308  2231    804 26151264 418116 0                  0 S RenderThread
u0_a588        1308  2232    804 26151264 418116 0                  0 S RenderThread
u0_a588        1308  2233    804 26151264 418116 0                  0 S RxCachedThreadS
u0_a588        1308  2238    804 26151264 418116 0                  0 S OkHttp TaskRunn
u0_a588        1308  2240    804 26151264 418116 0                  0 S OkHttp TaskRunn
u0_a588        1308  2254    804 26151264 418116 0                  0 S AudioDeviceBuff
u0_a588        1308  2255    804 26151264 418116 0                  0 S AudioPortEventH
u0_a588        1308  2256    804 26151264 418116 0                  0 S rtc-low-prio
u0_a588        1308  2260    804 26151264 418116 0                  0 S WebRtcVolumeLev
u0_a588        1308  2261    804 26151264 418116 0                  0 S rtc_event_log
u0_a588        1308  2263    804 26151264 418116 0                  0 S rtp_send_contro
u0_a588        1308  2285    804 26151264 418116 0                  0 S ModuleProcessTh
u0_a588        1308  2289    804 26151264 418116 0                  0 S PacerThread
u0_a588        1308  2346    804 26151264 418116 0                  0 S RxCachedThreadS
u0_a588        1308  2416    804 26151264 418116 0                  0 S UIMonitorThread
u0_a588        1308  2465    804 26151264 418116 0                  0 S PnsLoggerThread
u0_a588        1308  2478    804 26151264 418116 0                  0 S pool-13-thread-
u0_a588        1308  2501    804 26151264 418116 0                  0 S AsyncTask #2
u0_a588        1308  2828    804 26151264 418116 0                  0 S SVGAParser-Thre
u0_a588        1308  3069    804 26151264 418116 0                  0 S OkHttp Dispatch
u0_a588        1308  3078    804 26151264 418116 0                  0 S OkHttp Dispatch
u0_a588        1308  3285    804 26151264 418116 0                  0 S AudioDeviceBuff
u0_a588        1308  3286    804 26151264 418116 0                  0 S rtc-low-prio
u0_a588        1308  3292    804 26151264 418116 0                  0 S WebRtcVolumeLev
u0_a588        1308  3293    804 26151264 418116 0                  0 S rtc_event_log
u0_a588        1308  3294    804 26151264 418116 0                  0 S rtp_send_contro
u0_a588        1308  3295    804 26151264 418116 0                  0 S ModuleProcessTh
u0_a588        1308  3299    804 26151264 418116 0                  0 S PacerThread
u0_a588        1308  3503    804 26151264 418116 0                  0 S pool-10-thread-
u0_a588        1308  3504    804 26151264 418116 0                  0 S OkHttp Dispatch
u0_a588        1308  3717    804 26151264 418116 0                  0 S AudioDeviceBuff
u0_a588        1308  3720    804 26151264 418116 0                  0 S rtc-low-prio
u0_a588        1308  3721    804 26151264 418116 0                  0 S WebRtcVolumeLev
u0_a588        1308  3722    804 26151264 418116 0                  0 S rtc_event_log
u0_a588        1308  3725    804 26151264 418116 0                  0 S rtp_send_contro
u0_a588        1308  3726    804 26151264 418116 0                  0 S ModuleProcessTh
u0_a588        1308  3733    804 26151264 418116 0                  0 S PacerThread
u0_a588        1308  3807    804 26151264 418116 0                  0 S AudioDeviceBuff
u0_a588        1308  3810    804 26151264 418116 0                  0 S rtc-low-prio
u0_a588        1308  3813    804 26151264 418116 0                  0 S WebRtcVolumeLev
u0_a588        1308  3815    804 26151264 418116 0                  0 S rtc_event_log
u0_a588        1308  3816    804 26151264 418116 0                  0 S rtp_send_contro
u0_a588        1308  3817    804 26151264 418116 0                  0 S ModuleProcessTh
u0_a588        1308  3825    804 26151264 418116 0                  0 S PacerThread
u0_a588        1308  3863    804 26151264 418116 0                  0 S pool-10-thread-
u0_a588        1308  3865    804 26151264 418116 0                  0 S LiveEngineThrea
u0_a588        1308  3866    804 26151264 418116 0                  0 S AudioDeviceBuff
u0_a588        1308  3867    804 26151264 418116 0                  0 S rtc-low-prio
u0_a588        1308  3870    804 26151264 418116 0                  0 S WebRtcVolumeLev
u0_a588        1308  3871    804 26151264 418116 0                  0 S rtc_event_log
u0_a588        1308  3872    804 26151264 418116 0                  0 S rtp_send_contro
u0_a588        1308  3873    804 26151264 418116 0                  0 S ModuleProcessTh
u0_a588        1308  3874    804 26151264 418116 0                  0 S Thread-4839
u0_a588        1308  3875    804 26151264 418116 0                  0 R Thread-4804
u0_a588        1308  3876    804 26151264 418116 0                  0 S TimeRoutineThre
u0_a588        1308  3877    804 26151264 418116 0                  0 S PacerThread
u0_a588        1308  3878    804 26151264 418116 0                  0 S GLThread 8395
u0_a588        1308  3879    804 26151264 418116 0                  0 S AudioTrack
u0_a588        1308  3880    804 26151264 418116 0                  0 S AudioTrackJavaT
u0_a588        1308  3881    804 26151264 418116 0                  0 S DecodingQueue
u0_a588        1308  3882    804 26151264 418116 0                  0 S Thread-4838
u0_a588        1308  3890    804 26151264 418116 0                  0 S DecodingQueue
u0_a588        1308  3892    804 26151264 418116 0                  0 S DecodingQueue
u0_a588        1308  3895    804 26151264 418116 0                  0 S DecodingQueue
u0_a588        1308  3896    804 26151264 418116 0                  0 S DecodingQueue
u0_a588        1308  3897    804 26151264 418116 0                  0 S DecodingQueue
u0_a588        1308  3898    804 26151264 418116 0                  0 S DecodingQueue
u0_a588        1308  3899    804 26151264 418116 0                  0 S DecodingQueue
>>>>>>>>>>>>>>>>>>>>>

USER            PID   TID   PPID     VSZ    RSS WCHAN            ADDR S CMD
u0_a588        1308  1308    804 27130764 267340 0                  0 S android.servant
u0_a588        1308  1319    804 27130764 267340 0                  0 S Signal Catcher
u0_a588        1308  1320    804 27130764 267340 0                  0 S perfetto_hprof_
u0_a588        1308  1322    804 27130764 267340 0                  0 S ADB-JDWP Connec
u0_a588        1308  1323    804 27130764 267340 0                  0 S Jit thread pool
u0_a588        1308  1325    804 27130764 267340 0                  0 S HeapTaskDaemon
u0_a588        1308  1326    804 27130764 267340 0                  0 S ReferenceQueueD
u0_a588        1308  1327    804 27130764 267340 0                  0 S FinalizerDaemon
u0_a588        1308  1328    804 27130764 267340 0                  0 S FinalizerWatchd
u0_a588        1308  1329    804 27130764 267340 0                  0 S Binder:1308_1
u0_a588        1308  1330    804 27130764 267340 0                  0 S Binder:1308_2
u0_a588        1308  1332    804 27130764 267340 0                  0 S Binder:1308_3
u0_a588        1308  1340    804 27130764 267340 0                  0 S Profile Saver
u0_a588        1308  1341    804 27130764 267340 0                  0 S Timer-0
u0_a588        1308  1350    804 27130764 267340 0                  0 S LeakCanary-Heap
u0_a588        1308  1351    804 27130764 267340 0                  0 S plumber-android
u0_a588        1308  1366    804 27130764 267340 0                  0 S RxSchedulerPurg
u0_a588        1308  1367    804 27130764 267340 0                  0 S RxCachedWorkerP
u0_a588        1308  1368    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  1369    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  1370    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  1372    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  1373    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  1374    804 27130764 267340 0                  0 S RxComputationTh
u0_a588        1308  1375    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  1380    804 27130764 267340 0                  0 S arch_disk_io_0
u0_a588        1308  1383    804 27130764 267340 0                  0 S glide-active-re
u0_a588        1308  1392    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  1393    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  1394    804 27130764 267340 0                  0 S RxComputationTh
u0_a588        1308  1396    804 27130764 267340 0                  0 S queued-work-loo
u0_a588        1308  1398    804 27130764 267340 0                  0 S TaskQueueThread
u0_a588        1308  1399    804 27130764 267340 0                  0 S skExecuteThread
u0_a588        1308  1400    804 27130764 267340 0                  0 S Messages.Worker
u0_a588        1308  1401    804 27130764 267340 0                  0 S SENSORS_DATA_TH
u0_a588        1308  1403    804 27130764 267340 0                  0 S ConnectivityThr
u0_a588        1308  1408    804 27130764 267340 0                  0 S OkHttp TaskRunn
u0_a588        1308  1411    804 27130764 267340 0                  0 S BuglyThread-1
u0_a588        1308  1412    804 27130764 267340 0                  0 S Okio Watchdog
u0_a588        1308  1415    804 27130764 267340 0                  0 S BuglyThread-2
u0_a588        1308  1416    804 27130764 267340 0                  0 S BuglyThread-3
u0_a588        1308  1427    804 27130764 267340 0                  0 S Bugly-ThreadMon
u0_a588        1308  1428    804 27130764 267340 0                  0 S FileObserver
u0_a588        1308  1433    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  1434    804 27130764 267340 0                  0 S RxComputationTh
u0_a588        1308  1435    804 27130764 267340 0                  0 S RxComputationTh
u0_a588        1308  1446    804 27130764 267340 0                  0 S TcmReceiver
u0_a588        1308  1448    804 27130764 267340 0                  0 S work_thread
u0_a588        1308  1453    804 27130764 267340 0                  0 S NetWorkSender
u0_a588        1308  1469    804 27130764 267340 0                  0 S ZIDThreadPoolEx
u0_a588        1308  1470    804 27130764 267340 0                  0 S pool-5-thread-1
u0_a588        1308  1472    804 27130764 267340 0                  0 S io-pool-2-threa
u0_a588        1308  1487    804 27130764 267340 0                  0 S OkHttp Connecti
u0_a588        1308  1507    804 27130764 267340 0                  0 S Thread-20
u0_a588        1308  1509    804 27130764 267340 0                  0 S Thread-9487
u0_a588        1308  1510    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  1512    804 27130764 267340 0                  0 S pool-7-thread-1
u0_a588        1308  1517    804 27130764 267340 0                  0 S RxComputationTh
u0_a588        1308  1523    804 27130764 267340 0                  0 S Okio Watchdog
u0_a588        1308  1536    804 27130764 267340 0                  0 S Chrome_ProcessL
u0_a588        1308  1549    804 27130764 267340 0                  0 S GoogleApiHandle
u0_a588        1308  1595    804 27130764 267340 0                  0 S ThreadPoolServi
u0_a588        1308  1597    804 27130764 267340 0                  0 S ThreadPoolForeg
u0_a588        1308  1599    804 27130764 267340 0                  0 S ThreadPoolForeg
u0_a588        1308  1601    804 27130764 267340 0                  0 S ThreadPoolForeg
u0_a588        1308  1603    804 27130764 267340 0                  0 S Chrome_IOThread
u0_a588        1308  1606    804 27130764 267340 0                  0 S MemoryInfra
u0_a588        1308  1626    804 27130764 267340 0                  0 S ThreadPoolForeg
u0_a588        1308  1633    804 27130764 267340 0                  0 S ThreadPoolForeg
u0_a588        1308  1634    804 27130764 267340 0                  0 S AudioThread
u0_a588        1308  1637    804 27130764 267340 0                  0 S VideoCaptureThr
u0_a588        1308  1638    804 27130764 267340 0                  0 S ThreadPoolForeg
u0_a588        1308  1644    804 27130764 267340 0                  0 S ThreadPoolSingl
u0_a588        1308  1645    804 27130764 267340 0                  0 S NetworkService
u0_a588        1308  1646    804 27130764 267340 0                  0 S CookieMonsterCl
u0_a588        1308  1647    804 27130764 267340 0                  0 S CookieMonsterBa
u0_a588        1308  1649    804 27130764 267340 0                  0 S ThreadPoolSingl
u0_a588        1308  1650    804 27130764 267340 0                  0 S PlatformService
u0_a588        1308  1659    804 27130764 267340 0                  0 S Chrome_DevTools
u0_a588        1308  1662    804 27130764 267340 0                  0 S ThreadPoolSingl
u0_a588        1308  1664    804 27130764 267340 0                  0 S RenderThread
u0_a588        1308  1688    804 27130764 267340 0                  0 S FrameMetricsAgg
u0_a588        1308  1695    804 27130764 267340 0                  0 S pool-8-thread-1
u0_a588        1308  1721    804 27130764 267340 0                  0 S glide-disk-cach
u0_a588        1308  1729    804 27130764 267340 0                  0 S Thread-24
u0_a588        1308  1730    804 27130764 267340 0                  0 S Thread-1943
u0_a588        1308  1731    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  1732    804 27130764 267340 0                  0 S RxComputationTh
u0_a588        1308  1733    804 27130764 267340 0                  0 S glide-source-th
u0_a588        1308  1762    804 27130764 267340 0                  0 S InsetsAnimation
u0_a588        1308  1781    804 27130764 267340 0                  0 S RxComputationTh
u0_a588        1308  1784    804 27130764 267340 0                  0 S Binder:1308_4
u0_a588        1308  1878    804 27130764 267340 0                  0 S t.fenbi.com/...
u0_a588        1308  1968    804 27130764 267340 0                  0 S hwuiTask0
u0_a588        1308  1984    804 27130764 267340 0                  0 S hwuiTask1
u0_a588        1308  2050    804 27130764 267340 0                  0 S arch_disk_io_1
u0_a588        1308  2095    804 27130764 267340 0                  0 S Thread-1938
u0_a588        1308  2096    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  2097    804 27130764 267340 0                  0 S Thread-50
u0_a588        1308  2099    804 27130764 267340 0                  0 S RxComputationTh
u0_a588        1308  2103    804 27130764 267340 0                  0 S glide-source-th
u0_a588        1308  2105    804 27130764 267340 0                  0 S glide-animation
u0_a588        1308  2107    804 27130764 267340 0                  0 S glide-animation
u0_a588        1308  2110    804 27130764 267340 0                  0 S glide-source-th
u0_a588        1308  2111    804 27130764 267340 0                  0 S glide-source-th
u0_a588        1308  2222    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  2223    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  2224    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  2225    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  2226    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  2227    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  2228    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  2231    804 27130764 267340 0                  0 S RenderThread
u0_a588        1308  2232    804 27130764 267340 0                  0 S RenderThread
u0_a588        1308  2233    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  2254    804 27130764 267340 0                  0 S AudioDeviceBuff
u0_a588        1308  2255    804 27130764 267340 0                  0 S AudioPortEventH
u0_a588        1308  2256    804 27130764 267340 0                  0 S rtc-low-prio
u0_a588        1308  2260    804 27130764 267340 0                  0 S WebRtcVolumeLev
u0_a588        1308  2261    804 27130764 267340 0                  0 S rtc_event_log
u0_a588        1308  2263    804 27130764 267340 0                  0 S rtp_send_contro
u0_a588        1308  2285    804 27130764 267340 0                  0 S ModuleProcessTh
u0_a588        1308  2289    804 27130764 267340 0                  0 S PacerThread
u0_a588        1308  2346    804 27130764 267340 0                  0 S RxCachedThreadS
u0_a588        1308  2416    804 27130764 267340 0                  0 S UIMonitorThread
u0_a588        1308  2465    804 27130764 267340 0                  0 S PnsLoggerThread
u0_a588        1308  2478    804 27130764 267340 0                  0 S pool-13-thread-
u0_a588        1308  2501    804 27130764 267340 0                  0 S AsyncTask #2
u0_a588        1308  3285    804 27130764 267340 0                  0 S AudioDeviceBuff
u0_a588        1308  3286    804 27130764 267340 0                  0 S rtc-low-prio
u0_a588        1308  3292    804 27130764 267340 0                  0 S WebRtcVolumeLev
u0_a588        1308  3293    804 27130764 267340 0                  0 S rtc_event_log
u0_a588        1308  3294    804 27130764 267340 0                  0 S rtp_send_contro
u0_a588        1308  3295    804 27130764 267340 0                  0 S ModuleProcessTh
u0_a588        1308  3299    804 27130764 267340 0                  0 S PacerThread
u0_a588        1308  3503    804 27130764 267340 0                  0 S pool-10-thread-
u0_a588        1308  3717    804 27130764 267340 0                  0 S AudioDeviceBuff
u0_a588        1308  3720    804 27130764 267340 0                  0 S rtc-low-prio
u0_a588        1308  3721    804 27130764 267340 0                  0 S WebRtcVolumeLev
u0_a588        1308  3722    804 27130764 267340 0                  0 S rtc_event_log
u0_a588        1308  3725    804 27130764 267340 0                  0 S rtp_send_contro
u0_a588        1308  3726    804 27130764 267340 0                  0 S ModuleProcessTh
u0_a588        1308  3733    804 27130764 267340 0                  0 S PacerThread
u0_a588        1308  3807    804 27130764 267340 0                  0 S AudioDeviceBuff
u0_a588        1308  3810    804 27130764 267340 0                  0 S rtc-low-prio
u0_a588        1308  3813    804 27130764 267340 0                  0 S WebRtcVolumeLev
u0_a588        1308  3815    804 27130764 267340 0                  0 S rtc_event_log
u0_a588        1308  3816    804 27130764 267340 0                  0 S rtp_send_contro
u0_a588        1308  3817    804 27130764 267340 0                  0 S ModuleProcessTh
u0_a588        1308  3825    804 27130764 267340 0                  0 S PacerThread
u0_a588        1308  3863    804 27130764 267340 0                  0 S pool-10-thread-
u0_a588        1308  3866    804 27130764 267340 0                  0 S AudioDeviceBuff
u0_a588        1308  3867    804 27130764 267340 0                  0 S rtc-low-prio
u0_a588        1308  3870    804 27130764 267340 0                  0 S WebRtcVolumeLev
u0_a588        1308  3871    804 27130764 267340 0                  0 S rtc_event_log
u0_a588        1308  3872    804 27130764 267340 0                  0 S rtp_send_contro
u0_a588        1308  3873    804 27130764 267340 0                  0 S ModuleProcessTh
u0_a588        1308  3877    804 27130764 267340 0                  0 S PacerThread
u0_a588        1308  4260    804 27130764 267340 0                  0 S AudioDeviceBuff
u0_a588        1308  4261    804 27130764 267340 0                  0 S rtc-low-prio
u0_a588        1308  4262    804 27130764 267340 0                  0 S WebRtcVolumeLev
u0_a588        1308  4263    804 27130764 267340 0                  0 S rtc_event_log
u0_a588        1308  4264    804 27130764 267340 0                  0 S rtp_send_contro
u0_a588        1308  4265    804 27130764 267340 0                  0 S ModuleProcessTh
u0_a588        1308  4279    804 27130764 267340 0                  0 S PacerThread
u0_a588        1308  4323    804 27130764 267340 0                  0 S AudioDeviceBuff
u0_a588        1308  4324    804 27130764 267340 0                  0 S rtc-low-prio
u0_a588        1308  4326    804 27130764 267340 0                  0 S WebRtcVolumeLev
u0_a588        1308  4327    804 27130764 267340 0                  0 S rtc_event_log
u0_a588        1308  4328    804 27130764 267340 0                  0 S rtp_send_contro
u0_a588        1308  4329    804 27130764 267340 0                  0 S ModuleProcessTh
u0_a588        1308  4334    804 27130764 267340 0                  0 S PacerThread
u0_a588        1308  4374    804 27130772 267340 0                  0 S ExoPlayer:Frame
u0_a588        1308  4377    804 27130772 267340 0                  0 S WifiManagerThre
u0_a588        1308  4379    804 27130772 267340 0                  0 S OkHttp Dispatch
u0_a588        1308  4380    804 27130772 267340 0                  0 S OkHttp TaskRunn
u0_a588        1308  4383    804 27130772 267340 0                  0 S OkHttp TaskRunn
u0_a588        1308  4388    804 27130764 267340 0                  0 S HwBinder:1308_1
u0_a588        1308  4432    804 27130764 267340 0                  0 S CCodecWatchdog
u0_a588        1308  4433    804 27130764 267340 0                  0 S MediaCodec_loop
u0_a588        1308  4434    804 27130764 267340 0                  0 S MediaCodec_loop
u0_a588        1308  4576    804 27130764 267340 0                  0 S Binder:1308_5
u0_a588        1308  4948    804 27130764 267340 0                  0 S Binder:1308_6
u0_a588        1308  5491    804 27130764 267340 0                  0 S Binder:1308_7
u0_a588        1308  5776    804 27130764 267340 0                  0 S Binder:1308_8
u0_a588        1308  6583    804 27130764 267340 0                  0 S Binder:1308_9
u0_a588        1308  6584    804 27130764 267340 0                  0 S Binder:1308_A
u0_a588        1308  6678    804 27130764 267340 0                  0 S SVGAParser-Thre
u0_a588        1308  6679    804 27130764 267340 0                  0 S SVGAParser-Thre
u0_a588        1308  6681    804 27130764 267340 0                  0 S Binder:1308_B
u0_a588        1308  6744    804 27130764 267340 0                  0 S AudioDeviceBuff
u0_a588        1308  6745    804 27130764 267340 0                  0 S rtc-low-prio
u0_a588        1308  6746    804 27130764 267340 0                  0 S WebRtcVolumeLev
u0_a588        1308  6749    804 27130764 267340 0                  0 S rtc_event_log
u0_a588        1308  6750    804 27130764 267340 0                  0 S rtp_send_contro
u0_a588        1308  6751    804 27130764 267340 0                  0 S ModuleProcessTh
u0_a588        1308  6755    804 27130764 267340 0                  0 S PacerThread
u0_a588        1308  6765    804 27130764 267340 0                  0 S AudioDeviceBuff
u0_a588        1308  6766    804 27130764 267340 0                  0 S rtc-low-prio
u0_a588        1308  6767    804 27130764 267340 0                  0 S WebRtcVolumeLev
u0_a588        1308  6768    804 27130764 267340 0                  0 S rtc_event_log
u0_a588        1308  6769    804 27130764 267340 0                  0 S rtp_send_contro
u0_a588        1308  6770    804 27130764 267340 0                  0 S ModuleProcessTh
u0_a588        1308  6776    804 27130764 267340 0                  0 S PacerThread
u0_a588        1308  6791    804 27130764 267340 0                  0 S AudioDeviceBuff
u0_a588        1308  6792    804 27130764 267340 0                  0 S rtc-low-prio
u0_a588        1308  6793    804 27130764 267340 0                  0 S WebRtcVolumeLev
u0_a588        1308  6794    804 27130764 267340 0                  0 S rtc_event_log
u0_a588        1308  6795    804 27130764 267340 0                  0 S rtp_send_contro
u0_a588        1308  6796    804 27130764 267340 0                  0 S ModuleProcessTh
u0_a588        1308  6800    804 27130764 267340 0                  0 S PacerThread
u0_a588        1308  6819    804 27130764 267340 0                  0 S AudioDeviceBuff
u0_a588        1308  6820    804 27130764 267340 0                  0 S rtc-low-prio
u0_a588        1308  6821    804 27130764 267340 0                  0 S WebRtcVolumeLev
u0_a588        1308  6822    804 27130764 267340 0                  0 S rtc_event_log
u0_a588        1308  6823    804 27130764 267340 0                  0 S rtp_send_contro
u0_a588        1308  6824    804 27130764 267340 0                  0 S ModuleProcessTh
u0_a588        1308  6828    804 27130764 267340 0                  0 S PacerThread
u0_a588        1308  6876    804 27130764 267340 0                  0 S LiveEngineThrea
u0_a588        1308  6878    804 27130764 267340 0                  0 S AudioDeviceBuff
u0_a588        1308  6879    804 27130764 267340 0                  0 S rtc-low-prio
u0_a588        1308  6880    804 27130764 267340 0                  0 S WebRtcVolumeLev
u0_a588        1308  6881    804 27130764 267340 0                  0 S rtc_event_log
u0_a588        1308  6882    804 27130764 267340 0                  0 S rtp_send_contro
u0_a588        1308  6883    804 27130764 267340 0                  0 S ModuleProcessTh
u0_a588        1308  6884    804 27130764 267340 0                  0 S Thread-9548
u0_a588        1308  6885    804 27130764 267340 0                  0 R Thread-9481
u0_a588        1308  6886    804 27130764 267340 0                  0 S TimeRoutineThre
u0_a588        1308  6887    804 27130764 267340 0                  0 S PacerThread
u0_a588        1308  6888    804 27130764 267340 0                  0 S AudioTrack
u0_a588        1308  6889    804 27130764 267340 0                  0 S AudioTrackJavaT


处理文件描述符引起的问题的思路：

1. 知晓系统的限制。
```
$ adb shell ulimit -n
32768
```
或者查看对进程的限制：
```
$ adb shell ps | grep com.fenbi.android.servant
u0_a588        1308    804 26451052 172980 0                  0 S com.fenbi.android.servant

$ adb shell run-as com.fenbi.android.servant cat /proc/1308/limits
Limit                     Soft Limit           Hard Limit           Units
...
Max open files            32768                32768                files
...
```
```

1. 监控进程创建 FD 的数量

```
$ adb shell run-as com.fenbi.android.servant ls -l /proc/1308/fd

 adb shell run-as com.fenbi.android.servant ls -l /proc/1308/fd
total 0
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 0 -> /dev/null
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 1 -> /dev/null
lr-x------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 10 -> /apex/com.android.art/javalib/bouncycastle.jar
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 102 -> anon_inode:[eventfd]
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 103 -> anon_inode:[eventpoll]
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 104 -> /data/user/0/com.fenbi.android.servant/databases/smartpen.db
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 105 -> /data/user/0/com.fenbi.android.servant/databases/smartpen.db-wal
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 106 -> /data/user/0/com.fenbi.android.servant/databases/smartpen.db-shm
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 107 -> /data/user/0/com.fenbi.android.servant/databases/smartpen.db
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 108 -> /data/user/0/com.fenbi.android.servant/databases/smartpen.db-wal
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 109 -> anon_inode:[eventfd]
lr-x------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 11 -> /apex/com.android.art/javalib/apache-xml.jar
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 110 -> anon_inode:[eventpoll]
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 111 -> anon_inode:[eventfd]
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 112 -> anon_inode:[eventpoll]
lrwx------ 1 u0_a588 u0_a588 64 2023-09-04 15:47 113 -> anon_inode:[eventfd]
...
```

2. 监控线程的数量

```
$ adb shell ps -T -p 1308 | wc -l
```

3. 线程数量明显增长的，或者创建的线程在页面退出后没有销毁的需要处理。

4. 如何确定线程在哪里创建的。
     1. 名字很好关联代码的。
     2. 通过 CPU Profile 看代码。
