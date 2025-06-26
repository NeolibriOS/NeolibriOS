lang = get_option('lang')

custom_target('boot_fat12',
  input: ['boot_fat12.asm'],
  output: 'boot_fat12.bin',
  command: [
    fasm, '-dlang=' + lang, '@INPUT0@', '@OUTPUT@'
  ],
  build_by_default: true
)
