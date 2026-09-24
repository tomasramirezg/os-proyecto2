#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/riscv.h"
#include "kernel/sysinfo.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  struct sysinfo info;

  // Call the sysinfo syscall
  if(sysinfo(&info) < 0) {
    fprintf(2, "sysinfo: syscall failed\n");
    exit(1);
  }

  // Print system information in a formatted way
  printf("=== System Information ===\n");
  
  // Convert bytes to MB for easier reading
  uint64 free_mb = info.freemem / (1024 * 1024);
  printf("Free Memory: %d MB (%d bytes)\n", free_mb, info.freemem);
  
  printf("Used Pages: %d\n", info.used_pages);
  printf("Available Pages: %d\n", info.avail_pages);
  printf("Runnable Processes: %d\n", info.nproc);
  
  printf("==========================\n");

  exit(0);
}
