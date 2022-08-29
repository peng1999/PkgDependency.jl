module PkgDependency

using Pkg
using UUIDs
using OrderedCollections
import Term: Tree

"""
    tree()

Print dependency tree of current project.
"""
function tree()
    project = Pkg.project()
    name = something(project.name, "Unnamed Project")
    version = something(project.version, "")

    Tree(builddict(project), title="$name v$version")
end

"""
    tree(uuid::UUID)

Print dependency tree of a package identified by UUID
"""
function tree(uuid::UUID)
    project = Pkg.dependencies()[uuid]
    name = something(project.name, "Unnamed Project")
    version = something(project.version, "")

    Tree(builddict(project), title="$name v$version")
end

"""
    tree(name::AbstractString)

Print dependency tree of a package identified by name
"""
function tree(name::AbstractString)
    dep = Pkg.project().dependencies
    tree(dep[name])
end

# returns dependencies of info as OrderedDict, or nothing when no dependencies
function builddict(info; graph=Pkg.dependencies(), listed=Set{UUID}())
    deps = info.dependencies
    children = OrderedDict()
    for uuid in values(deps)
        subpkg = graph[uuid]
        if isnothing(subpkg.version)
            continue
        end
        postfix = uuid ∈ listed ? "(*)" : ""
        name = "$(subpkg.name) v$(subpkg.version) $postfix"

        child = nothing
        if uuid ∉ listed
            push!(listed, uuid)
            child = builddict(subpkg, graph=graph, listed=listed)
        end
        push!(children, name => child)
    end
    children
end

end

# vim: sw=4
