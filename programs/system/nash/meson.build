current_target = custom_target('system_nash',
  input: ['Nash.ob07'],
  output: 'NASH',
  command: [
    oberon07, '@INPUT0@', 'kosexe', '-out', '@OUTPUT@',  '-stk', '1', '-nochk', 'a', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
