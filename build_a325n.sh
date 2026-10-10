#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
OUT=${OUT_DIR:-"$ROOT/out"}
TOOLCHAIN=${TOOLCHAIN:-/home/lunar/zyc-clang-14.0.6-20260619}
JOBS=${JOBS:-$(nproc)}

export ARCH=arm64
export PATH="$TOOLCHAIN/bin:$PATH"
export LD_LIBRARY_PATH="$TOOLCHAIN/lib:${LD_LIBRARY_PATH:-}"
export CC=clang
export LD=ld.lld
export CROSS_COMPILE=aarch64-linux-gnu-
export LLVM=1
export LLVM_IAS=0
export KBUILD_BUILD_USER=${KBUILD_BUILD_USER:-bakasu}
export KBUILD_BUILD_HOST=${KBUILD_BUILD_HOST:-builder}
export KBUILD_BUILD_VERSION=${KBUILD_BUILD_VERSION:-1}
if [ -z "${KBUILD_BUILD_TIMESTAMP:-}" ]; then
  KBUILD_BUILD_TIMESTAMP=$(git -C "$ROOT" show -s --format=%cD HEAD)
  export KBUILD_BUILD_TIMESTAMP
fi
VENDOR_WARN_FLAGS="-Wno-error \
-Wno-error=incompatible-pointer-types \
-Wno-error=int-conversion \
-Wno-error=visibility \
-Wno-error=fortify-source \
-Wno-error=pointer-to-int-cast \
-Wno-error=typedef-redefinition \
-Wno-error=strict-prototypes \
-Wno-error=implicit-function-declaration"
export KCFLAGS=${KCFLAGS:-$VENDOR_WARN_FLAGS}

mkdir -p "$OUT"

"$ROOT/scripts/kconfig/merge_config.sh" -m -O "$OUT" \
  "$ROOT/arch/arm64/configs/mt6768_slm_defconfig" \
  "$ROOT/arch/arm64/configs/a32.config" \
  "$ROOT/arch/arm64/configs/battery.config" \
  "$ROOT/arch/arm64/configs/ksu-a325n-common.config" \
  "$ROOT/arch/arm64/configs/a325n-release.config"

make -C "$ROOT" O="$OUT" olddefconfig
make -C "$ROOT" O="$OUT" -j"$JOBS"
