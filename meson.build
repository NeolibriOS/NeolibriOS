project('NeolibriOS', 'c', default_options: ['warning_level=everything'])

lang = get_option('lang')

programs_dir = meson.current_source_dir() / 'programs'

# TODO this(<----) doesnt work but approach is good
# Get list of subdirs that contain meson.build file
# fs = import('fs')
# all_program_paths = fs.glob(programs_dir, '**/meson.build')  #  <----
# foreach p : all_program_paths
#   relpath = p.strip_prefix(meson.current_source_dir() + '/')
#   subdir(relpath.dirname())
# endforeach


subdir('programs/games/pipes')

