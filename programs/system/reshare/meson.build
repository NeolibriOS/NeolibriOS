current_target = custom_target('reshare',
  input: ['reshare.asm', 'chbox.inc'],
  output: 'reshare',
  command: [
    fasm, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
   env: {
    'INCLUDE': meson.source_root() + '/programs;'
    + meson.source_root() + '/programs/develop/libraries/libs-dev/libimg'
    ,
  },
  build_by_default: true
)
