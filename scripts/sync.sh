#!/bin/bash
# This file is part of BuildBox project
# Copyright (C) 2020-2026 Trusted Objects

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2, as published by the Free Software Foundation.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, see
# <https://www.gnu.org/licenses/>.

set -e

## Sync the Claude Code skills of a BuildBox release into this marketplace.
## Everything under plugins/ is produced from the BuildBox repository, this
## script is the only thing that writes it.
## Usage: sync.sh [BuildBox tag]
## Without a tag, the latest stable BuildBox release is used.
## Prints "tag=", "sha=" and "changed=" on standard output, progress on error
## output, so that a CI job can consume the result.

BUILDBOX_REPO="${BUILDBOX_REPO:-https://github.com/TrustedObjects/BuildBox.git}"
PLUGIN_DIR="plugins/buildbox"
RELEASE_FILE="${PLUGIN_DIR}/buildbox-release.json"

if [ ! -f .claude-plugin/marketplace.json ]; then
	>&2 echo "Run this script from the root of the marketplace repository"
	exit 1
fi

## Check the plugin is publishable: a broken plugin in a public directory costs
## more than a late one.
## @return 0 when the plugin is sound
function verify_plugin {
	local skill=""
	local name=""
	for skill in "${PLUGIN_DIR}"/skills/*/; do
		name=$(basename "${skill}")
		if [ ! -f "${skill}SKILL.md" ]; then
			>&2 echo "Skill ${name} has no SKILL.md"
			return 1
		fi
		# The declared name must match the directory, else the skill is ignored
		if ! grep -q "^name: ${name}$" "${skill}SKILL.md"; then
			>&2 echo "Skill ${name} does not declare that name"
			return 1
		fi
		if ! grep -q "^description: " "${skill}SKILL.md"; then
			>&2 echo "Skill ${name} has no description"
			return 1
		fi
		if [ -z "$(ls -A "${skill}reference" 2>/dev/null)" ]; then
			>&2 echo "Skill ${name} has no reference documentation"
			return 1
		fi
	done
	jq empty .claude-plugin/marketplace.json || return 1
	jq empty "${PLUGIN_DIR}/.claude-plugin/plugin.json" || return 1
	return 0
}

tag="${1}"
if [ -z "${tag}" ]; then
	# Same filter as the BuildBox Makefile: plain version tags only, so
	# pre-releases and the docker_* tags are never published
	tag=$(git ls-remote --tags --refs "${BUILDBOX_REPO}" \
		| sed 's|.*refs/tags/||' \
		| grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
		| sort -V | tail -1)
fi
if [ -z "${tag}" ]; then
	>&2 echo "No stable BuildBox release found in ${BUILDBOX_REPO}"
	exit 1
fi
sha=$(git ls-remote "${BUILDBOX_REPO}" "refs/tags/${tag}" | cut -f1)

published=""
if [ -f "${RELEASE_FILE}" ]; then
	published=$(jq -r '.tag // ""' "${RELEASE_FILE}")
fi
if [ "${published}" = "${tag}" ]; then
	>&2 echo "BuildBox ${tag} is already published"
	echo "tag=${tag}"
	echo "sha=${sha}"
	echo "changed=false"
	exit 0
fi

work=$(mktemp -d)
trap 'rm -rf "${work}"' EXIT
>&2 echo "Fetching BuildBox ${tag}..."
git clone --quiet --depth 1 --branch "${tag}" "${BUILDBOX_REPO}" "${work}/buildbox"

if [ ! -d "${work}/buildbox/settings/claude/skills" ]; then
	# Releases older than the skills themselves have nothing to publish
	>&2 echo "BuildBox ${tag} does not ship Claude Code skills, nothing to do"
	echo "tag=${tag}"
	echo "sha=${sha}"
	echo "changed=false"
	exit 0
fi

>&2 echo "Generating the reference from the BuildBox documentation..."
"${work}/buildbox/settings/claude/generate_reference.sh" \
	"${work}/buildbox/docs/src" "${work}/buildbox/settings/claude/skills" >&2

# Assembled from scratch, so that a skill or a page removed upstream disappears
rm -rf "${PLUGIN_DIR}/skills"
mkdir -p "${PLUGIN_DIR}/skills"
cp -a "${work}/buildbox/settings/claude/skills/." "${PLUGIN_DIR}/skills/"
cp "${work}/buildbox/LICENSE" "${PLUGIN_DIR}/LICENSE"

# Checked before anything is recorded: a failed check must leave no trace of a
# publication, so that the next run tries again
verify_plugin

# The plugin version is the BuildBox version it comes from, and the release file
# is what tells a later run this version is already published
updated=$(mktemp)
jq --arg version "${tag}" '.version = $version' \
	"${PLUGIN_DIR}/.claude-plugin/plugin.json" > "${updated}"
mv "${updated}" "${PLUGIN_DIR}/.claude-plugin/plugin.json"
updated=$(mktemp)
jq --arg version "${tag}" '.plugins[0].version = $version' \
	.claude-plugin/marketplace.json > "${updated}"
mv "${updated}" .claude-plugin/marketplace.json
jq -n --arg tag "${tag}" --arg sha "${sha}" \
	--arg synced "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
	'{tag: $tag, sha: $sha, synced: $synced}' > "${RELEASE_FILE}"

>&2 echo "Plugin assembled from BuildBox ${tag}"
echo "tag=${tag}"
echo "sha=${sha}"
echo "changed=true"
