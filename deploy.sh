#!/bin/bash

# 编译 Rust 代码
# cargo build --target riscv64gc-unknown-none-elf --release
rm *.bin

# 目标目录
target_dir="target/riscv64gc-unknown-none-elf/release/"

# 遍历目标目录下的所有可执行文件
for executable in "$target_dir"/*; do
    # 检查文件是否为可执行文件
    if [ -x "$executable" ]; then
        # 获取文件名（不包含路径）
        filename=$(basename "$executable")

        # 提取文件名（不包含扩展名）
        name="${filename%.*}"

        # 转换为二进制文件
        rust-objcopy --binary-architecture=riscv64 --strip-all -O binary "$executable" "./$name.bin"
    fi
done

# 获取当前目录下所有以 .bin 结尾的文件
bin_files=(*.bin)

# 计算文件个数
num_files=${#bin_files[@]}

# 将文件个数写入 apps.bin，大端字节序
printf "%016X" $num_files | xxd -r -p > ./apps.bin

# 遍历每个 .bin 文件，将大小依次写入 apps.bin
for bin_file in "${bin_files[@]}"; do
    # 获取文件大小
    file_size=$(stat -c%s "$bin_file")

    # 将文件大小写入 apps.bin，大端字节序
    printf "%016X" $file_size | xxd -r -p >> ./apps.bin
done

# 再次遍历每个 .bin 文件，将内容依次写入 apps.bin
for bin_file in "${bin_files[@]}"; do
    # 追加文件内容到 apps.bin
    cat "$bin_file" >> ./apps.bin
done

# 获取 hello_app.bin 文件的大小
# APP_SIZE=$(stat -c%s ./hello_app.bin)

# 将文件大小写入 apps.bin，大端字节序
# printf "%08X" $APP_SIZE | xxd -r -p > ./apps.bin
# echo "Size of apps.bin: $(stat -c%s ./apps.bin) bytes"
# 追加 hello_app.bin 的内容到 apps.bin
# cat ./hello_app.bin >> ./apps.bin
dd if=/dev/zero of=./pflash.img bs=1M count=32
dd if=./apps.bin of=./pflash.img conv=notrunc
# echo "Size of hello_app.bin: $APP_SIZE bytes"
# echo "Size of apps.bin: $(stat -c%s ./apps.bin) bytes"
# echo "Size of pflash.img: $(stat -c%s ./pflash.img) bytes"
# 创建目标目录
mkdir -p ../arceos/payload

# 移动文件到目标目录
cp ./pflash.img ../arceos/payload/pflash.img

