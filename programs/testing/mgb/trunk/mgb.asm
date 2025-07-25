;=============================================================================
; Kolibri Graphics Benchmark 0.9
;--------------------------------------
; MGB - Menuet Graphics Benchmark 0.3
; Compile with FASM
;
;=============================================================================
; version:	0.9
; last update:  15/04/2019
; written by:   Kiril Lipatov aka Leency
; changes:      use big fonts, editing two comments, improve UI, show delta %
;               Russian translation by Daniel Ovchinnikov
;---------------------------------------------------------------------
; version:	0.82
; last update:  03/11/2014
; written by:   Marat Zakiyanov aka Mario79, aka Mario
; changes:      fix "benchmark GS selector" for 16bpp (support SVN r.5154)
;---------------------------------------------------------------------
; version:	0.81
; last update:  01/05/2014
; written by:   Marat Zakiyanov aka Mario79, aka Mario
; changes:      fix "benchmark GS selector" for some display sizes
;               (for example, 1366 by horizontal) and code optimization
;---------------------------------------------------------------------
; version:	0.8
; last update:  08/07/2013
; written by:   Marat Zakiyanov aka Mario79, aka Mario
; changes:      benchmark f4 with memory + f65
;---------------------------------------------------------------------
; version:	0.7
; last update:  05/04/2013
; written by:   Marat Zakiyanov aka Mario79, aka Mario
; changes:      benchmark GS selector - read screen area
;---------------------------------------------------------------------
; version:	0.6
; last update:  14/03/2013
; written by:   Marat Zakiyanov aka Mario79, aka Mario
; changes:      benchmark f36 - read screen area
;---------------------------------------------------------------------
; version:	0.5
; last update:  05/03/2013
; written by:   Marat Zakiyanov aka Mario79, aka Mario
; changes:      benchmark f73-blitter
;---------------------------------------------------------------------
; version:	0.4
; last update:  18/09//2010
; written by:   Marat Zakiyanov aka Mario79, aka Mario
; changes:      select path with OpenDialog,
;               use of Box_Lib and Proc_Lib,
;               support start with path for *.mgb file
;               optimization code and size of use memory
;---------------------------------------------------------------------
; Original author and copyrights holder:
;     Mikhail Lisovin a.k.a. Mihasik
;     lisovin@26.ru
;
; Disassembled with IDA 5.0.0.879:
;     http://www.datarescue.com/
; With use of 'ida.int' and 'kloader.ldw':
;     Eugene Grechnikov a.k.a. diamond
;     diamondz@land.ru
;     http://diamondz.land.ru/
;
; Modified for version 0.3:
;     Mike Semenako a.k.a mike.dld
;     mike.dld@gmail.com
;     http://www.mikedld.com/
;
;=============================================================================

org 0x0
use32

	db 'MENUET01'
	dd 1
	dd start
	dd IM_END
	dd I_END	;0x200000
	dd stacktop	;0x07FFF0
	dd fname_buf
	dd cur_dir_path

include '../../../config.inc'		;for nightbuild
include '../../../macros.inc'
include '../../../proc32.inc'
;include '../../../debug.inc'
include '../../../develop/libraries/box_lib/trunk/box_lib.mac'
include '../../../develop/libraries/box_lib/load_lib.mac'
include 'lang.inc'	;language support
	@use_library
;---------------------------------------------------------------------
start:
	mcall	68,11

	mcall	68,12,8+9*6*38*4	; 7352
	mov	[text_scren_buffer],eax

	mcall	68,12,8+9*6*38*4	; 8216
	mov	[text_scren_buffer2],eax

load_libraries l_libs_start,end_l_libs

	cmp	eax,-1
	jz	close
;---------------------------------------------------------------------
	mov	edi,filename_area
	mov	esi,start_temp_file_name
	call	copy_str_1

	mov	edi,comment_string_1
	mov	esi,aComment1
	call	copy_str_1

	mov	edi,comment_string_2
	mov	esi,aComment2
	call	copy_str_1

	mov	edi,fname_buf
	cmp	[edi],byte 0
	jne	@f
	mov	esi,path4
	call	copy_str_1
	jmp	.OpenDialog
@@:
	call	locLoadFile
	xor	dword [wFlags],1
.OpenDialog:
;OpenDialog	initialisation
	push	dword OpenDialog_data
	call	[OpenDialog_Init]
;---------------------------------------------------------------------
	mcall	40,0x80000027
red:
	call	draw_window
still:
	mcall	10
	cmp	eax,1
	jz	red
	cmp	eax,2
	jz	key
	cmp	eax,3
	jz	button
	jmp	still
;---------------------------------------------------------------------
copy_str_1:
	xor	eax,eax
	cld
@@:
	lodsb
	stosb
	test	eax,eax
	jnz	@b
	ret
