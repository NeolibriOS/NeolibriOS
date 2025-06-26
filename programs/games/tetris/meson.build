lang = get_option('lang')

fasm = find_program('fasm', required: true)
kpack = find_program('kpack', required: true)

custom_target('game_tetris',
  input: ['tetris.asm'],
  output: 'tetris',
  command: [
    fasm, '-dlang=' + lang, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true,
  install: true,
  install_dir: get_option('bindir')
)
