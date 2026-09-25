# Proyecto 2 — System Calls en xv6 (`trace` y `sysinfo`)

## Información General

- **Proyecto:** System Calls en xv6-riscv
- **Curso:** Sistemas Operativos 2026-2 — Universidad EAFIT
- **Docente:** José Luis Montoya Pareja
- **Integrantes:**
  - Tomás Ramírez Galeano
  - Alejandro Restrepo Osorio

## Descripción de la Solución

Se extendió el kernel de xv6-riscv con dos llamadas al sistema nuevas:

- **`trace(char *name)`**: activa el monitoreo de una syscall, identificada por su nombre (por ejemplo `sys_write`), para el proceso que la invoca. Cada vez que ese proceso ejecuta la syscall monitoreada, el kernel imprime el PID, el nombre de la syscall, el valor de retorno y los registros RISC-V `s0`, `s1`, `a0` y `a1`.
- **`sysinfo(struct sysinfo *info)`**: recopila el estado actual del sistema (memoria libre, páginas usadas, páginas disponibles y procesos en estado `RUNNABLE`) y lo copia a una estructura en el espacio de usuario.

Cada syscall tiene un programa de usuario para probarla: `user/trace.c` y `user/sysinfo.c`.

## Archivos Modificados

### Kernel

| Archivo | Cambio |
|---|---|
| `kernel/syscall.h` | Números de las nuevas syscalls: `SYS_trace` (23) y `SYS_sysinfo` (24). |
| `kernel/syscall.c` | Registro de `sys_trace` y `sys_sysinfo` en la tabla `syscalls[]`, tabla `syscallnames[]` (número → nombre) e impresión de la información de trace dentro de `syscall()`. |
| `kernel/sysproc.c` | Implementación de `sys_trace` y `sys_sysinfo`. |
| `kernel/proc.h` | Campo `char tracesys[16]` en `struct proc` con el nombre de la syscall monitoreada. |
| `kernel/proc.c` | Función `count_runnable()`, que cuenta los procesos en estado `RUNNABLE`. |
| `kernel/kalloc.c` | Función `freemem()`, que calcula los bytes libres recorriendo la lista de páginas libres. |
| `kernel/defs.h` | Prototipos de `freemem()` y `count_runnable()`. |
| `kernel/sysinfo.h` | **Nuevo.** Definición de `struct sysinfo`, compartida entre kernel y usuario. |

### Usuario

| Archivo | Cambio |
|---|---|
| `user/trace.c` | **Nuevo.** Programa que activa `trace` con el nombre recibido por argumento y luego ejecuta `write`, `getpid`, `open` y `close` para generar llamadas monitoreables. |
| `user/sysinfo.c` | **Nuevo.** Programa que llama a `sysinfo` e imprime la información del sistema. |
| `user/user.h` | Prototipos `int trace(char*)` e `int sysinfo(struct sysinfo*)`. |
| `user/usys.pl` | Entradas `trace` y `sysinfo` para generar los stubs en ensamblador (`ecall`). |

### Otros

| Archivo | Cambio |
|---|---|
| `Makefile` | `$U/_trace` y `$U/_sysinfo` agregados a `UPROGS`. |

## Diseño Realizado

### Flujo general de una syscall

1. El programa de usuario llama a `trace(...)` o `sysinfo(...)`, declarados en `user/user.h`.
2. El stub generado por `usys.pl` pone el número de la syscall en el registro `a7` y ejecuta `ecall`.
3. El trap pasa a modo supervisor. `usertrap()` llama a `syscall()`, que usa `a7` como índice en `syscalls[]` y ejecuta el handler correspondiente.
4. El valor de retorno queda en `p->trapframe->a0`, que es lo que recibe el programa de usuario.

### `trace`

- **Parámetro por nombre:** el enunciado pide monitorear una syscall por su nombre (`trace sys_kill`), así que `sys_trace` copia el string desde el espacio de usuario con `argstr()` al campo `tracesys` del proceso (máximo 15 caracteres más `\0`).
- **Estado por proceso:** el nombre se guarda en `struct proc`, así que el monitoreo afecta solo al proceso que llamó a `trace` y no a todo el sistema.
- **Punto de intercepción:** la verificación se hace en `syscall()` (`kernel/syscall.c`) porque todas las syscalls pasan por ahí. Después de ejecutar el handler se compara `tracesys` contra `syscallnames[num]` con `strncmp`. Si coinciden, se imprime con `printk`:
  - `PID`: `p->pid`
  - `SYSCALL`: el nombre desde `syscallnames[]`
  - `RETURN`: `p->trapframe->a0` (el retorno ya escrito por el handler)
  - Registros `s0`, `s1`, `a0` y `a1` leídos del `trapframe`
