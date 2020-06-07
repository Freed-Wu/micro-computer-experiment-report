.model small ;简化段定义

.stack

.data;其实把未初始化的变量定义在.data?中更合适
	old_ip09  dw ?;?是未初始化的内存，通常编译器会把?初始化为0
	old_cs09 dw ?
	old_ip0f dw ?
	old_cs0f dw ?
	count  dw 0
	buffer db 20h dup('?')
	buf_p dw ?
	start_msg db 0ah,0dh,'RUN!'0ah,0dh,'$'
	end_msg db  0ah,0dh,'end!'0ah,0dh,'$'
	full_msg db  'buffer full !'0ah,0dh,'$'

.code
main proc far
start:
	mov ax,@data;默认数据段的名字,因为使用了简化段定义，实际上等同于mov ax,dgroup
	mov ds,ax
	lea ax,buffer
	mov buf_p,ax;buf_p 储存了buffer 的偏移地址
	;mov count,0;一开始count 直接定义0更方便

	;获取键盘硬件的中断向量
	mov al,09h
	mov ah,35h;
	int 21h
	mov old_cs09,es;保存该中断向量
	mov old_ip09,bx
	push ds;保护现场
	;设置键盘硬件中断向量到kbint
	cli;防止此时有键盘中断，所以先禁用中断
	lea dx,kdbint
	mov ax,seg kdbint
	mov ds,ax
	mov al,09h
	mov ah,25h
	int 21h
	pop ds;恢复现场
	;set keyboard interrupt mask bits
	in al,21h
	and al,0fdh
	out 21h,al
	sti
	;等待中断
	mov di,20000
delay:
	mov si,30000
delay1:
	dec si
	jnz delay1
	dec di
	jnz delay
	mov di,20000
dey:
	mov si,30000
dey1:
	dec si
	jnz dey1
	dec di
	jnz dey
	mov di,20000
de:
	mov si,30000
de1:
	dec si
	jnz de1
	dec di
	jnz de
	mov di,20000
d:
	mov si,30000
d1:
	dec si
	jnz d1
	dec di
	jnz d

	;中断禁止
	cli
	;save old
	push ds
	mov dx,old_ip09
	mov ax,old_cs09
	mov ds,ax
	mov al,09h
	mov ah,25h
	int 21h
	pop ds
	;enable
	in al,21h
	and al,0fdh
	out 21h,al
	;中断使能
	sti

	mov ax,4c00h
	int 21h
main endp

kdbint proc near
	push ax
	push bx
	sti;原程序是cld

	;1. Read scan code.  Note that "make" key scan code has bit 7=1,
	;"break" code has bit 7=0, except on AT, for which bit 7 is always 0,
	;a "break" produces a 0F0H code, then the key scan code.
	;2. Send acknowledge to keyboard by toggling bit 7 to 1, then back to 0.
	;3. Put keyboard in buffer.
	;4. Signal EOI to the interrupt controller.

	;060H Port A Input (acts as a one byte device output register):
	;If PB7 = 0 Read Keyboard Scan Code
	;If PB7 = 1 Read switches
	;PA7,6   = SW1-8,7  # of drives
	;PA5,4   = SW1-6,5  monitor type
	;11 = monochrome
	;10 = 80x25 color
	;01 = 40x25 color
	;PA3,2,0 = SW1-4,3,1 Reserved
	;PA1     = SW3       Math chip mounted
	in al,60h;获取键盘扫描码，有可能是通码也有可能是断码
	push ax;
	in al,61h;得到当前PB控制字
	mov ah,al
	or al,80h;最高位置1,禁止读键盘扫描码;清除键盘输入缓冲区
	out 61h,al
	xchg ah,al
	out 61h,al;恢复PB 控制字,使能读键盘扫描码
	pop ax
	test al,80h;键盘按下会产生通码，松开会产生断码。断码是通码的bit7 置位，所以判断bit7 是不是1
	jnz return1;输入断码就结束中断
	mov bx,buf_p;输入通码就继续
	mov [bx],al;加方括号 [ ] 表示一种取地址方式;把键盘扫描码储存在buf_p
	call display_hex
	inc bx;因为存入一个扫描码了地址++
	inc count
	mov buf_p,bx;把新的地址写入buf_p
	;check:;没有用到
	;cmp count ,20h;判断有没有buffer 溢出
	;jb return1
return1:
	cli
	mov al,20h;OCW2,控制中断结束和优先权循环,D5是中断结束EOI
	out 20h,al

	pop bx
	pop ax
	iret
kdbint endp

display_hex proc near
	push ax
	push cx
	push dx

	mov ch,2;循环2次
	mov cl,4
nextb:
	rol al,cl;第一次显示高4位,第二次显示低4位
	push ax;保存低4位
	;把al 的低4位显示出来。
	mov dl,al
	and dl,0fh;取低4位
	or dl,30h;加上30h 就是数字的ASCII码
	cmp dl,3ah;判断有没有超过3ah，因为3ah 以后的ASCII码不是数字
	jl dispit
	add dl,7h;加上7才是对应的16进制英文字母
dispit:
	mov ah,2
	int 21h
	pop ax
	dec ch
	jnz nextb;循环2次后不再循环，输出','
	;在显示屏上输出显示字符
	mov ah,2
	mov dl,','
	int 21h

	pop dx
	pop cx
	pop ax
	ret
display_hex endp

end start
