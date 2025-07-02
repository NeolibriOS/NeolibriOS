custom_target('box_lib',
  input: ['box_lib.asm'],
  output: 'box_lib.obj',
  command: [
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
