# Hermes & React Native C++ Dependencies — Sea Packages Project

> **Last updated:** 2026-03-20
> **Status:** In progress — most deps published, hermes itself not yet published, CI failures on Linux/Windows for folly and boost

---

## Goal

Build and publish **all C++ dependencies required by React Native's Hermes JavaScript engine** through the [sea](https://github.com/rtorr/sea) package manager, using this repository (`sea-packages`) as the public registry backed by GitHub Releases.

### Why sea?

React Native's C++ dependency story is fragmented: Gradle downloads tarballs on Android, CocoaPods uses podspecs on iOS, and there is no unified cross-platform C++ package manager handling ABI safety, versioning, and caching. Sea fills that gap.

### End state

A developer (or CI) can run `sea install` in a project that depends on `hermes` and get a fully resolved, ABI-verified dependency tree — including folly and all of its transitive deps — downloaded, cached, and wired into CMake automatically.

---

## Architecture: What Depends on What

### Critical finding: Hermes itself has ZERO external C++ deps

Hermes (v0.13.0, current `main`) is **self-contained**. Its CMakeLists.txt does **not** call `find_package()` for folly, fmt, glog, boost, or double-conversion. It bundles:

- **LLVH** — internal LLVM fork (at `external/llvh/`)
- **JSI** — JavaScript Interface (bundled at `API/jsi`, or overridden via `-DJSI_DIR`)
- **ICU** — platform-provided on Android/Apple; system ICU on Linux; Windows 10 fallback

The only optional external dep is **fbjni** (Android JNI bindings, gated behind `HERMES_IS_ANDROID`).

### So why do we need folly/fmt/glog/boost?

These deps are needed by **React Native's integration layers** that sit on top of Hermes:

```
┌──────────────────────────────────────────────────┐
│              React Native App                     │
├──────────────────────────────────────────────────┤
│  reactnative.so / ReactNativeDependencies.xcfw   │
│  ┌──────────────┐  ┌───────────┐  ┌───────────┐ │
│  │ react_cxxreact│  │ jsireact  │  │ jsi (RN)  │ │
│  │ needs: folly, │  │ needs:    │  │ needs:    │ │
│  │ glog, boost   │  │ folly,glog│  │ folly,glog│ │
│  └──────┬───────┘  └─────┬─────┘  └─────┬─────┘ │
│         │                │               │        │
│  ┌──────┴────────────────┴───────────────┴─────┐ │
│  │         hermes-engine (prefab/framework)     │ │
│  │         NO external C++ deps                 │ │
│  └──────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────┤
│  folly_runtime ← fmt, boost, double-conversion,  │
│                   glog, gflags, fast-float,       │
│                   libevent, zstd, snappy, lz4,    │
│                   zlib                            │
└──────────────────────────────────────────────────┘
```

On Android, Hermes is built **separately** as a prefab AAR, then consumed via `find_package(hermes-engine REQUIRED CONFIG)` by the main RN CMake build. The two builds never share C++ dependencies.

### Implication for sea-packages

We are building **two independent dependency trees**:

1. **`hermes`** — standalone, needs only ICU (and fbjni on Android)
2. **`folly`** (and by extension, the full RN native layer) — needs 11 transitive deps

Both are valuable. Publishing hermes as a standalone sea package lets consumers use Hermes without RN. Publishing the folly tree lets consumers build RN's native modules.

---

## React Native Pinned Versions (main branch, 2026-03-20)

Source of truth: `packages/react-native/gradle/libs.versions.toml` (Android) and `third-party-podspecs/` (iOS).

