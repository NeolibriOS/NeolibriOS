project('NeolibriOS', 'c', default_options: ['warning_level=everything'])

lang = get_option('lang')

fasm = find_program('fasm', required: true)
kpack = find_program('kpack', required: true)
kpack = [kpack, '--nologo']
kerpack = find_program('kerpack', required: true)
python3 = find_program('python3', required: true)

subdir('kernel/bootloader')
subdir('kernel')

games = [
  'pipes',
  'tetris',
]
foreach game : games
  subdir('programs/games/' + game)
endforeach

# Always rebuild the image
custom_target('make_image',
  output: 'neolibrios_' + lang + '.img',
  command: [
    python3, join_paths(meson.current_source_dir(), 'make_image.py'), '--srcdir', meson.current_source_dir(), '--builddir', meson.current_build_dir(), '--lang', lang, '--targetimg', '@OUTPUT@'
  ],
  build_always_stale: true,
  build_by_default: true
)

