current_target = custom_target('lib_sort',
  input: ['sort.asm'],
  output: 'sort.obj',
  command: [
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