;---------------------------------------------------------------------
key:
	mcall	2
	cmp	ah,'t'
	jz	ActionTest
	cmp	ah,'c'
	jz	ActionComment
	cmp	ah,'m'
	jz	ActionPatternMove
	cmp	ah,'o'
	jz	ActionOpen
	cmp	ah,'s'
	jz	ActionSave
	jmp	still
;---------------------------------------------------------------------
button:
	mcall	17
	cmp	ah,1
	jnz	NotClose
close:
	mcall	-1
NotClose:
	cmp	ah,2
	jnz	locNotTest
ActionTest:
	test	dword [wFlags],1
	jnz	still
	mcall	51,1,TestWndProc,thread_stack1
	jmp	still
;---------------------------------------------------------------------
locNotTest:
	cmp	ah,3
	jnz	NotComment
ActionComment:
	test	dword [wFlags],1
	jnz	still
	mcall	51,1,thread_comment,thread_stack2
	jmp	still
;---------------------------------------------------------------------
NotComment:
	cmp	ah,6
	jnz	NotPatternCopy
ActionPatternMove:
	test	dword [wFlags],1
	jnz	still
	mov	esi,results_table
	cld
@@:
	lodsd
	mov	[esi],eax
	add	esi,TEST_REC_SIZE-4
	cmp	dword [esi+TEST_REC_SIZE-4],0
	jne	@b
	mov	esi,comment_string_1
	mov	edi,comment_string_2
	call	copy_str_1
	call	DrawBars
	jmp	still
;---------------------------------------------------------------------
NotPatternCopy:
	cmp	ah,4
	jnz	NotOpen
ActionOpen:
	test	dword [wFlags],1
	jnz	still
	mov	[OpenDialog_data.type],0 ; open
	call	OpenDialog_Start_1
	jne	still
	call	locLoadFile
	call	DrawBars
.1:
	xor	dword [wFlags],1
	jmp	still
;---------------------------------------------------------------------
OpenDialog_Start_1:
	push    dword OpenDialog_data
	call	[OpenDialog_Start]
	cmp	[OpenDialog_data.status],1
	ret
;---------------------------------------------------------------------
NotOpen:
	cmp	ah,5
	jnz	still
ActionSave:
	test	dword [wFlags],1
	jnz	still
	mov	[OpenDialog_data.type],1 ; save
	call	OpenDialog_Start_1
	jne	still
	call	locSaveFile
	jmp	ActionOpen.1
;---------------------------------------------------------------------
TestWndProc:
	mcall	68,12,90*123*3
	mov	[area_for_f36],eax
	or	dword [wFlags],1
	mov	esi,results_table+8
align 4
.next_test:
	xor	edi,edi
	mcall	 26,9
	inc	eax
	mov	ecx,eax
	add	eax,100
	mov	[dwTestEndTime],eax
align 4
@@:
	mcall	 26
	cmp	eax,ecx
	jb	@r
align 4
@@:
	push	esi edi
	call	dword [esi]
	pop	edi esi
	inc	edi
	mcall	26,9
	cmp	eax,[dwTestEndTime]
	jb	@b
	mov	[esi-8],edi

	add	esi,TEST_REC_SIZE
	cmp	dword [esi], testDrawPicture_f73
	jnz	@f
	call	prepare_f73
@@:
	cmp	dword [esi],0
	jnz	.next_test
	xor	dword [wFlags],1
	mcall	68,13,[area_for_f36]
	mcall	-1
;---------------------------------------------------------------------
draw_window:
	mcall	12,1
	mcall	48,4
	mov	ebx,460*65536+(LINE_DESCRIPTION_CHARS+5)*8+16
	mov	ecx,80*65536+TESTS_NUM*(LINE_HEIGHT+2)+15+38
	add	cx,ax
	xor	eax,eax
	xor	esi,esi
	mcall	,,,34000000h,,aCaption

	mov	eax,8
	mov	ebx,20*65536+84
	mov	ecx,4*65536+24
	mov	edx,2
	mov	esi,0x00007F7F
@@:
	mcall
	add	ebx,96*65536
	inc	edx
	cmp	edx,7
	jb	@r

	mov	ecx,33
	mov	edx,0x00007F7F
	mov	esi,(LINE_DESCRIPTION_CHARS*8)/2+20
	call	drawSeparator

	mcall	4,<46,9>,0x90DDEEFF,aButtonsText
	call	DrawBars

	mov	ecx,TESTS_NUM*LINE_HEIGHT+15+23
	mov	edx,0x00007F7F
	mov	esi,(LINE_DESCRIPTION_CHARS*8)/2+20
	call	drawSeparator
	mcall	12,2
	ret
;---------------------------------------------------------------------
drawSeparator:
	mov	eax,1
	mov	ebx,3
@@:
	mcall
	add	ebx,2
	dec	esi
	jnz	@b
	ret
