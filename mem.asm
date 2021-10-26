%macro writeStr 2
        push    eax
        push    ebx
        push    ecx
        push    edx
        mov             edx,%2
        mov             ecx,%1
        mov             ebx,1
        mov             eax,4
        int             0x80
        pop             edx
        pop             ecx
        pop             ebx
        pop             eax
%endmacro

section .bss
	buffer resb 16 ; chua toan bo ky tu nhap vao tu C

section .data
	global display_memory
	global print_address
	printTable	 db	 '|................|' ; in ra cot thu 3
	lenPrintTable	 equ	 $-printTable
	address		 dd	0x00000000 ; gia tri tang dan cua dia chi
	length		 dd	 0 ; chieu dai cua chuoi nhap vao
	extern newline
	extern space
	extern write_char
	extern write_hex
	extern write_hex_address
	extern write_str

read:
	push ebp
	mov ebp, esp
	mov edx, [ebp + 20]; lay gia tri do dai chuoi
	mov ecx, [ebp + 16]; lay gia tri cua chuoi nhap vao
	mov dWord[length], edx; length = do dai chuoi
	leave
	ret

write:
	call read
	xor	 esi,	 esi
	writeArrChar:
	mov	 eax,	 [ecx + esi]
	mov	 [buffer + esi], eax
	inc	 esi
	cmp	 esi,	 16 ; den khi buffer du 16 ky tu thi dung
	jne writeArrChar
	ret

print_space:
	_print:
	call space
	inc	 edi
	cmp	 edi	,2
	jne _print
	ret

print_address:
	mov	 edx,	 dWord[address]; dua gia tri address cho edx dem sang display.asm de convert thanh dia chi hexan
	call write_hex_address ; goi ham den display.asm
	xor	 edi,	 edi
	call space
	call space ; in 2 khoang trang vi den day thi cot thu nhat va thu 2 da in xong
	xor	 edi,	 edi
	xor	 esi,	 esi

print_list_str:
	cmp	 Byte[buffer + esi], 0x20 ; 0x20: khoang trang
	jb no_print_list_str
	cmp	 Byte[buffer + esi], 0x7D ; 0x7D: '~'
	jg no_print_list_str 		; in ra ky tu lam xo lech cot 3
	mov	 al,	 byte[buffer + esi]
	mov	 Byte[printTable + esi + 1], al ; do ky tu dau tien cua printTable la '|' phai cong them 1
	jmp next

no_print_list_str:
	mov	 al,	 0x2E ; 0x2E la ky tu '.'
	mov	 byte[printTable + esi + 1], al ; do ky tu dau tien cua printTable la '|' phai cong them 1

next:
	inc esi
	cmp	 esi,	 16 ; lap cho den khi printTable lay du 16 ky tu
	jne print_list_str
	xor	 esi,	 esi
	jmp print_digithex

print_twospace:
	call space ; in them mot khoang trang  nua cong voi khoang trang truoc do da in la du 2 khoang trang
	cmp	 esi,	 dWord[length]
	je print_space_length
	jmp print_digithex

print_digithex:
	mov	 al,	 byte[buffer + esi]
	call write_hex ; in gia tri al thanh chuoi hexan 
	call space
	error_character:
	inc	 esi
	cmp 	esi,	 8 ; ky tu thu 8 va thu 9 cach nhau 2 khoang trang
	je print_twospace
	cmp	 esi,	 dWord[length]
	je print_space_length
	cmp	 esi,	 16 ; thuc hien den khi in du 16 ky tu 
	jne print_digithex
	call space
	xor	 esi,	 esi
	jmp WriteStr

_print_space:
	call space
	jmp loop_space

print_space_length:
	cmp	 esi,	 16 ; du 16 ky tu thi in printTable luon
	je jump_write_esi
	cmp	 dWord[length], 16
	je jump_write
	mov 	esi, 	dWord[length]
	loop_space:
	call space
	call space ; hai khoang trang dau tien cho so hexan
	call space ; khoang trang nay la in cho dung le
	inc	 esi
	cmp 	esi,	 0x08
	je _print_space
	cmp	 esi,	 0x10
	jne loop_space
	jmp jump_write_esi
	jump_write:
	call space
	call space ; in 2 khoang trang truoc khi in printTable
	xor	 esi,	 esi
	jmp WriteStr
	jump_write_esi:
	call space

WriteStr:
	cmp	 dWord[length], 0x10
	jne print_length ; truong hop chuoi nhap vao khong du 16 ky tu
	writeStr printTable, lenPrintTable

Exit:
	call newline
	ret

print_length:
	add	 dWord[length], 1 
	mov	 esi,	 dWord[length]
	mov	 byte[printTable + esi], '|'; cong 1 o length do printTable co ky tu dau tien la '|'
	inc	 dWord[length]
	writeStr printTable, dWord[length]
	xor 	esi,	 esi
	jmp Exit

display_memory:
	call write
	xor	 esi,	 esi
	call print_address
	add 	dWord[address], 16 ; sau moi lan thuc hien ham thi cong dia chi them 16 cho dia chi tiep theo
	ret



