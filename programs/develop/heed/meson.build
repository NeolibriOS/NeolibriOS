lang = get_option('lang')

current_target = custom_target('develop_heed',
  input: ['heed.asm', 'cp866-8x16', 'cp1251-8x16', 'koi8-r-8x16'],
  output: 'heed',
  command: [
    fasm, '-dlang=' + lang, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
