# rsync

当拷贝多个文件或目录时，可能会因为时间过长而因为这种原因中断，此时想要从断点开始重传是无法实现的，`rsync` 是更好的方法，rsync 是 linux 系统下的数据镜像备份工具。

rsync -avzP --rsh=ssh ./version ubuntu@35.169.80.106:/web/docker-laravel-ubuntu16/app/web_panda_dict_api/storage/app/

rsync -avz  /web/docker-for-dict/apps /disk2/web_online0`
