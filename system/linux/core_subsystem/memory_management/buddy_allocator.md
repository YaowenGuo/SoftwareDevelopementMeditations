# 伙伴系统


Buddy System Allocator: Each zone is divided into 11 orders sized chunks: 2⁰, 2¹, 2², …, 2¹⁰. Largest size of continuous memory is (2¹⁰ x page size) — 4MB (4KB page) (/proc/buddyinfo).