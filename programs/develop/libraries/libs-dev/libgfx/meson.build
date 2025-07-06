current_target = custom_target('libgfx',
  input: ['libgfx.asm'],
  output: 'libgfx.obj',
  command: [
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
