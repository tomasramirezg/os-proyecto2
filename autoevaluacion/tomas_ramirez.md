# Autoevaluación - Proyecto 2
**Estudiante:** Tomás Ramírez Galeano
**Curso:** Sistemas Operativos 2026-2
**Nota:** 4.5

## 1. Participación y Contribución
Durante el desarrollo del Proyecto 2 participé en la implementación de la llamada al sistema `trace` dentro del kernel de xv6-riscv y en su programa de usuario `user/trace.c`. También agregué los programas al `Makefile`, desarrollé el programa de usuario `user/sysinfo.c` e integré la implementación de `sysinfo` con `trace`, adaptándola a la versión actual de xv6 para que el sistema compilara y se ejecutara correctamente en QEMU.

## 2. Dominio Conceptual
A lo largo de estas dos semanas afiancé los conceptos teóricos vistos en clase aplicándolos directamente sobre el código de xv6. Entendí a profundidad:
*   El flujo completo de una llamada al sistema, desde el stub de usuario que ejecuta `ecall` hasta el despacho en `syscall()` a través de la tabla de syscalls.
*   La lectura del `trapframe` para obtener el número de la syscall, su valor de retorno y los registros del procesador RISC-V.
*   La copia de información entre el espacio de usuario y el espacio del kernel mediante `argstr` y `copyout`.

## 3. Declaración de Uso de IA Generativa
Usé herramientas de IA generativa como apoyo para entender el código de xv6 e investigar los conceptos necesarios para la implementación.

## 4. Conclusión
Considero que mi desempeño en el proyecto fue responsable y enfocado en el aprendizaje. Se cumplieron los objetivos de extender el kernel con nuevas llamadas al sistema y de implementar mecanismos de monitoreo del sistema.
