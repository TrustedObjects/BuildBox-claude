<!-- Generated from docs/src/dev/api.md by settings/claude/generate_reference.sh -->
<!-- Do not edit: update the documentation source instead -->

# BuildBox API

The API is used by BuildBox itself, and also can be used to develop shell
scripts dealing with BuildBox. Functions are provided to handle everything
that is managed by BuildBox.

The API is implemented in the `usr/sbin` folder of BuildBox repository, its
files names are ending with `.sh`, and are not executable.
Every file of the API is included by `buildbox_utils.sh`, which stands for the
user API entry point.
## BuildBox API entry point
This is the user API entry point, this file is the only to be sourced in
scripts which have to use BuildBox API.

When this file is sourced, the BuildBox environment is automatically set up
from the current working directory (project root is detected by locating
the .bbx/ directory).
Resolve the library directory: src/ in the source tree, lib/ when installed.

**Source file:** `buildbox_utils.sh`
### bb\_include()
Safely source a BuildBox script in the current script.
Before including BuildBox scripts, we go to the library directory to
avoid including a script from the current working directory having the same
name as a BuildBox script; current working directory is restored just after.
#### Parameters
- Script file base name
#### Return
0 on success, else error
Export bb_include
## Build packages
Generic build functions, relying on build modes implemented in
`_bb_build_{mode}.sh` files, where `{mode}` stands for the build mode
(autotools, make, ...).

