# BuildBox

Claude Code skills for [BuildBox](https://buildbox.trusted-objects.com), a containerized
build environment framework which gives a project reproducible, isolated builds.

Working on a BuildBox project means an unusual environment: the versioned part of a project
is its `.bbx/` profile, packages and tools are separate git clones, the build environment
lives in a container reached through the `bbx` command, and the active target drives the
compilation settings. These skills describe all of it, so Claude operates the project instead
of guessing.

## Skills

- **`buildbox`**: working on a project. Where to look to situate yourself, the layout, which
  commands run on the host and which in the container, where the logs are, and the whole
  command surface, from `target build` to pre-built targets.
- **`buildbox-scripting`**: writing what BuildBox runs. Target test and delivery scripts,
  package build scripts, tools, with the API functions, the environment variables and the
  build modes.
- **`buildbox-develop`**: working on BuildBox itself, its library, commands, images, test
  suite and documentation.

Each one carries the reference documentation it needs, generated from the BuildBox
documentation, so nothing has to be fetched at use time.

## Documentation

[buildbox.trusted-objects.com](https://buildbox.trusted-objects.com), and
[Working with Claude Code](https://buildbox.trusted-objects.com/user/claude.html) for how
these skills are installed and kept up to date.

## License

GNU General Public License v2, like BuildBox.
