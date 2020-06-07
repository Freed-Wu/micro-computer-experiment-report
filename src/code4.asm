stack segment para stack'stack';完整段定义
	db 256 dup(0)
stack ends

code segment para public'code'
start proc far
	assume cs:code
	push ds
	mov ax,0
	push ax
	;8250初始化
	;写线路控制寄存器
	mov dx,3fbh;线路控制寄存器地址
	mov al,80h;最高位DLAB=1;允许写除数寄存器
	out dx,al    ;AX=0080h，DX=03fbh，IP=000ah，OF=0，DF=0，IF=1，SF=0，ZF=0，AF=0，PF=0，CF=0，
	;写除数寄存器
	mov dx,3f8h;除数寄存器低字节端口地址
	mov al,60h;分频系数=1843200/16/波特率;波特率=1200
	out dx,al   ;AX=0060h，DX=03f8h，IP=0010
	;写除数寄存器
	mov dx,3f9h;除数寄存器高字节端口地址
	mov al,0;低字节写60h，高字节写0
	out dx,al   ;AX=0，DX=03f9h，IP=0016h
	;写线路控制寄存器
	mov dx,3fbh
	mov al,0ah;AL=00001010, 数据长度7位, 1位停止位,奇校验
	out dx,al   ;AX=000ah，DX=03fbh，IP=001ch
	;写MODEM控制寄存器
	mov dx,3fch;MODEM控制寄存器端口地址
	mov al,13h;D4=1,自检模式，使$ \overline{DTR}=\overline{RTS}=0 $, 数据终端准备就绪
	out dx,al   ;AX=0013h，DX=0022h，IP=0022h
	;写中断允许寄存器
	mov dx,3f9h;中断允许寄存器端口地址
	mov al,0;禁止所有中断
	out dx,al   ;AX=0，DX=03f9h，IP=0028h

fore:
	mov dx,3fdh;通信线路状态寄存器
	in al,dx    ;AX=0，DX=03fdh，IP=002ch，OF=0，DF=0，IF=1，SF=0，ZF=0，AF=0，PF=0，CF=0
	;00011110
	;   ||||
	;   |||溢出错
	;   ||奇偶错
	;   |帧格式错
	;   终止符检测
	test al,1eh ;OF=0，DF=0，IF=1，SF=0，ZF=0，AF=0，PF=0，CF=0
	jnz error;异常处理
	;00000001
	;       |
	;       接收数据就绪
	test al,01h;
	jnz rece;接收数据;AX=0060h，DX=03fdh，IP=0033h，OF=0，DF=0，IF=1，SF=0，ZF=1，AF=0，PF=1，CF=0
	;00100000
	;  |
	;  数据缓冲寄存器空
	test al,20h ;OF=0，DF=0，IF=1，SF=0，ZF=1，AF=0，PF=1，CF=0
	jz fore;数据缓冲器没有空；继续无限循环;处理异常或接收数据
	;数据缓冲寄存器没有数据
	mov ah,1;用来查询键盘缓冲区，对键盘扫描但不等待，并设置ZF标志。若有按键操作（即键盘缓冲区不空），则ZF＝0，AL中存放的是输入的ASCII码，AH中存放输入字符的扩展码。若无键按下，则标志位ZF＝1。
	int 16h
	jz fore;ZF=0；有键按下;键盘缓冲区不空;继续无限循环;处理异常或接收数据
	;无键按下；等待键盘输入
	mov ah,0;从键盘读入字符送AL寄存器。执行时，等待键盘输入，一旦输入，字符的ASCII码放入AL中。若AL＝0，则AH为输入的扩展码。
	int 16h
	mov dx,3f8h;数据发送寄存器
	out dx,al    ;AX=4200h，DX=03f8h，IP=0046h
	jmp fore;将键盘输入发送到8250

rece:
	mov dx,3f8h;数据接收寄存器
	in al,dx     ;AX=4261h，DX=03f8h，IP=004ch，OF=0，DF=0，IF=1，SF=0，ZF=0，AF=0，PF=0，CF=0
	and al,7fh;去除起始位   ;OF=0，DF=0，IF=1，SF=0，ZF=0，AF=0，PF=0，CF=0
	push ax
	mov bx,0
	mov ah,14;显示字符，在屏幕上显示字符并前进光标。接收：AL=ASCII 字符码，BH=视频页，BL=属性或颜色
	int 10h
	pop ax        ;AX=0e00h，DX=03f8h，IP=0057h，OF=0，DF=0，IF=1，SF=0，ZF=1，AF=0，PF=1，CF=0
	cmp al,0dh;比较是否为回车;AX=4200，DX=03f8h，IP=0058h，OF=0，DF=0，IF=1，SF=0，ZF=1，AF=0，PF=1，CF=0
	jnz fore;不是就返回
	mov al,0ah;是显示换行;回车是不回显字符，用换行显示
	mov bx,0
	mov ah,14;显示字符，在屏幕上显示字符并前进光标。接收：AL=ASCII 字符码，BH=视频页，BL=属性或颜色
	int 10h
	jmp fore;无限循环

error:
	mov dx,3f8h;数据接收寄存器
	in al,dx
	mov al,'?'
	mov bx,0
	mov ah,14;显示字符，在屏幕上显示字符并前进光标。接收：AL=ASCII 字符码，BH=视频页，BL=属性或颜色
	int 10h
	jmp fore;无限循环

start endp
code ends
end start
