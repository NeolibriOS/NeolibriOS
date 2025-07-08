current_target = custom_target('zsea_cnv_png',
  input: ['cnv_png.asm'],
  output: 'cnv_png.obj',
  command: [
    fasm, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
