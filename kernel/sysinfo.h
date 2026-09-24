// System information structure
// Used by sysinfo syscall to report system state

struct sysinfo {
  uint64 freemem;      // Amount of free memory (bytes)
  uint64 nproc;        // Number of processes in RUNNABLE state
  uint64 used_pages;   // Number of pages currently in use
  uint64 avail_pages;  // Number of pages available
};
