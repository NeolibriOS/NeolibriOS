
DELTA_COLOR	equ 70
COLOR_SEL_BUT	equ 00F7092Dh
MAX_USER_BUTTONS equ 30

;---- thread for rbutton -----------------------------------------------------------------------
RButtonWin:
	mcall	40,100101b	;SetMaskMessage 100101b
	mcall	48,3,sc,40

	mov	eax,[sc.work]	  ;����塞 梥� ᢥ⫥� 䮭�����
	rol	eax,16
	add	al,DELTA_COLOR
	jnc	@f
	mov	al,0FFh
      @@:
	rol	eax,16
	add	al,DELTA_COLOR
	jnc	@f
	mov	al,0FFh
      @@:
	add	ah,DELTA_COLOR
	jnc	@f
	mov	ah,0FFh
      @@:
	mov	[sc.workH],eax

	mov	eax,[sc.work]	  ;����塞 梥� ⥬��� 䮭�����
	rol	eax,16
	sub	al,DELTA_COLOR
	jnc	@f
	mov	al,0FFh
      @@:
	rol	eax,16
	sub	al,DELTA_COLOR
	jnc	@f
	mov	al,0FFh
      @@:
	sub	ah,DELTA_COLOR
	jnc	@f
	mov	ah,0FFh
      @@:
	mov	[sc.workL],eax



	stdcall GetNumIcon,[MouseX],[MouseY],-1
	mov	[SelIcon],eax

		      ;���⠢�塞 ��ࢮ��砫�� ���祭��
	m2m	[RMenuW],[MinRMenuW]

	cmp	[SelIcon],-1
	jne	.RBW1
;----------- �᫨ ���� �� �� ������ ------------------------------------------------
	mov	[NumMenuButt],0

	mcall	70,fiIni
	mcall	68,12,dword[bufIni+32]	;�뤥�塞 ������ ��� �����ᥩ � ��⥩ ����᪠
	mov	[RBMenuCP],eax		;GetUserBut ����� ��� ��ࢮ��砫�� 㪠��⥫� �� ������
	stdcall [ini_enum_keys],IconIni,secRButt,GetUserBut

	mov	ebx,[NumMenuButt]
	add	[NumMenuButt],4

	mov	[RBMenuCP+ebx*8],RMenuRedrawFon
	mov	[RBMenuCP+ebx*8+8],RMenuAlign
	cmp	[bFixIcons],1
	je	@f
	mov	[RBMenuCP+ebx*8+16],RMenuOffMoving
	jmp	.RBW11
    @@:
	mov	[RBMenuCP+ebx*8+16],RMenuOnMoving
    .RBW11:

	mov	[RBMenuCP+ebx*8+24],RMenuAdd

	mov	[RBMenuCP+ebx*8+4],0
	mov	[RBMenuCP+ebx*8+8+4],0
	mov	[RBMenuCP+ebx*8+16+4],0
	mov	[RBMenuCP+ebx*8+24+4],0


	jmp	.RBW2
;----------- �᫨ ���� �� ������ ------------------------------------------------
.RBW1:
	xor	ebx,ebx
	mov	[NumMenuButt],5

	mov	[RBMenuCP+ebx*8],RMenuRedrawFon
	mov	[RBMenuCP+ebx*8+8],RMenuAlign
	cmp	[bFixIcons],1
	je	@f
	mov	[RBMenuCP+ebx*8+16],RMenuOffMoving
	jmp	.RBW21
    @@:
	mov	[RBMenuCP+ebx*8+16],RMenuOnMoving
    .RBW21:
	mov	[RBMenuCP+ebx*8+24],RMenuDel
	mov	[RBMenuCP+ebx*8+32],RMenuProp

	mov	[RBMenuCP+ebx*8+4],0
	mov	[RBMenuCP+ebx*8+8+4],0
	mov	[RBMenuCP+ebx*8+16+4],0
	mov	[RBMenuCP+ebx*8+24+4],0
	mov	[RBMenuCP+ebx*8+32+4],0

;-------------------------------------------------------------------------------
.RBW2:

	cmp	[SelIcon],-1
	jne	@f
	mov	eax,[NumMenuButt]
	shl	eax,4
	mov	[RMenuH],ax
	jmp	.rbw1
      @@:
	mov	[RMenuH],16*5
    .rbw1:

	add	[RMenuW],3		;�� ࠬ��
	add	[RMenuH],3		;�� ࠬ��

