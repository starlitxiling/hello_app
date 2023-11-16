#!/bin/bash

cargo build --target riscv64gc-unknown-none-elf --release
rust-objcopy --binary-architecture=riscv64 --strip-all -O binary target/riscv64gc-unknown-none-elf/release/hello_app ./hello_app.bin
APP_SIZE=$(stat -c%s ./hello_app.bin)
APP_SIZE_U8=$(echo $APP_SIZE | tr -d '\n')
dd if=/dev/zero of=./apps.bin bs=4 count=4
echo -n $APP_SIZE_U8 | dd of=./apps.bin bs=4 conv=notrunc
echo $APP_SIZE_U8
# dd if=./hello_app.bin of=./apps.bin conv=notrunc 
mkdir -p ../arceos/payload 
cp ./apps.bin ../arceos/payload/apps.bin
