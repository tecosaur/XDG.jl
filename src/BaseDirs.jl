module BaseDirs

@static if VERSION >= v"1.11"
    eval(Expr(:public, :System, :User, :Project, :reload, :data, :config,
              :fonts, :applications, :DATA_HOME, :DATA_DIRS, :CONFIG_HOME,
              :CONFIG_DIRS, :BIN_HOME, :STATE_HOME, :CACHE_HOME, :RUNTIME_DIR,
              :DESKTOP_DIR, :DOWNLOAD_DIR, :DOCUMENTS_DIR, :PICTURES_DIR,
              :VIDEO_DIR, :TEMPLATE_DIR, :PUBLICSHARE_DIR, :APPLICATIONS_DIRS,
              :FONTS_DIRS, Symbol("@promise_no_assign")))
end

include("variables.jl")

function reload end
function projectpath end

struct Project
    name::AbstractString
    org::AbstractString
    qualifier::AbstractString
end

Project(name::AbstractString; org::AbstractString="julia", qualifier::AbstractString="lang") =
    Project(name, org, qualifier)

include("internals.jl")

using ..Internals

"""
    @promise_no_assign expr

Evaluate `expr`, while promising that none of the results of
`BaseDirs` will be assigned to any global constants.

This macro is intended for use in other package's precompilation scripts, to
suppress the spurious warnings about global constant assignments. It will itself
warn when used outside precompilation.

# Examples

Within a precompilation workload:

```julia
BaseDirs.@promise_no_assign MyPkg.somecall()
```

Alternatively, you could mark a larger block as safe with `begin ... end`:

```julia
BaseDirs.@promise_no_assign begin
    ...
    MyPkg.somecall()
    ...
end
```
"""
macro promise_no_assign(body)
    quote
        Internals.warn_misplaced_promise()
        Internals.PROMISED_NO_CONST_ASSIGNMENT = true
        try
            $(esc(body))
        finally
            Internals.PROMISED_NO_CONST_ASSIGNMENT = false
        end
    end
end

include("access.jl")

@static if Sys.isapple()
    const PLATFORM = :darwin
    include("darwin.jl")
elseif Sys.isunix()
    const PLATFORM = :unix
    include("unix.jl")
elseif Sys.iswindows()
    const PLATFORM = :nt
    include("nt.jl")
else
    error("Unsupported platform")
end

include("docstrings.jl")

const __init__ = reload

include("precompile.jl")

end
