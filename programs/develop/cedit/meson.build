current_target = custom_target('develop_cedit',
  input: ['./SRC/CEdit.ob07', './SRC/Args.ob07','./SRC/ChangeLog.ob07','./SRC/CheckBox.ob07','./SRC/Clipboard.ob07','./SRC/EditBox.ob07','./SRC/Encodings.ob07','./SRC/File.ob07','./SRC/Graph.ob07','./SRC/Icons.ob07','./SRC/Ini.ob07','./SRC/KolibriOS.ob07','./SRC/KOSAPI.ob07','./SRC/Languages.ob07','./SRC/Lines.ob07','./SRC/List.ob07','./SRC/Menu.ob07','./SRC/OpenDlg.ob07','./SRC/RW.ob07','./SRC/Scroll.ob07','./SRC/Search.ob07','./SRC/StatusBar.ob07','./SRC/Tabs.ob07','./SRC/Text.ob07','./SRC/Toolbar.ob07','./SRC/Utils.ob07'],
  output: 'CEDIT',
  command: [
    oberon07, '@INPUT0@', 'kosexe', '-out', '@OUTPUT@',  '-stk', '1', '-nochk', 'a', '&&',
    kpack, '@OUTPUT@'
  ],
  build_by_default: true
)
