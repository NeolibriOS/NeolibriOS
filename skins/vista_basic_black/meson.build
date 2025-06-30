custom_target('skins_vista_basic_black',
  input: ['default.asm', 'default.dtp.asm'],
  output: 'vista_basic_black.skn',
  command: [
    fasm,  '@INPUT1@', 'default.dtp', '&&',
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
