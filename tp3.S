
    .equ CODE_SEG, 8
    .equ DATA_SEG, gdt_data - gdt_start

comienzo: 
    .code16
    cli                                 /* Limpiamos los flags de interrupciones. */

    xor %ax, %ax                        /* Ponemos ax a 0 */
    
    mov %ax, %ds                        /* Limpiamos los registros de segmentos y punteros */
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %bp
    mov %ax, %ss
    mov %bp, %sp

    lgdt gdt_descriptor                 /* Cargamos la tabla de descriptores (go to gdt_descriptor)*/

    mov %cr0, %eax                      /* Modificamos el bit menos significativo de cr0 */
    orl $0x1, %eax
    mov %eax, %cr0

    ljmp $CODE_SEG, $protected_mode     /* Le indicamos a donde hacer e salto, es una instrucción de 16 bits */

    gdt_start:
    gdt_null:                           /* Se declara el descriptor nulo */
        .long 0x0                       /* "dd" o ".long" representan 4 bytes, por ese motivo se utilizan 2 */
        .long 0x0                       /* para llegar a los 8 bytes */
    gdt_code:                           /* El segmento descriptor de código */
        .word 0xffff                    /* Limite (bits 0 - 15) */
        .word 0x0                       /* Base (bits 0 -15) */
        .byte 0x0                       /* Base (bits 16 - 23) */
        .byte 0b10011010                /* 1 00 1 101 0 (P DPL S TIPO A) */
        .byte 0b11001111                /* 1 1 0 0 1111 (G D/W 0 AVL Límite(bits 16 - 19)) */
        .byte 0x0                       /* Base (bits 24 - 31) */
    gdt_data:                           /* El segmento descriptor de datos */
        .word 0xffff                    /* Limite (bits 0 - 15) */
        .word 0x0                       /* Base (bits 0 -15) */
        .byte 0x0                       /* Base (bits 16 - 23) */
        .byte 0b10010010                /* 1 00 1 001 0 (P DPL S TIPO A) */
        .byte 0b11001111                /* 1 1 0 0 1111 (G D/W 0 AVL Límite(bits 16 - 19)) */
        .byte 0x0                       /* Base (bits 24 - 31) */
    gdt_end:
    gdt_descriptor:
        .word gdt_end - gdt_start
        .long gdt_start                 /* Dirección de comienzo GDT */
    vga_current_line:
        .long 0

    
    .code32
    protected_mode:
        mov $DATA_SEG, %ax              /* Cargo el valor de DATA_SEG en todos los segmentos, salvo CS que se cargó antes */
        mov %ax, %ds        
        mov %ax, %es
        mov %ax, %fs
        mov %ax, %gs
        mov %ax, %ss

        mov $0X7000, %ebp
        mov %ebp, %esp

    print:                              /* Configuración de la memoria de video VGA */
        mov $message, %ecx
        mov vga_current_line, %eax
        mov $10, %edx
        mov $25, %ebx                   /* Numero de lineas horizontales */
        div %ebx
        mov %edx, %eax
        mov $160, %edx                  /* Ancho de línea * bytes por caracter en pantalla, 160 == 80 * 2 */
        mul %edx
        lea 0xb8000(%eax), %edx         /* 0xb8000 Es la dirección de memoria de video de monitores multicolor */
        mov $0x1f, %ah                  /* El primer byte es el color de fondo y el segundo byte es el color de letras */
    loop:
        mov (%ecx), %al
        cmp $0, %al
        je end
        mov %ax, (%edx)
        add $1, %ecx
        add $2, %edx
        jmp loop
    end:
        hlt

    message:
        .asciz "#ASM-Killer"
