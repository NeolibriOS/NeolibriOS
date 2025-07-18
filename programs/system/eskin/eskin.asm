 use32          
        org     0x0          
          
        db      'MENUET01'      ; 8 byte id          
        dd      38              ; required os          
        dd      STARTAPP        ; program start          
        dd      I_END           ; program image size          
        dd      0x1000000       ; required amount of memory          
        dd      0x1000000       ; stack heap          
        dd      0x0 
        dd      0x0          
                   
include '../../proc32.inc'          
include '../../macros.inc'          
include '../../dll.inc'          

          
PATH_MAX equ 255          

STARTAPP:          
    ; Initialize heap
    mcall   68, 11        
    ; Import libraries          
    stdcall dll.Load,importTable
    
	; Set button style: flat or gradient (3D)
    invoke  ini_get_int, aIni, aSection, aButtonStyle, 0
    mov ecx, eax
    mcall 48, 1

	; Set desktop background
    invoke  ini_get_str, aIni, aSection, aBgProgram, sz_app, PATH_MAX, 0
    invoke  ini_get_str, aIni, aSection, aBgParam, sz_param, PATH_MAX, 0
	
	cmp     byte[sz_param], '\' ;detecting KIV param like '\S__/path/to/img'
	jne     @f

	m2m     dword [ReadFile.path], sz_param+4
	call    check_file_exists

@@:
    mcall   70, RunApp
            
	; Set system skin
    invoke  ini_get_str, aIni, aSection, aSkinPath, sz_param, PATH_MAX, 0
	cmp     byte [sz_param], 0 ;no need to set skin if it was not specified
	je      @f
	
	m2m     dword [ReadFile.path], sz_param
	call    check_file_exists
	
    mcall   48, 8, sz_param          
@@:
	; Exit app
    mcall   -1

;----------------------------------------------------------------
; This is fix for files located at /kolibrios and /usbhd drives
; It checks is the file exists for 5 times with perioud 1 second
check_file_exists:
	mov     edi, 0
@@:
	mcall   70, ReadFile
	cmp     eax,0
	je      .exit
	mcall   5, 100
	inc     edi
	cmp     edi, 5
	jle     @b
.exit:
	ret
;----------------------------------------------------------------
        
importTable:          
library                                                 \          
        libini, 'libini.obj'          
          
import  libini, \          
        ini_get_str  ,'ini_get_str', \          
        ini_get_int  ,'ini_get_int'       
          
RunApp:
        dd      7     ; subfunction number          
        dd      0     ; position in the file in bytes          
        dd      sz_param  ; upper part of the position address          
        dd      0     ; number of bytes to read          
        dd      0     ; pointer to the buffer to write data          
        db      0          
        dd      sz_app ; pointer to the filename

ReadFile:
        dd      0     ; subfunction number          
        dd      0     ; position in the file in bytes          
        dd      0     ; upper part of the position address          
        dd      4     ; number of bytes to read          
        dd      buf   ; pointer to the buffer to write data  
		db      0          		
.path   dd      ?     ; pointer to the filename
buf rb 4
         
aIni          db  '/sys/settings/system.ini',0          
aSection      db  'style',0

aBgProgram    db  'bg_program',0
aBgParam      db  'bg_param',0          
aButtonStyle  db  'buttons_gradient',0
aSkinPath     db  'skin',0

sz_app:
    rb        PATH_MAX
sz_param:          
    rb        PATH_MAX
          
I_END:                ; End of application code and data marker          
        
