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
    tree(uuid::UUID; reverse=false)

Print dependency tree of a package identified by UUID
"""
function tree(uuid::UUID; reverse=false)
    graph = Pkg.dependencies()
    if reverse
        revgraph = Pkg.dependencies()
        for info in values(revgraph)
            empty!(info.dependencies)
        end
        for info in graph
            for dep in info[2].dependencies
                push!(revgraph[dep[2]].dependencies, info[2].name=>info[1])
            end
        end
        graph = revgraph
    end
    project = graph[uuid]
    name = something(project.name, "Unnamed Project")
    version = something(project.version, "")

    Tree(builddict(project, graph=graph), title="$name v$version")
end

"""
    tree(name::AbstractString; reverse=false)

Print dependency tree of a package identified by name. Pass `reverse=true` to get a reverse dependency.
"""
function tree(name::AbstractString; kwargs...)
    dep = Pkg.dependencies()
    uuid = findfirst(x -> x.name == name, dep)
    if uuid == nothing
        throw(ArgumentError("\"$name\" not found in dependencies. Please install this package and retry."))
    end
    tree(uuid; kwargs...)
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
