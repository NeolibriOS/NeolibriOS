custom_target('skins_shkvorka',
  input: ['default.asm', 'colors.dtp.asm'],
  output: 'shkvorka.skn',
  command: [
    fasm,  '@INPUT1@', 'colors.dtp', '&&',
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
