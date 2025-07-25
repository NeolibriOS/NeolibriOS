   ; Run with OpenDialog ;/sys/fs/opendial

org 0
use32

STACK_SIZE     equ 256
REDRAW_EVENT   equ 1
KEY_EVENT      equ 2
BUTTON_EVENT   equ 3
MOUSE_EVENT    equ 6

BUTTON_RUN     equ 10
BUTTON_BROWSE  equ 20

MENUET01       db 'MENUET01'
version        dd 1
program.start  dd start_
program.end    dd data_
program.memory dd end_ + STACK_SIZE
program.stack  dd end_ + STACK_SIZE
program.params dd 0
program.path   dd 0

include 'lang.inc'
include '../../develop/libraries/box_lib/trunk/box_lib.mac'

; ======================================================================= ;
start_:
        mov byte [file_info], 7
; set.event
	mov eax, 40
	mov ebx, 39
	int 64

	push sz_box_lib
	call load.library
	mov [box_lib], eax

	push dword[box_lib]
	push sz_edit_box
	call getprocaddress
	mov [edit_box_draw], eax

	push dword[box_lib]
	push sz_edit_box_key
	call getprocaddress
	mov [edit_box_key], eax

	push dword[box_lib]
	push sz_edit_box_mouse
	call getprocaddress
	mov [edit_box_mouse], eax

	push dword[box_lib]
	push sz_edit_box_set_text
	call getprocaddress
	mov [edit_box_set_text], eax

	push sz_proc_lib
	call load.library
	mov [proc_lib], eax

	push dword[proc_lib]
	push sz_OpenDialog_init
	call getprocaddress
	mov [opendialog_init], eax

	push dword[proc_lib]
	push sz_OpenDialog_start
	call getprocaddress
	mov [opendialog_start], eax


; memory.allocate:
	mov eax, 68
	mov ebx, 12
	mov ecx, 4096 + 4096 + 4096
	int 64

	mov [od.procinfo], eax

	add eax, 1024
	mov [od.filename_area], eax

	add eax, 4096 - 1024
	mov [od.opendir_path], eax

	add eax, 4096
	mov [od.openfile_path], eax

	push od
	call [opendialog_init]


; get.screen.size
	mov eax, 61
	mov ebx,  1
	int 64

	mov [screen], eax
	movzx eax,  word[screen.width]
	shr   eax, 3
	lea   eax, [eax*2 + eax]
	add   eax, 90
	mov [window.width], eax

; skin.height
	mov eax, 48
	mov ebx, 4
	int 64

	add eax, 100
	mov [window.height], eax

	movzx eax,  word[screen.width]
	sub   eax, [window.width]
	shr   eax, 1
	mov [window.left], eax

	movzx eax,  word[screen.height]
	sub   eax, [window.height]
	sub   eax, 100
	mov [window.top], eax

	mov eax, [window.width]
	sub eax, 80
	mov [edit1.width], eax

	mov eax, [od.openfile_path]
	mov [edit1.text], eax


	call on_redraw
; ----------------------- ;
.loop:
; wait.event
	mov eax, 10
	int 64
	cmp eax, REDRAW_EVENT
	jne .check_key
	call on_redraw
	jmp .loop
; ----------------------- ;
.check_key:
	cmp eax, KEY_EVENT
	jne .check_button
	mov eax, 2
	int 64
	cmp ah, 13
	jne .no_key_enter
	call on_button_run
	jmp .loop
; ----------------------- ;
.no_key_enter:
	cmp ah, 185
	jne .no_key_insert
	call on_button_browse
	jmp .loop
.no_key_insert:
	push edit1
	call [edit_box_key]
	jmp .loop
; ----------------------- ;
.check_button:
	cmp eax, BUTTON_EVENT
	jne .check_mouse
; get.button.number
	mov eax, 17
	int 64
	cmp ah, 1
	jne .check_button_run
; program.terminate
	or eax, -1
	int 64
; ----------------------- ;
.check_button_run:
	cmp ah, BUTTON_RUN
	jne .check_button_browse
	call on_button_run
	jmp .loop
; ----------------------- ;
.check_button_browse:
	cmp ah, BUTTON_BROWSE
	jne .loop
	call on_button_browse
	jmp .loop
; ----------------------- ;
.check_mouse:
	cmp eax, MOUSE_EVENT
	jne .loop
	push edit1
	call [edit_box_mouse]
	jmp .loop


