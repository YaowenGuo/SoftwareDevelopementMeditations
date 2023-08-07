# 用户管理


|  类型  | 命令 |
| ----  | ----  |
| 用户  | who, whoami, su, useradd, userdel, passwd, usermod, /etc/passwd |
| 群组  | groupadd, groupdel, groupmod, /etc/group |
| 权限  | sudo, exit   |



## 用户

### who, who am i 和 whoami

who 显示所有当前系统中的所有登录用户，对于 su 切换了的用户，只显示他们登录时的用户。
who am i: 显示当前用户登录时的用户。（实际用户=uid，即user id。）相当于 who -m
whoami: 显示当前用户正在使用的用户。（有效用户=euid，即effective user id）

### su 切换用户

root 用户可以切换到任何用户，而其他用户相互切换需要输入人密码。

su 后面加上 “-” 表示切换用户后同时把工作目录切换到该用户的 home 目录。

### useradd 添加用户

useradd []

参数:
    -d    指定新建用户的主目录, 如果不指定, 则系统自动在 /home 目录创建一个和用户名相同的文件夹作为新建用户的主目录（/home/username）
    -m    自动创建主目录文件夹
    -g    指定新建用户所在组名称, 如果不指定, 则系统自动创建一个和用户名相同的组作为新建用户所属组。指定组必须已经存在，不会自动创建不存在的组。

账号最长 32 个字符，用户的家目录下的文件拷贝自 /etc/skel


### 删除用户 userdel

删除用户时, 如果用户所属组是创建用户时自动创建的和用户名称同名的组, 并且该组内没有其他用户, 则该组也会被删掉。

格式: userdel [-options] username

参数:
    -f    强制删除用户, 即使用户当前已登录
    -r    删除用户, 同时删除用户主目录

### 设置或修改密码 passwd

普通用户只能设置自己的密码，超级用户可以重置所有用户的密码

参数:
    -a    all, 此选项只能和 -S 一起使用, 来显示所有用户的状态。显然需要 root 权限（可以以 sudo 执行）。
    -d    delete, 删除用户密码（把密码置为空）
    -l    lock, 锁定指定账户（将密码更改为一个不可能与加密值匹配的值来禁用）
    -u    unlock, 解锁指定账户
    -S    status, 显示账户状态信息

passwd 指定用户名时，修改指定用户的密码，否则设置自己的密码。

### 修改用户信息 usermod

usermode 不允许修改正在登陆的用户名称和 ID。

usermod username [-options params]

### /etc/passwd

关于用户的设置，都存放在 /etc/passwd 目录下，每一行是一个用户的信息，每一行有 7 列，用冒号 ':' 分割。

Username : Password : User ID : Group ID : Comment : Home Diretory : Login Command
  户名    : 密码      : 用户ID   : 组ID     : 用户注解 : 主目录         : 登录后执行的命令

其中 密码字段 只显示一个特殊字符“x”或“*”, 加密后的密码存放在 /etc/shadow 文件中, 只有超级用户才能访问。

 Linux 的一些服务运行需要不同的权限，为了安全，在服务安装的时候会自动给不同的服务创建用户来获得不同的权限。

每一行代表一个用户，每个用户的描述用 8 个 冒号隔开，也就是 9 个字段描述。

UserName : Password : Last Update Date | 

- 2: 密码为 "!"、"*" 的账号不能直接登录系统（其他账号登录后可切换为）
- 2: ! 密码锁定
- 3: 上次修改日期。
    - 自 1970-01-01 起的天数
    - 0 表示用户下次登录时需要修改密码，空表示关闭密码过期功能
- 4: 密码最小使用期
- 5：密码最长使用期, 后值小于前值时用户无法修改密码
- 6: 密码过期前几天提醒
- 7: 密码过期几天后账号会被锁定。账号过期用户不能登录，密码过期看此设置
- 8: 账号过期日期（距 1970-01-01 的天数）
- 9: 保留




### 类似用户，组的操作有

添加组 groupadd
删除组 groupdel
改变组信息 groupmod

组信息存放在 /etc/group 文件中。存放信息有

Group Name : Password : Group ID : User List