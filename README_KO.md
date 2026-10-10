# Samsung Galaxy A32 BakaSU 커널

Samsung MT6768 커널 소스를 기반으로 **BakaSU**와 **SUSFS**를 통합한 **Samsung Galaxy A32 4G(SM-A325 시리즈)**용 커스텀 Android 커널입니다.

이 커널은 SM-A325N과 SM-A325F를 포함한 SM-A325 계열의 지역별 모델을 대상으로 합니다. 실제 테스트는 SM-A325N에서 진행되었습니다. 모든 지역별 모델, 펌웨어 버전 및 ROM과의 호환성을 보장하지는 않습니다.

[English README](README.md)

## 지원 기기

- 기기: Samsung Galaxy A32 4G
- 대상 모델: SM-A325 시리즈
- 테스트된 모델: SM-A325N
- 플랫폼: MediaTek MT6768
- Android 버전: Android 12
- 커널 버전: Linux 4.14.357
- 커널 릴리스: `4.14.357-openela-vigus-slmkernel-a32`

다른 SM-A325 지역별 모델도 동일한 기반 플랫폼과 커널 트리를 사용하므로 호환될 가능성이 있습니다. 다만 플래시하기 전에 반드시 기존 부트 이미지를 백업하세요.

## 주요 기능

<!-- AUTO:BAKASU:START -->
- BakaSU `v4.2.0-rc3`
- BakaSU 커널 버전 코드 `35222`
- BakaSU 커밋 [`5b76b884`](https://github.com/Baka-SU/BakaSU/commit/5b76b884c75f729a220bb317aa4a4fc78f0e0e9c)
<!-- AUTO:BAKASU:END -->
- SUSFS `v2.3.0`
- KernelSU 멀티 매니저 지원
- 이 Non-GKI Linux 4.14 트리를 위한 BakaSU SUSFS inline-hook 통합(KProbes/Kretprobes는 호환성을 위해 활성화)
- SELinux Enforcing
- NoMount `v2.1.0` 내장형 경로 리다이렉션 및 가상 파일 주입
- SUSFS 마운트 숨김
- SUSFS 경로 숨김
- SUSFS kstat 위조
- SUSFS uname 위조
- SUSFS `/proc/cmdline` 위조
- `/proc/kallsyms`에서 KernelSU 및 SUSFS 심볼 자동 숨김
- SUSFS open redirect
- SUSFS 메모리 맵 숨김
- 릴리스 빌드에서 SUSFS 런타임 로그 비활성화
- AnyKernel3 설치 패키지

## 중요 안내

이 커널은 커스텀 커널, 부트로더 잠금 해제, 커스텀 리커버리 환경 및 기기 복구 절차를 이해하고 있는 사용자를 대상으로 합니다.

커스텀 커널을 플래시하면 다음과 같은 문제가 발생할 수 있습니다.

- 부팅 실패
- 데이터 손실
- 루트 권한 작동 중단
- 일부 ROM 또는 펌웨어 버전과의 비호환
- Knox 워런티 비트 변경
- 그 밖의 기기별 문제

기기에서 발생하는 모든 결과에 대한 책임은 사용자에게 있습니다. 플래시하기 전에 항상 정상 작동하는 부트 이미지 또는 전체 펌웨어 패키지를 준비해 두세요.

## 설치 방법

1. 사용 중인 기기가 Samsung Galaxy A32 4G SM-A325 시리즈인지 확인하세요.
2. 현재 부트 이미지를 백업하세요.
3. Releases 페이지에서 최신 AnyKernel3 ZIP을 다운로드하세요.
4. 호환되는 커스텀 리커버리 또는 커널 플래시 애플리케이션을 사용해 ZIP을 플래시하세요.
5. 기기를 재부팅하세요.
6. 호환되는 BakaSU Manager가 설치되어 있지 않다면 설치하세요.

이 커널은 SM-A325N에서 테스트되었습니다. 다른 SM-A325 모델 사용자는 플래시하기 전에 기존 부트 이미지를 복구할 수 있는지 반드시 확인하세요.

SM-A325 시리즈가 아닌 기기에는 이 커널을 플래시하지 마세요.

## 빌드 방법

BakaSU 서브모듈을 포함하여 저장소를 복제하세요.

```bash
git clone --recursive https://github.com/mzggr0914/android_kernel_a325x_bakasu.git
cd android_kernel_a325x_bakasu
```

서브모듈 없이 저장소를 복제했다면 다음 명령으로 서브모듈을 초기화하세요.

```bash
git submodule update --init --recursive
```

호환되는 LLVM/Clang 툴체인의 경로를 지정한 후 빌드 스크립트를 실행하세요.

```bash
TOOLCHAIN=/path/to/clang ./build_a325n.sh
```

선택적으로 다음 빌드 변수를 지정할 수 있습니다.

```bash
TOOLCHAIN=/path/to/clang \
OUT_DIR=/path/to/output \
JOBS=$(nproc) \
./build_a325n.sh
```

생성된 커널 이미지는 다음 경로에 저장됩니다.

```text
out/arch/arm64/boot/Image
out/arch/arm64/boot/Image.gz
```

## 설정

커널 설정은 다음 설정 조각을 병합하여 생성됩니다.

```text
arch/arm64/configs/mt6768_slm_defconfig
arch/arm64/configs/a32.config
arch/arm64/configs/battery.config
arch/arm64/configs/ksu-a325n-common.config
arch/arm64/configs/a325n-release.config
```

빌드 스크립트는 위 설정 조각을 병합하고 `olddefconfig`를 실행한 다음 커널을 컴파일합니다.

초기 개발과 테스트가 SM-A325N에서 진행되었기 때문에 일부 설정 파일과 빌드 스크립트에는 `a325n`이라는 이름이 유지되어 있습니다. 빌드되는 커널 자체는 더 넓은 SM-A325 기기 계열을 대상으로 합니다.

## 소스 및 크레딧

이 프로젝트는 다음 프로젝트와 개발자들의 작업이 없었다면 만들어질 수 없었습니다.

### 기본 커널

- [Samsung-MT6769-Devs/android_kernel_samsung_mt6768](https://github.com/Samsung-MT6769-Devs/android_kernel_samsung_mt6768)

  이 저장소는 Samsung-MT6769-Devs에서 관리하는 Samsung MT6768 커널 소스를 기반으로 제작되었습니다.

### BakaSU

- [Baka-SU/BakaSU](https://github.com/Baka-SU/BakaSU)

  BakaSU는 이 커널에 사용된 KernelSU 구현과 매니저 측 통합 기능을 제공합니다.

### KernelSU 백포트 참고 자료

- [backslashxx/KernelSU](https://github.com/backslashxx/KernelSU)

  backslashxx의 작업은 KernelSU 통합, Non-GKI 커널 호환성 및 구형 Android 커널 지원을 구현하는 데 중요한 참고 자료로 사용되었습니다.

### SUSFS

- [simonpunk/susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu)

  SUSFS와 원본 커널 패치는 Simonpunk가 개발하고 관리합니다. 이 커널에는 SUSFS v2.3.0을 기반으로 한 Linux 4.14 포팅이 포함되어 있습니다. 패치 참고 기준은 NonGKI_Kernel_Build_2nd 커밋 `b5d7e5be60398f040b9e9919186c410c01a228da`에 고정했으며, Simonpunk 커밋 `f3b5aecf53ff8b3296603071b91383f6be6c7cbb`의 `clone_mnt()` 레이스 수정과 A32 호환성 수정을 포함합니다.

- [JackA1ltman/NonGKI_Kernel_Build_2nd](https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd)

  Non-GKI SUSFS 패치의 상당 부분은 이 저장소를 기반으로 적용되었습니다. NoMount 업데이트 과정에서도 구형/Non-GKI 커널 통합 방식을 참고했습니다. 이후 이 커널 트리에 맞는 추가 호환성 수정과 기기별 버그 수정이 적용되었습니다.

### NoMount

- [maxsteeel/nomount](https://github.com/maxsteeel/nomount)

  NoMount는 별도의 파일시스템 마운트 없이 경로 리다이렉션과 가상 파일 주입 기능을 제공합니다. 이 커널에는 Linux 4.14 기기 트리에 맞춰 업스트림 NoMount v2.1.0 커널 구현이 built-in 서브시스템으로 통합되어 있습니다. 소스는 커밋 `c7f63e3feb4125d591b6969a33aac04feb40f8ba`에 고정되어 있으며 드라이버 버전은 `21-500`으로 표시됩니다. 일치하는 NoMount v2.1.0 메타모듈과 CLI를 사용하세요.

### AnyKernel3

- [osm0sis/AnyKernel3](https://github.com/osm0sis/AnyKernel3)

  플래시 가능한 릴리스 패키지는 osm0sis의 AnyKernel3를 기반으로 제작되었습니다.

Linux, Android, Samsung 커널, KernelSU, BakaSU, SUSFS 및 AnyKernel3의 모든 업스트림 기여자에게 감사드립니다.

## 이 커널에 적용된 변경 사항

이 저장소에는 다음과 같은 기기별 통합 및 호환성 작업이 포함되어 있습니다.

- Samsung Galaxy A32 SM-A325 커널 트리를 위한 BakaSU 통합
- Linux 4.14용 SUSFS v2.3.0 백포트
- `execve`, post-exec SU session, `faccessat` 및 stat 계열 조회를 위한 BakaSU SUSFS sucompat 런타임 처리
- 최신 Non-GKI 4.14 참고 패치를 기반으로 갱신한 SUSFS v2.3.0 kstat/statfs, inotify, proc-fd, mount hiding, open redirect 및 map spoofing 통합
- post-exec 부트 멈춤, kstat 플래그 충돌, statfs spoof 반환 처리, readlink/open-redirect 의미론, mount reference 처리 및 SUSFS allocation failure 경로에 대한 A32 전용 버그 수정
- 마운트 없는 경로 리다이렉션과 가상 파일 주입을 제공하는 NoMount v2.1.0 built-in 통합
- Samsung 및 MediaTek 호환성 수정
- `/proc/cmdline` 위조 안정성 수정
- 구형 네트워크, 메모리 관리 및 커널 API 호환성 수정
- 재현 가능한 SM-A325 빌드 설정
- SM-A325용 AnyKernel3 패키징

## 문제 보고

문제를 보고할 때는 다음 정보를 포함해 주세요.

- 정확한 기기 모델
- ROM 및 Android 버전
- 펌웨어 또는 부트로더 버전
- BakaSU Manager 버전
- 매니저에 표시되는 커널 버전
- 관련 커널 로그
- 문제를 재현하는 데 필요한 절차

문제가 테스트된 SM-A325N에서 발생했는지, 다른 지역별 SM-A325 모델에서 발생했는지도 명확히 적어 주세요.

SM-A325 시리즈가 아닌 기기에서 발생한 문제는 조사 없이 종료될 수 있습니다.

문제가 수정되지 않은 업스트림 코드에서 발생한 것으로 확인되지 않았다면 BakaSU, SUSFS, KernelSU, AnyKernel3 또는 기본 커널의 업스트림 저장소에 문제를 보고하지 마세요.

## 라이선스

Linux 커널 소스는 GNU General Public License 버전 2에 따라 배포됩니다.

추가 구성 요소에는 각각의 업스트림 라이선스가 그대로 적용됩니다. 자세한 내용은 다음 파일과 업스트림 저장소를 참고하세요.

- `COPYING`
- `KernelSU/LICENSE`
- `KernelSU/kernel/LICENSE`

이 저장소는 업스트림 프로젝트의 라이선스 조건을 변경하지 않습니다.

## 면책 조항

이 프로젝트는 독립적인 커뮤니티 프로젝트입니다.

Samsung Electronics, BakaSU, KernelSU, SUSFS, AnyKernel3 또는 그 밖의 업스트림 프로젝트와 제휴되어 있지 않으며, 이들로부터 승인, 유지보수 또는 보증을 받지 않습니다.