; ======================================================================= ;
on_button_run:
	push dword[edit1.text]
	call extractrunpathandparams

;file.run:
	mov eax, 70
	mov ebx, file_info
	int 64

	mov    dl, byte[lastendpath]
	mov   ecx, [ptrlastendpath]
	mov [ecx], dl

	test eax, eax
	jnge .error
	mov [runresult], dword sz_Program_run_successfully
	jmp .exit

.error:
; ----------------------- ;
.5:
	cmp al, -5
	jne .31
	mov [runresult], dword sz_File_not_found
	jmp .exit
; ----------------------- ;
.31:
	cmp al, -31
	jne .32
	mov [runresult], dword sz_File_is_not_executable
	jmp .exit
; ----------------------- ;
.32:
	cmp al, -32
	jne .10
	mov [runresult], dword sz_Too_many_processes
	jmp .exit
; ----------------------- ;
.10:
	cmp al, -10
	jne .30
	mov [runresult], dword sz_Access_denied
	jmp .exit
; ----------------------- ;
.30:
	cmp al, -30
	jne .unknown
	mov [runresult], dword sz_Out_of_memory
	jmp .exit
; ----------------------- ;
.unknown:
	mov [runresult], dword sz_Unknown_error
; ----------------------- ;
.exit:
	call on_redraw
	ret

; ======================================================================= ;
on_button_browse:
	push od
	call [opendialog_start]

	mov eax, [od.status]
	test eax, eax
	je .exit

;======== if space exist in filepath, then quote filepath
	mov eax, [od.openfile_path]
; ----------------------- ;
.check_space:
	cmp [eax], byte 0
	je .no_space
	cmp [eax], byte 32 ;space
	je .space
	inc eax
	jmp .check_space
.space:
; ----------------------- ;
.find_end_zero:
	inc eax
	cmp [eax], byte 0
	jne .find_end_zero
	mov [eax + 2], byte 0
	mov [eax + 1], byte 34 ; quote
; ----------------------- ;
.shift_path:
	dec eax

	mov dl, byte [eax ]
	mov [eax + 1], dl

	cmp eax, [od.openfile_path]
	jne .shift_path
	mov [eax ], byte 34 ; quote

.no_space:
;=================================

	push dword[od.openfile_path]
	push edit1
	call [edit_box_set_text]
; ----------------------- ;
.exit:
	ret


; ======================================================================= ;
on_redraw:
; redraw.start
	mov eax, 12
	mov ebx, 1
	int 64
; get.standart.colors
	mov eax, 48
	mov ebx, 3
	mov ecx, sc
	mov edx, 40
	int 64

	mov eax, [sc.work_graph]
	mov [edit1.shift_color], eax

	mov eax, [sc.work_graph]
	mov [edit1.focus_border_color], eax

	mov eax, [sc.frames]
	mov [edit1.blur_border_color], eax

	mov eax, [sc.work_text]
        bts eax, 28
	mov [edit1.text_color], eax

; draw.window
	xor eax, eax
	mov ebx, [window.left]
	shl ebx, 16
	add ebx, [window.width]
	mov ecx, [window.top]
	shl ecx, 16
	add ecx, [window.height]
	mov edx, [sc.work]
	or  edx, 34000000h
	mov edi, title
	int 64

	push 5
	push 5
	push sz_Type_name_of_program
	push dword [sc.work_text]
	call draw.text
; ====================| browse button |====================
	push 20
	mov  eax, [window.width]
	sub  eax, 70
	push eax
	push 26
	push 52
	push 21
	call draw.button

	mov  eax, [window.width]
	sub  eax, 56
	push eax
	push 29
	push sz_browse
	push dword [sc.work_button_text]
	call draw.text
; ====================| run button |====================
	push 10
	push 5
	push 52
	mov  eax, [window.width]
	sub  eax, 22
        push eax
	push 21
	call draw.button

	mov  eax, [window.width]
        shr  eax, 1
        sub  eax, 40
	push eax
	push 55
	push sz_run
	push dword [sc.work_button_text]
	call draw.text
 ; =====================================================
	push 5
	push 80
	push dword[runresult]
	push dword [sc.work_text]
	call draw.text

	push edit1
	call [edit_box_draw]

; redraw.finish
	mov eax, 12
	mov ebx, 2
	int 64

	ret


