# PkgDependency.jl

## Quick Start

```
julia> import PkgDependency
julia> PkgDependency.tree("Tables")
 Tables v1.10.0
━━━━━━━━━━━━━━━━
       │
       ├── DataAPI v1.13.0
       ├── OrderedCollections v1.4.1
       ├── IteratorInterfaceExtensions v1.0.0
       ├── DataValueInterfaces v1.0.0
       └── TableTraits v1.0.1
           └── IteratorInterfaceExtensions v1.0.0 (*)
```

`PkgDependency.tree()` can be used to print dependency tree of current workspace.

Unless otherwise specified, all methods of `tree` function support following kwargs:

| kwarg | default | description |
| --- | --- | --- |
| `reverse` | `false` | get a reverse dependency tree |
| `compat` | `false` | show compat info in tree |
| `show_link` | `false` | show packages' repo link in tree |
| `dedup` | `true` | hide duplicate dependencies in tree |

## API

```@autodocs
Modules = [PkgDependency]
```
