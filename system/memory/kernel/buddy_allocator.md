# 伙伴系统

在人际关系中伙伴是指关系亲密或熟悉的人，将这一词汇用于内存管理也很形象。内存管理的伙伴是指，地址相邻的物理页。Linux 上物理

Buddy System Allocator: Each zone is divided into 11 orders sized chunks: 2⁰, 2¹, 2², …, 2¹⁰. Largest size of continuous memory is (2¹⁰ x page size) — 4MB (4KB page) (/proc/buddyinfo).