; ======================================================================= ;
extractrunpathandparams:
	xor ecx, ecx

	mov eax, [esp + 4]
	mov [runpath], eax

	movzx eax, byte [eax]
	cmp eax, 34
	jne .start_without_quote

	inc ecx
; ----------------------- ;
.loop1:
	mov eax, [runpath]
	movzx eax, byte [eax + ecx]
	cmp eax, 34
	jne .not_quote

	mov eax, [runpath]
	mov [eax + ecx], byte 0

	mov eax, [runpath]
	add eax, ecx
	mov [ptrlastendpath], eax
	mov [lastendpath], byte 34
	inc ecx
; ----------------------- ;
.skip_space1:
	mov eax, [runpath]
	movzx eax, byte [eax + ecx]
	cmp al, 32
	jne .skipped1
	inc ecx
	jmp .skip_space1
; ----------------------- ;
.skipped1:
	mov eax, [runpath]
	add eax, ecx
	mov [runparams], eax
	inc dword [runpath]
	jmp .exit
; ----------------------- ;
.not_quote:
	mov eax, [runpath]
	movzx eax, byte [eax + ecx]

	test eax, eax
	jne .not_zero1
	mov eax, [runpath]
	add eax, ecx
	mov [runparams], eax
	mov eax, [runpath]
	add eax, ecx
	mov [ptrlastendpath], eax
	mov [lastendpath], byte 0
	jmp .exit
; ----------------------- ;
.not_zero1:
	inc ecx
	jmp .loop1
; ----------------------- ;
.start_without_quote:
; ----------------------- ;
.loop2:
	mov eax, [runpath]
	movzx eax, byte [eax + ecx]
	cmp eax, 32
	jne .not_space

	mov eax, [runpath]
	mov [eax + ecx], byte 0

	mov eax, [runpath]
	add eax, ecx
	mov [ptrlastendpath], eax
	mov [lastendpath], byte 32
	inc ecx
; ----------------------- ;
.skip_space2:
	mov eax, [runpath]
	movzx eax, byte [eax + ecx]
	cmp al, 32
	jne .skipped2
	inc ecx
	jmp .skip_space2
; ----------------------- ;
.skipped2:
	mov eax, [runpath]
	add eax, ecx
	mov [runparams], eax
	jmp .exit
; ----------------------- ;
.not_space:
	mov eax, [runpath]
	movzx eax, byte [eax + ecx]

	test eax, eax
	jne .not_zero2
	mov eax, [runpath]
	add eax, ecx
	mov [runparams], eax
	mov eax, [runpath]
	add eax, ecx
	mov [ptrlastendpath], eax
	mov [lastendpath], byte 0
	jmp .exit
; ----------------------- ;
.not_zero2:
	inc ecx
	jmp .loop2
; ----------------------- ;
.exit:
	ret 4

; ======================================================================= ;
draw.button:
	mov eax, 8
	mov ebx, [esp + 16]
	shl ebx, 16
	add ebx, [esp + 8]
	mov ecx, [esp + 12]
	shl ecx, 16
	add ecx, [esp + 4]
	mov edx, [esp + 20]
	mov esi, [sc.work_button]
	int 64
	ret 20
; ======================================================================= ;
draw.text:
	mov eax, 4
	mov ebx, [esp + 16]
	shl ebx, 16
	add ebx, [esp + 12]
	mov ecx, [esp + 4]
        or  ecx, 90000000h
	mov edx, [esp + 8]
	int 64
	ret 16
; ======================================================================= ;
load.library:
	mov eax, 68
	mov ebx, 19
	mov ecx, [esp + 4]
	int 64
	ret 4
; ======================================================================= ;
getprocaddress:
	mov  edx, [esp + 8] ; hlib
	xor  eax, eax
	test edx, edx ; If hlib = 0 then goto .end
	jz  .end
; ----------------------- ;
.next:
	cmp  [edx], dword 0 ; If end of export table then goto .end
	jz  .end

	xor  eax, eax
	mov  esi, [edx]
	mov  edi, [esp + 4] ; name
; ----------------------- ;
.next_:
	lodsb
	scasb
	jne  .fail
	or   al, al
	jnz  .next_
	jmp  .ok
; ----------------------- ;
.fail:
	add  edx, 8
	jmp  .next
; ----------------------- ;
.ok:		   ; return address
	mov  eax, [edx + 4]