;---------------------------------------------------------------------
align 4
testDrawWindow:
	xor	eax,eax
	mcall	,640145h,4F0190h,3000000h
	ret
;---------------------------------------------------------------------
align 4
testDrawBar:
	mcall	13,0A0064h,1E00FAh,6A73D0h
	ret
;---------------------------------------------------------------------
align 4
testDrawPicture:
;	xor	ebx,ebx
	mcall	7,[area_for_f36],<90,123>,<15,33>
	ret
;---------------------------------------------------------------------
prepare_f73:
	mov	ecx, 90*123
	mov	eax, params_f73.data
	mov	ebx, [area_for_f36]
@@:
	mov	edx, [ebx]
	and	edx, 0xFFFFFF
	mov	[eax], edx
	add	ebx, 3
	add	eax, 4
	dec	ecx
	jnz	@b
	ret
align 4
testDrawPicture_f73:
	xor	ebx,ebx
	mcall	73,,params_f73
	ret
;---------------------------------------------------------------------
align 4
testGetScreen_f36:
	xor	ebx,ebx
	mcall	36,[area_for_f36],<90,123>,<15,33>
	ret
;---------------------------------------------------------------------
GS_start_x = 15
GS_start_y = 33
GS_size_x = 90
GS_size_y = 123
;-----------------------------------------------------------------------------
align 4
testGetScreen_GS:
	push	edi
	mov	edi,[area_for_f36]

	mcall	61,2
	cmp	eax,24
	je	get_area_with_GS_24

	cmp	eax,16
	je	get_area_with_GS_16
;-----------------------------------------------------------------------------
align 4
get_area_with_GS_32:
	mcall	61,3
	mov	ebx,eax

	mov	esi,GS_start_y
	imul	esi,eax

	mov	eax,GS_start_x
	shl	eax,2
	add	esi,eax

	mov	ebp,GS_size_x
	mov	eax,ebp
	shl	eax,2
	sub	ebx,eax

	mov	edx,GS_size_y
	sub	esi,ebx
;--------------------------------------
align 4
.start_y:
	add	esi,ebx
	mov	ecx,ebp
;--------------------------------------
align 4
.start_x:
	mov	eax,[gs:esi]
	mov	[edi],eax
	add	esi,4
	add	edi,3

        dec     ecx
        jnz     .start_x

        dec     edx
        jnz     .start_y

	pop	edi
	ret
;-----------------------------------------------------------------------------
align 4
get_area_with_GS_24:
	mcall	61,3
	mov	ebx,eax

	mov	esi,GS_start_y
	imul	esi,eax

	mov	eax,GS_start_x
	lea	eax,[eax*3]
	add	esi,eax

	mov	ebp,GS_size_x
	mov	eax,ebp
	lea	eax,[eax*3]
	sub	ebx,eax

	mov	edx,GS_size_y
	sub	esi,ebx
;--------------------------------------
align 4
.start_y:
	add	esi,ebx
	mov	ecx,ebp
;--------------------------------------
align 4
.start_x:
	mov	eax,[gs:esi]
	mov	[edi],eax
	add	esi,3
	add	edi,3

        dec     ecx
        jnz     .start_x

        dec     edx
        jnz     .start_y

	pop	edi
	ret
;-----------------------------------------------------------------------------
align 4
get_area_with_GS_16:
	mcall	61,3
	mov	ebx,eax

	mov	esi,GS_start_y
	imul	esi,eax

	mov	eax,GS_start_x
	shl	eax,1
	add	esi,eax

	mov	ebp,GS_size_x
	mov	eax,ebp
	shl	eax,1
	sub	ebx,eax

	mov	edx,GS_size_y
	sub	esi,ebx
;--------------------------------------
align 4
.start_y:
	add	esi,ebx
	mov	ecx,ebp
;--------------------------------------
align 4
.start_x:
	xor	eax,eax
	mov	ax,[gs:esi]
        shl     eax, 3
        ror     eax, 8
        shl     ax, 2
        ror     eax, 8
        shl     al, 3
        rol     eax, 16
	mov	[edi],eax
	add	esi,2
	add	edi,3

        dec     ecx
        jnz     .start_x

        dec     edx
        jnz     .start_y

	pop	edi
	ret
;-----------------------------------------------------------------------------
align 4
testDrawVertLine:
	mcall	38,<300,300>,<30,380>,1090207Fh
	ret
;---------------------------------------------------------------------
align 4
testDrawHorzLine:
	mcall	38,<30,300>,<380,380>,1090207Fh
	ret
;---------------------------------------------------------------------
align 4
testDrawFreeLine:
	mcall	38,<30,300>,<380,30>,1090207Fh
	ret
;---------------------------------------------------------------------
align 4
testDrawText1:
	mcall	4,<12,300>,0x0000AA66,aTestText,34
	ret
