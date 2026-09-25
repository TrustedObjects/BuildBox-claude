<!-- Generated from docs/src/user/index.md by settings/claude/generate_reference.sh -->
<!-- Do not edit: update the documentation source instead -->

# Introduction

BuildBox main key concepts are [projects](https://buildbox.trusted-objects.com/user/project.html), [targets](https://buildbox.trusted-objects.com/user/target.html), [packages](https://buildbox.trusted-objects.com/user/package.html) and [tools](https://buildbox.trusted-objects.com/user/tool.html).

A [project](https://buildbox.trusted-objects.com/user/project.html) stands for deliverable components, and the way to build them.
It is composed of one or several [targets](https://buildbox.trusted-objects.com/user/target.html), which define the platform of a deliverable, including build, test and distribution methods.
[Targets](https://buildbox.trusted-objects.com/user/target.html) embed [packages](https://buildbox.trusted-objects.com/user/package.html), which are software components built for them.
And [tools](https://buildbox.trusted-objects.com/user/tool.html) are used by [targets](https://buildbox.trusted-objects.com/user/target.html) and involved in the build, test and distribution to release the deliverable.

<ProjectLayout />

BuildBox is used through the `bbx` command, directly from a project directory.
It works like any other command-line tool: no shell to enter, no workspace to configure.
Please run `bbx --help` to get a complete list of supported commands.

**Warning:**
BuildBox commands are not meant to be used from shell scripts if you need to deal with output data.
Indeed, output format is not fixed for BuildBox commands as they are to be used by humans.
So, if you have to deal with BuildBox from scripts and need to parse output data, consider using [BuildBox API](https://buildbox.trusted-objects.com/dev/api.html).
