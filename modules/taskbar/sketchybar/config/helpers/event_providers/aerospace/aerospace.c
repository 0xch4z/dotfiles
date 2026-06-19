#include <stdio.h>
#include <stdlib.h>

#define event_namespace argv[1]

#define evt_init "init"

int main(int argc, char *argv[]) {
  if (argc < 2) {
    fprintf(stderr, "Usage: %s <event-namespace>\n", argv[0]);
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
