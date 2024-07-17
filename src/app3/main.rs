#![no_std]
#![no_main]

static mut COUNTER: u32 = 0;


// it's a loop app
#[no_mangle]
pub unsafe extern "C" fn _start() -> ! {
    loop {
        COUNTER += 1;
    }
}

use core::panic::PanicInfo;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

