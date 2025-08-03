current_target = custom_target('lib_http',
  input: ['http.asm', 'http.inc'],
  output: 'http.obj',
  command: [
    fasm, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
