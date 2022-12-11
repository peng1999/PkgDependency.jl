# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2022-12-11

### Added

- Option to show the repo link ([#11])
- Option to not cut duplicate branches in tree ([#10])

### Fixed

- Error when showing compat info of legacy packages

## [0.3.0] - 2022-10-31

### Added

- Option to show compat info ([#7])

### Fixed

- Title display in non-package workspace

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

[Unreleased]: https://github.com/peng1999/PkgDependency.jl/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/peng1999/PkgDependency.jl/releases/tag/v0.4.0
[0.3.0]: https://github.com/peng1999/PkgDependency.jl/releases/tag/v0.3.0
[0.2.0]: https://github.com/peng1999/PkgDependency.jl/releases/tag/v0.2.0
[0.1.0]: https://github.com/peng1999/PkgDependency.jl/releases/tag/v0.1.0

[#4]: https://github.com/peng1999/PkgDependency.jl/issues/4
[#5]: https://github.com/peng1999/PkgDependency.jl/issues/5
[#6]: https://github.com/peng1999/PkgDependency.jl/issues/6
[#7]: https://github.com/peng1999/PkgDependency.jl/issues/7
[#10]: https://github.com/peng1999/PkgDependency.jl/issues/10
[#11]: https://github.com/peng1999/PkgDependency.jl/issues/11