| Dependency | Android (gradle) | iOS (podspec) | Sea version | Sea published? |
|---|---|---|---|---|
| **hermes** | V1: `250829098.0.11` | same | `0.13.0` | No |
| **folly** | `2024.11.18.00` | same (dynamic) | `2024.11.0` | macOS only |
| **fmt** | `12.1.0` | `12.1.0` | `11.0.2`, `11.1.0`, `12.1.0` | Yes (all 3 platforms) |
| **boost** | `1_83_0` | `1.84.0` (!) | `1.83.0` | macOS + Linux |
| **glog** | `0.3.5` | `0.3.5` | `0.3.5` | Yes (all 3 platforms) |
| **double-conversion** | `1.1.6` | `1.1.6` | `1.1.6` | Yes (all 3 platforms) |
| **fast-float** | `8.0.0` | `8.0.0` | `8.0.0` | Yes (header-only) |
| **fbjni** | `0.7.0` | N/A (Android only) | `0.7.0` | macOS + Linux |
| **gflags** | `2.2.0` | N/A | `2.2.0` | Yes (all 3 platforms) |

### Version discrepancies to track

- **fmt**: RN main now pins `12.1.0`, not `11.0.2`. We have `12.1.0` published — good. The `11.0.2` version in the folly sea.toml dep spec (`>=11.0.0`) will resolve to `12.1.0` if it's the latest compatible.
- **boost**: Android says `1.83.0`, iOS podspec says `1.84.0`. We have `1.83.0`. May need `1.84.0` for iOS parity.
- **hermes**: RN uses a custom versioning scheme (`250829098.0.11`) tied to their CI. Our `0.13.0` corresponds to the `v0.13.0` git tag. These are different release channels — RN's hermes versions are cut from `main`, not from git tags.
- **folly**: We have `2024.11.0` in sea, which downloads from the `v2024.11.18.00` tag. The version string in sea.toml should probably be `2024.11.18.00` to match exactly.

---

## Package Publication Status

### Fully published (all 3 platforms: macOS, Linux, Windows)

| Package | Version |
|---|---|
| fmt | 11.0.2, 11.1.0, 12.1.0 |
| glog | 0.3.5, 0.7.0 |
| double-conversion | 1.1.6, 3.3.0 |
| gflags | 2.2.0 |
| snappy | 1.2.0 |
| libevent | 2.1.0 |
| zstd | 1.5.0 |
| lz4 | 1.10.0 |
| zlib | 1.3.0 |
| xxhash | 0.8.0 |

### Header-only (platform-agnostic, fully published)

| Package | Version |
|---|---|
| fast-float | 8.0.0 |
| boost-headers | 1.83.0, 1.87.0 |
| nlohmann-json | 3.11.0 |
| doctest | 2.4.0 |

### Published on macOS + Linux

| Package | Version | Notes |
|---|---|---|
| **hermes** | 0.13.0 | macOS + Linux. Windows fails (MSVC CompressedPointer issue in v0.13.0) |
| **folly** | 2024.11.0 | All 3 platforms! Windows uses static build (no dllexport annotations) |
| **boost** (compiled) | 1.83.0 | All 3 platforms! Builds both static+shared. |
| **fbjni** | 0.7.0 | macOS + Linux. Windows may not apply (Android-only dep) |

---

## Issues Fixed (2026-03-20/21 session)

### Linux PIC issue (RESOLVED)
All folly deps needed `-DCMAKE_POSITION_INDEPENDENT_CODE=ON` in their sea.toml
cmake_args. Static `.a` files without PIC cannot be linked into shared `.so` libs.
Fixed for: double-conversion, libevent, gflags, glog, zstd, zlib, fmt.

### Hermes CMP0026 (RESOLVED)
cmake 4.0 removed support for `cmake_policy(SET CMP0026 OLD)`. Hermes build.sh
patches this to `NEW`. Also patches `DomainState.cpp` to include `<string>` for GCC 13.

### Boost Windows (RESOLVED)
b2 needs `cmd //c bootstrap.bat` and `toolset=msvc address-model=64` on Windows.
Build produces both static and shared (`link=static,shared`).

### Folly Windows (RESOLVED)
- VS multi-config generator breaks `file(GENERATE)` for `libfolly.pc` → pkgconfig
  block is commented out by sed patch
- Boost cmake detects MinGW GCC instead of MSVC → override with `-DBoost_COMPILER=-vc143`
- Folly lacks `__declspec(dllexport)` → build as static on Windows
- libevent cmake config has hardcoded paths → remove libevent cmake dir at build time

