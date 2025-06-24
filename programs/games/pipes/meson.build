lang = get_option('lang')

fasm = find_program('fasm', required: true)

custom_target('game_pipes',
  input: ['pipes.asm', 'pipes.png', 'pipes.raw'],
  output: 'pipes',
  command: [fasm, '-dlang=' + lang, '@INPUT0@', '@OUTPUT@'],
  build_by_default: true,
  install: true,
  install_dir: get_option('bindir')
)
