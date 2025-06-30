lang = get_option('lang')

custom_target('sys_board',
  input: 'board.asm',
  output: 'board',
  command: [
    fasm, '-dlang=' + lang, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
