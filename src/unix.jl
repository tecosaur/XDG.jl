function parseuserdirs(parentdir)
    validnames = ("DESKTOP", "DOWNLOAD", "TEMPLATES", "PUBLICSHARE",
                  "DOCUMENTS", "MUSIC", "PICTURES", "VIDEOS")
    userdirsfile = joinpath(parentdir, "user-dirs.dirs")
    if isfile(userdirsfile)
        keys = Symbol[]
        values = String[]
        for line in Iterators.map(strip, eachline(userdirsfile))
            if !startswith(line, '#') && occursin('=', line)
                key, value = split(line, '=')
                if key in validnames
                    if startswith(value, '"') && endswith(value, '"')
                        value = unescape_string(value[2:end-1])
                    end
                    if startswith(value, "\$HOME")
                        value = string(homedir(), value[6:end])
                    end
                    if startswith(value, '/')
                        push!(keys, Symbol(key))
                        push!(values, value)
                    end
                end
            end
        end
        NamedTuple{Tuple(keys)}(values)
    else
        (;)
    end
end

function reload()
    # Base directories
    @setxdg DATA_HOME "~/.local/share"
    @setxdgs DATA_DIRS ["/usr/local/share", "/usr/share"]
    @setxdg CONFIG_HOME "~/.config"
    @setxdgs CONFIG_DIRS ["/etc/xdg"]
    @setxdg STATE_HOME "~/.local/state"
    @setxdg BIN_HOME "~/.local/bin"
    @setxdg CACHE_HOME "~/.cache"
    @setxdg RUNTIME_DIR joinpath("/run/user", string(Base.Libc.getuid()))
    # User directories
    userdirs = merge(parseuserdirs(first(CONFIG_DIRS[])),
                     parseuserdirs(CONFIG_HOME[]))
    @setxdg DESKTOP_DIR get(userdirs, :DESKTOP, "~/Desktop")
    @setxdg DOWNLOAD_DIR get(userdirs, :DOWNLOAD, "~/Downloads")
    @setxdg DOCUMENTS_DIR get(userdirs, :DOCUMENTS, "~/Documents")
    @setxdg MUSIC_DIR get(userdirs, :MUSIC, "~/Music")
    @setxdg PICTURES_DIR get(userdirs, :PICTURES, "~/Pictures")
    @setxdg VIDEOS_DIR get(userdirs, :VIDEOS, "~/Videos")
    @setxdg TEMPLATES_DIR get(userdirs, :TEMPLATES, "~/Templates")
    @setxdg PUBLICSHARE_DIR get(userdirs, :PUBLICSHARE, "~/Public")
    # Other directories
    FONTS_DIRS[] =
        append!([joinpath(DATA_HOME[], "fonts"),
                 expanduser("~/.fonts")],
                joinpath.(DATA_DIRS[], "fonts")) |> unique!
    APPLICATIONS_DIRS[] =
        append!([joinpath(DATA_HOME[], "applications")],
                joinpath.(DATA_DIRS[], "applications")) |> unique!
    nothing
end

projectpath(p::Project, _) = projectpath(p)
projectpath(p::Project) =
    string(lowercase(replace(p.org, r"[^A-Za-z0-9_-]" => "")), '/',
           lowercase(replace(p.name, r"[^A-Za-z0-9_-]" => "")), '/')
