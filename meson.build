project('NeolibriOS', 'c', default_options: ['warning_level=everything'])

lang = get_option('lang')

fasm = find_program('fasm', required: true)
kpack = find_program('kpack', required: true)
kpack = [kpack, '--nologo']
kerpack = find_program('kerpack', required: true)
python3 = find_program('python3', required: true)
pestrip = find_program('data/common/pestrip.asm', required: true)

# Get all directories containing meson.build files and include them as subdir():

fs = import('fs')

find_meson_builds = '''
import os
import sys

root = sys.argv[1]
build_files = []
for dirpath, _, filenames in os.walk(root):
    if 'meson.build' in filenames:
        relpath = os.path.relpath(dirpath, root)
        if relpath != '.':  # Exclude root directory
            build_files.append(relpath)
print('\n'.join(sorted(build_files)))
'''

result = run_command('python3', '-c', find_meson_builds, meson.project_source_root(), check: false)
if result.returncode() != 0
    error('Failed to find meson.build files: ' + result.stderr())
endif

subdirs = result.stdout().strip()
if subdirs != ''
    subdirs = subdirs.split('\n')
    foreach dir : subdirs
        message('Including subdirectory: ' + dir)
        subdir(dir)
    endforeach
endif
