lang = get_option('lang')

current_target = custom_target('game_tetris',
  input: ['tetris.asm'],
  output: 'tetris',
  command: [
    fasm, '-dlang=' + lang, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
