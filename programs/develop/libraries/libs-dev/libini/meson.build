custom_target('libini',
  input: ['libini.asm'],
  output: 'libini.obj',
  command: [
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
