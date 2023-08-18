# ps(process)

查看进程
```
ps | grep <name>
```

USER    PID   PPID VSZ     RSS    WCHAN ADDR S NAME
u0_a355 19907 639  2441608 258964 0     0    S tech.yaowen.test

可以通过进程的pid或者user属性来查找相应进程下的线程

查看某进程下的线程
```
ps -T | grep [<USER>|<PID>]
```
USER 或者 PID 选其一即可。
