#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  if (argc < 2) {
    fprintf(2, "uso: trace <nombre_syscall>\n");
    fprintf(2, "ejemplo: trace sys_write\n");
    exit(1);
  }

  if (trace(argv[1]) < 0) {
    fprintf(2, "trace: error al activar monitoreo de %s\n", argv[1]);
    exit(1);
  }

  printf("trace: monitoreando %s\n", argv[1]);

  // Hacemos algunas llamadas al sistema para que se vea el monitoreo
  write(1, "hola desde trace\n", 17);
  getpid();
  int fd = open("README", 0);
  if (fd >= 0)
    close(fd);

  exit(0);
}
