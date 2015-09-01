    .code32

    .global KERNEL_LMA
    .set KERNEL_LMA, 0x0000000000100000

    .global KERNEL_VMA
    .set KERNEL_VMA, 0xffff800000000000

#define MULTIBOOT2_MAGIC 0xe85250d6
#define MULTIBOOT2_ARCH  0

#define MULTIBOOT2_HEADER_TAG_END 0

    .section .multiboot
    .balign 8

.Lmultiboot_header_start:
    .long MULTIBOOT2_MAGIC
    .long MULTIBOOT2_ARCH
    .long .Lmultiboot_header_end - .Lmultiboot_header_start
    .long -(MULTIBOOT2_MAGIC + MULTIBOOT2_ARCH + (.Lmultiboot_header_end - .Lmultiboot_header_start))

.Lmultiboot_header_tag_end_start:
# Since our kernel will be an ELF binary, we don't need any additional tags.
    .short MULTIBOOT2_HEADER_TAG_END
    .short 0
    .long 8
.Lmultiboot_header_tag_end_end:
.Lmultiboot_header_end:

    .section .start, "ax"
    .balign 8

# Main entry point.
    .global _start32
    .type _start32, @function
_start32:
    cld
    cli

.Lmultiboot_save:
# Save Multiboot information into an unused register.
    movl %ebx, %esi

.Llm_cpuid_check:
# Test for long mode support on the CPU.
    movl $0x80000000, %eax
    cpuid
    cmpl $0x80000001, %eax
    jb .Llm_unsupported

    movl $0x80000001, %eax
    cpuid
    btl $29, %edx
    jnc .Llm_unsupported

.Lpae_enable:
# Enable support for PAE.
    movl %cr4, %eax
    btsl $5, %eax
    movl %eax, %cr4

.Lpaging_setup:
# Clear memory.
    leal .Lpage_table, %edi
    movl %edi, %cr3
    xorl %eax, %eax
    movl $0x3000, %ecx
    rep stosb
    movl %cr3, %edi

# Set up PML4T (at +0x0000). We map at 0x0 and KERNEL_VMA (at 0xffff800000000000).
    leal 0x1003(%edi), %eax
    movl %eax, (%edi)
    movl %eax, 0x800(%edi)

# Set up PDPT (at +0x1000).
    addl $0x1000, %edi
    leal 0x1003(%edi), %eax
    movl %eax, (%edi)

# Determine the size of the kernel in large pages.
    leal KERNEL_LMA_END - 1, %ecx
    shrl $21, %ecx # 2MB
    addl $1, %ecx

# Set up PDT (at +0x2000). We temporarily map the full kernel in here in 2MB pages.
    addl $0x1000, %edi
    movl $0x83, %eax
1:  movl %eax, (%edi)
    addl $0x200000, %eax
    addl $8, %edi
    loop 1b

.Llm_enable:
# Switch to 32-bit compatibility mode in long mode.
    movl $0xc0000080, %ecx
    rdmsr
    btsl $8, %eax
    wrmsr

.Lgdt_setup:
# Install the GDT.
    leal .Lgdt_descriptor, %edi
    lgdt (%edi)

.Lpaging_enable:
# Enable paging using our previously set up mapping.
    movl %cr0, %eax
    btsl $31, %eax
    movl %eax, %cr0

.Lcs_setup:
# Jump into 64-bit code.
    ljmpl $0x08, $_start64

.Llm_unsupported:
# Unsupported architecture, so jump out.

.Lhang32:
    hlt
    jmp .Lhang32
.size _start32, . - _start32

# Entry point for 64-bit code.
    .code64
    .global _start64
    .type _start64, @function
_start64:
# Switch to VMA address, and jump into our kernel main.
    movabsq $_start64_vma, %rax
    jmpq *%rax
.size _start64, . - _start64

    .section .text
    .balign 8

# Entry point for 64-bit code linked to virtual address.
    .type _start64_vma, @function
_start64_vma:
.Lds_setup:
# Set up data segment.
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss

.Lstack_setup:
# Make stack addressable.
    movabsq $.Lstack_end, %rsp

# Zero EFLAGS.
    pushq $0
    popfq

.Lmultiboot_restore:
# Make Multiboot information addressable.
    movabsq $KERNEL_VMA, %rdi
    addq %rsi, %rdi

.Lkernel:
    call main

.Lhang64:
    hlt
    jmp .Lhang64
.size _start64_vma, . - _start64_vma

# Auxiliary tables.
    .section .start.data, "aw"
    .balign 0x1000
.Lgdt:
    .quad 0x0000000000000000
    .quad 0x00af9a000000ffff
    .quad 0x00cf92000000ffff
    .quad 0x0080890000000000
    .quad 0x0000000000000000
.Lgdt_descriptor:
    .short . - .Lgdt - 1
    .long .Lgdt
    .short 0

    .balign 0x1000
.Lpage_table:
    .space 0x3000

    .section .bss
    .balign 8
.Lstack_start:
    .space 0x4000
.Lstack_end:
