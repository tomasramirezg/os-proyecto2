#!/bin/bash

# Script de verificación de implementación de sysinfo
# Ejecutar desde el directorio raíz del proyecto

echo "=========================================="
echo "  Verificador de Implementación sysinfo"
echo "=========================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contadores
ERRORES=0
ADVERTENCIAS=0
CORRECTOS=0

# Función de verificación
verificar_archivo() {
    local archivo=$1
    local descripcion=$2
    
    if [ -f "$archivo" ]; then
        echo -e "${GREEN}✓${NC} $descripcion: $archivo"
        ((CORRECTOS++))
        return 0
    else
        echo -e "${RED}✗${NC} $descripcion: $archivo ${RED}NO ENCONTRADO${NC}"
        ((ERRORES++))
        return 1
    fi
}

# Función para verificar contenido
verificar_contenido() {
    local archivo=$1
    local patron=$2
    local descripcion=$3
    
    if [ ! -f "$archivo" ]; then
        return 1
    fi
    
    if grep -q "$patron" "$archivo"; then
        echo -e "${GREEN}✓${NC} $descripcion en $archivo"
        ((CORRECTOS++))
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $descripcion ${YELLOW}NO ENCONTRADO${NC} en $archivo"
        ((ADVERTENCIAS++))
        return 1
    fi
}

echo "1. Verificando archivos del kernel..."
echo "--------------------------------------"
verificar_archivo "kernel/sysinfo.h" "Estructura sysinfo"
verificar_archivo "kernel/syscall.h" "Header de syscalls"
verificar_archivo "kernel/syscall.c" "Implementación de syscalls"
verificar_archivo "kernel/sysproc.c" "Syscalls de procesos"
verificar_archivo "kernel/kalloc.c" "Asignador de memoria"
verificar_archivo "kernel/proc.c" "Gestión de procesos"
verificar_archivo "kernel/defs.h" "Definiciones del kernel"
echo ""

echo "2. Verificando archivos de usuario..."
echo "--------------------------------------"
verificar_archivo "user/sysinfo.c" "Programa de prueba"
verificar_archivo "user/user.h" "Header de usuario"
verificar_archivo "user/usys.pl" "Generador de stubs"
echo ""

echo "3. Verificando contenido de archivos..."
echo "----------------------------------------"

# Verificar syscall.h
verificar_contenido "kernel/syscall.h" "SYS_sysinfo" "Definición de SYS_sysinfo"

# Verificar syscall.c
verificar_contenido "kernel/syscall.c" "sys_sysinfo" "Declaración extern sys_sysinfo"
verificar_contenido "kernel/syscall.c" "\[SYS_sysinfo\]" "Entrada en tabla de syscalls"

# Verificar sysproc.c
verificar_contenido "kernel/sysproc.c" "sys_sysinfo" "Implementación de sys_sysinfo"
verificar_contenido "kernel/sysproc.c" "copyout" "Uso de copyout"
verificar_contenido "kernel/sysproc.c" "freemem" "Llamada a freemem"
verificar_contenido "kernel/sysproc.c" "count_runnable" "Llamada a count_runnable"

# Verificar kalloc.c
verificar_contenido "kernel/kalloc.c" "freemem" "Implementación de freemem"

# Verificar proc.c
verificar_contenido "kernel/proc.c" "count_runnable" "Implementación de count_runnable"

# Verificar defs.h
verificar_contenido "kernel/defs.h" "freemem" "Declaración de freemem"
verificar_contenido "kernel/defs.h" "count_runnable" "Declaración de count_runnable"

# Verificar user.h
verificar_contenido "user/user.h" "sysinfo" "Prototipo de sysinfo"

# Verificar usys.pl
verificar_contenido "user/usys.pl" "sysinfo" "Entrada para sysinfo"

# Verificar Makefile
verificar_contenido "Makefile" "_sysinfo" "Entrada en UPROGS"

echo ""
echo "4. Verificaciones adicionales..."
echo "--------------------------------"

# Verificar que sysinfo.h tenga la estructura correcta
if [ -f "kernel/sysinfo.h" ]; then
    if grep -q "struct sysinfo" "kernel/sysinfo.h" && \
       grep -q "freemem" "kernel/sysinfo.h" && \
       grep -q "nproc" "kernel/sysinfo.h"; then
        echo -e "${GREEN}✓${NC} Estructura sysinfo parece completa"
        ((CORRECTOS++))
    else
        echo -e "${YELLOW}⚠${NC} Estructura sysinfo incompleta"
        ((ADVERTENCIAS++))
    fi
fi

# Verificar que user/sysinfo.c tenga main
if [ -f "user/sysinfo.c" ]; then
    if grep -q "int main" "user/sysinfo.c" && \
       grep -q "printf" "user/sysinfo.c"; then
        echo -e "${GREEN}✓${NC} Programa de usuario parece completo"
        ((CORRECTOS++))
    else
        echo -e "${YELLOW}⚠${NC} Programa de usuario incompleto"
        ((ADVERTENCIAS++))
    fi
fi

echo ""
echo "5. Verificando documentación..."
echo "-------------------------------"
verificar_archivo "README.md" "README principal"
verificar_archivo "autoevaluacion/estudiante1.md" "Autoevaluación estudiante 1"

echo ""
echo "=========================================="
echo "           RESUMEN DE VERIFICACIÓN"
echo "=========================================="
echo -e "${GREEN}Verificaciones exitosas: $CORRECTOS${NC}"
echo -e "${YELLOW}Advertencias: $ADVERTENCIAS${NC}"
echo -e "${RED}Errores: $ERRORES${NC}"
echo ""

if [ $ERRORES -eq 0 ] && [ $ADVERTENCIAS -eq 0 ]; then
    echo -e "${GREEN}✓ ¡Implementación completa y lista para compilar!${NC}"
    exit 0
elif [ $ERRORES -eq 0 ]; then
    echo -e "${YELLOW}⚠ Implementación mayormente completa, revisar advertencias${NC}"
    exit 0
else
    echo -e "${RED}✗ Faltan archivos o contenido requerido${NC}"
    echo "   Revisa los errores arriba antes de compilar"
    exit 1
fi
