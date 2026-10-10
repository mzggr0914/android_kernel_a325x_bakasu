#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
OUT=${OUT_DIR:-"$ROOT/out"}
IMAGE_DIR="$OUT/arch/arm64/boot"
AK3_DIR=${AK3_DIR:-/home/lunar/AnyKernel3-A325N-BakaSU}
AK3_CONFIG=${AK3_CONFIG:-"$ROOT/anykernel/a325n-anykernel.sh"}
ZIP_OUT_DIR=${ZIP_OUT_DIR:-/home/lunar}
KSU_DIR="$ROOT/KernelSU"

[ -f "$IMAGE_DIR/Image" ] || { echo "ERROR: Image not found: $IMAGE_DIR/Image" >&2; exit 1; }
[ -f "$IMAGE_DIR/Image.gz" ] || { echo "ERROR: Image.gz not found: $IMAGE_DIR/Image.gz" >&2; exit 1; }
[ -f "$AK3_DIR/anykernel.sh" ] || { echo "ERROR: AnyKernel dir invalid: $AK3_DIR" >&2; exit 1; }
[ -f "$AK3_CONFIG" ] || { echo "ERROR: A325N AnyKernel config not found: $AK3_CONFIG" >&2; exit 1; }
[ -d "$KSU_DIR/.git" ] || [ -f "$KSU_DIR/.git" ] || { echo "ERROR: KernelSU git repo not found" >&2; exit 1; }

grep -q '^device\.name1=a32$' "$AK3_CONFIG" || {
  echo "ERROR: Invalid A325N AnyKernel device configuration" >&2
  exit 1
}
grep -Eq '^BLOCK=/dev/block/by-name/boot;?$' "$AK3_CONFIG" || {
  echo "ERROR: Invalid A325N boot partition configuration" >&2
  exit 1
}

TAG=$(git -C "$KSU_DIR" describe --abbrev=0 --tags 2>/dev/null || echo v4.1.0)
SHA=$(git -C "$KSU_DIR" rev-parse --short=8 HEAD)
COUNT=$(git -C "$KSU_DIR" rev-list --count HEAD)
KSU_CODE=$((30700 + COUNT))
SUSFS=$(sed -n 's/^#define SUSFS_VERSION "\([^"]*\)"/\1/p' "$ROOT/include/linux/susfs.h" | head -n1)
[ -n "$SUSFS" ] || { echo "ERROR: SUSFS version not found" >&2; exit 1; }
SUSFS_DISPLAY=${SUSFS#v}
KERNEL_STRING="A325N BakaSU ${TAG}(${KSU_CODE}) SUSFS ${SUSFS_DISPLAY}"
ZIP_NAME="A325N-BakaSU-${TAG}-${KSU_CODE}-SUSFS-${SUSFS}-stable.zip"
ZIP_PATH="$ZIP_OUT_DIR/$ZIP_NAME"

STAGE_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/a325n-anykernel.XXXXXX")
STAGE_DIR="$STAGE_ROOT/AnyKernel3"
trap 'rm -rf "$STAGE_ROOT"' 0 1 2 3 15

mkdir -p "$STAGE_DIR"
cp -a "$AK3_DIR/." "$STAGE_DIR/"

# Never package upstream Git metadata or a stale example kernel payload.
rm -rf "$STAGE_DIR/.git"
rm -f "$STAGE_DIR"/zImage* "$STAGE_DIR"/Image*

# Keep only the device-specific file in this repository. The rest comes from
# the pinned upstream AnyKernel3 checkout.
cp -f "$AK3_CONFIG" "$STAGE_DIR/anykernel.sh"
cp -f "$IMAGE_DIR/Image" "$STAGE_DIR/Image"
cp -f "$IMAGE_DIR/Image.gz" "$STAGE_DIR/Image.gz"
sed -i "s|^kernel\.string=.*|kernel.string=$KERNEL_STRING|" "$STAGE_DIR/anykernel.sh"

printf '%s\n' "BakaSU : $TAG-$SHA ($KSU_CODE)"
printf '%s\n' "SUSFS    : $SUSFS"
printf '%s\n' "Source   : $IMAGE_DIR"
printf '%s\n' "AnyKernel: $AK3_DIR"
printf '%s\n' "AK config: $AK3_CONFIG"

mkdir -p "$ZIP_OUT_DIR"
rm -f "$ZIP_PATH"
(
  cd "$STAGE_DIR"
  zip -qr "$ZIP_PATH" . \
    -x '.git/*' '.git' '.github/*' '*.zip' '*~' '*.bak'
)

printf '%s\n' "Created  : $ZIP_PATH"
sha256sum "$ZIP_PATH"
printf '%s\n' "Image.gz : $(sha256sum "$STAGE_DIR/Image.gz" | awk '{print $1}')"
