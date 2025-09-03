#include <sys/ksys.h>

#define NSH_NAME "Neolibri Shell"
#define NSH_VERSION "0.1a"

int main(int argc, char *argv[])
{
    _ksys_debug_puts(NSH_NAME  " " NSH_VERSION);
}

