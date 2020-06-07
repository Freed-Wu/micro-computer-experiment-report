data segment
	count  dw 18
	num dw 255
	msg db  'hello$!';显示字符串的系统中断显示到$\$$前的字符就结束;注意不能有非ASCII 字符
data ends

code segment
	;主程序
main proc far
	assume cs:code,ds:data;code是数据段，ds 是代码段
start:
	;初始化
	;取中断;类型号为1ch;中断地址放到es:bx
	mov al,1ch
	mov ah,35h
	int 21h
	;保护现场
	push es;es,bx保存了原来中断1ch的中断地址
	push bx
	push ds;接下来程序中会使用ds
	mov dx,offset ring;把ring的偏移位置加载到dx
	mov ax, seg ring;把ring的地址给ds;ds 不能立即数寻址，所以用了ax 中转
	mov ds,ax
	;设中断;类型号为1ch;中断地址为ring
	mov al,1ch
	mov ah,25h
	int 21h
	mov ax,data;把data的地址给ds;ds 不能立即数寻址，所以用了ax 中转
	mov ds,ax
	;恢复ds
	pop ds
	;修改8259
	in al,21h;读中断屏蔽操作寄存器OCW1
	mov num,ax;保存OCW1,后面恢复用;!原程序无这句
	and al,11111110b;开放IRQ0中断;IRQ0是时钟中断
	out 21h,al;重新写入OCW1
	;中断使能
	sti

	;等待中断
	mov ax,65534
delay1:
	mov di,65534
delay2:
	mov si,65534
delay3:
	dec si
	jnz delay3
	dec di
	jnz delay2
	dec ax
	jnz delay1
	;恢复8259;原程序无这段
	mov ax,num;恢复
	out 21h,al;重新写入OCW1
	;恢复现场
	pop dx
	pop ds
	;设中断；恢复到原来的中断地址
	mov al,1ch
	mov ah,25h
	int 21h

	;退出
	mov ax,4c00h;正常退出
	int 21h
main endp

	;中断子程序ring
ring proc near
	;初始化
	;保护现场
	push ds
	push ax
	push cx
	push dx
	mov ax,data;把data的地址给ds;ds 不能立即数寻址，所以用了ax 中转
	mov ds,ax
	;中断使能
	sti

	;开始
	dec count;计数少1次
	jnz exit;判断有没有减少到0，没有就到exit 子程序，屏幕没有输出
	;有就继续，屏幕会有输出
	mov dx,offset msg;显示字符串;插入"hello"
	mov ah,09h;显示字符;插入<LF>
	int 21h
	mov dl,0ah;显示字符;插入<CR>;<LF><CR>是Windows 风格换行
	mov ah,2
	int 21h
	mov dl,0dh
	mov ah,2
	int 21h
	;重新计数
	mov count, 18

	;退出子程序
	;中断禁止
	cli
	;恢复现场
	pop dx
	pop cx
	pop ax
	pop ds
	;返回主程序
	iret

	;子程序exit
	;屏幕没有输出
exit:
	;中断禁止
	cli
	;恢复现场
	pop dx
	pop cx
	pop ax
	pop ds
	;返回主程序
	iret

ring endp

code ends

end start;注明程序从start 开始加载;没有堆栈段链接时会报个警告，但无伤大雅

