current_target = custom_target('lib_dll',
  input: ['dll.asm', 'dll.inc', 'external.inc', 'strhlp.inc', 'strings.rus'],
  output: 'dll.obj',
  command: [
    fasm, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
