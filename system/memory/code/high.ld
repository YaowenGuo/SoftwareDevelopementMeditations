/* 
 high.ld 
 as -o sleep.o sleep.s && ld -o sleep2 sleep.o -T high.ld --defsym=__page_size=0x1000 -z max-page-size=0x1000
*/
ENTRY(_start)
PAGE_SIZE = 0x1000;

SECTIONS
{
    /* 可执行文件起始，包含 ELF 头 */
    . = 0x0000fffffffff000;
    
    /* 文本段 - 可执行、只读 */
    .text : ALIGN(PAGE_SIZE) {
        *(.text)
    } :text
    /DISCARD/ : { *(.note*) *(.comment) }
    
}

PHDRS {
    text PT_LOAD FLAGS(5);  /* R-X */
}