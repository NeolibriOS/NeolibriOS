current_target = custom_target('fs_opendial',
  input: ['opendial.asm'],
  output: 'opendial',
  command: [
    fasm, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
