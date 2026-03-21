# sea-packages — C++ Package Registry

Public package registry for [sea](https://github.com/rtorr/sea), backed by GitHub Releases.
Located at `/Users/rtorr/personal/sea-packages`.

## Structure

```
packages/<name>/<version>/
  sea.toml      — package manifest (deps, build config, source URL)
  build.sh      — optional custom build script (if cmake auto-detect isn't enough)
```

## Adding a Package

1. `mkdir -p packages/<name>/<version>`
2. Create `sea.toml` with `[package]`, `[build.source]`, `[publish]`
3. Add `-DCMAKE_POSITION_INDEPENDENT_CODE=ON` to cmake_args (required for Linux shared libs)
4. `sea build` to verify locally
5. `sea publish --registry sea-packages --skip-verify` for local platform
6. `./scripts/publish-one.sh <name>/<version> --ci` to trigger all platforms

## Scripts

- `scripts/publish-all.sh [--watch]` — trigger CI for ALL packages, optionally wait
- `scripts/publish-one.sh <name>/<version> [--ci]` — build+publish one package
- `scripts/check-status.sh` — show publication status across platforms

## CI

`.github/workflows/build-packages.yml` detects changed packages on push and builds on
ubuntu-latest, macos-latest, windows-latest. Also supports `workflow_dispatch` with a
`package` input for manual triggers.

CI downloads `sea` from the latest GitHub release of `rtorr/sea`.

## Key Lessons (from building React Native's deps)

- **Always set `-DCMAKE_POSITION_INDEPENDENT_CODE=ON`** in cmake_args
- **Windows MSVC + shared libs**: most C++ libs lack `__declspec(dllexport)`, build static
- **Boost Windows**: needs `cmd //c bootstrap.bat`, `toolset=msvc`, `address-model=64`
- **folly Windows**: needs pkgconfig block removed, `-DBoost_COMPILER=-vc143`, static build
- **Hermes**: needs CMP0026 NEW patch, `<string>` include for GCC 13, union init fix for MSVC
- **libevent cmake configs**: sea's relocator handles SONAME paths at publish time
- **Source pinning**: use `build.source.commit` for reproducible builds from git branches

## Related

- sea CLI: `/Users/rtorr/personal/seapkg`
- ReactCommon standalone build: `/Users/rtorr/rn-pal/standalone/`
- Project documentation: `HERMES_PROJECT.md` in this repo