RBWRedraw:
	mcall	12,1	;RedrawWinBeg
	mov	ebx,[MouseX]
	shl	ebx,16
	mov	bx,[RMenuW]

	mov	ecx,[MouseY]
	shl	ecx,16
	mov	cx,[RMenuH]

	mov	edx,01000000h
	mov	esi,01000000h
	xor	eax,eax
	int	40h

	and	ebx,0FFFFh	;䮭��� ��אַ㣮�쭨�
	inc	bx
	and	ecx,0FFFFh
	inc	cx
	mcall	13,,,[sc.work]

       ;----------- ��।��塞 � ��㥬 ������
	mov	ecx,[NumMenuButt]
  .DrawUB:
	push	ecx

		mov	eax,[NumMenuButt]
	sub	eax,ecx
	mov	edx,eax      ;button ID = �� 0 �� NumMenuButt
	or	edx,60000000h
	shl	eax,4+16	  ;*16*10000h
	mov	ecx,eax
	mov	cx,16

	xor	ebx,ebx
	mov	bx,[RMenuW]
	mov	esi,[sc.work]
	mcall	8			;��।�����

	mov	ebx,70000h
	shr	ecx,16
	mov	bx,cx
	add	bx,7

	mov	ecx,[sc.work_text]
	or	ecx,80000000h

	mov	eax,[NumMenuButt]
	sub	eax,[esp]
	mov	edx,[RBMenuCP+eax*8]
	mcall	4


	pop	ecx
	loop	.DrawUB
  ;---------------

; ��ࠬ���騩 ��אַ㣮�쭨�
	xor	ebx,ebx 	   ;����
	mov	bx,[RMenuW]
	xor	ecx,ecx
	mcall	38,,,[sc.workL]

	mov	bx,[RMenuW]	    ;�ࠢ�
	shl	ebx,16
	mov	bx,[RMenuW]
	xor	ecx,ecx
	mov	cx,[RMenuH]
	mcall

	xor	ebx,ebx 		 ;���
	mov	bx,[RMenuW]
	mov	cx,[RMenuH]
	shl	ecx,16
	mov	cx,[RMenuH]
	mcall

	xor	ebx,ebx 	      ;����
	xor	ecx,ecx
	mov	cx,[RMenuH]
	mcall


; ᢥ�� ���� ���孨� 㣮�
	xor	ebx,ebx
	mov	bx,[RMenuW]
	add	ebx,1*10000h-1
	mov	ecx,00010001h
	mcall	 ,,,[sc.workH]

	mov	ebx,00010001h
	xor	ecx,ecx
	mov	cx,[RMenuH]
	add	ecx,1*10000h-1
	mcall


;����� �ᮢ����
	mcall	12,2	;RedrawWinEnd
;-------------------------------------------------------------------

	mcall	9,RBProcInfo,-1 	;GetThreadInfo RBProcInfo,-1
	mcall	18,21,dword[RBProcInfo+30]
	m2m	dword[RBSlot],eax

RBWMessages:
	mcall	10		;WaitMessage
	dec	eax
	jz	RBWRedraw
	sub	eax,2
	jz	RBWButton
	sub	eax,3
	jz	RBWMouse
	jmp	RBWMessages

RBWButton:
	mcall	17		;GetButtonPressed
	shr	eax,8

	mov	ebx,eax
	mov	eax,[RBMenuCP+ebx*8+4] ;�᫨ ᤥ�� 0, � ���� �� �⠭���⭮� ������(����� �� � ini)
	test	eax,eax
	jnz	.RBWB
	mov	eax,[RBMenuCP+ebx*8]  ;ᬮ�ਬ, 㪠��⥫� �� ����� ������� � ������
	cmp	eax,RMenuRedrawFon		    ; � �� ��� �롨ࠥ� ����⢨�
	jz	RBRedrawFon
	cmp	eax,RMenuAlign
	jz	RBAlign
	cmp	eax,RMenuOffMoving
	jz	RBFixIcons
	cmp	eax,RMenuOnMoving
	jz	RBFixIcons
	cmp	eax,RMenuAdd
	jz	RBAdd
	cmp	eax,RMenuDel
	jz	RBDelete
	cmp	eax,RMenuProp
	jz	RBPropeties

	jmp	RBWExit
   .RBWB:
	mov	dword[fiRunProg+8],0
	mov	dword[fiRunProg+21],eax
	mcall	70,fiRunProg

	jmp	RBWExit

