custom_target('libio',
  input: ['libio.asm'],
  output: 'libio.obj',
  command: [
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
