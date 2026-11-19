.set MB2_MAGIC, 0xE85250D6
.set MB2_ARCH, 0
.set MB2_HEADER_LEN, mb2_header_end - mb2_header
.set MB2_CHECKSUM, -(MB2_MAGIC + MB2_ARCH + MB2_HEADER_LEN)

.section .multiboot
.align 8
mb2_header:
    .long MB2_MAGIC
    .long MB2_ARCH
    .long MB2_HEADER_LEN
    .long MB2_CHECKSUM
    .short 0
    .short 0
    .long 8
mb2_header_end:

.section .bss
.align 16
stack_bottom:
    .skip 16384
stack_top:

.align 4096
pml4:
    .skip 4096
pdpt:
    .skip 4096
pd:
    .skip 4096

.section .text
.code32
.global _start
.type _start, @function
_start:
    cli
    mov $stack_top, %esp

    # Identity-map the first 1 GiB using 2 MiB pages.
    mov $pd, %edi
    mov $0, %ecx
1:
    mov %ecx, %eax
    shl $21, %eax
    or $0x83, %eax
    mov %eax, (%edi)
    mov $0, 4(%edi)
    add $8, %edi
    inc %ecx
    cmp $512, %ecx
    jne 1b

    mov $pd, %eax
    or $0x3, %eax
    mov %eax, pdpt
    mov $0, pdpt+4

    mov $pdpt, %eax
    or $0x3, %eax
    mov %eax, pml4
    mov $0, pml4+4

    # Enable PAE.
    mov %cr4, %eax
    or $(1 << 5), %eax
    mov %eax, %cr4

    # Load page-table root.
    mov $pml4, %eax
    mov %eax, %cr3

    # Enable long mode in EFER.
    mov $0xC0000080, %ecx
    rdmsr
    or $(1 << 8), %eax
    wrmsr

    # Enable paging.
    mov %cr0, %eax
    or $(1 << 31), %eax
    mov %eax, %cr0

    lgdt gdt64_pointer
    ljmp $0x08, $long_mode_start

.code64
long_mode_start:
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    xor %ax, %ax
    mov %ax, %fs
    mov %ax, %gs

    mov $stack_top, %rsp
    xor %rbp, %rbp
    call kernel_main

2:
    cli
    hlt
    jmp 2b

.align 8
gdt64:
    .quad 0
    .quad 0x00AF9A000000FFFF
    .quad 0x00AF92000000FFFF
gdt64_end:
gdt64_pointer:
    .word gdt64_end - gdt64 - 1
    .quad gdt64

.section .note.GNU-stack,"",@progbits
