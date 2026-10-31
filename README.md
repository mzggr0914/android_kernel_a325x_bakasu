# Samsung Galaxy A32 BakaSU Kernel

Custom Android kernel for the **Samsung Galaxy A32 4G (SM-A325 series)**, based on the Samsung MT6768 kernel source and integrated with **BakaSU** and **SUSFS**.

This kernel is intended for the SM-A325 family, including regional variants such as the SM-A325N and SM-A325F. It has been tested on the SM-A325N. Compatibility with every regional variant, firmware release, and ROM cannot be guaranteed.

[한국어 README](README_KO.md)

> **BakaSU source:** This project tracks BakaSU's `main` branch without modifying its sources. Linux 4.14 preinit, manual SELinux and SUSFS command integration live in the parent kernel. Automatic updates check the source API before updating the pinned submodule commit.

## Device Support

- Device: Samsung Galaxy A32 4G
- Target models: SM-A325 series
- Tested model: SM-A325N
- Platform: MediaTek MT6768
- Android version: Android 12
- Kernel version: Linux 4.14.357
- Kernel release: `4.14.357-openela-vigus-slmkernel-a32`

Other SM-A325 regional variants may be compatible because they share the same base platform and kernel tree. However, users should keep a backup of their original boot image before flashing.

## Features

<!-- AUTO:BAKASU:START -->
- BakaSU `v4.2.0-rc3`
- BakaSU kernel version code `35257`
- BakaSU commit [`516d3e87`](https://github.com/Baka-SU/BakaSU/commit/516d3e87fbc986ccefdde2c2765f1700612441a9)
<!-- AUTO:BAKASU:END -->
- SUSFS `v2.3.0`
- KernelSU multi-manager support
- BakaSU SUSFS inline-hook integration for this non-GKI Linux 4.14 tree (KProbes/Kretprobes remain enabled for compatibility)
- SELinux enforcing
- NoMount `v2.2.0` built-in path redirection and virtual file injection
- SUSFS mount hiding
- SUSFS path hiding
- SUSFS kstat spoofing
- SUSFS uname spoofing
- SUSFS `/proc/cmdline` spoofing
- Automatic hiding of KernelSU and SUSFS symbols from `/proc/kallsyms`
- SUSFS open redirect
- SUSFS memory map hiding
- SUSFS runtime logging disabled for release builds
- AnyKernel3 installation package

## Important Notice

This kernel is intended for users who understand custom kernels, unlocked bootloaders, custom recovery environments, and device recovery procedures.

Flashing a custom kernel may result in:

- Boot failure
- Data loss
- Broken root access
- Incompatibility with certain ROMs or firmware versions
- Knox warranty bit changes
- Other device-specific problems

You are responsible for your own device. Always keep a working boot image or complete firmware package available before flashing.

## Installation

1. Confirm that your device belongs to the Samsung Galaxy A32 4G SM-A325 series.
2. Back up your current boot image.
3. Download the latest AnyKernel3 ZIP from the Releases page.
4. Flash the ZIP using a compatible custom recovery or kernel flashing application.
5. Reboot the device.
6. Install a compatible BakaSU Manager build if it is not already installed.

The kernel has been tested on the SM-A325N. Users of other SM-A325 variants should verify that they can restore the original boot image before flashing.

Do not flash this kernel on devices outside the SM-A325 series.

## Building

Clone the repository with its BakaSU submodule:

```bash
git clone --recursive https://github.com/mzggr0914/android_kernel_a325x_bakasu.git
cd android_kernel_a325x_bakasu
```

If the repository was cloned without submodules, initialize them manually:

```bash
git submodule update --init --recursive
```

The standard build uses official **AOSP Clang 14.0.6 (`clang-r450784d`)**.
Its source revision and Git subtree ID are pinned in `scripts/aosp_clang14.conf`.
The compiler's bundled `lib64` runtime is retained, including the libxml2 needed
by LLD, so the build does not require a host `libxml2.so.2` compatibility package.
Local builds and Actions use the same installation script; Actions targets
`ubuntu-latest`.

Install the separate GNU assembler required by this kernel's Makefile, then run:

```bash
sudo apt-get install binutils-aarch64-linux-gnu
./build_a325n.sh
```

On the first build, the script downloads the complete AOSP archive and verifies
every extracted file, symlink and executable bit against the pinned Git subtree,
and installs it under `.toolchains/clang-r450784d`. Downloads are cached under
`~/.cache/bakasu-toolchains`. Existing unrelated toolchain directories are not
overwritten. You can select another installation directory for the same pinned
compiler:

```bash
TOOLCHAIN=/path/to/aosp-clang14 \
OUT_DIR=/path/to/output \
JOBS=$(nproc) \
./build_a325n.sh
```

Gitiles can generate different archive headers for the same revision, so the
archive SHA256 is recorded for tracing while the Git subtree verifies content.
`out/toolchain-source.txt` records the AOSP revision, tree ID, archive SHA256, compiler,
linker and GNU assembler versions. Keep the complete toolchain layout when
moving it; `bin` alone is not sufficient.

Actions release tags include an `-aosp14` suffix. If that tag already identifies
a different kernel commit, the new release adds the kernel's short commit ID.

The generated kernel images will be located at:

```text
out/arch/arm64/boot/Image
out/arch/arm64/boot/Image.gz
```

## Configuration

The kernel configuration is assembled from the following fragments:

```text
arch/arm64/configs/mt6768_slm_defconfig
arch/arm64/configs/a32.config
arch/arm64/configs/battery.config
arch/arm64/configs/ksu-a325n-common.config
arch/arm64/configs/a325n-release.config
```

The build script verifies the unmodified BakaSU source, merges these fragments, runs `olddefconfig`, and installs target UAPI headers before compiling the kernel and embedded preinit runner. `out/bakasu-source.txt` records the upstream SHA and clean submodule state.

### BakaSU main integration

- Use a Manager/ksud build with UAPI v6 to match the updated kernel.
- SUSFS preinit runs enabled modules' staged `preinit/preinit.conf` actions before SELinux policy loading. The runner is embedded in the kernel; ksud prepares its input under `/metadata` for the next boot. Actual execution depends on the ROM's init and early mounts and needs device verification.
- For this built-in configuration, `kernelsu.preinit=0` disables the preinit runner. Existing module boot scripts retain their normal stages.
- Kernel module loading retains the kernel's native blacklist behavior; no BakaSU blacklist acknowledgement hooks are added.
- SELinux hide uses BakaSU's supported manual SUSFS mode; policy logic remains upstream. The priority UID filter uses a parent-owned command bridge and package watcher, based on simonpunk `eb95da0`. See [SUSFS integration and usage](docs/susfs-integration.md).
- See [preinit integration notes](docs/bakasu-preinit.md) for manual builds, source checks and exec failure handling. The upstream support flag alone does not prove that a preinit action executed.

Some configuration files and build scripts retain the `a325n` name because the initial development and testing were performed on the SM-A325N. The resulting kernel is intended for the wider SM-A325 device family.

## Source and Credits

This project would not have been possible without the work of the following projects and developers.

### Base Kernel

- [Samsung-MT6769-Devs/android_kernel_samsung_mt6768](https://github.com/Samsung-MT6769-Devs/android_kernel_samsung_mt6768)

  This repository is based on and derived from the Samsung MT6768 kernel source maintained by Samsung-MT6769-Devs.

### BakaSU

- [Baka-SU/BakaSU](https://github.com/Baka-SU/BakaSU)

  BakaSU provides the KernelSU implementation and manager-side integration used by this kernel.

### KernelSU Backport References

- [backslashxx/KernelSU](https://github.com/backslashxx/KernelSU)

  Work by backslashxx was used as an important reference for KernelSU integration, non-GKI kernel compatibility, and support for older Android kernel versions.

### SUSFS

- [simonpunk/susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu)

  SUSFS and its original kernel patches are developed and maintained by Simonpunk. The Linux 4.14 base comes from JackA1ltman/NonGKI_Kernel_Build_2nd commit `dcd789634247c77d8549a42aef232c680a905585` (SUSFS v2.3.0). Parent-side fixes correct clone allocation control flow and keep private KSTAT flags out of statx replies. The priority UID filter is based on simonpunk `gki-android12-5.10` commit `eb95da080c76724c4962d0c62e9af3be37d9d439`, with parent-owned command/watcher integration. SELinux policy handling remains BakaSU code through its supported manual hooks.

- [JackA1ltman/NonGKI_Kernel_Build_2nd](https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd)

  A significant portion of the non-GKI SUSFS patch set was adapted from this repository. Its legacy/non-GKI integration approach was also used as a reference while updating NoMount. The patches were integrated into this kernel tree with additional compatibility changes and device-specific bug fixes.

### NoMount

- [maxsteeel/nomount](https://github.com/maxsteeel/nomount)

  NoMount provides mountless path redirection and virtual file injection. This kernel includes the upstream NoMount v2.2.0 kernel implementation as a built-in subsystem for the Linux 4.14 device tree. The source is pinned to commit `bf1847f98fed382369c43bfd652cd93774b9b8e3` and reports driver version `22 (605)`. Use the matching NoMount v2.2.0 metamodule and CLI: protocol v22 is incompatible with the older v21 tools.

### AnyKernel3

- [osm0sis/AnyKernel3](https://github.com/osm0sis/AnyKernel3)

  The flashable release package is based on AnyKernel3 by osm0sis.

Special thanks to all upstream Linux, Android, Samsung kernel, KernelSU, BakaSU, SUSFS, and AnyKernel3 contributors.

## Changes Specific to This Kernel

This repository contains device-specific integration and compatibility work, including:

- BakaSU integration for the Samsung Galaxy A32 SM-A325 kernel tree
- SUSFS v2.3.0 backport for Linux 4.14
- BakaSU SUSFS sucompat runtime handling for `execve`, post-exec SU sessions, `faccessat`, and stat-family lookups
- Refreshed SUSFS v2.3.0 kstat/statfs, inotify, proc-fd, mount-hiding, open-redirect, and map-spoofing integration based on the current non-GKI 4.14 reference patches
- Samsung 4.14 compatibility for KDP mount layout, VFS signatures and split smaps accounting; successful-exec SU session handling, NULL filename protection, mount-ID ownership and allocation failure fixes
- NoMount v2.2.0 built-in integration with mountless path redirection and virtual file injection
- Samsung and MediaTek compatibility adjustments
- `/proc/cmdline` spoofing stability fixes
- Compatibility fixes for older networking, memory-management, and kernel APIs
- Reproducible SM-A325 build configuration
- SM-A325 AnyKernel3 packaging

## Reporting Issues

When reporting an issue, include:

- Exact device model
- ROM and Android version
- Firmware or bootloader version
- BakaSU Manager version
- Kernel version shown in the manager
- Relevant kernel logs
- Steps required to reproduce the issue

Please clearly state whether the issue occurred on the tested SM-A325N or another regional SM-A325 variant.

Issues from devices outside the SM-A325 series may be closed without investigation.

Do not report issues to the upstream BakaSU, SUSFS, KernelSU, AnyKernel3, or base-kernel repositories unless the issue has been confirmed to originate from their unmodified upstream code.

## License

The Linux kernel source is distributed under the GNU General Public License version 2.

Additional components retain their respective upstream licenses. Refer to the following files and upstream repositories for details:

- `COPYING`
- `KernelSU/LICENSE`
- `KernelSU/kernel/LICENSE`

This repository does not change the licensing terms of any upstream project.

## Disclaimer

This is an independent community project.

It is not affiliated with, authorized by, maintained by, or endorsed by Samsung Electronics, BakaSU, KernelSU, SUSFS, AnyKernel3, or any other upstream project.
