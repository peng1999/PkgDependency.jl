module DependencyTree

using Pkg
using UUIDs

"""
    list()

Show dependency tree of current project.
"""
function list()
    project = Pkg.project()
    name = something(project.name, "Unnamed Project")
    version = something(project.version, "")
    println("$name $version")

    printtree(project, indent=4)
end

struct CustomInfo
    dependencies::Dict{Nothing, UUID}
end

"""
    list(uuid::UUID)

Show dependency tree of a package identified by UUID
"""
function list(uuid::UUID)
    printtree(CustomInfo(Dict(nothing => uuid)))
end

"""
    list(name::AbstractString)

Show dependencies of a package identified by name
"""
function list(name::AbstractString)
    dep = Pkg.project().dependencies
    list(dep[name])
end

function printtree(info; graph=Pkg.dependencies(), indent=0, listed=Set{UUID}())
    deps = info.dependencies
    for uuid in values(deps)
        subpkg = graph[uuid]
        if isnothing(subpkg.version)
            continue
        end
        prefix = " " ^ indent
        postfix = uuid ∈ listed ? "(*)" : ""
        println("$prefix$(subpkg.name) v$(subpkg.version) $postfix")

        if uuid ∉ listed
            push!(listed, uuid)
            printtree(subpkg, graph=graph, indent=indent+4, listed=listed)
        end
    end
end

end
