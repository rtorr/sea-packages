# sea-packages

Public package registry for [sea](https://github.com/rtorr/sea) — the C/C++ package manager with ABI safety.

## Packages

| Package | Version | Description |
|---------|---------|-------------|
| cjson | 1.7.0, 1.8.0 | Ultralightweight JSON parser in ANSI C |
| lz4 | 1.10.0 | Extremely fast compression algorithm |
| fmt | 11.1.0 | Modern C++ formatting library |

## Usage

```bash
# Add this registry
sea remote add sea-packages filesystem /path/to/sea-packages

# Install a package
sea install cjson@1.7.0
```

## Layout

```
{package}/{version}/{abi_tag}/
  {package}-{version}-{abi_tag}.tar.zst   # compiled archive
  sea-package.toml                         # metadata + symbols + deps
{package}/{version}/sea-version.toml       # version manifest (all platforms)
```

## Building from source

Each package was built from upstream source:
- **cjson**: https://github.com/DaveGamble/cJSON (v1.7.17)
- **lz4**: https://github.com/lz4/lz4 (v1.10.0)
- **fmt**: https://github.com/fmtlib/fmt (v11.1.4)
