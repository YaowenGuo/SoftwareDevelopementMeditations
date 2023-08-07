# 条件

```
```

判断是否设置了目标。Use the TARGET clause of the if command:

```
conditionally_add (mylib mysrc.cc ${some_condition})
if (TARGET mylib)
  # Do something when target found
endif()
```