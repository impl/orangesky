#![feature(asm, lang_items, no_std)]
#![no_std]
#![no_main]

#[no_mangle]
pub extern fn main() {
    loop {}
}

#[lang = "panic_fmt"]
#[allow(unused_variables)]
extern fn panic_fmt(args: &core::fmt::Arguments, file: &str, line: u32) -> ! {
    loop {}
}

#[lang = "stack_exhausted"] extern fn stack_exhausted() {}
#[lang = "eh_personality"] extern fn eh_personality() {}
