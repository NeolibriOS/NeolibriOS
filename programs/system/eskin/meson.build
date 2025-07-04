current_target = custom_target('sys_eskin',
  input: ['eskin.asm'],
  output: 'eskin',
  depends: [target_libini],
  command: [
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