RBWMouse:
	call	MouseInWin
	jnc	.RBWMnoInWin	      ;�᫨ ��� ����, � ���� ����⠭�������� �।����� ������

	mcall	37,1	      ;��������� ��� �⭮�⥫쭮 ����
	and	eax,0FFF0h	;�㦥� ⮫쪮 Y, ���� ���㣫�� �� ���孥� �窨 ��⭮� 16(���� ������)
	cmp	[PredItem],eax
	je	.RBWMendLightBut

	shr	eax,4		   ;�᫨ ���� �� ������ ࠬ��, � ⠪�� ⮫쪮 ����⠭����� �।����� ������
	cmp	eax,[NumMenuButt]
	jae	.RBWMnoInWin

	cmp	[PredItem],-1	   ;����⠭������� �।��饩 ������
	je	@f

	stdcall DrawRBLine,[PredItem],0

      @@:

	call	MouseInWin
	jnc	@f
	mcall	37,1	      ;��������� ��� �⭮�⥫쭮 ����
	and	eax,0FFF0h	;�㦥� ⮫쪮 Y, ���� ���㣫�� �� ���孥� �窨 ��⭮� 16(���� ������)
	mov	[PredItem],eax
	stdcall DrawRBLine,eax,1

      @@:
	jmp	.RBWMendLightBut


  .RBWMnoInWin:
	cmp	[PredItem],-1	   ;����⠭������� �।��饩 ������
	je	.RBWMendLightBut

	stdcall DrawRBLine,[PredItem],0
	mov	[PredItem],-1

  .RBWMendLightBut:
	mcall	37,2		;GetMouseKey
	test	eax,111b
	jz	RBWMessages

	call	MouseInWin
	jc	RBWMessages

RBWExit:
	cmp	[SelIcon],-1
	jne	@f
	mcall	68,13,[RBMenuCP]			;�᢮������� ������ � ������ﬨ � ���ﬨ � �ண��
      @@:
	mov	[RButtonActiv],0
	mcall	-1	;ExitProcess


RBRedrawFon:
	mcall	15,3
	jmp	RBWExit

RBAlign:
	call	AlignIcons

	m2m	[PIcoDB],[BegData]
	stdcall [ini_enum_sections],IconIni,Ini_SavePos

	mov	dword[fiRunProg+8],WarningSave
	mov	dword[fiRunProg+21],pthNotify
	mcall	70,fiRunProg
	mov	[bNotSave],0

	jmp	RBRedrawFon

RBFixIcons:
	xor	dword[bFixIcons],1

	cmp	[bNotSave],0
	je	@f

	mov	dword[fiRunProg+8],WarningSave
	mov	dword[fiRunProg+21],pthNotify
	mcall	70,fiRunProg
	mov	[bNotSave],0

      @@:
	jmp	RBWExit

RBAdd:
	cmp	[DlgAddActiv],1
	je	RBWSetActivWin
	mov	[DlgAddActiv],1

	mcall	51,1,DlgAdd,stack_dlg		;CreateThread DlgAdd,stack_dlg
	jmp	RBWExit

RBDelete:
	mov	eax,[SelIcon]
	lea	eax,[IconsID+eax*4]
	stdcall [ini_del_section],IconIni,eax

	stdcall DelIcon,[SelIcon]
	mov	ebx,[SelIcon]
	lea	edi,[IconsID+ebx*4]
	lea	esi,[edi+4]
	mov	ecx,[MaxNumIcon]
	sub	ecx,[SelIcon]
;dph ecx
	test	ecx,ecx
	jz	@f
	rep movsd
     @@:
;debug_newline
;dpsP IconsID+4*0
;dps ' '
;dpsP IconsID+4*1
;dps ' '
;dpsP IconsID+4*2
;dps ' '
;dpsP IconsID+4*3
;dps ' '
;dpsP IconsID+4*4
;dps ' '
;dpsP IconsID+4*5
;dps ' '
;dpsP IconsID+4*6
;dps ' '
;dpsP IconsID+4*7
;dps ' '
;dpsP IconsID+4*8
;dps ' '
;dpsP IconsID+4*9
;dps ' '
;dpsP IconsID+4*10
;dps ' '
;dpsP IconsID+4*11
;dps ' '
;dpsP IconsID+4*12
;dps ' '
;dpsP IconsID+4*13
;dps ' '
;dpsP IconsID+4*14
;dps ' '
;dpsP IconsID+4*15
;dps ' '
;dpsP IconsID+4*16
;dps ' '
;dpsP IconsID+4*17
;debug_newline


	mov	dword[fiRunProg+8],WarningSave
	mov	dword[fiRunProg+21],pthNotify
	mcall	70,fiRunProg
	mov	[bNotSave],0

	jmp	RBRedrawFon