;---------------------------------------------------------------------
align 4
testDrawText1m:
	mov	eax,[text_scren_buffer]
	mov	[eax],dword 6*34
	mov	[eax+4],dword 9
	mcall	4,<0,0>,0x0800AA66,aTestText,34,[text_scren_buffer]
	xor	ebp,ebp
	mov	ebx,[text_scren_buffer]
	add	ebx,8
	mcall	65,,<6*34,9>,<18,309>,32
	ret
;---------------------------------------------------------------------
align 4
testDrawText2:
	mcall	4,<27,315>,0x10E7B850,aTestText,34
	ret
;---------------------------------------------------------------------
align 4
testDrawText2m:
	mov	eax,[text_scren_buffer2]
	mov	[eax],dword 6*38
	mov	[eax+4],dword 9
	mcall	4,<0,0>,0x18E7B850,aTestText,34,[text_scren_buffer2]
	xor	ebp,ebp
	mov	ebx,[text_scren_buffer2]
	add	ebx,8
	mcall	65,,<6*38,9>,<33,324>,32
	ret
;---------------------------------------------------------------------
align 4
testDrawNumber:
	mcall	47,0x80000,12345678,<42,333>,0x0E0B27B
	ret
;---------------------------------------------------------------------
align 4
testDrawPixel:
	mcall	1,100,100,0FFFFFFh
	ret
;---------------------------------------------------------------------
DrawBars:
	mov	edi,results_table
	mov	ebx,30+7
.next_result:
	cmp	dword[edi+TEST_REC_SIZE-4],0
	je	.exit

	push	ebx
	movzx	ecx,bx
	add	ecx,-2
	shl	ecx,16
	mov	cx,LINE_HEIGHT
	mov	ebx,0*65536+LINE_DESCRIPTION_CHARS*8+5
	xor	edx,edx
	mcall	13
	pop	ebx

	and	ebx,0x0000FFFF
	or	ebx,5*65536
	mov	edx,[edi+TEST_REC_SIZE-4]
	mcall	4,,0x9000CCCC

	push	'=' 0x00FFFF00 0x00FFFF7F 0x00FFFF7F
	mov	eax,[edi+0]
	cmp	eax,[edi+4]
	je	@f
	jb	.lp1
	mov	dword[esp+0],0x007FFF7F
	mov	dword[esp+4],0x00FF7F7F
	mov	dword[esp+8],0x0000FF00
	mov	byte[esp+12],'>'
.lp1:
	ja	@f
	mov	dword[esp+0],0x00FF7F7F
	mov	dword[esp+4],0x007FFF7F
	mov	dword[esp+8],0x00FF0000
	mov	byte[esp+12],'<'
@@:
	pop	ecx
	call	int2str
	add	ebx,(LINE_DESCRIPTION_CHARS*8-8*8*2-20)*65536 ; 196
	add ecx,0x10000000 ;big font
	mcall	4,,,textarea,8

	pop	ecx
	mov	eax,[edi+4]
	call	int2str
	add	ebx,(6*8+26)*65536
	add ecx,0x10000000 ;big font
	mcall	4

	;pop	ecx
	;add	ebx,(-15)*65536
	;mov	edx,esp
	;mov	esi,1
	;add ecx,0x10000000 ;big font
	;mcall


	; draw difference
	pop ecx
	add ecx,0x10000000 ;big font

	pusha
	mov esi,ecx
	mov eax,[edi+0]
	mov ecx,[edi+4]
	cmp ecx,0
	je .difference_end ; no div by zero
	imul eax,100
	xor edx,edx
	div ecx
	mov ecx, eax
	sub ecx,100
	mov	[sign],'+'
	cmp ecx,0
	jge @f             ; no need to invert positive rumber
	neg ecx
	mov	[sign],'-'
	@@:
	cmp ecx,1          ; do not show <=1% results
	jle .difference_end
	cmp ecx,100        ; do not show >=100% results
	je .difference_end

	push ecx esi
	add	ebx,(10*8)*65536
	mov ecx,esi
	mov edx,sign
	mov	esi,1
	mcall	4
	pop esi ecx

	add	ebx,(1*8)*65536
	mov edx,ebx
	mcall	47, 10000000000001000000000000000000b

  .difference_end:
	popa

	add	esp,4

	add	edi,TEST_REC_SIZE
	add	bx,LINE_HEIGHT
	jmp	.next_result
