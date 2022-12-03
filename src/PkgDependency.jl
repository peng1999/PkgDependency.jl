module PkgDependency

using Pkg
using UUIDs
using OrderedCollections
import Term: Tree, Theme, set_theme

function __init__()
    set_theme(Theme(tree_max_width=-1))
end

"""
    tree(...; reverse=false, compat=false, show_link=false, dedup=true)

"""
function tree end

"""
    tree(; kwargs...)

Print dependency tree of current project. `reverse` kwarg is not supported in this method.
"""
function tree(; compat=false, show_link=false, dedup=true)
    project = Pkg.project()
    if project.ispackage
        name = something(project.name, "Unnamed Project")
        version = isnothing(project.version) ? "" : "v$(project.version)"
    else
        name = "Workspace"
        version = ""
    end

    registries = check_and_get_registries(; show_link)
    Tree(builddict(project.uuid, project; compat, registries, dedup), title="$name $version")
end

"""
    tree(uuid::UUID; kwargs...)

Print dependency tree of a package identified by UUID
"""
function tree(uuid::UUID; reverse=false, compat=false, show_link=false, dedup=true)
    graph = Pkg.dependencies()
    if reverse
        revgraph = Pkg.dependencies()
        for info in values(revgraph)
            empty!(info.dependencies)
        end
        for info in graph
            for dep in info[2].dependencies
                push!(revgraph[dep[2]].dependencies, info[2].name => info[1])
            end
        end
        graph = revgraph
    end
    project = graph[uuid]
    name = something(project.name, "Unnamed Project")
    version = something(project.version, "")

    # registries is used to find url
    registries = check_and_get_registries(; show_link)
    Tree(builddict(uuid, project; graph, compat, registries, dedup), title="$name v$version")
end

"""
    tree(name::AbstractString; kwargs...)

Print dependency tree of a package identified by name.
"""
function tree(name::AbstractString; kwargs...)
    dep = Pkg.dependencies()
    uuid = findfirst(x -> x.name == name, dep)
    if uuid === nothing
        throw(ArgumentError("\"$name\" not found in dependencies. Please install this package and retry."))
    end
    tree(uuid; kwargs...)
end

function check_and_get_registries(; show_link)
    show_link || return nothing
    @static if VERSION < v"1.7"
        error("Sorry, your Julia version $(VERSION) is too old to use `show_link = true`, please upgrade your Julia version to v1.7 or higher.")
    else
        return Pkg.Operations.Context().registries
    end
end

function locate_project_file(env::String)
    for proj in ("Project.toml", "JuliaProject.toml")
        project_file = joinpath(env, proj)
        if isfile(project_file)
            return project_file
        end
    end
end

function compatinfo(uuid::UUID)
    project = Pkg.project()
    if project.uuid == uuid
        manifest = project.path
    else
        path = Pkg.dependencies()[uuid].source
        manifest = locate_project_file(path)
    end
    isnothing(manifest) ? Dict() : Pkg.Types.read_package(manifest).compat
end

# compatibility layer for julia 1.6
compatstr(c::String) = c
compatstr(c::Any) = c.str

# returns dependencies of info as OrderedDict, or nothing when no dependencies
function builddict(uuid::Union{Nothing,UUID}, info; graph=Pkg.dependencies(), listed=Set{UUID}(), dedup=true, compat=false, registries=nothing)
    deps = info.dependencies
    compats = compat && !isnothing(uuid) ? compatinfo(uuid) : Dict()
    children = OrderedDict()

    for uuid in values(deps)
        # find link
        if registries !== nothing
            links = collect(Pkg.Operations.find_urls(registries, uuid))
            if length(links) > 0
                link = links[1]
            else
                link = ""
            end
        end

        subpkg = graph[uuid]
        if isnothing(subpkg.version)
            continue
        end
        postfix = uuid ∈ listed ? " (*)" : ""
        cinfo = get(compats, subpkg.name, nothing)
        if !isnothing(cinfo)
            postfix = postfix * " compat=\"$(compatstr(cinfo))\""
        end
        name = "$(subpkg.name) v$(subpkg.version)$postfix"
        if registries !== nothing && !isempty(link)
            name *= " ($link)"
        end

        child = nothing
        if uuid ∉ listed
            push!(listed, uuid)
            child = builddict(uuid, subpkg; graph, listed, compat, registries, dedup)
            if !dedup
                pop!(listed, uuid)
            end
        end
        push!(children, name => child)
    end
    children
end

end

# vim: sw=4
