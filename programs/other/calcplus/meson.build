lang = get_option('lang')

current_target = custom_target('other_calcplus',
  input: ['calcplus.asm', 'parser.inc'],
  output: 'calcplus',
  command: [
    fasm, '-dlang=' + lang, '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