.exit:


	mov	ebx, 0*65536+LINE_DESCRIPTION_CHARS*8+5
	mov	ecx, (TESTS_NUM*LINE_HEIGHT+15+27)*65536+LINE_HEIGHT*2
	xor	edx, edx
	mcall	13

	mov	ebx, 5*65536+(TESTS_NUM*LINE_HEIGHT+15+27)
	mcall	4,,0x9000CCCC,aLeft

	add	ebx, (8*10)*65536
	mcall	,,0x90FFFF00,comment_string_1

	mov	ebx, 5*65536+(TESTS_NUM*LINE_HEIGHT+15+27+LINE_HEIGHT)
	mcall	,,0x9000CCCC,aRight

	add	ebx, (8*10)*65536
	mcall	,,0x90FFFF00,comment_string_2
	ret
;---------------------------------------------------------------------
int2str:
	push	eax ecx edx edi
	mov	edi,textarea+7
	mov	dword[textarea+0],'    '
	mov	dword[textarea+4],'    '
	mov	ecx,10
@@:
	xor	edx,edx
	div	ecx
	add	dl,'0'
	mov	[edi],dl
	dec	edi
	or	eax,eax
	jnz	@b
	pop	edi edx ecx eax
	ret
;---------------------------------------------------------------------
thread_comment:
	or	dword [wFlags],1
	mcall	40,0x80000027
	mov	esi,comment_string_1
	cld
@@:
	lodsb
	test	al,al
	jne	@r
	sub	esi,comment_string_1
	mov	eax,esi
	dec	eax
	mov	edi, edit1
	mov	[edi+48], eax	;ed_size
	mov	[edi+52], eax	;ed_pos

	mov	esi,comment_string_2
	cld
@@:
	lodsb
	test	al,al
	jne	@r
	sub	esi,comment_string_2
	mov	eax,esi
	dec	eax
	mov	edi, edit2
	mov	[edi+48], eax	;ed_size
	mov	[edi+52], eax	;ed_pos

	;---------------------------------------------------------------------
.red:
	call .draw_window
.still:
	mcall	10	; wait here for event
	cmp	eax,1	; redraw request ?
	je	.red
	cmp	eax,2	; key in buffer ?
	je	.key
	cmp	eax,3	; button in buffer ?
	je	.button

	push	dword edit1
	call	[edit_box_mouse]
	push	dword edit2
	call	[edit_box_mouse]
	jmp	.still
;---------------------------------------------------------------------
.key:		; key
	mcall	2
	cmp	ah,13
	je	.close	;.close_with_open_file
	cmp	ah,27
	je	.close

	push	dword edit1
	call	[edit_box_key]
	push	dword edit2
	call	[edit_box_key]
	jmp	.still
;---------------------------------------------------------------------
.button:		; button
	mcall	17
	cmp	ah,1	; button id=1 ?
	jne	.still
.close:
	xor	dword [wFlags],1
	mcall	-1
;---------------------------------------------------------------------
.draw_window:
	mcall	12,1
	xor	eax,eax
	xor	esi,esi
	mcall	,<110,300>,<120,120>,0x34C0C0C0,,aCommentT ; 0x34780078
	push	dword edit1
	call	[edit_box_draw]
	push	dword edit2
	call	[edit_box_draw]
	mcall	12,2
	ret
;---------------------------------------------------------------------
locLoadFile:
	mov	[stFileInfoBlock], 0
	or	dword [wFlags],1
	mcall	70,stFileInfoBlock
	mov	esi,mgb_data
	mov	edi,results_table+4
	cld
@@:
	cmp	dword[edi+TEST_REC_SIZE-8],0
	je	@f
	movsd
	add	edi,TEST_REC_SIZE-4
	jmp	@b
@@:
	mov	edi,comment_string_2
	mov	ecx,44
	rep	movsb
	ret
;---------------------------------------------------------------------
locSaveFile:
	mov	[stFileInfoBlock], 2
	or	dword [wFlags],1
	mov	esi,results_table ;+4 to save Right Bar
	mov	edi,mgb_data
	cld
@@:
	cmp	dword[esi+TEST_REC_SIZE-8],0
	je	@f
	movsd
	add	esi,TEST_REC_SIZE-4
	jmp	@b
@@:
	mov	esi,comment_string_2
	mov	ecx,44
	rep	movsb
	mcall	70,stFileInfoBlock
	ret
;---------------------------------------------------------------------
align 4
stFileInfoBlock dd 0,0,0
dwDataSize	dd TESTS_NUM*4+44	;1
		dd mgb_data
		db 0
		dd fname_buf
;---------------------------------------------------------------------
wFlags		dd 0
;---------------------------------------------------------------------
align 4
results_table dd \
	?,?,testDrawWindow,aDrawingWindow,\
	?,?,testDrawBar,aDrawingBar,\
	?,?,testGetScreen_f36,aGetScreenF36,\
	?,?,testGetScreen_GS,aGetScreen_GS,\
	?,?,testDrawPicture,aDrawingPicture,\
	?,?,testDrawPicture_f73,aDrawingPictF73,\
	?,?,testDrawVertLine,aDrawingVLine,\
	?,?,testDrawHorzLine,aDrawingHLine,\
	?,?,testDrawFreeLine,aDrawingFLine,\
	?,?,testDrawText1,aDrawingText1,\
	?,?,testDrawText1m,aDrawingText1m,\
	?,?,testDrawText2,aDrawingText2,\
	?,?,testDrawText2m,aDrawingText2m,\
	?,?,testDrawNumber,aDrawingNumber,\
	?,?,testDrawPixel,aDrawingPixel,\
	0,0,0,0
