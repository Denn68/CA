
#include <stdlib.h>
#include "gc.h"

int main () {
    GC_malloc(sizeof(int) * 1000);
    return 0;
}