RBPropeties:
	cmp	[DlgAddActiv],1
	je	RBWSetActivWin
	mov	[DlgAddActiv],1

	mcall	51,1,DlgProp,stack_dlg		;CreateThread DlgProp,stack_dlg
	jmp	RBWExit

RBWSetActivWin:
	mcall	18,3,[slotDlgAdd]
	jmp	RBWExit

proc DrawRBLine y,active

	xor	ebx,ebx
	mov	bx,[RMenuW]
	add	ebx,2*10000h-3
	mov	ecx,[y]
	add	ecx,2
	shl	ecx,16
	mov	cx,16;-1-2
	cmp	[active],1
	jne	@f
	mov	edx,[sc.work_button]
	jmp	.L1
       @@:
	mov	edx,[sc.work]
      .L1:
	mcall	13

;----------------------------------------------
	xor	ebx,ebx 	   ;����
	mov	bx,[RMenuW]
	add	ebx,2*10000h-3
	mov	cx,word[y]
	shl	ecx,16
	mov	cx,word[y]
	add	ecx,00020002h

	cmp	[active],1
	jne	@f
	mov	edx,[sc.workL]
	jmp	.L3
       @@:
	mov	edx,[sc.work]
      .L3:

	mcall	38

	mov	ebx,00020002h		 ;����
	mov	cx,word[y]
	shl	ecx,16
	mov	cx,word[y]
	add	ecx,00020002h+16

	cmp	[active],1
	jne	@f
	mov	edx,[sc.workL]

       @@:

	mcall

	xor	ebx,ebx 		 ;���
	mov	bx,[RMenuW]
	add	ebx,2*10000h-3
	mov	cx,word[y]
	shl	ecx,16
	mov	cx,word[y]
	add	ecx,16*10000h+16+00020002h

	cmp	[active],1
	jne	@f
	mov	edx,[sc.workH]
       @@:

	mcall

	mov	bx,[RMenuW]		    ;�ࠢ�
	shl	ebx,16
	mov	bx,[RMenuW]
	add	ebx,-2*10000h-2
	mov	cx,word[y]
	shl	ecx,16
	mov	cx,word[y]
	add	ecx,00020002h+16

	cmp	[active],1
	jne	@f
	mov	edx,[sc.workH]
       @@:

	mcall

	mov	eax,[y]
	shr	eax,4
	mov	edx,[RBMenuCP+eax*8]

	xor	ebx,ebx
	mov	ebx,[y]
	add	ebx,7*10000h+7

	cmp	[active],1
	jne	@f
	mov	ecx,[sc.work_button_text]
	jmp	.L2
       @@:
	mov	ecx,[sc.work_text]
      .L2:

	or	ecx,80000000h

	mcall	4

	ret
endp

proc MouseInWin        ;Carry flag = 1, �᫨ ���� � ����
	mcall	37,0		;GetMousePos
	xor	ebx,ebx
	mov	bx,ax		;y
	shr	eax,16		;x

	xor	ecx,ecx
	mov	cx,bx
	mov	bx,ax

	mcall	34
	cmp	eax,[RBSlot]
	jne	@f
	stc
	ret
      @@:
	clc
	ret
endp