;---------------------------------------------------------------------
LINE_HEIGHT   = 17
TEST_REC_SIZE = 16
LINE_DESCRIPTION_CHARS = 58
TESTS_NUM     = ($ - results_table) / TEST_REC_SIZE - 1
;---------------------------------------------------------------------
if lang eq it_IT
	aDrawingWindow	db 'Window Of Type #3, 325x400 px',0
	aDrawingBar	db 'Filled Rectangle, 100x250 px',0
	aDrawingPicture db 'Picture, 90x123, px',0
	aDrawingPictF73	db 'Picture for Blitter, 90x123, px',0
	aGetScreenF36	db 'Get a piece of screen f.36, 90x123, px',0
	aGetScreen_GS	db 'Get a piece of screen GS, 90x123, px',0
	aDrawingVLine	db 'Linea verticale, 350 px',0
	aDrawingHLine	db 'Linea orizzontale, 270 px',0
	aDrawingFLine	db 'Free-angled Line, 350 px',0
	aDrawingText1	db 'Fixed-width Text, 34 chars',0
	aDrawingText1m	db 'Fixed-width Text(m), 34 chars',0
	aDrawingText2	db 'Proportional Text, 34 chars',0
	aDrawingText2m	db 'Proportional Text(m), 34 chars',0
	aDrawingNumber	db 'Decimal Number, 8 digits',0
	aDrawingPixel	db 'Singolo pixel',0

	aTestText    db 'This is a 34-charachters test text'
	aButtonsText db 'Test      Commenti      Apri        Salva      Move >',0
	aCaption     db 'Kolibri Graphical Benchmark 0.9',0

	aLeft	db 'Sinistra:',0
	aRight	db 'Destra  :',0

	aComment1	db 'Attuale test',0
	aComment2	db 'previous test',0
	aCommentT	db 'Commenti',0
else if lang eq ru_RU
	aDrawingWindow  db '���⥬��� ���� � ᪨���, 325x400 px',0
	aDrawingBar     db '����襭�� ��אַ㣮�쭨�, 100x250 px',0
	aDrawingPicture db '���⨭��, 90x123, px',0
	aDrawingPictF73 db '���⨭�� ��� ������, 90x123, px',0
	aGetScreenF36   db '�⥭�� ��࠭� �� ����������, 90x123, px',0
	aGetScreen_GS   db '�⥭�� ��࠭� �� ����������, 90x123, px',0
	aDrawingVLine   db '����訩 ����, 350 px',0
	aDrawingHLine   db '����訩 ����, 270 px',0
	aDrawingFLine   db '����⥭㧠, 350 px',0
	aDrawingText1   db '���⥬�� ⥪�� �����쪨�, 34 �����',0
	aDrawingText1m  db '���⥬�� ⥪�� �����쪨� (���), 34 �����',0
	aDrawingText2   db '���⥬�� ⥪�� ����让, 34 �����',0
	aDrawingText2m  db '���⥬�� ⥪�� ����让 (���), 34 �����',0
	aDrawingNumber  db '�����筮� �᫮, 8 ���',0
	aDrawingPixel   db '������� ���ᥫ�',0

	aTestText    db 'This is a 34-charachters test text'
	aButtonsText db '����      ��������    �� 䠩��     � 䠩�     ��ࠢ� >',0
	aCaption     db '����᪨� ���笠� ��� ������ v0.9',0

	aLeft	db '�����:',0
	aRight	db '��ࠢ�:',0

	aComment1	db '��� ���',0
	aComment2	db '�।��騩 ���',0
	aCommentT	db '������஢��� �������ਨ',0
