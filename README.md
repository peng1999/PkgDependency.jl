# DependencyTree.jl

Show dependency tree of project or package.

## Installation

In julia REPL:

```
]add https://github.com/peng1999/DependencyTree.jl
```

Then call `DependencyTree.tree`

```julia
julia> using DependencyTree
julia> DependencyTree.list("CSV")
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