proc AlignIcons
local posX:WORD,\
      posY:WORD,\
      negatX:WORD,\
      negatY:WORD

	xor	ebx,ebx

	mov	ecx,[MaxNumIcon]
	test	ecx,ecx
	jnz	.AlignIco
	ret
 .AlignIco:
	push	ecx
	or	ecx,-1
	mov	edi,dword[IconsOffs+ebx]
	xor	eax,eax
	repne	scasb
	repne	scasb
	repne	scasb
	repne	scasb

	mov	dword[negatX],0

     ;-------- �८�ࠧ㥬 ���न���� � ������⥫��
	mov	ax,[edi+2]
	test	ax,8000h
	jz	@f
	neg	ax
	mov	word[negatX],1
      @@:
	mov	[posX],ax

	mov	ax,[edi]
	test	ax,8000h
	jz	@f
	neg	ax
	mov	word[negatY],1
      @@:
	mov	[posY],ax

      ;-----
	mov	ax,[posY]
	mov	dx,ALIGN_SIZE

	cmp	ax,dx
	jb	.AI0
    @@: sub	ax,dx
	cmp	ax,dx
	jae	@b
    .AI0:

	mov	dx,ax
	cmp	dx,ALIGN_SIZE/2
	jb	.AI1

	mov	ax,ALIGN_SIZE
	sub	ax,dx
	add	[posY],ax

	jmp	.AI2
     .AI1:
	sub	[posY],dx
     .AI2:
     ;-----
	mov	ax,[posX]
	mov	dx,ALIGN_SIZE

	cmp	ax,dx
	jb	.AI3
    @@: sub	ax,dx
	cmp	ax,dx
	jae	@b
    .AI3:

	mov	dx,ax
	cmp	dx,ALIGN_SIZE/2
	jb	.AI4

	mov	ax,ALIGN_SIZE
	sub	ax,dx
	add	[posX],ax

	jmp	.AI5
     .AI4:
	sub	[posX],dx
     .AI5:

      ;----- �८�ࠧ������ ����� � ���ࠢ�� � ����⥫��� ���न���
	mov	ax,[posX]

	cmp	[negatX],1
	jne	@f
	neg	ax
	inc	ax
	jmp	.AI6
      @@:

	mov	dx,[wsW]
	shr	dx,1
	add	dx,[wsX]
	cmp	ax,dx
	jbe	.AI6
	sub	ax,[wsW]
      .AI6:
	mov	word[edi+2],ax


	mov	ax,[posY]
	cmp	[negatY],1
	jne	@f
	neg	ax
	inc	ax
	jmp	.AI7
      @@:

	mov	dx,[wsH]
	shr	dx,1
	add	dx,[wsY]
	cmp	ax,dx
	jbe	.AI7
	sub	ax,[wsH]
      .AI7:
	 mov	 word[edi],ax

       ;--------



	pop	ecx
	add	ebx,4
	dec	ecx
	jnz	.AlignIco
;        loop    .AlignIco


;        mov     dword[fInfo],2
;        mcall   70,fInfo
	ret
endp

;-------------------------------------------------------------------------------
proc GetUserBut stdcall,f_name,sec_name,key_name,key_value
	cmp	[NumMenuButt],MAX_USER_BUTTONS
	jne	@f
	ret
     @@:

	push	ebx esi edi

	mov	edi,[key_name]		 ;��।��塞 �ਭ� ����
	xor	eax,eax
	or	ecx,-1
	repne	scasb
	sub	edi,[key_name]
	mov	eax,edi
	shl	eax,1
	lea	eax,[eax*2+eax+5*2]
	cmp	ax,[RMenuW]
	jbe	@f
	mov	[RMenuW],ax
     @@:

	mov	ebx,[NumMenuButt]

	mov	esi,[key_name]
	mov	edi,[RBMenuCP+ebx*8]
    @@: lodsb
	stosb
	test	al,al
	jnz	@b


	mov	[RBMenuCP+ebx*8+4],edi
	mov	esi,[key_value]
    @@: lodsb
	stosb
	test	al,al
	jnz	@b

	mov	[RBMenuCP+ebx*8+8],edi

	inc	[NumMenuButt]

	pop	edi esi ebx
	mov	eax,1
	ret
endp

proc Ini_SavePos stdcall,f_name,sec_name
	push	ebx edi esi

	mov	ebx,[sec_name]
	xor	eax,eax
	mov	ax,[ebx]

	xor	ebx,ebx
  .SearchSect:
	cmp	eax,[IconsID+ebx*4]
	je	.IcoDataFound

	inc	ebx
	cmp	ebx,[MaxNumIcon]
	jb	.SearchSect

	mov	eax,1
	pop	esi edi ebx
	ret

.IcoDataFound:
	xor	al,al
	mov	edi,[IconsOffs+ebx*4]

	or	ecx,-1
	repne	scasb
	repne	scasb
	repne	scasb
	repne	scasb

	movzx	eax,word[edi]
	test	eax,8000h
	jz	@f
	or	eax,0FFFF0000h
     @@:

	stdcall [ini_set_int],[f_name],[sec_name],keyY,eax

	movzx	eax,word[edi+2]

	test	eax,8000h
	jz	@f
	or	eax,0FFFF0000h
     @@:

	stdcall [ini_set_int],[f_name],[sec_name],keyX,eax

	mov	eax,1
	pop	esi edi ebx
	ret
endp



