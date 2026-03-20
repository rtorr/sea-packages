# sea-packages

Public package registry for [sea](https://github.com/rtorr/sea) — the C/C++ package manager with ABI safety.

## Using these packages

```bash
# Add this registry
sea remote add packages github-releases rtorr/sea-packages

# Install packages
sea install cjson@1.8.0
sea install lz4 zlib sqlite3
```

## Available Packages

| Package | Version(s) | Type | Description |
|---------|-----------|------|-------------|
| boost-headers | 1.87.0 | C++ header-only | Boost C++ Libraries (headers) |
| cjson | 1.7.0, 1.8.0 | C | Ultralightweight JSON parser |
| doctest | 2.4.0 | C++ header-only | Fast testing framework |
| double-conversion | 3.3.0 | C++ | Binary-decimal conversion |
| fmt | 11.1.0 | C++ | Modern formatting library |
| folly | 2024.12.0 | C++ | Facebook's C++ library |
| gflags | 2.2.0 | C++ | Command line flags |
| glog | 0.7.0 | C++ | Google logging (depends on gflags) |
| libevent | 2.1.0 | C | Event notification library |
| lz4 | 1.10.0 | C | Fast compression |
| nlohmann-json | 3.11.0 | C++ header-only | JSON for Modern C++ |
| snappy | 1.2.0 | C++ | Fast compression |
| spdlog | 1.14.0 | C++ | Fast logging (depends on fmt) |
| sqlite3 | 3.45.0 | C | Embedded SQL database |
| xxhash | 0.8.0 | C | Fast hashing |
| zlib | 1.3.0 | C | Compression |
| zstd | 1.5.0 | C | Zstandard compression |

## Repository structure

```
packages/
  {name}/{version}/
    sea.toml      # package manifest
    build.sh      # build script (downloads and compiles upstream source)
    test/         # optional verification tests
```

Each package is built from upstream source. The `build.sh` scripts download the source tarball, compile it, and install headers + libraries to the output directory. Sea handles the rest: symbol extraction, ABI verification, archive creation, and publishing to GitHub Releases.

## Building packages locally

```bash
cd packages/cjson/1.8.0
sea build              # downloads source, compiles, verifies
sea publish --dry-run   # see what would be published
```

## Adding a new package

1. Create `packages/{name}/{version}/sea.toml` and `build.sh`
2. Test locally: `sea build && sea publish --dry-run`
3. Open a PR

## Built from upstream sources

All packages are built from official upstream releases:
- Boost: https://www.boost.org/
- cJSON: https://github.com/DaveGamble/cJSON
- double-conversion: https://github.com/google/double-conversion
- fmt: https://github.com/fmtlib/fmt
- Folly: https://github.com/facebook/folly
- gflags: https://github.com/gflags/gflags
- glog: https://github.com/google/glog
- libevent: https://github.com/libevent/libevent
- lz4: https://github.com/lz4/lz4
- nlohmann-json: https://github.com/nlohmann/json
- snappy: https://github.com/google/snappy
- spdlog: https://github.com/gabime/spdlog
- SQLite: https://www.sqlite.org/
- xxHash: https://github.com/Cyan4973/xxHash
- zlib: https://github.com/madler/zlib
- Zstandard: https://github.com/facebook/zstd