; ----------------------- ;
.end:
	ret 8

data_:

sz_box_lib              db "/sys/lib/box_lib.obj",0
sz_edit_box             db "edit_box",0
sz_edit_box_key         db "edit_box_key",0
sz_edit_box_mouse       db "edit_box_mouse",0
sz_edit_box_set_text    db "edit_box_set_text",0

sz_proc_lib             db "/sys/lib/proc_lib.obj",0
sz_OpenDialog_init      db "OpenDialog_init",0
sz_OpenDialog_start     db "OpenDialog_start",0
sz_FFFFFFFF_open_dialog db "FFFFFFFF_open_dialog",0
sz_SYS                  db "/sys",0
sz_opendial_path        db "/sys/File managers/opendial",0

if lang eq it_IT
	sz_Program_run_successfully db "Programma eseguito correttamente",0
	sz_File_not_found           db "File non trovato",0
	sz_File_is_not_executable   db "File non eseguibile",0
	sz_Too_many_processes       db "Troppi processi",0
	sz_Access_denied            db "Accesso negato",0
	sz_Out_of_memory            db "Out of memory",0
	sz_Unknown_error            db "Errore sconosciuto",0
	sz_Type_name_of_program     db "Digita il nome del programma per eseguirlo",0
	sz_run                      db " Esegui",0
	sz_browse                   db "Browse",0
	title                       db "Esegui",0
else if lang eq ru_RU
	sz_Program_run_successfully db "�ணࠬ�� ����饭� �ᯥ譮",0
	sz_File_not_found           db "���� �� ������",0
	sz_File_is_not_executable   db "���� �� ���� �ᯮ��塞�",0
	sz_Too_many_processes       db "���誮� ����� ����ᮢ",0
	sz_Access_denied            db "����� ����饭",0
	sz_Out_of_memory            db "�������筮 �����",0
	sz_Unknown_error            db "�������⭠� �訡��",0
	sz_Type_name_of_program     db "������ �������� �ணࠬ��",0
	sz_run                      db "��������",0
	sz_browse                   db "...",0
	title                       db "����� �ணࠬ��",0
else
	sz_Program_run_successfully db "Program run successfully",0
	sz_File_not_found           db "File not found",0
	sz_File_is_not_executable   db "File is not executable",0
	sz_Too_many_processes       db "Too many processes",0
	sz_Access_denied            db "Access denied",0
	sz_Out_of_memory            db "Out of memory",0
	sz_Unknown_error            db "Unknown error",0
	sz_Type_name_of_program     db "Type name of program to run",0
	sz_run                      db "   Run",0
	sz_browse                   db "...",0
	title                       db "Run",0
end if

align 4
od:
.mode           dd  0
.procinfo       dd  0
.com_area_name  dd  sz_FFFFFFFF_open_dialog
.com_area       dd  0
.opendir_path   dd  0
.dir_default_path   dd  sz_SYS
.start_path     dd  sz_opendial_path
.draw_window    dd  on_redraw
.status         dd  0
.openfile_path  dd  0
.filename_area  dd  0
.filter_area    dd  filefilter
.x_size         dw  414
.x_start        dw  0
.y_size         dw  414
.y_start        dw  0

runresult   dd  sz_empty

edit1 edit_box 0, 5, 26, 0ffffffh, 0, 0, 0, 0, 4096, 0, 0, 4002h

box_lib     dd  ?
proc_lib    dd  ?
filefilter      dd  ?
ptrlastendpath  dd  ?
edit_box_draw   dd  ?
edit_box_key    dd  ?
edit_box_mouse  dd  ?
edit_box_set_text   dd  ?
opendialog_init     dd  ?
opendialog_start    dd  ?

sc:
.frames         dd  ?
.grab           dd  ?
.grab_button    dd  ?
.grab_button_text   dd  ?
.grab_text      dd  ?
.work           dd  ?
.work_button    dd  ?
.work_button_text   dd  ?
.work_text      dd  ?
.work_graph     dd  ?

window:
.left   dd  ?
.top    dd  ?
.width  dd  ?
.height dd  ?

screen:
.height dw  ?
.width  dw  ?

file_info:
	dd  ?
	dd  ?
runparams:
	dd  ?
	dd  ?
	dd  ?
	db  ?
runpath:
	dd  ?

lastendpath db  ?
sz_empty    db  ?

align 4
end_:
