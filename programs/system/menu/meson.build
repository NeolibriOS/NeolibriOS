lang = get_option('lang')

current_target = custom_target('menu',
  input: ['menu.asm'],
  output: 'menu',
  command: [
    fasm, '-dlang=' + lang, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
