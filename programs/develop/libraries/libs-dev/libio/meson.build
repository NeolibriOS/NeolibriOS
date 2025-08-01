current_target = custom_target('libio',
  input: ['libio.asm', 'libio_p.asm', 'libio_p.inc', 'libio.inc'],
  output: 'libio.obj',
  command: [
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
