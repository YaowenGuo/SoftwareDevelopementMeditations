/* 
* ld -pie -o main main.o -T my.ld
*/

ENTRY(_start)
SECTIONS {
    . = 0x0040000;  /* ⚠️ 强制基地址为0 */
    .text : { *(.text) }
    .data : { *(.data) }
    .bss : { *(.bss) }
}
