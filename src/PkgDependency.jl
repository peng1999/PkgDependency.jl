module PkgDependency

using Pkg
using UUIDs
using OrderedCollections
import Term: Tree, Theme, set_theme

function __init__()
    set_theme(Theme(tree_max_width=-1))
end

"""
    tree(;compat=false)

Print dependency tree of current project.
"""
function tree(;compat=false)
    project = Pkg.project()
    if project.ispackage
	name = something(project.name, "Unnamed Project")
	version = isnothing(project.version) ? "" : "v$(project.version)"
    else
	name = "Workspace"
	version = ""
    end

    Tree(builddict(project.uuid, project; compat), title="$name $version")
end

"""
    tree(uuid::UUID; reverse=false, compat=false)

Print dependency tree of a package identified by UUID
"""
function tree(uuid::UUID; reverse=false, compat=false)
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

    Tree(builddict(uuid, project; graph, compat), title="$name v$version")
end

"""
    tree(name::AbstractString; reverse=false, compat=false)

Print dependency tree of a package identified by name. Pass `reverse=true` to get a reverse dependency, `compat=true` to get compat info.
"""
function tree(name::AbstractString; kwargs...)
    dep = Pkg.dependencies()
    uuid = findfirst(x -> x.name == name, dep)
    if uuid === nothing
        throw(ArgumentError("\"$name\" not found in dependencies. Please install this package and retry."))
    end
    tree(uuid; kwargs...)
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
        name = Pkg.dependencies()[uuid].name
        pkgid = Base.PkgId(uuid, name)
        path = abspath(Base.locate_package(pkgid), "..", "..")
        manifest = locate_project_file(path)
    end
    Pkg.Types.read_package(manifest).compat
end

# returns dependencies of info as OrderedDict, or nothing when no dependencies
function builddict(uuid::Union{Nothing, UUID}, info; graph=Pkg.dependencies(), listed=Set{UUID}(), compat=false)
    deps = info.dependencies
    compats = compat && !isnothing(uuid) ? compatinfo(uuid) : Dict()
    children = OrderedDict()
    for uuid in values(deps)
        subpkg = graph[uuid]
        if isnothing(subpkg.version)
            continue
        end
        postfix = uuid ∈ listed ? " (*)" : ""
        cinfo = get(compats, subpkg.name, nothing)
        if !isnothing(cinfo)
            postfix = postfix * " compat=\"$(cinfo.str)\""
        end
        name = "$(subpkg.name) v$(subpkg.version)$postfix"

        child = nothing
        if uuid ∉ listed
            push!(listed, uuid)
            child = builddict(uuid, subpkg; graph, listed, compat)
        end
        push!(children, name => child)
    end
    children
end

end

# vim: sw=4
