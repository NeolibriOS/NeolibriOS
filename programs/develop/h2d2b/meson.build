lang = get_option('lang')

current_target = custom_target('develop_h2d2b',
  input: ['h2d2b.asm'],
  output: 'h2d2b',
  command: [
    fasm, '-dlang=' + lang, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
