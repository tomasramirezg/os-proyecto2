# Autoevaluación - Proyecto 2
**Estudiante:** Alejandro Restrepo Osorio
**Curso:** Sistemas Operativos 2026-2

## 1. Participación y Contribución
Durante el desarrollo del Proyecto 2, participé activamente en la implementación de las llamadas al sistema `trace` y `sysinfo` dentro del kernel de xv6-riscv. Mi trabajo se enfocó en comprender la arquitectura interna del sistema, modificar las estructuras de los procesos y garantizar la correcta transferencia de información entre el espacio de kernel y el espacio de usuario, cumpliendo con los requerimientos técnicos exigidos.

## 2. Dominio Conceptual
A lo largo de estas dos semanas, logré afianzar los conceptos teóricos vistos en clase, aplicándolos directamente sobre el código de xv6. Comprendí a profundidad:
*   El flujo completo de una llamada al sistema, desde su invocación en el espacio de usuario hasta su intercepción y ejecución en el kernel (mecanismos de trap).
*   La lectura y manipulación del `trapframe` para extraer los argumentos y registros relevantes del procesador RISC-V.
*   El cálculo y gestión de la memoria física mediante la inspección de la lista de páginas libres (`freelist`) y su conversión a Megabytes.

## 3. Declaración de Uso de IA Generativa
Dando cumplimiento a la política del curso, declaro explícitamente el uso de la herramienta de IA generativa **Claude** (y asistencia adicional de IA) durante el desarrollo de este proyecto. 

**Uso específico:**
La herramienta no fue utilizada para generar el código final a ciegas, sino como un tutor interactivo para:
*   Entender el funcionamiento exacto y la interacción de archivos críticos del kernel como `syscall.c`, `proc.c` y `kalloc.c`.
*   Comprender línea por línea la lógica de los punteros y las estructuras de memoria necesarias para implementar las syscalls.
*   Depurar errores de concepto sobre la virtualización de memoria y la transferencia de datos.
*   Aplicar conceptos y buenas prácticas de documentación aprendidos con la IA, poniéndolos en práctica directamente en los comentarios, estructuras y funciones del código entregado.

Gracias a este apoyo, garantizo que comprendo completamente la implementación realizada y estoy en plena capacidad de explicar y defender cualquier fragmento del código entregado durante la sustentación.

## 4. Conclusión
Considero que mi desempeño en el proyecto fue responsable y enfocado en el aprendizaje real. Se cumplieron los objetivos de extender la funcionalidad del kernel y desarrollar mecanismos de observabilidad, logrando un código robusto y reproducible.
