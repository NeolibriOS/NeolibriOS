custom_target('sys_launcher',
  input: ['launcher.asm'],
  output: 'launcher',
  command: [
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
