current_target = custom_target('media_kiv',
  input: ['kiv.asm'],
  output: 'kiv',
  command: [
    fasm, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
   env: {
    'INCLUDE': meson.source_root() + '/programs/develop/libraries/libs-dev/libimg'
    ,
  },
  build_by_default: true
)
