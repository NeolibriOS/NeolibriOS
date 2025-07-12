lang = get_option('lang')

current_target = custom_target('sys_icon',
  input: ['icon.asm', 'bgredraw.inc', 'DlgAdd.inc', 'iconman.inc', 'Moving.inc', 'RButton.inc'],
  output: 'icon',
  command: [
    fasm, '-dlang=' + lang, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
