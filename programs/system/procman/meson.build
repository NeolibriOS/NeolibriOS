lang = get_option('lang')

current_target = custom_target('system_procman',
  input: ['procman.asm'],
  output: 'procman',
  command: [
    fasm, '-dlang=' + lang, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
