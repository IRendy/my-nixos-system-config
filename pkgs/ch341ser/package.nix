{
  lib,
  stdenv,
  fetchurl,
  unzip,
  linuxPackages,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ch341ser";
  version = "1.8.0";
  src = fetchurl {
    url = "https://www.wch-ic.com/download/file?id=177";
    sha256 = "sha256-p+DXJR08+Pi8e5iTMuLZ46Q/CsLaUBOx5a/gWaceh8c=";
  };

  # 1. 只将 unzip 作为构建工具
  nativeBuildInputs = [ unzip ];

  # 2. 将内核头文件作为构建依赖
  buildInputs = [ linuxPackages.kernel.dev ];

  # 3. 指定解压后的源码根目录
  sourceRoot = "CH341SER_LINUX";

  # 4. 手动解压，因为源文件没有扩展名
  unpackPhase = ''
    unzip $src
  '';

  # 5. 打补丁 + 动态查找内核构建路径并编译
  buildPhase = ''
    cd driver

    # 修复: Linux 6.18+ 中 asm/unaligned.h 已移除，get_unaligned_le16 迁移到 linux/unaligned.h
    sed -i 's|#include <asm/unaligned.h>|#include <linux/unaligned.h>|' ch341.c

    # 动态查找内核构建目录，兼容不同 nixpkgs 版本的目录结构
    KERNEL_BUILD_DIR=""
    if [ -d "${linuxPackages.kernel.dev}/lib/modules/${linuxPackages.kernel.modDirVersion}/build" ]; then
      KERNEL_BUILD_DIR="${linuxPackages.kernel.dev}/lib/modules/${linuxPackages.kernel.modDirVersion}/build"
    elif [ -d "${linuxPackages.kernel.dev}/build" ]; then
      KERNEL_BUILD_DIR="${linuxPackages.kernel.dev}/build"
    else
      echo "Error: Cannot find kernel build directory in ${linuxPackages.kernel.dev}"
      exit 1
    fi

    echo "Using kernel build directory: $KERNEL_BUILD_DIR"

    # 使用找到的路径编译内核模块
    make -C "$KERNEL_BUILD_DIR" M=$(pwd) modules
  '';

  # 6. 将编译好的模块安装到 $out（兼容 .ko 和 .ko.zst / .ko.xz 等压缩格式）
  installPhase = ''
    mkdir -p $out/lib/modules/${linuxPackages.kernel.modDirVersion}/kernel/drivers/usb/serial/
    for f in ch341.ko*; do
      cp "$f" $out/lib/modules/${linuxPackages.kernel.modDirVersion}/kernel/drivers/usb/serial/
    done
  '';

  meta = {
    description = "Linux driver for USB to serial port, supports CH340 and CH341.";
    homepage = "https://www.wch-ic.com/downloads/CH341SER_LINUX_ZIP.html";
    maintainers = [ "IRendy" ];
    platforms = lib.platforms.linux;
  };
})
