data segment
	out1 db 'Hello world$';显示字符串的系统中断显示到$\$$前的字符就结束
	out2 db 'My name is WuZhenyu$';注意不能有非ASCII 字符
data ends

code segment
assume cs:code,ds:data;code是数据段，ds 是代码段

start:
;初始化
	mov ax,data;把data的地址给ds;ds 不能立即数寻址，所以用了ax 中转
	mov ds,ax
	lea dx,out1;把out1的偏移位置加载到dx

;开始
	mov ah,9;显示字符串;插入"Hello world"
	int 21h
	mov dl,0ah;显示字符;插入<LF>
	mov ah,2
	int 21h
	mov dl,0dh;显示字符;插入<CR>;<LF><CR>是Windows 风格换行
	mov ah,2
	int 21h
	lea dx,out2;把out2的偏移位置加载到dx
	mov ah,9;显示字符串;插入"My name is WuZhenyu"
	int 21h

;退出
	mov ah,4ch;正常退出
	int 21h

code ends

end start;注明程序从start 开始加载;没有堆栈段链接时会报个警告，但无伤大雅

