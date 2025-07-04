current_target = custom_target('drivers_ps2mouse',
  input: ['ps2mouse.asm'],
  output: 'ps2mouse.sys',
  command: [
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    'EXENAME=' + '@OUTPUT@', fasm, pestrip, '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
