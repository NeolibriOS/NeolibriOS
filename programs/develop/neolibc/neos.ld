OUTPUT_FORMAT("binary")
ENTRY(start)
SECTIONS
{
  .text 0x000000:
   {
    *(.text)
   }

  .data : {
    *(.data)
    hEnd = . ;
   }

  .bss :
   {
    *(.bss)
   }
   Memory = . ;
}
