# Samsung Galaxy A32 ReSukiSU Kernel

Custom Android kernel for the **Samsung Galaxy A32 4G (SM-A325 series)**, based on the Samsung MT6768 kernel source and integrated with **ReSukiSU** and **SUSFS**.

This kernel is intended for the SM-A325 family, including regional variants such as the SM-A325N and SM-A325F. It has been tested on the SM-A325N. Compatibility with every regional variant, firmware release, and ROM cannot be guaranteed.

[한국어 README](README_KO.md)

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

<!-- AUTO:RESUKISU:START -->
- ReSukiSU `v4.2.0-rc3`
- ReSukiSU kernel version code `35196`
- ReSukiSU commit [`b0fa24df`](https://github.com/ReSukiSU/ReSukiSU/commit/b0fa24df91674e02e8fba29ad31ddff0174456ca)
<!-- AUTO:RESUKISU:END -->
- SUSFS `v2.3.0`
- KernelSU multi-manager support
- ReSukiSU SUSFS inline-hook integration for this non-GKI Linux 4.14 tree (KProbes/Kretprobes remain enabled for compatibility)
- SELinux enforcing
- NoMount `v2.0.0` built-in path redirection and virtual file injection
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
6. Install a compatible ReSukiSU Manager build if it is not already installed.

The kernel has been tested on the SM-A325N. Users of other SM-A325 variants should verify that they can restore the original boot image before flashing.

Do not flash this kernel on devices outside the SM-A325 series.

## Building

Clone the repository with its ReSukiSU submodule:

```bash
git clone --recursive https://github.com/mzggr0914/android_kernel_a325x_resukisu.git
cd android_kernel_a325x_resukisu
```

If the repository was cloned without submodules, initialize them manually:

```bash
git submodule update --init --recursive
```

Set the path to a compatible LLVM/Clang toolchain and run:

```bash
TOOLCHAIN=/path/to/clang ./build_a325n.sh
```

Optional build variables:

```bash
TOOLCHAIN=/path/to/clang \
OUT_DIR=/path/to/output \
JOBS=$(nproc) \
./build_a325n.sh
```

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

The build script merges these fragments and runs `olddefconfig` before compiling the kernel.

Some configuration files and build scripts retain the `a325n` name because the initial development and testing were performed on the SM-A325N. The resulting kernel is intended for the wider SM-A325 device family.

## Source and Credits

This project would not have been possible without the work of the following projects and developers.

### Base Kernel

- [Samsung-MT6769-Devs/android_kernel_samsung_mt6768](https://github.com/Samsung-MT6769-Devs/android_kernel_samsung_mt6768)

  This repository is based on and derived from the Samsung MT6768 kernel source maintained by Samsung-MT6769-Devs.

### ReSukiSU

- [ReSukiSU/ReSukiSU](https://github.com/ReSukiSU/ReSukiSU)

  ReSukiSU provides the KernelSU implementation and manager-side integration used by this kernel.

### KernelSU Backport References

- [backslashxx/KernelSU](https://github.com/backslashxx/KernelSU)

  Work by backslashxx was used as an important reference for KernelSU integration, non-GKI kernel compatibility, and support for older Android kernel versions.

### SUSFS

- [simonpunk/susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu)

  SUSFS and its original kernel patches are developed and maintained by Simonpunk. This kernel includes a Linux 4.14 port based on SUSFS v2.3.0.

- [JackA1ltman/NonGKI_Kernel_Build_2nd](https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd)

  A significant portion of the non-GKI SUSFS patch set was adapted from this repository. Its legacy/non-GKI integration approach was also used as a reference while updating NoMount. The patches were integrated into this kernel tree with additional compatibility changes and device-specific bug fixes.

### NoMount

- [maxsteeel/nomount](https://github.com/maxsteeel/nomount)

  NoMount provides mountless path redirection and virtual file injection. This kernel includes the upstream NoMount v2.0.0 kernel implementation as a built-in subsystem for the Linux 4.14 device tree.

### AnyKernel3

- [osm0sis/AnyKernel3](https://github.com/osm0sis/AnyKernel3)

  The flashable release package is based on AnyKernel3 by osm0sis.

Special thanks to all upstream Linux, Android, Samsung kernel, KernelSU, ReSukiSU, SUSFS, and AnyKernel3 contributors.

## Changes Specific to This Kernel

This repository contains device-specific integration and compatibility work, including:

- ReSukiSU integration for the Samsung Galaxy A32 SM-A325 kernel tree
- SUSFS v2.3.0 backport for Linux 4.14
- ReSukiSU SUSFS sucompat runtime handling for `execve`, post-exec SU sessions, `faccessat`, and stat-family lookups
- Refreshed SUSFS v2.3.0 kstat/statfs, inotify, proc-fd, mount-hiding, open-redirect, and map-spoofing integration based on the current non-GKI 4.14 reference patches
- A32-specific fixes for post-exec boot hangs, kstat flag collisions, statfs spoof return handling, readlink/open-redirect semantics, mount reference handling, and SUSFS allocation failure paths
- NoMount v2.0.0 built-in integration with mountless path redirection and virtual file injection
- Samsung and MediaTek compatibility adjustments
- Mount ID normalization for zygote namespaces
- Mount peer-group filtering fixes
- `/proc/cmdline` spoofing stability fixes
- Compatibility fixes for older networking, memory-management, and kernel APIs
- Reproducible SM-A325 build configuration
- SM-A325 AnyKernel3 packaging

## Reporting Issues

When reporting an issue, include:

- Exact device model
- ROM and Android version
- Firmware or bootloader version
- ReSukiSU Manager version
- Kernel version shown in the manager
- Relevant kernel logs
- Steps required to reproduce the issue

Please clearly state whether the issue occurred on the tested SM-A325N or another regional SM-A325 variant.

Issues from devices outside the SM-A325 series may be closed without investigation.

Do not report issues to the upstream ReSukiSU, SUSFS, KernelSU, AnyKernel3, or base-kernel repositories unless the issue has been confirmed to originate from their unmodified upstream code.

## License

The Linux kernel source is distributed under the GNU General Public License version 2.

Additional components retain their respective upstream licenses. Refer to the following files and upstream repositories for details:

- `COPYING`
- `KernelSU/LICENSE`
- `KernelSU/kernel/LICENSE`

This repository does not change the licensing terms of any upstream project.

## Disclaimer

This is an independent community project.

It is not affiliated with, authorized by, maintained by, or endorsed by Samsung Electronics, ReSukiSU, KernelSU, SUSFS, AnyKernel3, or any other upstream project.
