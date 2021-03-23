module DepTree

using Pkg
using UUIDs

"""
    tree()

Show dependencies of current project.
"""
function tree()
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
    tree(uuid::UUID)

Show dependencies of a package by UUID
"""
function tree(uuid::UUID)
    printtree(CustomInfo(Dict(nothing => uuid)))
end

"""
    tree(name::AbstractString)

Show dependencies of a package by name
"""
function tree(name::AbstractString)
    dep = Pkg.project().dependencies
    tree(dep[name])
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