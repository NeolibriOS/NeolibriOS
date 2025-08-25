format ELF
section '.text' executable
public start
public start as '_start'

extrn main
include 'proc32.inc'
include 'macros.inc'

virtual at 0
        db 'MENUET01' ; 1. Magic number (8 bytes)
        dd 0x01       ; 2. Version of executable file
        dd start      ; 3. Start address
imgsz	dd 0x0	      ; 4. Size of image
        dd 0x100000   ; 5. Size of needed memory
        dd 0x100000   ; 6. Pointer to stack
__app_params dd 0x0   ; 7. Pointer to program arguments
        dd 0x0	      ; 8. Pointer to program path
end virtual

start:
    ; init heap
    mcall 68, 11

    mov  [argc], 0
    mov  eax, [__app_params]
    test eax, eax
    jz	 .without_path
    mov  eax, path
    cmp	 word ptr eax, 32fh  ; '/#3'  UTF8
    jne  .without_path
    mov  word ptr eax, 12fh  ; '/#1'  fix to CP866
.without_path:
    mov  esi, eax
    call push_param
; retrieving parameters
    mov  esi, params
    xor  edx, edx  ; dl - идёт параметр(1) или разделители(0)
                   ; dh - символ с которого начался параметр (1 кавычки, 0 остальное)
    mov  ecx, 1    ; cl = 1
                   ; ch = 0  просто ноль
.parse:
    lodsb
    test al, al
    jz	 .run
    test dl, dl
    jnz  .findendparam
                     ;{если был разделитель
    cmp  al, ' '
    jz	 .parse  ;загружен пробел, грузим следующий символ
    mov  dl, cl  ;начинается параметр
    cmp  al, '"'
    jz	 @f	 ;загружены кавычки
    mov  dh, ch     ;параметр без кавычек
    dec  esi
    call push_param
    inc  esi
    jmp  .parse

  @@:
    mov  dh, cl     ;параметр в кавычеках
    call push_param ;если не пробел значит начинается какой то параметр
    jmp  .parse     ;если был разделитель}

.findendparam:
    test dh, dh
    jz	 @f ; без кавычек
    cmp  al, '"'
    jz	 .clear
    jmp  .parse
  @@:
    cmp  al, ' '
    jnz  .parse

.clear:
    lea  ebx, [esi - 1]
    mov  [ebx], ch
    mov  dl, ch
    jmp  .parse

.run:
    push argv
    push [argc]
    call main
.exit:
    xor  eax,eax
    dec  eax
    int  0x40
    dd	 -1
.crash:
    jmp  .exit
;============================
push_param:
;============================
;parameters
;  esi - pointer
;description
;  procedure increase argc
;  and add pointer to array argv
;  procedure changes ebx
    mov  ebx, [argc]
    cmp  ebx, max_parameters
    jae  .dont_add
    mov  [argv+4*ebx], esi
    inc  [argc]
.dont_add:
    ret


public argc as '__argc'
public params as '__argv'
public path as '__path'

section '.bss'
buf_len = 0x400
max_parameters=0x20
argc	 rd 1
argv	 rd max_parameters
path	 rb buf_len
params	 rb buf_len

;section '.data'
;include_debug_strings ; ALWAYS present in data section
