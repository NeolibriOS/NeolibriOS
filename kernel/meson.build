lang = get_option('lang')

fasm = find_program('fasm', required: true)
kerpack = find_program('kerpack', required: true)

custom_target('kernel',
  input: ['kernel.asm'],
  output: ['kernel.mnt', 'kernel.mnt.fas'],
  command: [
    fasm, '-m', '262144', '-dlang=' + lang, '@INPUT0@', '@OUTPUT0@', '-s', '@OUTPUT1@', '&&',
    kerpack, '@OUTPUT0@'
  ],
  build_by_default: true,
  install: true,
  install_dir: get_option('bindir')
)
