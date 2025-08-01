current_target = custom_target('lib_console',
  input: ['console.asm', 'conscrl.inc', 'conscrlv.bmp', 'font.inc', 'font8x16.bmp'],
  output: 'console.obj',
  command: [
    fasm, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
