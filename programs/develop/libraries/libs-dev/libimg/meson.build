custom_target('libimg',
  input: ['libimg.asm'],
  output: 'libimg.obj',
  command: [
    fasm, '-m', '32768', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
   env: {
    'INCLUDE': meson.source_root() + '/programs;'
    + meson.source_root() + '/programs/develop/libraries/libs-dev/libio'
    ,
  },
  build_by_default: true
)
