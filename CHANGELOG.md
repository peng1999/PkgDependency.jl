# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2022-09-17

### Added

- `tree(...; reverse=true)` to get reverse dependencies. ([#5])

### Changed

- `tree()` will throw a custom error when package is not found. ([#4])

### Fixed

- Error with packages with empty dependency. ([#6])
- Accpect all transitive dependent package name.

## [0.1.0] - 2022-09-01

### Added

- `tree()` function to display dependency tree of packages.

[Unreleased]: https://github.com/peng1999/PkgDependency.jl/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/peng1999/PkgDependency.jl/releases/tag/v0.2.0
[0.1.0]: https://github.com/peng1999/PkgDependency.jl/releases/tag/v0.1.0

[#4]: https://github.com/peng1999/PkgDependency.jl/issues/4
[#5]: https://github.com/peng1999/PkgDependency.jl/issues/5
[#6]: https://github.com/peng1999/PkgDependency.jl/issues/6
