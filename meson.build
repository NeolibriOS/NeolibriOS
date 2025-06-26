project('NeolibriOS', 'c', default_options: ['warning_level=everything'])

lang = get_option('lang')


subdir('kernel')

games = [
  'pipes',
  'tetris',
]
foreach game : games
  subdir('programs/games/' + game)
endforeach
