lang = get_option('lang')

current_target = custom_target('game_pipes',
  input: ['pipes.asm', 'pipes.png', 'pipes.raw'],
  output: 'pipes',
  command: [
    fasm, '-dlang=' + lang, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