### Hermes Windows (OPEN)
MSVC error: `CompressedPointer: no appropriate default constructor available` in
`HadesGC.cpp:964`. This is a Hermes v0.13.0 bug on MSVC. May need a newer version
or MSVC-specific patches.

### Non-relocatable cmake configs (SYSTEMIC)
Published sea packages embed absolute build paths in cmake config files. This breaks
`find_package()` on machines with different paths. Currently worked around per-package
(removing cmake config dirs). Should be fixed in the sea CLI long-term.

---

## Hermes sea.toml — Current vs. Needed

### Current (`packages/hermes/0.13.0/sea.toml`)

```toml
[package]
name = "hermes"
version = "0.13.0"
kind = "source"
description = "Hermes JavaScript engine"

[build]
cmake_args = ["-DHERMES_BUILD_APPLE_FRAMEWORK=OFF", "-DHERMES_ENABLE_TEST_SUITE=OFF", "-DCMAKE_CXX_STANDARD=17"]

[build.source]
url = "https://github.com/facebook/hermes/archive/refs/tags/v0.13.0.tar.gz"

[publish]
registry = "sea-packages"
include = ["include/**", "lib/**", "bin/**", "share/**"]
```

### Assessment

The sea.toml is **correct as-is** for a standalone Hermes build. Hermes does not need a `[dependencies]` section because it has no external C++ deps. The only thing it needs is:

- **ICU**: On Linux, system ICU must be installed (`libicu-dev`). On macOS and Windows, platform ICU is used automatically. This is a system-level dep, not a sea package dep.
- **Python**: Required by Hermes's build system for code generation. Also a system-level dep.

### Potential improvements

```toml
[build]
cmake_args = [
    "-DHERMES_BUILD_APPLE_FRAMEWORK=OFF",
    "-DHERMES_ENABLE_TEST_SUITE=OFF",
    "-DCMAKE_CXX_STANDARD=17",
    "-DHERMES_ENABLE_TOOLS=ON",       # builds hermesc compiler
    "-DBUILD_SHARED_LIBS=ON",
]
```

Consider whether we want `hermesc` (the Hermes bytecode compiler) included in the published package — it's useful for ahead-of-time JS compilation.

---

## Remaining Work

### Priority 1: Hermes Windows (MSVC compilation bug)

Hermes v0.13.0 fails on MSVC with `CompressedPointer: no appropriate default constructor`
in `HadesGC.cpp`. Options:
1. Patch `CompressedPointer` to add a default constructor
2. Use a newer Hermes version where this is fixed
3. Accept macOS+Linux only for now (Windows Hermes is rarely needed — RN Android uses NDK/Clang)

### Priority 2: Version alignment

1. Decide whether to update folly sea version string from `2024.11.0` to `2024.11.18.00` for clarity
2. Consider adding boost `1.84.0` for iOS podspec parity
3. Consider whether we need an RN-versioned hermes package (matching `250829098.0.11`) or if the git-tag-based `0.13.0` is sufficient
4. RN main pins fmt `12.1.0` — our folly `>=11.0.0` constraint resolves to this correctly

### Priority 3: Sea CLI improvements

1. Add `-DCMAKE_POSITION_INDEPENDENT_CODE=ON` to auto-detected cmake builds (fix exists in seapkg but not released)
2. Fix non-relocatable cmake config files in published packages (systemic issue)
3. Release new `sea` binary to pick up these fixes

### Priority 4 (future): Full RN native layer package

Create a meta-package or documented recipe that pulls hermes + folly + all transitive deps together, representing the complete C++ dependency set for building React Native native modules with sea.

### Completed (2026-03-20/21)

- [x] Hermes published (macOS + Linux)
- [x] Folly published (all 3 platforms)
- [x] All folly deps rebuilt with PIC (Linux fix)
- [x] Boost compiled on all 3 platforms (Windows b2 fix)
- [x] Hermes GCC 13 compilation fix (missing `<string>` include)
- [x] Hermes cmake 4.0 compatibility (CMP0026 patch)
- [x] Folly Windows: pkgconfig patch, Boost_COMPILER, static build