**Source file:** `_build.sh`
### \_bb\_build\_package()
This function should not be called directly, it is used by
[bb_build_package()](#bb-build-package) and [bb_build_package_fast()](#bb-build-package-fast).
#### Parameters
- Mode, 1 = fast, else normal (refer to package build mode to know what
differs between these modes).
Package has to be already built in normal mode.
- Package name
- Build options (allowed to contain shell variables), these options are
appended after package provided options.
#### Expected environment
- `BB_PROJECT_DIR`: current project path
- `BB_TARGET_SRC_DIR`: path where cloned package are stored
#### Return
0 on success
### bb\_build\_package()
Generic function to build a package.
Sources are built and installed in the target `build` directory.

Package is cloned if not already done.

Package does not need to be referenced in target packages file.

If package `SRC_BUILD` is not defined, return with success. If `SRC_BUILD`
mode is not supported, return with error.
#### Parameters
- package name
- build options
#### Expected environment
- `BB_PROJECT_DIR`: current project path
- `BB_TARGET_SRC_DIR`: path where cloned package are stored
#### Return
0 on success
### bb\_build\_package\_fast()
Generic function to build package (fast mode).
Package has to be already built in normal mode.
#### Parameters
- Package name
- Build options
#### Expected environment
- `BB_PROJECT_DIR`: current target path
- `BB_TARGET_SRC_DIR`: path where cloned package are stored
#### Return
0 on success
### bb\_clean\_package()
Generic function to clean package built files.
Installed files in target `build` directory are not affected.
No error is returned if the package is not already built or not cloned.
#### Parameters
- Package name
#### Expected environment
- `BB_PROJECT_DIR`: current target path
- `BB_TARGET_SRC_DIR`: path where cloned package are stored
#### Return
1 if package doesn't exists, or if build mode clean operation is not
supported, 0 on success
### bb\_wipe\_package()
Generic function to wipe package sources and built files from target and
project.
Installed files in target `build` directory are not affected.
No error is returned if the package is not already built or not cloned.
#### Parameters
- Package name
#### Expected environment
- `BB_TARGET_SRC_DIR`: path where cloned package are stored
#### Return
0 on suuccess
### bb\_get\_build\_log\_warning\_count()
Generic function to get build log file warning count.
Supported warning format in build log:
- `warning:` (GCC)
- `[Warning]` (Mbed)
#### Parameters
- Log file path (file must exists, else an error is returned)
#### Print
Warning count
#### Return
0 on success
### bb\_stat\_package()
Generic function to stat package. Refer to build mode implementation for
available stats. Commonly available:
- `warning`: to get the build warnings count.

#### Parameters
- Package name
- Type of stat
#### Expected environment
- `BB_PROJECT_DIR`: current target path
- `BB_TARGET_SRC_DIR`: path where cloned package are stored
#### Print
Result, depending on requested information.
#### Return
0 on success, else build mode stat is not supported or returned an error.
### bb\_package\_supports\_sources\_sharing()
Generic function to know if a package supports sources sharing.
Package doesn't need to be cloned yet.

`SRC_SUPPORTS_SHARING` declared in the package file always wins, and is the
only way a package with no build mode can support sharing, since there is no
build mode to ask. Without it, the answer comes from the build mode, and is 0
when the build mode is unknown or does not tell.
#### Parameters
- Package name
#### Return
1 if package supports sources sharing, 0 if not
### bb\_get\_package\_build\_dir()
Get package build directory absolute path.
If package build mode does not implement a `bb_${mode}_get_build_dir`
function, package sources dir is returned.
#### Parameters
- Package name
#### Print
Package build directory absolute path
#### Return
0 on success
## Build packages with Autotools
This build mode is used to build components using Autotools

**Source file:** `_build_autotools.sh`
### bb\_autotools\_build()
Build with autotools.
#### Parameters
- Package directory
- Build options
### bb\_autotools\_build\_fast()
Build with autotools, fast mode: only make install is called, then it is
assumed configuration is already done. Build options changes are ignored at
this step.
#### Parameters
- Package directory
### bb\_autotools\_clean()
Clean autotools build by removing package build sub-directory.
#### Parameters
- Package directory
### bb\_autotools\_stat\_warning()
Get autotools build warnings count.
Uses [bb_get_build_log_warning_count()](#bb-get-build-log-warning-count) to get warning count.
#### Parameters
- Package directory
### bb\_autotools\_stat\_installed()
Get package installed version
#### Parameters
- package directory
### bb\_autotools\_supports\_sources\_sharing()
Autotools build plugin supports sources sharing
#### Return
1
### bb\_autotools\_get\_build\_dir()
Get Autotools build directory for a given package
#### Parameters
- package directory
#### Print
Build directory absolute path (may not exists if package not built yet)
#### Return
0 on success
## Build packages with custom process
This build mode is used to build components using custom build scripts
provided by the component itself.

The following scripts are involved, and must be located at component root:
- `build.sh`: cleanup, build and install the component into $PREFIX
- `build_fast.sh` (optional): fast build mode (no cleanup, no configuration),
if not present 'build.sh' is used instead.
- `clean.sh`: clean built files (do not uninstall)
- `warning_count.sh` (optional) prints number of build warnings

Scripts are run from the component root as current working directory.
These scripts must return 0 on success, else error.

**Source file:** `_build_custom.sh`
### bb\_custom\_build()
Build and install with custom `build.sh` script.
Installation is done under $PREFIX directory.
#### Parameters
- Package directory
- Build options, passed to `build.sh` script
#### Return
0 on success
### bb\_custom\_build\_fast()
Build and install with custom `build_fast.sh` script.
Fast mode only build sources, with no preceding cleanup or configuration,
then it is assumed configuration is already done.
If `build_fast.sh` is not present, `build.sh` is used instead.
Installation is done under `$PREFIX` directory.
#### Parameters
- Package directory
- Build options, passed to 'build_fast.sh'
#### Return
0 on success
### bb\_custom\_clean()
Clean build by calling custom `clean.sh` script.
Built files are cleaned by this custom script, but nothing is uninstalled
from `$PREFIX` directory.
#### Parameters
- package directory
#### Return
0 on success
### bb\_custom\_stat\_warning()
Get custom build warnings count with `warning_count.sh` script.
This script must only print out the number of warnings.
If this script is not provided, uses [bb_get_build_log_warning_count()](#bb-get-build-log-warning-count) to get
warning count from a `build.log` file in package directory.
And if `build.log` file is not present, nothing is printed.
#### Print
Warning count
#### Parameters
- Package directory
## Executable build mode
Build mode used to install a single executable file (script, binary, ...)

**Source file:** `_build_executable.sh`
### bb\_executable\_build()
Install executable package.
#### Parameters
- Package directory
#### Return
0 on success
### bb\_executable\_build\_fast()
Same as [bb_executable_build()](#bb-executable-build)
#### Parameters
- Package directory
#### Return
0 on success
### bb\_executable\_clean()
Nothing to clean for executable.
#### Parameters
- Package directory
### bb\_executable\_stat\_warning()
No warnings for executable.
#### Parameters
- package directory
#### Print
Always "0"
### bb\_executable\_supports\_sources\_sharing()
Executable build plugin supports sources sharing
#### Return
1
## Build packages with Makefile
This build mode is used to build components using simple Makefile

**Source file:** `_build_make.sh`
### bb\_make\_build()
Build with simple make.
#### Parameters
- Package directory
- Build options
#### Return
0 on success
### bb\_make\_build\_fast()
Build with make, fast mode (same as normal mode).
#### Parameters
- package directory
#### Return
0 on success
### bb\_make\_clean()
Clean make build.
#### Parameters
- Package directory
#### Return
0 on success
### bb\_make\_stat\_warning()
Get make build warnings count.
Uses [bb_get_build_log_warning_count()](#bb-get-build-log-warning-count) to get warning count.
#### Parameters
- Package directory
## Pre-built packages
Fake build mode used to install pre-built package

**Source file:** `_build_prebuilt.sh`
### bb\_prebuilt\_build()
Install pre-built package.
#### Parameters
- Package directory
#### Return
0 on success
### bb\_prebuilt\_build\_fast()
Same as [bb_prebuilt_build()](#bb-prebuilt-build)
#### Parameters
- Package directory
#### Return
0 on success
### bb\_prebuilt\_clean()
Nothing to clean for prebuilt.
#### Parameters
- Package directory
### bb\_prebuilt\_stat\_warning()
No warnings for prebuilt.
#### Parameters
- package directory
#### Print
Always "0"
### bb\_prebuilt\_supports\_sources\_sharing()
Prebuilt build plugin supports sources sharing
#### Return
1
## File cache

**Source file:** `_cache.sh`
### bb\_cache\_store\_file()
Store a file in the cache.
The file is not copied, instead an hard-link is made to limit disk usage.
Cached files are referenced according to their SHA256 sum, and are stored in
`BB_CACHE_DIR` folder.
#### Parameters
- File path
#### Return
0 on success
### bb\_cache\_load\_file()
Load a file from the cache, to the specified file destination path.
On cache hit, the file is hard-linked to the destination.
#### Parameters
- Requested file SHA256 sum
- File destination path
#### Return
0 on cache hit, else cache miss
### bb\_cache\_known\_file()
Check if a file is known by the cache.
#### Parameters
- File SHA256 sum
#### Print
Cached file path
#### Return
0 if cache hit, 1 if cache miss
### bb\_cache\_clear()
Remove all cached content.
## Sources
Generic sources management mechanism, relying on `_bb_clone_{tool}.sh` files,
where `{tool}` stand for the sources scraping tool (Git, HTTP, ...).

**Source file:** `_clone.sh`
### bb\_clone\_package()
Generic function to clone package sources.
Packages sources are cloned into `BB_PROJECT_SRC_DIR` directory, and then:
- symlinked into `BB_TARGET_SRC_DIR` directory if used build plugin supports
sources sharing,
- or copied into `BB_TARGET_SRC_DIR` directory if build plugin does not
supports sources sharing.

Package does not need to be referenced in target packages file.

If package is in sub-folder in project packages repository, this sub-folder
is kept in `BB_PROJECT_SRC_DIR`.

In case of symlink, the link target path is relative.
`BB_PROJECT_SRC_DIR` and `BB_TARGET_SRC_DIR` are created if they don't exist.

In `BB_TARGET_SRC_DIR`, a link is created to ease access to package sources
without knowing the revision. The link name is `package_name.sources` (base
name, no revision in package name). This links point to packages sources in
`BB_TARGET_SRC_DIR`.
#### Parameters
- Package name
#### Expected environment
- `BB_PROJECT_PROFILE_DIR`: current project path
- `BB_PROJECT_SRC_DIR`: path where cloned package are stored
- `BB_TARGET_SRC_DIR`: path where cloned package are symlinked
#### Return
0 on success
### bb\_apply\_package\_sources\_sharing()
Make the sources of a package in the current target match the sources sharing
it supports, when the two do not agree any more.

Sharing support is read when the sources are cloned (see [bb_clone_package()](#bb-clone-package)),
and the layout stays as it is afterwards: a package whose package file or
build mode changed keeps the layout it got on the day it was cloned. This
brings it back in line, for the current target only:
- sources which are shared now replace the target copy by a symlink to the
project sources, the copy being moved to the trash,
- sources which are not shared any more replace the symlink by a copy of the
project sources, the project sources being left untouched.

A target copy holding local work the project sources do not have is kept as
it is: replacing it would discard that work, which is never done. So is a
copy whose protocol can not be asked for local work.
#### Parameters
- Package name
#### Expected environment
- `BB_PROJECT_SRC_DIR`: path where the project sources are
- `BB_TARGET_SRC_DIR`: path where the target sources are
#### Print
What has been done, or why nothing was
#### Return
0 when the sources layout changed, 2 when there is nothing to change,
3 when the sources hold local work and are kept as they are, else error
### bb\_update\_package()
Update the sources of an already cloned package, when the revision it sits
on can move.

The update is delegated to the `bb_{proto}_update` function of the package
protocol, on the sources the current target uses. A protocol providing no
such function has nothing to update. Sources holding local work are kept as
they are: an update never discards anything.

Sources shared between targets are updated once, for every target using
them, which is what sharing means (see [bb_clone_package()](#bb-clone-package)).
#### Parameters
- Package name
#### Expected environment
- `BB_PROJECT_PROFILE_DIR`: current project path
- `BB_TARGET_SRC_DIR`: path where the target sources are
#### Print
What has been done, or why nothing was
#### Return
0 when updated, 2 when there is nothing to update, 3 when the
sources hold local work and are kept as they are, else error
### bb\_is\_package\_cloned()
Check if a package is cloned.
#### Parameters
- Target name
- Package name
#### Return
1 if package is cloned, else 0
## Sources using Git
Clone backend to clone components using Git.

**Source file:** `_clone_git.sh`
### bb\_git\_clone()
Clone a Git repository in a target directory, and go to specified revision.
Get submodules if needed.
#### Parameters
- Repository URI
- Target directory (where to clone sources)
- Branch, tag or changeset to use
#### Return
0 on success
### bb\_git\_moved\_tags()
Print the tags of a repository which do not designate the same commit
upstream any more, one per line.

Such a tag is the mark of a remote repository whose history changed, and it
is what makes a fetch of the tags fail: Git refuses to overwrite a tag it
already has. A tag which is not here yet is not one of them, it is simply
fetched.
#### Parameters
- Directory holding the repository
#### Print
The name of every tag which moved upstream, one per line
#### Return
0 on success, else error
### bb\_git\_update()
Update an already cloned Git repository, when the revision it sits on can
move: a branch which got new commits.

The update is a fast forward, so nothing already committed is ever lost. A
revision which is a tag or a changeset designates a fixed commit and is left
untouched, and so is a branch which received no new commit, one holding local
commits which are not upstream, and a repository holding uncommitted work.
#### Parameters
- Directory holding the repository
- Branch, tag or changeset the sources sit on
#### Print
What has been done, or why nothing was
#### Return
0 when updated, 2 when there is nothing to update, 3 when the
repository holds local work and is kept as it is, else error
### bb\_git\_has\_local\_work()
Tell if a repository holds work another clone of the same repository does not
have: uncommitted changes, untracked files, or commits the other clone has
never seen.

This answers the question asked before a clone is discarded, so anything
which can not be checked is reported as local work: the answer is never
optimistic.
#### Parameters
- Directory holding the repository
- Directory holding the repository to compare with
#### Print
What the repository holds, when it holds local work
#### Return
1 when the repository holds local work, 2 when it can not be told,
0 when it holds nothing the other clone has not
## Sources using HTTP
Clone backend to get components archives from an HTTP server.

**Source file:** `_clone_http.sh`
### bb\_http\_clone()
Get a component archive from an HTTP server.
If the archive SHA256 is specified, the archive may be cached for later use,
and if it is present in the cache it may not be re-downloaded.
#### Parameters
- Repository URI
- Destination directory (where to put the extracted archive)
- Archive SHA256 sum
- Options (separated by spaces)
#### Return
0 on success
## BuildBox internal common stuff

**Source file:** `_common.sh`
### bb\_update\_shell\_options()
Refresh the BuildBox shell options list from `BB_DEBUG`.
It is called when the API is loaded, and again once the custom
configuration files are read, as they may define `BB_DEBUG`.
#### Set environment
- `BB_SETOPT_LIST`
#### Return
0 on success
### bb\_exportfn()
BuildBox API declaration function:
- Export the function
- Add a decorator to every API to set BuildBox shell options, and restore them

API functions must begin with 'bb_'. Function must exists when declared.
#### Parameters
- API name
#### Return
0 on success
### bb\_is\_subpath\_of()
Check if a path is parent of another path.
#### Parameters
- Expected parent path
- Path to check
#### Return
0 if path has the expected parent, else 1
### bb\_confirm()
Ask user to confirm, the answer is read from standard input.
`Y` and `y` are accepted as "yes", else assume "no"
#### Parameters
- Question prompt
#### Print
The question prompt followed by ` (y/n) `
#### Return
1 if the response is "yes", else 0
### bb\_extract()
Extracts an archive in the current directory.
Supported formats:
- .tar.bz2
- .tar.gz
- .tar.xz
- .tgz
- .zip
- .tar.zst
#### Parameters
- Archive file path
Return 0 on success
### bb\_expand\_string\_vars()
Expand variables included in a string.
#### Parameters
- String to expand
#### Print
Expanded string
### bb\_function\_exists()
Check if a function exists.
#### Parameters
- Function name
#### Return
1 if function exists, else 0
### bb\_source()
Source a file if not already done.
Unlike `source`, variables exported by the sourced script are not present in
the caller scope.
#### Parameters
- File to source
#### Return
0 on success
### bb\_get\_common\_parent\_path()
Given a list of path, return the common parent path
#### Parameters
- Path 1
- Path 2
- ... Path N

At least 2 paths have to be provided, and must be absolute (starting with /).
#### Print
Common parent path, with no ending /
#### Return
0 on success
### bb\_get\_relative\_path()
Given two paths, return the relative path to go from the first to the second
#### Parameters
- First path
- Second path
#### Print
Relative path to go to second path from first path
#### Return
0 on success
### bb\_xdg\_find\_folder()
Find a folder in `XDG_DATA_DIRS`.

`XDG_DATA_DIRS` environment is a paths list separated by colon
`:` character, pointing to target build directory `share` folder, and to
tools `share` directories.
Only the first occurence is returned.
#### Parameters
- Folder name
#### Print
The folder absolute path, or nothing if not found
### bb\_add\_exit\_action()
Add an exit action. This function can be called several times, new actions
are appended after already added ones. These actions are then evaluated on
script exit.
#### Parameters
- Action shell code
## Configuration
BuildBox settings defaults can be overridden by `config` files, which are
plain shell fragments only made of variable assignments.

Three files are read, in increasing priority order:
1. the system one, shared by all the users of the machine
2. the user one, shared by all the projects of the user
3. the project one, stored in the project profile

Each file therefore overrides the previous ones, and all of them override
BuildBox built-in defaults.

The system and user files are also the shell plugin configuration files, so
they may hold `BBX_*` settings. These are only read by the host shell
plugin: they have no effect in the project file.

**Source file:** `_config.sh`
### bb\_get\_system\_config\_dir()
Get the BuildBox system configuration directory.
`BB_SYSTEM_CONFIG_DIR` is honoured when set, mainly to isolate tests from
the machine configuration. Else `/etc/buildbox` is used.
#### Print
System configuration directory absolute path
#### Return
0 on success
### bb\_get\_user\_config\_dir()
Get the BuildBox user configuration directory.
`BB_USER_CONFIG_DIR` is honoured when set, which allows the host
configuration directory to be bind-mounted at another path inside the
container. Else the XDG location is used, which is `~/.config/buildbox`
unless `XDG_CONFIG_HOME` is set.
#### Print
User configuration directory absolute path
#### Return
0 on success
### bb\_apply\_config\_defaults()
Apply BuildBox settings defaults, for every setting left undefined by the
configuration files.
#### Set environment
- `BB_BUILD_JOBS`, `BB_TRASH_KEEP_DAYS`, `BB_PREBUILT_ONLY_TAGGED`
#### Return
0 on success
### bb\_load\_config()
Load BuildBox configuration files, then apply defaults for the settings they
leave undefined.
Files are sourced in increasing priority order:
1. `$BB_SYSTEM_CONFIG`: system configuration
2. `$BB_USER_CONFIG`: user configuration
3. `$BB_CONFIG`: project configuration, skipped when no project is set
Every variable assigned by these files is exported.
This function is called by [bb_set_current_project()](#bb-set-current-project) and
[bb_autodetect_project()](#bb-autodetect-project), so it does not have to be called by hand.
#### Set environment
- `BB_SYSTEM_CONFIG`: system configuration file path
- `BB_USER_CONFIG`: user configuration file path
- `BB_CONFIG`: project configuration file path
- and every variable assigned by the configuration files
#### Return
0 on success
## Display helpers

**Source file:** `_display.sh`
### bb\_print\_columns()
Print tab-separated rows as auto-sized, aligned columns.
The first row is treated as a header and printed in bold.
ANSI color codes in cell values are accounted for in width calculations.
#### Parameters
- [--indent N] Number of spaces to prepend to each row (default: 0)
@stdin Tab-separated rows; first row is the header
## Error management

**Source file:** `_error.sh`
### bb\_error\_silent()
Catch an error and disable log file.

Exits with code 1
### bb\_trap\_errors\_silent()
Catch error signal to call [bb_error_silent()](#bb-error-silent) function.
#### Set environment
- `BB_ERROR_HANDLER`, set to [bb_error_silent()](#bb-error-silent) function
### bb\_error()
Catch an error: logs redirection is reset to stdout/stderr, and generic
error log is printed out with log file path.
Error log is written to standard error output.

Exits with code 1
### bb\_trap\_errors()
Catch error signal to call [bb_error()](#bb-error) function.
#### Set environment
- `BB_ERROR_HANDLER`, set to [bb_error()](#bb-error) function
### bb\_error\_nolog()
Catch an error: logs redirection is reset to stdout/stderr, and generic [bb_error()](#bb-error)
log is printed out. No log file is used.

Exits with code 1
### bb\_trap\_errors\_nolog()
Catch error signal to call [bb_error_nolog()](#bb-error-nolog) function.
#### Set environment
- `BB_ERROR_HANDLER`, set to [bb_error_nolog()](#bb-error-nolog) function
### bb\_trap\_errors\_custom()
Catch error signal to call custom error function.
#### Parameters
- Custom error function
#### Set environment
- `BB_ERROR_HANDLER`, set to custom error handler function name
### bb\_restore\_error\_handler()
Restore buildbox error handler to the last set one.
This is useful when dealing with sourced scripts which may define their own
error function, overwritting the BuildBox one.
#### Expected environment
- `BB_ERROR_HANDLER`, if set, use it as error handler, else, define error
handler as 'true'
## Host tools
These tools are available to deal with BuildBox container host machine to
make it execute some commands outside of BuildBox, and then get back results
and output in BuildBox.

This mechanism is prepared by BuildBox launcher, which create the following
resources:
- a pipe where BuildBox can write the command (and its arguments) to run on
the host, `workspace/tmp/launcher-ID_send.pipe`,
- a pipe where host command returned code is written,
`workspace/tmp/launcher-ID_ret.pipe`,
- and a filename is reserved to write command output,
`workspace/tmp/launcher-ID_send.out`.

The launcher ID is the launcher instance process ID, so each launcher can
run host commands without conflict with other launchers instances.

Some commands are also available, relying on these tools.

**Source file:** `_host.sh`
### bb\_path\_to\_host()
Convert a path to its host-side form, suitable for use in commands sent
via bb_host_send.
The container is bind-mounted at the same absolute path as on the host, so
no translation is needed.
#### Parameters
- Path (relative or absolute)
#### Print
Quoted absolute path for use in eval'd host commands
#### Return
0 on success
### bb\_host\_send()
Send command to host.
The BuildBox launcher creates two pipes reserved for its instance: one to
send commands to host, and the other to get return codes.
#### Parameters
- The command to run, followed by command arguments.
#### Return
0 on success, else the returned code
### bb\_host\_send\_print\_out()
Print out last host command output, started with [bb_host_send()](#bb-host-send).
The BuildBox launcher reserves an output file name for its instance, to
store commands output. The output file is removed after printing.
#### Parameters
- Optional printing command (default: cat)
#### Print
Last host command output.

**Below are listed available host commands**

### code()
VS-code host command.
### meld()
Meld host command.
### gitk()
Gitk host command.
### nautilus()
Nautilus host command (gnome files browser).
### evince()
Evince host command (gnome PDF reader).
### gedit()
Gedit host command.
### man()
Man host command, to have man pages installed out of BuildBox.
First of all, the requested man page is looked for in BuildBox, and if not
found, it is looked for host side.
## Local environment
Local environment configuration, to set environment according to current
project target

**Source file:** `_local_env.sh`
### bb\_reset\_sys\_env()
Reset local environment to defaults for system variables.
#### Reset environment
- `PATH`
- `XDG_DATA_DIRS`
### bb\_unset\_target\_local\_env\_vars()
Unset all target variables from environment.
#### Reset environment
- `BB_TARGET_VAR_xxx`: target variable xxx
#### Return
0 on success
### bb\_set\_target\_local\_env\_vars()
Set environment according to project current target variables.
#### Expected environment
- `BB_TARGET`, the target name
#### Set environment
- : `BB_TARGET_VAR_xxx`: target variable xxx
#### Return
0 on success
### bb\_set\_target\_build\_local\_env()
Set build environment according to project current target settings.

Hardware specific settings are not known by BuildBox: they are read from the
current target profile (see [bb_get_target_build_settings()](#bb-get-target-build-settings)), which is the
only place where they can be described. Each setting the target profile does
not define falls back to a default matching a native x86 build:
- `CPU` defaults to `x86`,
- `CPUDEF` and `CPU_FAMILY` default to `CPU`, uppercased, with every
character which is neither a letter nor a digit replaced by an underscore
(for example `CPU=cortex-m33` gives `CORTEX_M33`),
- `CPU_DESCRIPTION` defaults to `CPU`,
- `CHOST` defaults to `x86_64-pc-linux-gnu`,
- `CFLAGS` and `LDFLAGS` default to no architecture specific flag.

`CFLAGS` and `LDFLAGS` are then completed with the target build directory
include and library paths.
#### Expected environment
- `BB_TARGET`, the target name
- `BB_TARGET_BUILD_DIR`, the target build directory
#### Set environment
- `CFLAGS`
- `LDFLAGS`
- `CHOST`
- `CPU`
- `CPUDEF`
- `CPU_FAMILY`
- `CPU_DESCRIPTION`
- `PREFIX`, to target build directory `${BB_TARGET_BUILD_DIR}`
- `PATH`, to `${PREFIX}/bin` and `${PREFIX}/sbin`
- `PKG_CONFIG_PATH`, to `${PREFIX}/share/pkgconfig` and
`${PREFIX}/lib/pkgconfig`
- `LD_LIBRARY_PATH`, to `${PREFIX}/lib`
- `PYTHONPATH`, to `${PREFIX}/bin`,
`${PREFIX}/lib/python.../site-packages` and `${PREFIX}/lib/python/site-packages`
- `ACLOCAL_PATH`, to `${PREFIX}/share/aclocal`
- `XDG_DATA_DIRS`, to `${PREFIX}/share`
#### Return
0 on success
### bb\_set\_tools\_local\_env()
Set environment according to project current target required tools.
Only cloned tools are taken into account.
#### Set environment
- `PATH`, to tools `bin` and `sbin` folder
- `PKG_CONFIG_PATH`, to tools `share/pkgconfig` and `lib/pkgconfig`
folders
- `CFLAGS`
- `LD_LIBRARY_PATH`, to tools `lib` folder
- `LDFLAGS`
- `ACLOCAL_PATH`, to tools directory `share/aclocal` folder
- `XDG_DATA_DIRS`, to tools directory `share` folder
- `PYTHONPATH`, to tools `bin` and `lib/python/site-packages` folders
#### Return
0 on success
### bb\_is\_local\_env\_outdated()
Check if local env need to be refreshed.
The following parameters are taken into account for this:
- current target name,
- required tools,
- target variables,
- and target build settings (CPU and toolchain settings, see
[bb_get_target_build_settings()](#bb-get-target-build-settings)).

If one of them have changed, refresh is needed.
#### Return
0 if refresh not needed
### bb\_local\_env\_updated()
To be called just after local env has been updated sucessfully, then the
project is considered up-to-date. Just after call,
[bb_is_local_env_outdated()](#bb-is-local-env-outdated) returns 0.
### bb\_set\_local\_env()
Set local environment according to current project and target.
#### Expected environment
- `BB_PROJECT_DIR`, project root path
- `BB_PROJECT_PROFILE_DIR`, project profile path (.bbx/)
- `BB_TARGET`, target name
- `BB_TARGET_BUILD_DIR`, target build directory
- `BB_TOOLS_DIR`, tools directory
- `BB_DISABLE_LOCAL_ENV_SET`, if set, makes the function skip
immediately
#### Set environment
- Variables set by [bb_set_target_build_local_env()](#bb-set-target-build-local-env)
- Variables set by [bb_set_target_local_env_vars()](#bb-set-target-local-env-vars)
- Variables set by [bb_set_tools_local_env()](#bb-set-tools-local-env) if target requires tools

Environment variables precedence is: tools (from the last to the first in
target tools list), target, BuildBox and system. For example, PATH entries
are ordered following this rule.
#### Return
0 on success, 1 if project is not defined.
No error is returned if `BB_TARGET` is not set, but nothing is done.
### bb\_reset\_local\_env()
Reset local environment.
#### Expected environment
- `BB_DISABLE_LOCAL_ENV_SET`, if set, makes the function skip
immediately
#### Reset environment
- `CPU`
- `CPUDEF`
- `CPU_DESCRIPTION`
- `CFLAGS`
- `LDFLAGS`
- `CHOST`
- `CPU_FAMILY`
- `PREFIX`
- `PKG_CONFIG_PATH`
- `LD_LIBRARY_PATH`
- `PYTHONPATH`
- `ACLOCAL_PATH`
- Variables reset by [bb_unset_target_local_env_vars()](#bb-unset-target-local-env-vars)
- [bb_reset_sys_env()](#bb-reset-sys-env) is called to restore default values for some
variables
## Locks
Locks are used to control access to ressources or to synchronize processes.

A lock is a symbolic link whose target is `\<PID\>:\<SCOPE\>`, the process holding
it and the scope this PID belongs to. Creating a symbolic link is an unitary
operation, and it carries the owner without any further write, so taking a
lock can not race.

No file descriptor is involved: a lock is never inherited by a child process,
and nothing started during a build can keep it alive.

A lock whose owner process is gone is stale: it is taken over by the next
process asking for it, so a killed process leaves no lock behind.

**Source file:** `_locks.sh`
### bb\_lock\_acquire()
Acquire lock.
Only one process can hold the lock at the same time.
If the lock is already hold, block until released, or until the process
holding it is gone.
#### Parameters
- Lock file path (must be located somewhere in the project directory)
- Optional waiting message
#### Return
0 on success, else error
### bb\_lock\_try\_acquire()
Try to acquire lock.
Only one process can hold the lock at the same time.
Returns immediately.
A stale lock, whose owner process is gone, is taken over.
An exit action is configured to release the lock when the process ends.
#### Parameters
- Lock file path (must be located somewhere in BuildBox workspace
directory)
#### Return
0 on success, 1 if lock not acquired, 2 on error
### bb\_lock\_release()
Release lock.
Only the process holding the lock releases it: releasing a lock held by
another process does nothing, such a lock is taken over once its owner is
gone.
#### Parameters
- Lock file path
#### Return
0 on success
### bb\_lock\_is\_held()
Tell whether a lock is currently held, by any process.
A stale lock is not held: it is taken over by the next process asking for it.
#### Parameters
- Lock file path
#### Return
0 if the lock is held, else 1
## Log files
Log file defaults to .bbx/.logs/ if a project is active, else /tmp

**Source file:** `_log.sh`
### bb\_get\_current\_log\_file()
Get current log file path.
If [bb_set_current_log_file()](#bb-set-current-log-file) was not called, log file is by default stored
in session directory and named according to the running command,
`COMMAND_NAME.log`.
#### Print
Log file path
### bb\_set\_current\_log\_file()
Set current log file path.
If parent dir does not exists, it is created.
#### Parameters
- Log file path
- Move log file to new log file path (1 = yes, 0 = no) (optional, default no)
#### Return
0 on success
### bb\_enable\_log\_file()
Enable log file: redirect stdout and stderr to it and enable every expanded
shell command logging.
#### Return
0 on success, else log file creation failed
### bb\_log\_file\_write()
Write in log file
#### Parameters
- message to write (if no message, writes an empty newline)
#### Return
0 on success, else log file write failed
### bb\_disable\_log\_file()
Disable log file and command logging.
Reverse of [bb_enable_log_file()](#bb-enable-log-file) actions.
### bb\_is\_log\_file\_enabled()
Check if log file is enabled
#### Return
1 if enabled, 0 if disabled
### bb\_backup\_log\_file()
Backup log file.
#### Parameters
- Backup destination
### bb\_clear\_log\_file()
Clear log file
#### Return
0 on success
## Packages

**Source file:** `_package.sh`
### bb\_get\_packages()
Get packages list for a target of the current project.
#### Parameters
- Target name
#### Expected environment
- `BB_PROJECT_PROFILE_DIR`
#### Print
Packages list. The name of each returned package is the full name
(the path in packages repository).
#### Return
0 on success
### bb\_get\_packages\_with\_options()
Get packages list for a target of the current project, including packages
options.
#### Parameters
- Target name
#### Expected environment
- `BB_PROJECT_PROFILE_DIR`
#### Print
Packages list and their options, formatted like this:
`pkg_name[:[option1] [option2] ...]`.
The name of each returned package is the full name (the path in packages
repository).

For example:
```
package1: +logs -tests
package2:
package3
```
#### Return
0 on success
### bb\_find\_matching\_packages()
Given a filter list, find matching packages on current target.
#### Parameters
- Include options in output (1 to include options)
- Filter list, separated by spaces
#### Expected environment
- `BB_TARGET`: current target
- `BB_PROJECT_PROFILE_DIR`: project directory
#### Print
Matching packages list, and their build options (if requested).
If a filter does not match anything, nothing at all will be printed out.
The name of each returned package is the full name (the path in packages
repository).
Packages are returned in their order of appearance in target packages list.
Each package is returned once.
#### Return
0 on success
### bb\_package\_is\_modified()
To know if a package sources has been locally modified in current target.
A package is considered as modified if the content is not matching the
original cloned revision.

Only Git packages are supported, else this status is unknown. If the package
is not found, the status is unknown too.
#### Parameters
- Package name
#### Return
1 if modified, 0 if not modified, 2 if unknown.
### bb\_get\_package\_src\_dir()
Get package source directory absolute path
#### Parameters
- Package name
#### Print
Package source directory absolute path
#### Return
0 on success, else error (the package may be not cloned yet)
### bb\_get\_package\_name\_no\_revision()
Given a package name, extract the package name prefix, without revision.
If package name include a path prefix, it is also returned.
The revision can be:
- a branch or a tag, starting with an `@` sign,
- or a tag, starting with a dash immediately followed by a digit.

#### Parameters
- Package name
#### Print
Package name prefix (without revision, if present)
### bb\_get\_package\_revision()
Given a package name, extract the revision suffix.
The revision can be:
- a branch or a tag, starting with an `@` sign,
- or a tag, starting with a dash immediately followed by a digit.

#### Parameters
- Package name
#### Print
Package revision suffix, or nothing if no revision is present in
package name.
### bb\_load\_package()
Load a package file.
Package data are defined in the current scope.

If package name includes the package revision as suffix (after `-` or `@`),
the complete package file name is looked for. If it doesn't exists, but the
package file with no revision in its name exists, then this file is used and
`SRC_REVISION` is overwritten with revision provided in package name
parameter.

For example, if `package-1.2.3` file exists in package repository, then it is
used directly. Else, if `package-1.2.3` doesn't exists, but `package` exists,
then this file is used and `SRC_REVISION` is overwritten with `1.2.3`.
#### Parameters
- Package name
#### Print
Error message on error
#### Set environment
- `SRC_PROTO`: protocol used to clone package sources
- `SRC_URI`: sources location
- `SRC_REVISION`: sources revision
- `SRC_BUILD`: build mode
- `SRC_CONFIG`: build settings
- `SRC_POST_CLONE_HOOK`: optional function to be executed after clonig sources
#### Return
0 on success, else package not found
### bb\_get\_package\_path()
Get package path.
If package name includes the package revision as suffix (after `-` or `@`),
the package file path is printed if it exists. If it doesn't exists, but the
package file with no revision in its name exists, then this file path is
printed.

For example, if `package-1.2.3` file exists in package repository, then its
path is printed. Else, if `package-1.2.3` doesn't exists, but `package`
exists, then this file path is printed.

The package doesn't need to be referenced in target package file, but it has
to exists in project profile packages sub-module repository.
#### Parameters
- package name
#### Print
package absolute path
#### Return
0 on success, else package not found
### bb\_escape\_package\_name()
Convenient function to espace package name by removing special characters
which may be present in its revision.
Escaped characters: '/', '\'.
Escaped characters are replaced with '_'.
#### Parameters
- package name
#### Print
escaped package name
## Projects

**Source file:** `_project.sh`
### bb\_detect\_project\_root()
Detect the BuildBox project root by walking up from the current directory
looking for a .bbx/ directory.
#### Print
Absolute path of the project root, or nothing if not found
#### Return
0 if found, 1 if not found
### bb\_autodetect\_project()
Detect and set current project environment.
First checks if BB_PROJECT_DIR is already set in the environment (allows
subprocesses to inherit the project context set by the parent). If not set,
walks up from the current working directory to find a .bbx/ directory.
If no project is found, environment is left undefined. No error is raised.
#### Set environment
- Like [bb_set_current_project()](#bb-set-current-project), plus target env from state
#### Return
0 on success (including "no project found")
### bb\_set\_current\_project()
Set current project by absolute path.
#### Parameters
- Project root absolute path
#### Set environment
- `BB_PROJECT_DIR`: project root absolute path
- `BB_PROJECT`: project folder name (basename of BB_PROJECT_DIR, for 1.x compatibility)
- `BB_PROJECT_PROFILE_DIR`: .bbx/ directory path
- `BB_PROJECT_SRC_DIR`: shared package sources path
- `BB_CACHE_DIR`: per-project cache directory
- `BB_TOOLS_DIR`: per-project tools directory
- `BB_TRASH_DIR`: per-project trash directory
- `BB_CONFIG`: project configuration file path
- and env set by [bb_load_config()](#bb-load-config) and by
[bb_set_project_current_target()](#bb-set-project-current-target) via state
#### Return
0 on success
### bb\_reset\_current\_project()
Reset current project environment.
#### Reset environment
- `BB_PROJECT_DIR`, `BB_PROJECT`, `BB_PROJECT_PROFILE_DIR`, `BB_PROJECT_SRC_DIR`
- `BB_CACHE_DIR`, `BB_TOOLS_DIR`, `BB_TRASH_DIR`, `BB_CONFIG`
### bb\_is\_project\_profile\_clean()
Check if the project profile (.bbx/) has no uncommitted changes.
If .bbx/ is not a git repository (plain folder), it is considered clean.
#### Parameters
- Project root path (optional, defaults to BB_PROJECT_DIR)
#### Return
0 if profile is clean, else 1
### bb\_project\_get\_branch\_name()
Get current project git branch name.
#### Parameters
- Project root path (optional, defaults to BB_PROJECT_DIR)
#### Print
Branch name
#### Return
0 on success, else error
### bb\_project\_get\_tag()
Get current project git tag.
#### Print
Tag name
#### Return
0 on success, else error
### bb\_archive\_prebuilt\_target()
Archive current target built files.
The following is archived:
- target `build` directory
- all inside target `src` directory, except shared sources
#### Expected environment
- `BB_PREBUILT_ONLY_TAGGED`: 1 to restrict prebuilt generation to tagged
projects, else 0
#### Print
Archive directory path, to be deleted after use.
#### Return
0 on success, else error
### bb\_export\_prebuilt\_target()
Export current target pre-built archive, made by [bb_archive_prebuilt_target()](#bb-archive-prebuilt-target).
#### Parameters
- Archive directory path, from [bb_archive_prebuilt_target()](#bb-archive-prebuilt-target).
#### Expected environment
- `BB_PREBUILT_SERVER`: pre-built targets server
- `BB_PREBUILT_USERNAME`: server user name
- `BB_PREBUILT_PATH`: pre-built targets location path on server
#### Return
0 on success, else error
### bb\_target\_has\_prebuilt()
Check on the pre-built targets server if this target has an available
pre-built archive.
#### Return
0 if there is a pre-built archive for this target
### bb\_import\_prebuilt\_target()
#### Return
0 on success, else error
## Targets

**Source file:** `_target.sh`
### bb\_get\_target\_profile\_path()
Get target profile absolute path
#### Parameters
- Target name
#### Print
Target absolute path, or nothing if not found
#### Return
0 if the target is found
### bb\_project\_target\_name\_from\_file()
Get project target name from target file path.
#### Parameters
- Target file path
#### Print
Target name
### bb\_get\_project\_current\_target()
Get current project target from state file.
#### Print
Target name (empty string if no current target is defined)
### bb\_reset\_project\_current\_target()
Reset current target to let it undefined.
#### Reset environment
- `BB_TARGET`: target name
- `BB_TARGET_DIR`: target absolute path
- `BB_TARGET_SRC_DIR`: target packages sources absolute path
- `BB_TARGET_BUILD_DIR`: target built (installed) files absolute path
### bb\_set\_project\_current\_target()
Set current project target. Persists selection in state.
#### Parameters
- Target name
#### Expected environment
- `BB_TARGET`: target name
- `BB_TARGET_DIR`: target absolute path
- `BB_TARGET_SRC_DIR`: target packages sources absolute path, containing
target packages sources, which are symlinked or copied from
`BB_PROJECT_SRC_DIR` (depends on build mode)
- `BB_TARGET_BUILD_DIR`: target built (installed) files absolute path
#### Return
0 on success
### bb\_set\_project\_default\_target()
Set current project target to the project default one.
#### Expected environment
- Like [bb_set_project_current_target()](#bb-set-project-current-target)
#### Return
0 on success
### bb\_get\_project\_targets()
Get project targets names list.
#### Print
Project targets list (one per line).
#### Return
0 on success
### bb\_get\_project\_targets\_formatted()
Format project targets list.
#### Parameters
- Output mode: set to 0 for simple list on a single line separated by
spaces, else detailed view
#### Print
Formatted targets list.
#### Return
0 on success
### bb\_get\_target\_cpu()
Get target CPU
#### Parameters
- Target name
#### Print
Target CPU
#### Return
0 if target is found
### bb\_get\_target\_build\_settings()
Get build settings defined by a target profile.

These settings describe the target hardware and its toolchain. BuildBox does
not know anything about them, it only reports what the target profile
defines. Settings which are not defined (or defined empty) are not printed,
so that the [local environment](#local-environment) can apply its own
defaults.
#### Parameters
- Target name
#### Print
One `NAME=VALUE` line per defined setting, among `CPU`, `CPU_FAMILY`,
`CPU_DESCRIPTION`, `CPUDEF`, `CHOST`, `CFLAGS` and `LDFLAGS`
#### Return
0 if target is found
### bb\_get\_target\_description()
Get specified current project target description
#### Parameters
- Target name
#### Print
Description
#### Return
0 if target is found
### bb\_get\_target\_vars()
Get target variables.

The target profile is sourced, so the value of a variable may use any
variable available at that point: a BuildBox environment variable, another
field of the profile, or a variable the profile defines for its own needs.
Values are printed expanded, and quotes around them are shell quotes, so
they are not part of the value.
#### Parameters
- Target name
#### Print
Target variables list, one `VAR_NAME=VALUE` per line, formatted like
this for example:
- VAR_1=val1
- VAR_2=10
#### Return
0 on success
### bb\_save\_last\_target()
Save the current target name so it can be restored later by
bb_restore_last_target. Call this before any operation that may switch the
current target (e.g. before running a dist or test script).
#### Set environment
- BB_LAST_TARGET saved target name
### bb\_restore\_last\_target()
Restore the target previously saved by bb_save_last_target.
If the current target has changed, switches back and persists to .state.
Does nothing if bb_save_last_target was not called.
#### Reset environment
- BB_LAST_TARGET
#### Return
0 on success
## Tools (packages)

**Source file:** `_tool.sh`
### bb\_get\_tool\_dir()
Given a tool name, as written in a target tools list file, give the name of
its directory in `BB_TOOLS_DIR`.
A tool name may hold a path prefix, locating its package file in the project
profile, which is not part of the tool directory name. It may also hold a
revision (after `@` or `-`), which is part of it: as for packages, a
revision may contain `/`, escaped to `_` so that the tool stays in a single
directory.
#### Parameters
- Tool name
#### Print
Tool directory name
### bb\_find\_matching\_tools()
Given a filter list, find matching tools for current project target.
#### Parameters
- Filter list, separated by spaces. Must not be empty.
#### Expected environment
- `BB_TARGET`: current target
- `BB_PROJECT_PROFILE_DIR`: current project path
#### Print
Matching tools list

#### Return
0 on success
### bb\_get\_tools()
Get tools list for current project target
#### Parameters
- Set to 1 to return only cloned tools (optional, default 0)
#### Expected environment
- `BB_TARGET`: current target
- `BB_PROJECT_PROFILE_DIR`: current project path
#### Print
tools list
#### Return
0 on success
### bb\_clone\_tool()
Generic function to clone a tool into the tools directory.
Packages sources are cloned into `BB_TOOLS_DIR` directory.
#### Parameters
- Tool package name
#### Expected environment
- `BB_TOOLS_DIR`: path where cloned package are symlinked
- `BB_PROJECT_PROFILE_DIR`: current project path
#### Return
0 on success
### bb\_update\_tool()
Update an already cloned tool, when the revision it sits on can move.

The update is delegated to the `bb_{proto}_update` function of the tool
protocol. A protocol providing no such function has nothing to update, and
sources holding local work are kept as they are.

Tools are installed once per project and shared by all its targets, so
updating a tool updates it for every target requiring it.
#### Parameters
- Tool package name
#### Expected environment
- `BB_TOOLS_DIR`: path where tools are installed
- `BB_PROJECT_PROFILE_DIR`: current project path
#### Print
What has been done, or why nothing was
#### Return
0 when updated, 2 when there is nothing to update, 3 when the tool
holds local work and is kept as it is, else error
### bb\_load\_tools()
Load current target tools by running their (optional) `load.sh` script.
Tools are loaded in order of appearance in target tools list file
#### Expected environment
- `BB_PROJECT`: current project
- `BB_TARGET`: current target
- `BB_TOOLS_DIR`: path where tools are installed
- `BB_DISABLE_TOOLS_SCRIPTS`: if set disables this feature, the function
immediately returns
#### Return
0 on success
### bb\_unload\_tools()
Unload current target tools by running their (optional) `unload.sh` script.
Tools are unloaded in inverse order of appearance in target tools list file.
#### Expected environment
- `BB_PROJECT`: current project
- `BB_TARGET`: current target
- `BB_TOOLS_DIR`: path where tools are installed
- `BB_DISABLE_TOOLS_SCRIPTS`: if set disables this feature, the function
immediately returns
#### Return
0 on success
### bb\_run\_tools\_cleanup\_hook()
Run current target tools (optional) cleanup hook `cleanup.sh` script.
Tools cleanup hooks are run in order of appearance in target tools list file
#### Expected environment
- `BB_PROJECT`: current project
- `BB_TARGET`: current target
- `BB_TOOLS_DIR`: path where tools are installed
#### Return
0 on success
## Trash
BuildBox Trash is located in the workspace `trash` directory, and can be
referenced through `BB_TRASH_DIR` environment.

Older files are automatically removed after at least `BB_TRASH_KEEP_DAYS`.
This remove action is triggered by a call to [bb_trash()](#bb-trash) or to
[bb_trash_dir_content()](#bb-trash-dir-content).

**Source file:** `_trash.sh`
### bb\_trash\_wipe()
Remove everything from trash.
### bb\_trash\_clean()
Remove older files from trash (older than `BB_TRASH_KEEP_DAYS`).
### bb\_trash()
Trash a file or directory.
Files sent to trash are renamed with an UUID as suffix to make them unique:
`filename-UUID`.

The trash older files are automatically cleaned by a call to [bb_trash_clean()](#bb-trash-clean).
#### Parameters
- File or directory path
#### Print
File name in the trash
#### Return
0 on success, 1 if path is not in workspace.
### bb\_trash\_dir\_content()
Clean a directory content.
Files sent to trash are stored in a directory, nammed with the source
directory name with an UUID suffix to make them unique:
`directory-UUID`.

The trash older files are automatically cleaned by a call to [bb_trash_clean()](#bb-trash-clean).
#### Parameters
- Directory path
#### Print
Directory name where the files have been moved to trash.
#### Return
0 on success, 1 if path is not a directory or not in workspace.
