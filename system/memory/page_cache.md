BuffersFile Systems Cache

True free memory is not useful and it does nothing, so the OS will attempt to utilize spare memory to cache file system. Kernel is also able to quickly free memory from file system cache. This processes is transparent to applications . Logical I/O latency is much lower, as requests are being served from main memory.

Cache grows over time and “free” memory shrinks. Regular caching is used to improve read performance and buffering inside the cache is used to improve write performance.

Page cache

Buffer cache is stored in the page cache in modern Linux and is used for disk I/O to buffer writes.

It is dynamic and current cache size can be checked in /proc/meminfo. Page cache is used to increase directly and file I/O and virtual memory pages and file system pages are stored in it. Dirty file system pages are flushed by flusher threads (flush), per device processes.

It happens after:

An interval (default 30s)
Sync(), fsync(), msync() system calls
Too many dirty pages (dirty_ratio)
No available page cache pages
If there is a system memory deficient, kswapd will look for dirty pages to be written to disk. All I/O goes through the page cache unless explicitly set not to do so — Direct I/O. This can result in all writes being blocked if the page cache has completely filled. When all writes are blocked, operating system have a tendency to stop.

Dropping Cache

It is possible to drop the page, dentry (directory entry cache), and inode caches in Linux, either to forcefully free up memory, or to test file system performance prior to anything being cached.

To drop the page cache, use “Echo 1 > /proc/sys/vm/drop_caches”

To drop dentry and inode caches use “Echo 2 /proc/sys/vm/drop_caches”

To drop both use: “Echo 3 > / proc/sys/vm/drop_caches”