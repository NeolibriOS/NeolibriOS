lang = get_option('lang')

current_target = custom_target('system_calendar',
  input: ['calendar.asm'],
  output: 'calendar',
  command: [
    fasm, '-dlang=' + lang, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
