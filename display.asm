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
section .data
        hexchar 	db 	'0123456789abcdef'
        bMem times 8	 db	 0x30    ;Memory to store string
        cMem   		 db	 0
        rowAddress	 dd	 4
        temp		 db	 0
        pow		 db	 2 ; bien de tinh so mu theo nhi phan
        flag		 db	 8 ; thong bao da xu ly 2 bit cuoi cung
        addressStr	 db	"0x00000000" ; chuoi de in dia chi dang hex
        lenAddress	 equ	 $-addressStr ; chieu dai cua chuoi
        count		 dd	 9 ; bien de dem so lan lap bit
	global space
        global newline
        global write_char
        global write_str
        global get_hex_digit
        global write_hex
        global write_bin
        global write_dec
        global write_hex_address



write_hex_digit:
	;input al
	push ebx
	mov	 ebx,	 hexchar
	xlat
	call write_char
	pop ebx
	ret

get_hex_digit:
	; input al
	push ebx
	mov	 ebx,	 hexchar
	xlat
	pop ebx
	ret


write_hex:
	;input al
	push ebx
	mov	 bl,	 al
	shr	 al,	 4 
	call write_hex_digit
	mov	 al,	 bl
	and	 al,	 0x0f
	call write_hex_digit
	pop ebx
	ret

write_hex_flag_0:
	;input al
	push ebx
	mov	 bl, al
	shl al, 4 ; lay gia tri 4 bit thap khi doi tu nhi phan sang thap phan
	call get_hex_digit 
	mov	 Byte[addressStr + esi], al
	dec esi ; = esi--
	mov	 al, bl
	shr	 al, 4 ; lay gia tri 4 bit cao khi doi tu nhi phan sang thap phan
	call get_hex_digit
	mov	 Byte[addressStr + esi], al
	dec	 esi
	pop 	ebx
	ret

write_hex_flag_1:
	;input al
	push ebx
	mov	 bl, al
	and	 al, 0x0f ; xoa toan bo cac bit 1 o 4 bit cao
	call 	get_hex_digit
	mov	 Byte[addressStr + esi], al
	dec	 esi
	mov	 al, bl
	shr	 al, 4
	call	get_hex_digit
	mov	 Byte[addressStr + esi], al
	dec	 esi
	pop	 ebx
	ret

write_hex_address:
	xor	 eax, eax
	xor	 esi, esi
	xor	 edi, edi
	mov	 ebx, edx
	mov	 byte[flag], 0
	mov	 dWord[count], 9
	loop1:
		shr	 ebx, 1
		jc	 flag_1 ; bit bi dich la bit 1 hay CF = 1 
		getPoint:
		inc     esi
		cmp 	esi,8
		jne 	loop1
		loop2:
			mov	 esi, dWord[count]
			cmp	 byte[flag], 0
			je	 flag_0; dau hieu de nhan biet la 2 bit cuoi cua dia chi da xu ly chua
			call	 write_hex_flag_1
			point:
			shr	 edx, 8 ; bo 8 bit da xet
			xor 	 eax, eax
			mov	 ebx, edx
			mov	 dWord[count], esi
			xor	 esi, esi
			inc	 edi
			cmp	 edi, 4 ; 32 bit / 8 bit = 4 lan
			jne loop1
	writeStr addressStr, lenAddress
	ret

flag_0:
	call write_hex_flag_0
	inc	 byte[flag]
	jmp point

pow_zero:
	add	 al, 1
	jmp getPoint

flag_1:
	;input al
	cmp	 esi, 0 ; bit 1 o vi tri dau tien
	je pow_zero
	mov	 byte[temp], al
	mov 	al, 1
	xor	 ecx, ecx
	pow_jump:
	mul	 byte[pow] ; nhan 2 lan de tinh so mu 
	inc	 ecx
	cmp	 ecx, esi
	jne pow_jump
	add	 al, Byte[temp] ; lay gia tri nhi phan 
	jmp getPoint

write_bin:
	;input al
	push ebx
	push ecx
	push edx
	push edi
	push esi
	push eax

	mov al, 0x30
	mov ecx, 8
	mov edi, bMem
	cld
	rep stosb
	pop eax

_st_writebin:
        mov             ecx,7
        mov             esi,bMem
        mov             bl,128
_bin_disp_loop:
        mov             dl,al
        test    dl,bl
        jz              dl_zero
        inc             byte[esi]
dl_zero:
        inc             esi
        shr             bl,1
        loop    _bin_disp_loop

write_str:
        ; strAddr [ebp+12]
        ; strLen [ebp+8]
        push ebp
        mov  ebp,esp
        writeStr [ebp+12],[ebp+8]
	pop ebp
        leave
        ret 


space:
        push eax
        mov al,0x20
        call write_char
        pop eax
        ret
newline:
        push eax
        mov al,10
        call write_char
        pop eax
        ret
write_char:
        ; input al
        mov byte[cMem],al
        writeStr cMem,1
	ret

write_dec:
        ; input ax
        ;input  ax
        push    ebx
        push    ecx
        push    edx