else
	aDrawingWindow	db 'Window Of Type #3, 325x400 px',0
	aDrawingBar	db 'Filled Rectangle, 100x250 px',0
	aDrawingPicture db 'Picture, 90x123, px',0
	aDrawingPictF73	db 'Picture for Blitter, 90x123, px',0
	aGetScreenF36	db 'Get a piece of screen f.36, 90x123, px',0
	aGetScreen_GS	db 'Get a piece of screen GS, 90x123, px',0
	aDrawingVLine	db 'Vertical Line, 350 px',0
	aDrawingHLine	db 'Horizontal Line, 270 px',0
	aDrawingFLine	db 'Free-angled Line, 350 px',0
	aDrawingText1	db 'Fixed-width Text, 34 chars',0
	aDrawingText1m	db 'Fixed-width Text(mem), 34 chars',0
	aDrawingText2	db 'Proportional Text, 34 chars',0
	aDrawingText2m	db 'Proportional Text(mem), 34 chars',0
	aDrawingNumber	db 'Decimal Number, 8 digits',0
	aDrawingPixel	db 'Single Pixel',0

	aTestText    db 'This is a 34-charachters test text'
	aButtonsText db 'Test      Comments      Open        Save       Move >',0
	aCaption     db 'Kolibri Graphical Benchmark 0.9',0

	aLeft	db 'Left    :',0
	aRight	db 'Right   :',0

	aComment1	db 'current test',0
	aComment2	db 'previous test',0
	aCommentT	db 'Edit comments',0
end if
;---------------------------------------------------------------------
system_dir_Boxlib	db '/sys/lib/box_lib.obj',0
system_dir_ProcLib	db '/sys/lib/proc_lib.obj',0
;---------------------------------------------------------------------
head_f_i:
if lang eq it_IT
	head_f_l	db 'Errore Sistema',0
else
	head_f_l	db 'System error',0
end if

err_message_found_lib1	db 'box_lib.obj - Not found!',0
err_message_found_lib2	db 'proc_lib.obj - Not found!',0

err_message_import1	db 'box_lib.obj - Wrong import!',0
err_message_import2	db 'proc_lib.obj - Wrong import!',0
;---------------------------------------------------------------------
align 4
l_libs_start:

library01  l_libs system_dir_Boxlib+9, cur_dir_path, library_path, system_dir_Boxlib, \
err_message_found_lib1, head_f_l, Box_lib_import, err_message_import1, head_f_i

library02  l_libs system_dir_ProcLib+9, cur_dir_path, library_path, system_dir_ProcLib, \
err_message_found_lib2, head_f_l, ProcLib_import, err_message_import2, head_f_i

end_l_libs:
;---------------------------------------------------------------------
align 4
OpenDialog_data:
.type			dd 1	; Save
.procinfo		dd procinfo	;+4
.com_area_name		dd communication_area_name	;+8
.com_area		dd 0	;+12
.opendir_pach		dd temp_dir_pach	;+16
.dir_default_pach	dd communication_area_default_pach	;+20
.start_path		dd open_dialog_path	;+24
.draw_window		dd draw_window	;+28
.status			dd 0	;+32
.openfile_pach 		dd fname_buf	;+36
.filename_area		dd filename_area	;+40
.filter_area		dd Filter
.x:
.x_size			dw 420 ;+48 ; Window X size
.x_start		dw 10 ;+50 ; Window X position
.y:
.y_size			dw 320 ;+52 ; Window y size
.y_start		dw 10 ;+54 ; Window Y position

communication_area_name:
	db 'FFFFFFFF_open_dialog',0
open_dialog_path:
if __nightbuild eq yes
	db '/sys/MANAGERS/opendial',0
else
	db '/sys/fs/opendial',0
end if
communication_area_default_pach:
	db '/sys/',0

Filter:
dd	Filter.end - Filter
.1:
db	'MGB',0
.end:
db	0

sign db ?,0

start_temp_file_name:	db 'results.mgb',0

path4	db '/sys/results.mgb',0
;---------------------------------------------------------------------
align 4
params_f73:
; destination
.offset_X_dest	dd 0	; +0
.offset_Y_dest	dd 0	; +4
.width_dest	dd 90	; +8
.height_dest	dd 123	; +12
; source
.offset_X_src	dd 0	; +16
.offset_Y_src	dd 0	; +20
.width_src	dd 90	; +24
.height_src	dd 123	; +28
; other
.pointer	dd .data; 90*4	; +32
.row_size	dd 90*4	; +36
;---------------------------------------------------------------------
align 4
ProcLib_import:
OpenDialog_Init		dd aOpenDialog_Init
OpenDialog_Start	dd aOpenDialog_Start
;OpenDialog__Version	dd aOpenDialog_Version
	dd 0,0
aOpenDialog_Init	db 'OpenDialog_init',0
aOpenDialog_Start	db 'OpenDialog_start',0
;aOpenDialog_Version	db 'Version_OpenDialog',0
;---------------------------------------------------------------------
align 4
Box_lib_import:
;init_lib		dd a_init
;version_lib		dd a_version


edit_box_draw		dd aEdit_box_draw
edit_box_key		dd aEdit_box_key
edit_box_mouse		dd aEdit_box_mouse
;version_ed		dd aVersion_ed

;check_box_draw		dd aCheck_box_draw
;check_box_mouse	dd aCheck_box_mouse
;version_ch		dd aVersion_ch

;option_box_draw	dd aOption_box_draw
;option_box_mouse	dd aOption_box_mouse
;version_op		dd aVersion_op

