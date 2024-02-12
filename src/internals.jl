# Helper functions and macros

module Internals

using ..BaseDirs
using Base.Docs

export @defaccessor, @setxdg, @setxdgs

@static if Sys.isunix()
    macro setxdg(envvar::Symbol, default)
        quote $(esc(envvar))[] = if haskey(ENV, $("XDG_$envvar")) && !isempty(ENV[$("XDG_$envvar")])
            path = ENV[$("XDG_$envvar")]
            if endswith(path, first(Base.Filesystem.path_separator))
                path[begin:end-1]
            else path end
        else expanduser($(esc(default))) end
        end
    end
else
    macro setxdg(envvar::Symbol, default)
        quote $(esc(envvar))[] = if haskey(ENV, $("XDG_$envvar")) && !isempty(ENV[$("XDG_$envvar")])
            path = ENV[$("XDG_$envvar")]
            if endswith(path, first(Base.Filesystem.path_separator))
                path[begin:end-1]
            else path end
        else $(esc(default)) end
        end
    end
end

macro setxdgs(envvar::Symbol, defaults)
    quote $(esc(envvar))[] = if haskey(ENV, $("XDG_$envvar")) && !isempty(ENV[$("XDG_$envvar")])
        map(split(ENV[$("XDG_$envvar")], ':')) do path
            if endswith(path, first(Base.Filesystem.path_separator))
                path[begin:end-1]
            else path end
        end
    else $(esc(defaults)) end
    end
end

const NEW_BASEDIR_MODE = 0o700

ensurebasedir(path::String) =
    isdir(path) || mkpath(path, mode=NEW_BASEDIR_MODE)

const DIRECTORY_SUFFIX_FLAG = '/'

"""
    ensurepath(path::String)

Ensure that `path` exists. Should `path` end with `$DIRECTORY_SUFFIX_FLAG` it is
interpreted as a directory. The directory-suffix `$DIRECTORY_SUFFIX_FLAG` is
used on all filesystems for consistency of the API, regardless of the native
path seperator of the host filesystem.
"""
function ensurepath(path::String)
    if !ispath(path)
        if endswith(path, DIRECTORY_SUFFIX_FLAG) || (Sys.iswindows() && endswith(path, "\\"))
            mkpath(path[begin:prevind(path, end)])
        else
            mkpath(dirname(path))
            touch(path)
        end
    end
end

"""
    ensureexecutable(path::String)

Make `path` executable by everybody who can read it. Returns `path`.
"""
function ensureexecutable(path::String)
    if isfile(path)
        basemode = filemode(path)
        uread = basemode & 0o400 > 0
        gread = basemode & 0o040 > 0
        oread = basemode & 0o004 > 0
        xmask = 0o100 * uread + 0o010 * gread + 0o001 * oread
        chmod(path, basemode | xmask)
    end
    path
end

function resolvedirpath(basedir::String, pathcomponents::Union{Tuple, AbstractVector}; create::Bool=false)
    create && ensurebasedir(basedir)
    if isempty(pathcomponents)
        basedir
    else
        fullpath = joinpath(basedir, pathcomponents...)
        create && ensurepath(fullpath)
        fullpath
    end
end

function resolvedirpaths(basedirs::Vector{String}, pathcomponents::Union{Tuple, AbstractVector}; create::Bool=false, existent::Bool=false)
    allpaths = resolvedirpath.(basedirs, Ref(pathcomponents); create)
    if existent
        filter(ispath, allpaths)
    else
        allpaths
    end
end

macro defaccessor(fnname::Symbol, var::Union{Symbol, Expr})
    dirvar = if var isa Symbol
        Expr(:ref, Expr(:., :BaseDirs, QuoteNode(var)))
    else esc(var) end
    vecfns = (:vec, :vcat, :filter, :map, :push!, :pushfirst!) # a few that come to mind
    resolver = if (var isa Symbol && getfield(BaseDirs, var) isa Ref{Vector{String}}) ||
          (var isa Expr && (var.head == :vect ||
                            (var.head == :call && var.args[1] in vecfns)))
        :resolvedirpaths
    else
        :resolvedirpath
    end
    quote
        $(esc(fnname))(pathcomponents...; kwargs...) =
            $resolver($dirvar, pathcomponents; kwargs...)
        $(esc(fnname))(project::BaseDirs.Project, pathcomponents...; kwargs...) =
            $(esc(fnname))(BaseDirs.projectpath(project, $dirvar), pathcomponents...; kwargs...)
    end
end

function acessordoc(finfo::Union{Symbol, Tuple{String, Symbol}},
                    var::Union{Nothing, Symbol, Vector{Symbol}}=nothing;
                    plural::Bool=if isnothing(var) false
                    elseif var isa Vector true
                    else getfield(BaseDirs, var) isa Ref{Vector{String}} end,
                    name::String=String(if fname isa Symbol fname else last(fname) end))
    fprefix, fname = if finfo isa Symbol; ("", finfo) else finfo end
    rettype = ifelse(plural, "Vector{String}", "String")
    dirprefix, dirterm = ifelse(plural, ("all", "directories"), ("the", "directory"))
    existentkwarg = ifelse(plural, " - `existent::Bool` (default `false`), filter out paths that do not exist.", "")
    vardoc = if var isa Vector && (dvars = filter(v -> haskey(Docs.meta(BaseDirs), Docs.Binding(BaseDirs, v)), var)) |> !isempty
        "\nThe returned path is based on the variables $(join(map(v -> "`BaseDirs.$v`", dvars), ", ", ", and ")), which see.\n"
    elseif !isnothing(var) && haskey(Docs.meta(BaseDirs), Docs.Binding(BaseDirs, var))
        "\nThe returned path is based on the variable `BaseDirs.$var`, which see.\n"
    else "" end
    kwargs = ifelse(plural, "; create, existent", "; create")
    """
    $fprefix$fname($kwargs) -> $rettype # $dirprefix $dirterm
    $fprefix$fname(parts...$kwargs) # $dirprefix $dirterm joined with parts
    $fprefix$fname(proj::Project$kwargs) # $dirprefix project-specific $dirterm
    $fprefix$fname(proj::Project, parts...$kwargs) # $dirprefix project-specific $dirterm joined with parts

Locate $dirprefix $name $dirterm. Optionally, a project and/or path components
can be provided as arguments, in which case they are joined with the $name
$dirterm as appropriate.
$vardoc
## Keyword arguments
 - `create::Bool` (default `false`), whether the path should be created if it
   does not exist. Paths ending in `$DIRECTORY_SUFFIX_FLAG` are interpreted as
   directories, and all other paths are considered files. This takes care to
   create the base directories with the appropriate permissions ($(string(NEW_BASEDIR_MODE, base=8))).
$existentkwarg"""
end

end
