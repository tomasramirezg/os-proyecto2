# Guía de Instalación y Pruebas - Syscall sysinfo

## Requisitos Previos

### 1. Sistema Operativo
- **Linux** (Ubuntu 20.04+ recomendado)
- **macOS** (con Homebrew)
- **Windows** (WSL2 con Ubuntu)

### 2. Herramientas Necesarias

#### En Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install git build-essential gdb-multiarch qemu-system-misc gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu
```

#### En macOS:
```bash
brew tap riscv/riscv
brew install riscv-tools
brew install qemu
```

#### En WSL2 (Windows):
```bash
# Desde Ubuntu en WSL2
sudo apt-get update
sudo apt-get install git build-essential qemu-system-misc gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu
```

### 3. Verificar Instalación
```bash
# Verificar RISC-V toolchain
riscv64-linux-gnu-gcc --version

# Verificar QEMU
qemu-system-riscv64 --version
```

## Instalación del Proyecto

### Paso 1: Clonar xv6-riscv
```bash
cd ~
git clone https://github.com/mit-pdos/xv6-riscv.git
cd xv6-riscv
```

### Paso 2: Clonar este Repositorio
```bash
cd ~
git clone [URL_DE_TU_REPOSITORIO] Proyecto2-sysinfo
```

### Paso 3: Copiar Archivos Modificados
```bash
# Copiar archivos del kernel
cp ~/Proyecto2-sysinfo/kernel/sysinfo.h ~/xv6-riscv/kernel/
cp ~/Proyecto2-sysinfo/kernel/syscall.h ~/xv6-riscv/kernel/
cp ~/Proyecto2-sysinfo/kernel/syscall.c ~/xv6-riscv/kernel/
cp ~/Proyecto2-sysinfo/kernel/sysproc.c ~/xv6-riscv/kernel/
cp ~/Proyecto2-sysinfo/kernel/kalloc.c ~/xv6-riscv/kernel/
cp ~/Proyecto2-sysinfo/kernel/proc.c ~/xv6-riscv/kernel/
cp ~/Proyecto2-sysinfo/kernel/defs.h ~/xv6-riscv/kernel/

# Copiar archivos de usuario
cp ~/Proyecto2-sysinfo/user/user.h ~/xv6-riscv/user/
cp ~/Proyecto2-sysinfo/user/usys.pl ~/xv6-riscv/user/
cp ~/Proyecto2-sysinfo/user/sysinfo.c ~/xv6-riscv/user/
```

### Paso 4: Modificar Makefile
```bash
cd ~/xv6-riscv
nano Makefile
```

Buscar la sección `UPROGS` y agregar:
```makefile
$U/_sysinfo\
```

Debería verse así:
```makefile
UPROGS=\
	$U/_cat\
	$U/_echo\
	...
	$U/_zombie\
	$U/_sysinfo\
```

## Compilación

### Compilar el Proyecto
```bash
cd ~/xv6-riscv
make clean
make qemu
```

Si todo está correcto, deberías ver:
```
xv6 kernel is booting

hart 2 starting
hart 1 starting
init: starting sh
$
```

## Pruebas

### Prueba Básica
Dentro de xv6, ejecutar:
```bash
$ sysinfo
```

**Salida esperada:**
```
=== System Information ===
Free Memory: XXX MB (XXXXXXX bytes)
Used Pages: XXX
Available Pages: XXXXX
Runnable Processes: X
==========================
```

### Prueba con Múltiples Procesos
```bash
$ sysinfo &
$ sysinfo &
$ sysinfo
```

Deberías ver que el número de procesos RUNNABLE aumenta.

### Prueba de Estrés
```bash
# Ejecutar múltiples comandos
$ ls &
$ cat README &
$ sysinfo
```

Observa cómo cambian los valores.

### Salir de xv6
```bash
# Presionar: Ctrl + A, luego X
# O desde otra terminal:
$ pkill qemu
```

## Debugging

### Si la compilación falla:

#### Error: "cannot find -lriscv"
```bash
# Reinstalar toolchain
sudo apt-get install --reinstall gcc-riscv64-linux-gnu
```

#### Error: "qemu-system-riscv64: command not found"
```bash
# Instalar QEMU
sudo apt-get install qemu-system-misc
```

#### Error: "undefined reference to 'freemem'"
```bash
# Verificar que kernel/defs.h incluya:
uint64 freemem(void);

# Y que kernel/kalloc.c tenga la función implementada
```

#### Error: "undefined reference to 'count_runnable'"
```bash
# Verificar que kernel/defs.h incluya:
uint64 count_runnable(void);

# Y que kernel/proc.c tenga la función implementada
```

### Si sysinfo no aparece en el shell:

1. Verificar que `$U/_sysinfo\` esté en UPROGS del Makefile
2. Recompilar completamente:
```bash
make clean
make qemu
```

### Si sysinfo retorna valores incorrectos:

1. **Memoria = 0**: Verificar implementación de `freemem()` en kalloc.c
2. **Procesos = 0**: Verificar implementación de `count_runnable()` en proc.c
3. **Crash al ejecutar**: Verificar que `copyout()` en sysproc.c esté correcto

## Testing Avanzado

### Test 1: Verificar Consistencia de Memoria
```c
// Crear user/memtest.c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/sysinfo.h"
#include "user/user.h"

int main() {
    struct sysinfo info;
    sysinfo(&info);
    uint64 mem1 = info.freemem;
    
    // Alocar 10 páginas
    char *p = sbrk(10 * 4096);
    
    sysinfo(&info);
    uint64 mem2 = info.freemem;
    
    printf("Memoria antes: %d MB\n", mem1 / (1024*1024));
    printf("Memoria después: %d MB\n", mem2 / (1024*1024));
    printf("Diferencia: ~40 KB (10 páginas)\n");
    
    exit(0);
}
```

### Test 2: Verificar Conteo de Procesos
```bash
# Script de prueba
$ sysinfo > baseline.txt
$ echo "Baseline" &
$ echo "Test1" &
$ echo "Test2" &
$ sysinfo > withprocs.txt
$ cat baseline.txt
$ cat withprocs.txt
```

## Limpieza

```bash
cd ~/xv6-riscv
make clean
```

## Problemas Comunes y Soluciones

| Problema | Solución |
|----------|----------|
| QEMU no inicia | Verificar instalación: `qemu-system-riscv64 --version` |
| Kernel panic al boot | Verificar que no se rompió código existente |
| sysinfo no compila | Verificar que todos los archivos se copiaron |
| Valores incorrectos | Revisar implementación de freemem() y count_runnable() |
| copyout falla | Verificar que el puntero de usuario sea válido |

## Recursos Adicionales

- **xv6 Book**: https://pdos.csail.mit.edu/6.828/2023/xv6/book-riscv-rev3.pdf
- **MIT 6.S081**: https://pdos.csail.mit.edu/6.828/2023/
- **RISC-V Spec**: https://riscv.org/technical/specifications/
- **xv6 Source**: https://github.com/mit-pdos/xv6-riscv

## Contacto y Soporte

Si encuentras problemas, revisa:
1. La documentación oficial de xv6
2. Los issues en el repositorio de xv6
3. Stack Overflow con tag [xv6]
