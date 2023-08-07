;windows下调试需要把org 07c00ch改成org 0100h，然后编译生成一个.COM文件
;在DOS下运行。nasm boot.asm -o boot.com 
;但使用宏汇编更方便
;%define _BOOT_DEBUG_       ;制作Boot Sector时一定要讲此行注释掉，去掉注释用于生成.COM文件调试。
%ifdef  _BOOT_DEBUG_
    org 0100h
%else 
    org	07c00h              ;告诉编译器程序加载到7c00处
%endif
    mov	ax,	cs
	mov	ds,	ax
	mov	es,	ax
	call	DispStr         ;调用显示字符串例程
	jmp	$                   ;无限循环 $：是当前指令汇编后的地址，$$:一节的开始处汇编后的地址。
DispStr:
	mov	ax,	BootMessage
	mov	bp,	ax              ;ES:BP = 串地址
	mov	cx,	16              ;CX = 串长度
	mov	ax,	01301h          ;AH = 13，AL = 01H
	mov	bx,	000ch           ;页号为0（BH = 0）黑底红字（BL = 0CH，高亮）
	mov	dl,	0
	int	10h                 ;10H号中断
	ret
BootMessage:             db	"Hello, OS World!"
	times	510-($-$$)	 db 0   ;填充剩下的空间，使生成的二进制代码恰好为512字节
	dw	0xaa55                  ;结束标志，当计算机电源被打开时，它会先加电自检（POST），然后寻找启动盘，如果
    ;选择从软盘启动，计算机会检查软盘的0面0磁道1扇区。如果发现是以0Xaa55结束
    ;就认为是引导扇区，将其加载进内存。
