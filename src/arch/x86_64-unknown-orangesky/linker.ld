OUTPUT_FORMAT(elf64-x86-64)
OUTPUT_ARCH(i386:x86-64)

ENTRY(_start32)
SECTIONS
{
    . = KERNEL_LMA;

    .start :
    {
        *(.multiboot)
        *(.start)
        . = ALIGN(4096);
    }

    .start.data :
    {
        *(.start.data)
        . = ALIGN(4096);
    }

    . += KERNEL_VMA;

    .text : AT(ADDR(.text) - KERNEL_VMA)
    {
        _code = .;
        *(.text)
        *(.text.*)
        . = ALIGN(4096);
    }

    .rodata : AT(ADDR(.rodata) - KERNEL_VMA)
    {
        _rodata = .;
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4096);
    }

    .data : AT(ADDR(.data) - KERNEL_VMA)
    {
        _data = .;
        *(.data)
        . = ALIGN(4096);
    }

    .bss : AT(ADDR(.bss) - KERNEL_VMA)
    {
        _bss = .;
        *(.bss)
        *(COMMON)
        . = ALIGN(4096);
    }

    _end = .;
    KERNEL_LMA_END = . - KERNEL_VMA;

    /DISCARD/ :
    {
        *(.comment)
    }
}
