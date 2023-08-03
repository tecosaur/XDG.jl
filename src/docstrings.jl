# Reference: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

Base.Docs.doc!(@__MODULE__, # Please let me know if there's an easier way.
               Base.Docs.Binding(@__MODULE__, Symbol(@__MODULE__)),
               Base.Docs.docstr(
                   """
**BaseDirs**

This module provides utilities to identify the appropriate locations for files.

The `User` and `System` submodules provide a number of accessor functions, which see.

There are also four combined accessor functions defined, namely: `data`,
`config`, `fonts`, and `applications`. These provide a list of all relevant user
and system directories.

!!! note
    This is essentially an implementation of the XDG (Cross-Desktop Group) directory
    specifications, with analogues for Windows and MacOS for cross-platform. More
    specifically, this is a hybrid of:
    - The *XDG base directory* and the *XDG user directory* specifications on Linux
    - The *Known Folder* API on Windows
    - The *Standard Directories* guidelines on macOS

""",
                   Dict(:path => joinpath(@__DIR__, @__FILE__),
                        :linenumber => @__LINE__,
                        :module => @__MODULE__)),
               Union{})

@doc """
A representation of a "Project", namely the essential components of naming
information used to produce platform-appropriate project paths.

    Project(name::AbstractString;
            org::AbstractString="julia", qualifier::AbstractString="lang")
      -> Project

The information needed, and the platforms that make use of it, are as follows:
- `name`, the name of the project (Linux, MacOS, Windows)
- `org` (`"julia"`), the organisation the project belongs to (MacOS, Windows)
- `qualifier` (`"org"`), the nature of the organisation, usually a TLD (MacOS)

The resulting "project path components" take one of the following forms:

| Platform | Project path form         |
|----------|---------------------------|
| Linux    | `"\$name"`                 |
| MacOS    | `"\$qualifier.\$org.\$name"` |
| Windows  | `"\$org\\\$name"`           |
""" Project

# ---------

@doc """
**DATA_HOME** (`XDG_DATA_HOME`)

The single base directory relative to which user-specific data files should be
written.

**Default values**

| Linux            | MacOS                          | Windows          |
|------------------|--------------------------------|------------------|
| `~/.local/share` | `~/Library/ApplicationSupport` | `RoamingAppData` |
""" DATA_HOME

@doc """
**DATA_DIRS** (`XDG_DATA_DIRS`)

The set of *preference ordered* base directories relative to which data files
should be searched.

**Default values**

| Linux              | MacOS                         | Windows       |
|--------------------|-------------------------------|---------------|
| `/usr/local/share` | `/Library/ApplicationSupport` | `ProgramData` |
| `/usr/share`       |                               |               |
""" DATA_DIRS

@doc """
**CONFIG_HOME** (`XDG_CONFIG_HOME`)

The single base directory relative to which user-specific configuration files
should be written.

**Default values**

| Linux             | MacOS                          | Windows          |
|-------------------|--------------------------------|------------------|
| `~/.local/config` | `~/Library/ApplicationSupport` | `RoamingAppData` |
""" CONFIG_HOME

@doc """
**CONFIG_DIRS** (`XDG_CONFIG_DIRS`)

The set of *preference ordered* base directories relative to which data files
should be searched.

**Default values**

| Linux      | MacOS                         | Windows       |
|------------|-------------------------------|---------------|
| `/etc/xdg` | `/Library/ApplicationSupport` | `ProgramData` |
""" CONFIG_DIRS

@doc """
**STATE_HOME** (`XDG_STATE_HOME`)

The single base directory relative to which user-specific state data
should be written.

This should contain  state data that should persist between (application)
restarts, but that is not important or portable enough to the user that it
should be stored in `DATA_HOME`. It may contain:
- actions history (logs, history, recently used files, …)
- current state of the application that can be reused on a restart (view, layout, open files, undo history, …)

**Default values**

| Linux            | MacOS                          | Windows        |
|------------------|--------------------------------|----------------|
| `~/.local/state` | `~/Library/ApplicationSupport` | `LocalAppData` |
""" STATE_HOME

@doc """

**BIN_HOME** (`XDG_BIN_HOME`)

The single base directory relative to which user-specific executables should be
written.

**Default values**

| Linux          | MacOS\\*                         | Windows\\*             |
|----------------|--------------------------------|----------------------|
| `~/.local/bin` | `~/.local/bin`                 | `\\bin`               |
|                | `/opt/local/bin`               | `RoamingAppData\\bin` |
|                | `/usr/local/bin`               | `AppData\\bin`        |
|                |                                | current working dir  |

\\* The first of these directories that exists is used.

!!! warning
    This is not yet standardised by the XDG, see
    https://gitlab.freedesktop.org/xdg/xdg-specs/-/issues/14 for more
    information.
""" BIN_HOME

@doc """
**CACHE_HOME** (`XDG_CACHE_HOME`)

The single base directory relative to which user-specific non-essential (cached)
data should be written.

**Default values**

| Linux      | MacOS              | Windows              |
|------------|--------------------|----------------------|
| `~/.cache` | `~/Library/Caches` | `LocalAppData\\cache` |

""" CACHE_HOME

@doc """
**RUNTIME_DIR** (`XDG_RUNTIME_DIR`)

The single base directory relative to which user-specific runtime files and
other file objects should be placed. . Applications should use this directory
for communication and synchronization purposes and should not place larger files
in it.

**Default values**

| Linux            | MacOS                          | Windows        |
|------------------|--------------------------------|----------------|
| `/run/user/\$UID` | `~/Library/ApplicationSupport` | `LocalAppData` |
""" RUNTIME_DIR

# ---------

@doc """
**DESKTOP_DIR** (`XDG_DESKTOP_DIR`)

The user's desktop directory.
""" DESKTOP_DIR