---

## How the Sea Build System Works (Reference)

### Package manifest (`sea.toml`)

```toml
[package]
name = "example"
version = "1.0.0"
kind = "source"           # "source" for compiled libs, or header-only detection

[dependencies]
fmt = { version = ">=11.0.0" }
boost = { version = "^1.83.0" }    # ^1.83.0 means >=1.83.0 <2.0.0

[build]
script = "build.sh"                 # optional custom build script
cmake_args = ["-DFOO=ON"]           # passed to cmake if no script

[build.source]
url = "https://example.com/source.tar.gz"   # auto-downloaded

[publish]
registry = "sea-packages"
include = ["include/**", "lib/**", "bin/**", "share/**"]
```

### Dependency resolution flow

1. `sea install` reads `[dependencies]`, resolves versions from the registry
2. Downloads pre-built packages from GitHub Releases to `~/.sea/cache/`
3. Symlinks each dep into `sea_packages/<pkg-name>/` (with `include/`, `lib/`, etc.)
4. Generates `sea_packages/sea-cmake.cmake` that appends all dep paths to `CMAKE_PREFIX_PATH`

### Build flow

1. `sea build` downloads source from `[build.source].url` into `_src/`
2. If `build.script` exists, runs it with env vars (`SEA_PACKAGES_DIR`, `SEA_INSTALL_DIR`, etc.)
3. If no script, auto-detects CMake and runs it with `cmake_args` + auto-injected `CMAKE_PREFIX_PATH`
4. Output goes to `sea_build/<ABI_TAG>/`

### Key environment variables during build

| Variable | Value |
|---|---|
| `SEA_PACKAGES_DIR` | `<project>/sea_packages` — where deps are linked |
| `SEA_INSTALL_DIR` | `<project>/sea_build/<ABI_TAG>` — install prefix |
| `SEA_PROJECT_DIR` | Project root (where sea.toml lives) |
| `SEA_OS` | `darwin`, `linux`, `windows` |
| `SEA_ARCH` | `aarch64`, `amd64` |

### Publishing

```bash
sea publish              # uploads to configured registry (GitHub Releases)
sea publish --dry-run    # preview without uploading
```

Creates a GitHub Release tagged `<name>/v<version>` with platform-specific `.tar.zst` assets.

---

## Repository Layout

```
sea-packages/
├── .github/workflows/build-packages.yml    # CI: detect changes → build → publish
├── README.md                                # Public registry docs
├── HERMES_PROJECT.md                        # This file
└── packages/
    ├── hermes/0.13.0/sea.toml              # Hermes JS engine
    ├── folly/2024.11.0/sea.toml            # Facebook's C++ library (11 deps)
    ├── fmt/12.1.0/sea.toml                 # (also 11.0.2, 11.1.0)
    ├── boost/1.83.0/sea.toml               # Compiled boost (with b2)
    ├── boost-headers/1.83.0/sea.toml       # Header-only boost
    ├── glog/0.3.5/sea.toml                 # Google logging
    ├── gflags/2.2.0/sea.toml               # Google command-line flags
    ├── double-conversion/1.1.6/sea.toml    # Binary-decimal conversion
    ├── fast-float/8.0.0/sea.toml           # Fast float parsing (header-only)
    ├── fbjni/0.7.0/sea.toml                # Facebook JNI (Android)
    ├── libevent/2.1.0/sea.toml             # Event notification
    ├── zstd/1.5.0/sea.toml                 # Zstandard compression
    ├── snappy/1.2.0/sea.toml               # Fast compression
    ├── lz4/1.10.0/sea.toml                 # LZ4 compression
    ├── zlib/1.3.0/sea.toml                 # zlib compression
    └── ... (+ sqlite3, xxhash, spdlog, cjson, nlohmann-json, doctest)
```
