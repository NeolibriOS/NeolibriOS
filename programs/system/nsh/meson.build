current_target = custom_target('system_nsh',
    input: ['main.c'],
    output: 'nsh',
    command: [
        gcc, '-m32', '-fno-builtin', '-fno-pie', '-nostdlib', '-I@SOURCE_ROOT@/programs/develop/neolibc/include', '-Wall', '-Wextra', '-T@SOURCE_ROOT@/programs/develop/neolibc/neos.ld', '@SOURCE_ROOT@/programs/develop/neolibc/src/crt/crt0.o', '@INPUT@', '-o', '@OUTPUT@',
        # objcopy, '@OUTPUT@', '-O', 'binary', '&&',
        # kpack, '@OUTPUT@'
    ],
    build_by_default: true
)
