current_target = custom_target('skins_gnome_green',
  input: ['default.asm', 'default.dtp.asm'],
  output: 'gnome_green.skn',
  command: [
    fasm,  '@INPUT1@', 'default.dtp', '&&',
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
