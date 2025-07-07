lang = get_option('lang')

current_target = custom_target('fs_kfar',
  input: ['kfar.asm'],
  output: 'kfar',
  command: [
    fasm, '-dlang=' + lang, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