@doc """
**DOWNLOAD_DIR** (`XDG_DOWNLOAD_DIR`)

The user's downloads directory.
""" DOWNLOAD_DIR

@doc """
**DOCUMENTS_DIR** (`XDG_DOCUMENTS_DIR`)

The user's documents directory.
""" DOCUMENTS_DIR

@doc """
**MUSIC_DIR** (`XDG_MUSIC_DIR`)

The user's music directory.
""" MUSIC_DIR

@doc """
**PICTURES_DIR** (`XDG_PICTURES_DIR`)

The user's pictures directory.
""" PICTURES_DIR

@doc """
**VIDEOS_DIR** (`XDG_VIDEOS_DIR`)

The user's videos directory.
""" VIDEOS_DIR

@doc """
**TEMPLATES_DIR** (`XDG_TEMPLATES_DIR`)

The user's templates directory.
""" TEMPLATES_DIR

@doc """
**PUBLICSHARE_DIR** (`XDG_PUBLICSHARE_DIR`)

The user's public directory.
""" PUBLICSHARE_DIR

@doc """
**APPLICATIONS_DIRS**

A list of locations in which application files may be found/placed.
""" APPLICATIONS_DIRS

@doc """
**FONTS_DIRS**

A list of locations in which font files may be found.
""" FONTS_DIRS

# ---------

@doc """
**BaseDirs.User**

This module containes accessor functions for user-specific directories.

### Base directory acessors

`data`, `config`, `state`, `cache`, and `runtime` -> `String`

### User directory accessors

`desktop`, `downloads`, `music`, `videos`, `templates`, `public` -> `String`

### Other acessors

`fonts` and `applications` -> `Vector{String}`

!!! note
    Unlike the `System` and "combined" (BaseDirs.\\*) acessors, the *Base* and *User*
    acessors here return a single directory (`String`).
""" User

@doc """
$(Internals.acessordoc(:data, :DATA_HOME, name="user configuration"))
""" User.data

@doc """
$(Internals.acessordoc(:config, :CONFIG_HOME, name="user configuration"))
""" User.config

@doc """
$(Internals.acessordoc(:state, :STATE_HOME, name="state data"))
""" User.state

@doc """
$(Internals.acessordoc(:bin, :BIN_HOME, name="executables"))

!!! note "Special behaviour"
    When `create` is `true` and the path referrs to a file, `chmod` is called to
    ensure that all users who can read the file can execute it.
""" User.bin

@doc """
$(Internals.acessordoc(:cache, :CACHE_HOME, name="cached data"))
""" User.cache

@doc """
$(Internals.acessordoc(:state, :STATE_HOME, name="runtime information"))
""" User.runtime

@doc """
$(Internals.acessordoc(:fonts, name="user fonts", plural=true))
""" User.fonts

@doc """
$(Internals.acessordoc(:applications, name="user applications", plural=true))
""" User.applications

# ---------

@doc """
    desktop(parts...) -> String

Join the desktop directory with zero or more path components (`parts`).

The desktop directory is based on the variable `BaseDirs.DESKTOP_DIR`, which see.
""" User.desktop


@doc """
    downloads(parts...) -> String

Join the downloads directory with zero or more path components (`parts`).

The downloads directory is based on the variable `BaseDirs.DOWNLOADS_DIR`, which see.
""" User.downloads

@doc """
    documents(parts...) -> String

Join the documents directory with zero or more path components (`parts`).

The documents directory is based on the variable `BaseDirs.DOCUMENTS_DIR`, which see.
""" User.documents

@doc """
    music(parts...) -> String

Join the music directory with zero or more path components (`parts`).

The music directory is based on the variable `BaseDirs.MUSIC_DIR`, which see.
""" User.music

@doc """
    pictures(parts...) -> String

Join the pictures directory with zero or more path components (`parts`).

The pictures directory is based on the variable `BaseDirs.PICTURES_DIR`, which see.
""" User.pictures

@doc """
    videos(parts...) -> String

Join the videos directory with zero or more path components (`parts`).

The videos directory is based on the variable `BaseDirs.VIDEOS_DIR`, which see.
""" User.videos

@doc """
    templates(parts...) -> String

Join the templates directory with zero or more path components (`parts`).

The templates directory is based on the variable `BaseDirs.TEMPLATES_DIR`, which see.
""" User.templates

@doc """
    public(parts...) -> String

Join the public directory with zero or more path components (`parts`).

The public directory is based on the variable `BaseDirs.PUBLIC_DIR`, which see.
""" User.public

# ---------

@doc """
**BaseDirs.System**

This module contains acessor functions for system directories.

### Base directory acessors

`data`, `config` -> `Vector{String}`

### Other acessors

`fonts` and `applications` -> `Vector{String}`
""" System

@doc """
$(Internals.acessordoc(:data, :DATA_DIRS, name="system configuration"))
""" System.data

@doc """
$(Internals.acessordoc(:config, :CONFIG_DIRS, name="system configuration"))
""" System.config

@doc """
$(Internals.acessordoc(:fonts, name="system fonts", plural=true))
""" System.fonts

@doc """
$(Internals.acessordoc(:applications, name="system applications", plural=true))
""" System.applications

# ---------

@doc """
$(Internals.acessordoc(:data, [:DATA_HOME, :DATA_DIRS], name="user and system configuration"))
""" data

@doc """
$(Internals.acessordoc(:config, [:CONFIG_HOME, :CONFIG_DIRS], name="user and system configuration"))
""" config

@doc """
$(Internals.acessordoc(:fonts, name="user and system fonts", plural=true))
""" fonts

@doc """
$(Internals.acessordoc(:applications, name="user and system applications", plural=true))
""" applications
