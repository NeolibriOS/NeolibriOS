current_target = custom_target('proc_lib',
  input: ['proc_lib.asm'],
  output: 'proc_lib.obj',
  command: [
    fasm, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
