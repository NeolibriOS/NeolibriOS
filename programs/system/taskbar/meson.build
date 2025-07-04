lang = get_option('lang')

current_target = custom_target('sys_taskbar',
  input: ['TASKBAR.ASM'],
  output: 'taskbar',
  command: [
    fasm, '-dlang=' + lang, '-m', '16384', '@INPUT0@', '@OUTPUT@', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
