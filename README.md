# PkgDependency.jl

[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://peng1999.github.io/PkgDependency.jl/dev/)

Print dependency tree of a project or package.

## Installation

In julia REPL, type `]` to enter package manager:

```
pkg> add https://github.com/peng1999/PkgDependency.jl
```

## Usage

Call `PkgDependency.tree`. Circular dependencies are marked as `(*)`.

```julia
julia> using PkgDependency
julia> PkgDependency.tree("CSV")
CSV v0.8.3
    Tables v1.3.1
        DataAPI v1.5.1
        IteratorInterfaceExtensions v1.0.0
        DataValueInterfaces v1.0.0
        TableTraits v1.0.0
            IteratorInterfaceExtensions v1.0.0 (*)
    Parsers v1.0.15
    PooledArrays v1.1.0
        DataAPI v1.5.1 (*)
    SentinelArrays v1.2.16
```

## Contribution

Feel free to create issues if you want more features!
