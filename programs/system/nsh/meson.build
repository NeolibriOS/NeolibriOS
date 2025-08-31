# KTCC_DIR = ../../develop/ktcc
# KLIBC = $(KTCC_DIR)/libc.obj

# NAME = nsh

# KTCC = $(KTCC_DIR)/bin/kos32-tcc
# KPACK = kpack

# SRC = $(wildcard *.c)
# FLAGS= -B$(KTCC_DIR)/bin -I $(KLIBC)/include -Wall# -stack=20480
# LIBS =

# all: $(SRC)
# 	$(KTCC) $(FLAGS) $(SRC) $(LIBS) -o $(NAME)
# # $(KPACK) $(NAME)

# clean:
# 	rm $(NAME)


current_target = custom_target('system_nsh',
    input: ['main.c'],
    output: 'nsh',
    command: [
        kos32_tcc, '-B@SOURCE_ROOT@/programs/develop/ktcc/bin', '-I@SOURCE_ROOT@/programs/develop/ktcc/libc.obj/include', '-Wall', '@INPUT@', '-o', '@OUTPUT@', '&&',
        kpack, '@OUTPUT@'
    ],
    build_by_default: true
)
