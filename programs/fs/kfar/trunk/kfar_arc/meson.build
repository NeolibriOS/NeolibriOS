lang = get_option('lang')

current_target = custom_target('fs_kfar_arc',
  input: ['kfar_arc.asm'],
  output: 'kfar_arc.obj',
  command: [
    fasm, '-dlang=' + lang, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
