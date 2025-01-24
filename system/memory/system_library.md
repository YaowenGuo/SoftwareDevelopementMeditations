 ## Underlying OS Support
 
You might have noticed that we haven’t been talking about system
calls when discussing malloc() and free(). The reason for this is simple: they are not system calls, but rather library calls. Thus the malloc library manages space within your virtual address space, but itself is built
on top of some system calls which call into the OS to ask for more memory or release some back to the system.
One such system call is called brk, which is used to change the location of the program’s break: the location of the end of the heap. It takes
one argument (the address of the new break), and thus either increases or
decreases the size of the heap based on whether the new break is larger
or smaller than the current break. An additional call sbrk is passed an
increment but otherwise serves a similar purpose.
Note that you should never directly call either brk or sbrk. They
are used by the memory-allocation library; if you try to use them, you
will likely make something go (horribly) wrong. Stick to malloc() and
free() instead.
Finally, you can also obtain memory from the operating system via the
mmap() call. By passing in the correct arguments, mmap() can create an
anonymous memory region within your program — a region which is not
associated with any particular file but rather with swap space, something
we’ll discuss in detail later on in virtual memory. This memory can then
also be treated like a heap and managed as such. Read the manual page
of mmap() for more details.