;scrollbar_ver_draw	dd aScrollbar_ver_draw
;scrollbar_ver_mouse	dd aScrollbar_ver_mouse
;scrollbar_hor_draw	dd aScrollbar_hor_draw
;scrollbar_hor_mouse	dd aScrollbar_hor_mouse
;version_scrollbar	dd aVersion_scrollbar

;dinamic_button_draw	dd aDbutton_draw
;dinamic_button_mouse	dd aDbutton_mouse
;version_dbutton	dd aVersion_dbutton

;menu_bar_draw		dd aMenu_bar_draw
;menu_bar_mouse		dd aMenu_bar_mouse
;menu_bar_activate	dd aMenu_bar_activate
;version_menu_bar	dd aVersion_menu_bar

;FileBrowser_draw	dd aFileBrowser_draw
;FileBrowser_mouse	dd aFileBrowser_mouse
;FileBrowser_key	dd aFileBrowser_key
;Version_FileBrowser	dd aVersion_FileBrowser

;PathShow_prepare	dd sz_PathShow_prepare
;PathShow_draw		dd sz_PathShow_draw
;Version_path_show	dd szVersion_path_show
			dd 0,0

;a_init			db 'lib_init',0
;a_version		db 'version',0

aEdit_box_draw		db 'edit_box_draw',0
aEdit_box_key		db 'edit_box_key',0
aEdit_box_mouse		db 'edit_box_mouse',0
;aVersion_ed		db 'version_ed',0

;aCheck_box_draw	db 'check_box_draw',0
;aCheck_box_mouse	db 'check_box_mouse',0
;aVersion_ch		db 'version_ch',0

;aOption_box_draw	db 'option_box_draw',0
;aOption_box_mouse	db 'option_box_mouse',0
;aVersion_op		db 'version_op',0

;aScrollbar_ver_draw	db 'scrollbar_v_draw',0
;aScrollbar_ver_mouse	db 'scrollbar_v_mouse',0
;aScrollbar_hor_draw	db 'scrollbar_h_draw',0
;aScrollbar_hor_mouse	db 'scrollbar_h_mouse',0
;aVersion_scrollbar	db 'version_scrollbar',0

;aDbutton_draw		db 'dbutton_draw',0
;aDbutton_mouse		db 'dbutton_mouse',0
;aVersion_dbutton	db 'version_dbutton',0

;aMenu_bar_draw		db 'menu_bar_draw',0
;aMenu_bar_mouse		db 'menu_bar_mouse',0
;aMenu_bar_activate	db 'menu_bar_activate',0
;aVersion_menu_bar	db 'version_menu_bar',0

;aFileBrowser_draw	db 'FileBrowser_draw',0
;aFileBrowser_mouse	db 'FileBrowser_mouse',0
;aFileBrowser_key	db 'FileBrowser_key',0
;aVersion_FileBrowser	db 'version_FileBrowser',0

;sz_PathShow_prepare	db 'PathShow_prepare',0
;sz_PathShow_draw	db 'PathShow_draw',0
;szVersion_path_show	db 'version_PathShow',0
;---------------------------------------------------------------------
; for EDITBOX
align 4
editboxes:
edit1 edit_box 260,12,15,0xffffff,0xbbddff,0xFF00FF,0x7F7F7F,\
	0x90000000,43,comment_string_1,0,ed_focus,0
edit2 edit_box 260,12,50,0xffffff,0xbbddff,0xFF00FF,0x7F7F7F,\
	0x90000000,43,comment_string_2,0,0,0
editboxes_end:
;---------------------------------------------------------------------

IM_END:
align 4
area_for_f36	rd 1
dwTestEndTime	rd 1
dwMainPID	rd 1
;-----------------------------------------------------------------------------
text_scren_buffer	rd 1
text_scren_buffer2	rd 1
;---------------------------------------------------------------------
textarea:
	rb 8
;---------------------------------------------------------------------
comment_string_1:
	rb 44
;---------------------------------------------------------------------
comment_string_2:
	rb 44
;---------------------------------------------------------------------
mgb_data:
	rb 100
;---------------------------------------------------------------------
procinfo:
	rb 1024
;---------------------------------------------------------------------
cur_dir_path:
	rb 4096
;---------------------------------------------------------------------
library_path:
	rb 4096
;---------------------------------------------------------------------
temp_dir_pach:
	rb 4096
;---------------------------------------------------------------------
fname_buf:
	rb 4096
;---------------------------------------------------------------------
filename_area:
	rb 256
;---------------------------------------------------------------------
align 4
	rb 4096
thread_stack2:
;---------------------------------------------------------------------
align 4
	rb 4096
thread_stack1:
;---------------------------------------------------------------------
align 4
	rb 4096
stacktop:
params_f73.data	rb 123*90*4
I_END:
