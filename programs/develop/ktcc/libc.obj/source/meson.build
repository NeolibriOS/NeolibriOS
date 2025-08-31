gas_src = [
    'setjmp/setjmp.s',
    'setjmp/longjmp.s',
    'math/round.s',
    'math/atan.s',
    'math/pow2.s',
    'math/log10.s',
    'math/exp.s',
    'math/pow10.s',
    'math/log.s',
    'math/pow.s',
    'math/ceil.s',
    'math/cos.s',
    'math/sin.s',
    'math/asin.s',
    'math/modf.s',
    'math/floor.s',
    'math/fabs.s',
    'math/fmod.s',
    'math/log2.s',
    'math/acos.s',
    'math/modfl.s',
    'math/atan2.s',
    'math/sqrt.s',
    'math/tan.s',
    'string/memset.s',
    'string/memmove.s'
]

gas_objs = []
foreach gas_file : gas_src
    gas_obj = custom_target('gas_' + gas_file.underscorify(),
        input: gas_file,
        output: '@BASENAME@.o',
        command: [as, '--32', '@INPUT@', '-o', '@OUTPUT@'],
        build_by_default: false
    )
    gas_objs += gas_obj
endforeach

current_target = custom_target('develop_ktcc_libcobj',
    input: ['libc.c'] + gas_objs,
    output: 'libc.obj',
    command: [
        kos32_tcc, '-r', '-nostdinc', '-nostdlib', '-DGNUC', '-D_BUILD_LIBC', '-I@CURRENT_SOURCE_DIR@/../include', '@INPUT0@',
        '-o', 'libc.o',
        '&&', strip, 'libc.o', '--strip-unneeded',
        '&&', objconv, '-fcoff32', 'libc.o', '@OUTPUT@',
        '&&', kpack, '@OUTPUT@'
    ],
    depends: gas_objs,
    build_by_default: true
)
