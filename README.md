# BuildBox skills for Claude Code

A [Claude Code](https://claude.com/claude-code) plugin marketplace distributing the skills of
[BuildBox](https://github.com/TrustedObjects/BuildBox), the containerized build environment
framework by Trusted Objects.

## Install

```
/plugin marketplace add TrustedObjects/BuildBox-claude
/plugin install buildbox@trusted-objects
```

If you installed BuildBox from its sources, you do not need this marketplace: `bbx claude
install` links the same skills from your installation, and they follow every BuildBox update.
See the [documentation](https://buildbox.trusted-objects.com/user/claude.html).

## What the plugin provides

| Skill | Purpose |
|-------|---------|
| `buildbox` | Working on a project: targets, packages, tools, container, deliveries |
| `buildbox-scripting` | Writing scripts run by BuildBox: target tests and deliveries, package builds, tools |
| `buildbox-develop` | Working on BuildBox itself |

Each skill embeds the reference documentation it needs, so it works offline.

## How this repository is maintained

Everything under `plugins/` is **generated**, never edited by hand:

- the skills come from `settings/claude/skills/` of a BuildBox release,
- their reference is generated from the BuildBox documentation sources, which stay the single
  source of truth,
- `plugins/buildbox/buildbox-release.json` records the BuildBox release published here.

`scripts/sync.sh` does the assembling, and the `Sync BuildBox skills` workflow runs it: on
demand after a BuildBox release, and once a day as a safety net. It opens a pull request, so
every publication is reviewed before it reaches users.

To run it by hand:

```
scripts/sync.sh              # latest stable BuildBox release
scripts/sync.sh 2.2.0        # a given release
```

## License

GNU General Public License v2, like BuildBox. See [LICENSE](LICENSE).
