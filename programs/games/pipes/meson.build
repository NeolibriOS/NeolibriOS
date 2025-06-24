lang = get_option('lang')

fasm = find_program('fasm', required: true)
kpack = find_program('kpack', required: true)

custom_target('game_pipes',
  input: ['pipes.asm', 'pipes.png', 'pipes.raw'],
  output: 'pipes',
  command: [
    fasm, '-dlang=' + lang, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true,
  install: true,
  install_dir: get_option('bindir')
)
