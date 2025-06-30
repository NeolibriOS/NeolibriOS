custom_target('sys_loaddrv',
  input: ['loaddrv.asm'],
  output: 'loaddrv',
  command: [
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
