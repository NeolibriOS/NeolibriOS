current_target = custom_target('sys_setup',
  input: ['setup.asm'],
  output: 'setup',
  command: [
    fasm, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
