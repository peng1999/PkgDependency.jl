module PkgDependency

using Pkg
using UUIDs
import AbstractTrees: children
import Term: Tree, TERM_THEME

"""
    tree(...; reverse=false, compat=false, show_link=false, dedup=true, stdlib=false)

"""
function tree end

"""
    tree(; kwargs...)

Print dependency tree of current project. `reverse` kwarg is not supported in this method.
"""
function tree(; compat=false, show_link=false, dedup=true, stdlib=false)
    project = Pkg.project()
    if project.ispackage
        name = something(project.name, "Unnamed Project")
        version = isnothing(project.version) ? "" : "v$(project.version)"
    else
        name = "Workspace"
        version = ""
    end

    registries = check_and_get_registries(; show_link)
    title_color = TERM_THEME[].tree_title
    title = "{$title_color}$name $version{/$title_color}"
    Tree(
        PkgTree(title, builddict(project.uuid, project; compat, registries, dedup, stdlib)),
        printkeys=false,
        maxdepth=99,
        print_node_function=writenode
    )
end

"""
    tree(uuid::UUID; kwargs...)

Print dependency tree of a package identified by UUID
"""
function tree(uuid::UUID; reverse=false, compat=false, show_link=false, dedup=true, stdlib=false)
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
    title = "$name v$version"
    Tree(
        PkgTree(title, builddict(uuid, project; graph, compat, registries, dedup, stdlib)),
        printkeys=false,
        maxdepth=99,
        print_node_function=writenode
    )
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

struct PkgTree
    name::String
    children::Vector{PkgTree}
    is_duplicated::Bool

    PkgTree(name, children, is_duplicated=false) = new(name, children, is_duplicated)
end

children(node::PkgTree) = node.children
writenode(io, node::PkgTree) = write(io, node.name)

# returns dependencies of info as OrderedDict, or nothing when no dependencies
function builddict(uuid::Union{Nothing,UUID}, info; graph=Pkg.dependencies(), listed=Set{UUID}(), dedup=true, compat=false, registries=nothing, stdlib=false)
    deps = info.dependencies
    compats = compat && !isnothing(uuid) ? compatinfo(uuid) : Dict()
    children = PkgTree[]

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
        if isnothing(subpkg.version) && !stdlib
            continue
        end
        deduped = dedup && uuid ∈ listed
        postfix = deduped ? " (*)" : ""
        cinfo = get(compats, subpkg.name, nothing)
        if !isnothing(cinfo)
            postfix = postfix * " compat=\"$(compatstr(cinfo))\""
        end
        color_tree_keys = deduped ? TERM_THEME[].tree_skip : TERM_THEME[].tree_keys
        name = "{$(color_tree_keys)}$(subpkg.name){/$(color_tree_keys)}"
        if isnothing(subpkg.version)
            # This branch will not be entered in newer julia
            name *= " StdLib v$VERSION$postfix"
        else
            name *= " v$(subpkg.version)$postfix"
        end
        if registries !== nothing && !isempty(link)
            name *= " ($link)"
        end

        child = PkgTree[]
        if uuid ∉ listed
            if dedup
                push!(listed, uuid)
            end
            child = builddict(uuid, subpkg; graph, listed, compat, registries, dedup, stdlib)
        end
        push!(children, PkgTree(name, child, deduped))
    end
    children
end

end

# vim: sw=4