- **Por qué se imprime después del handler:** así el valor de retorno ya está disponible. Por eso `a0` muestra el mismo valor que `RETURN`: en RISC-V el retorno se escribe en `a0`.

### `sysinfo`

- **Estructura compartida:** `struct sysinfo` (`kernel/sysinfo.h`) usa campos `uint64` para evitar problemas de alineación entre kernel y usuario:
  ```c
  struct sysinfo {
    uint64 freemem;      // memoria libre en bytes
    uint64 nproc;        // procesos en estado RUNNABLE
    uint64 used_pages;   // páginas en uso
    uint64 avail_pages;  // páginas disponibles
  };
  ```
- **Memoria libre (`freemem`)**: recorre `kmem.freelist` en `kalloc.c` bajo `kmem.lock`, cuenta las páginas libres y multiplica por `PGSIZE` (4096). El programa de usuario convierte los bytes a MB.
- **Páginas disponibles:** `freemem / PGSIZE`.
- **Páginas usadas:** el asignador de xv6 administra la memoria física entre `end` (fin del kernel) y `PHYSTOP`. El total de páginas es `(PHYSTOP - end) / PGSIZE`, y las usadas son ese total menos las disponibles.
- **Procesos RUNNABLE (`count_runnable`)**: recorre la tabla `proc[NPROC]` en `proc.c`, toma `p->lock` de cada proceso para leer su estado de forma segura y cuenta los que están en `RUNNABLE`. El proceso que ejecuta `sysinfo` está en `RUNNING`, así que no se cuenta.
- **Transferencia kernel → usuario:** `sys_sysinfo` obtiene la dirección del usuario con `argaddr()`, llena la estructura en la pila del kernel y la copia con `copyout()`, que valida la dirección contra la tabla de páginas del proceso. Si la dirección es inválida, la syscall retorna `-1`.

### Manejo de errores

- `trace` sin argumentos imprime el uso en stderr (`fprintf(2, ...)`) y termina con `exit(1)`.
- Si la syscall `trace` falla, el programa imprime el error en stderr y termina con `exit(1)`.
- Si la syscall `sysinfo` falla (por ejemplo, `copyout` con una dirección inválida), el programa imprime `sysinfo: syscall failed` en stderr y termina con `exit(1)`.

## Compilación

### Requisitos

- Toolchain RISC-V y QEMU:
  - Ubuntu/Debian: `sudo apt-get install git build-essential gdb-multiarch qemu-system-misc gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu`
  - Arch Linux: `sudo pacman -S riscv64-elf-gcc riscv64-elf-binutils qemu-system-riscv`

El `Makefile` de xv6 detecta automáticamente el prefijo del toolchain (`riscv64-elf-` o `riscv64-linux-gnu-`).

### Pasos

Este repositorio contiene solo los archivos creados o modificados. Para compilar hay que copiarlos sobre xv6-riscv. La solución se probó sobre el commit `9e3161a` de xv6-riscv.

```bash
# 1. Clonar xv6-riscv en la versión usada
git clone https://github.com/mit-pdos/xv6-riscv.git
cd xv6-riscv
git checkout 9e3161a9abf5f51ea402562d1874caf6c4926597
cd ..

# 2. Clonar este repositorio
git clone https://github.com/tomasramirezg/os-proyecto2.git

# 3. Copiar los archivos del proyecto sobre xv6
cp -r os-proyecto2/kernel os-proyecto2/user os-proyecto2/Makefile xv6-riscv/

# 4. Compilar
cd xv6-riscv
make clean
make
```

## Ejecución

```bash
make qemu
```

Para salir de QEMU: `Ctrl+a` y luego `x`.

### `sysinfo`

```
$ sysinfo
=== System Information ===
Free Memory: 127 MB (133259264 bytes)
Used Pages: 200
Available Pages: 32534
Runnable Processes: 0
==========================
```

### `trace`

Uso: `trace <nombre_syscall>`, con el nombre tal como aparece en `syscallnames[]` (`sys_write`, `sys_getpid`, `sys_open`, `sys_close`, etc.).

```
$ trace sys_getpid
trace: monitoreando sys_getpid
hola desde trace
PID: 5
SYSCALL: sys_getpid
RETURN: 5
s0: 0x3fb0
s1: 0x3fc0
a0: 0x5
a1: 0x9e8
```

Con `trace sys_write` también se ve cada `write` que hace el `printf` de usuario. El `printf` de xv6 escribe carácter por carácter, así que genera una entrada de trace por cada carácter impreso.

### Caso de error

```
$ trace
uso: trace <nombre_syscall>
ejemplo: trace sys_write
```

El programa termina con código de salida `1`.

## Uso de IA

Se usaron herramientas de IA generativa como apoyo para entender el código de xv6 (flujo de traps y syscalls, estructuras del kernel, transferencia de datos entre kernel y usuario) y para investigar los conceptos necesarios para la implementación.
