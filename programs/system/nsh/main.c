#include <stdio.h>
#include <string.h>
#include <conio.h>

#define NSH_NAME "Neolibri Shell"
#define NSH_VERSION "0.1a"

int main(int argc, char *argv[])
{
    con_init_opt(-1, -1, -1, -1, NSH_NAME  " " NSH_VERSION);

    printf("argc = %u, argv[0] = %s\n", argc, argv[0]);

    int x[10];
    memset(x, 0xFF, sizeof(x));
    printf("x[5] = %d\n",  x[5]);

    // TODO
}
