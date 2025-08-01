current_target = custom_target('develop_cobj',
  input: ['cobj.asm'],
  output: 'cobj',
  command: [
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
