#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   clone_worktree.sh <repo_url> [dir_name] [branch]
#
# Examples:
#   clone_worktree.sh git@github.com:me/project.git
#   clone_worktree.sh git@github.com:me/project.git my-dir
#   clone_worktree.sh git@github.com:me/project.git my-dir main

if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <repo_url> [dir_name] [branch]" >&2
	exit 1
fi

REPO_URL="$1"
DIR_NAME="${2:-}"
BRANCH="${3:-master}"

# If no dir name provided, infer it from the repo URL (strip trailing .git if present)
if [[ -z "${DIR_NAME}" ]]; then
	base="$(basename "${REPO_URL}")"
	DIR_NAME="${base%.git}"
fi

# Create directory (fail if it already exists and is not empty)
if [[ -e "${DIR_NAME}" && ! -d "${DIR_NAME}" ]]; then
	echo "Error: ${DIR_NAME} exists and is not a directory." >&2
	exit 1
fi
if [[ -d "${DIR_NAME}" && -n "$(ls -A "${DIR_NAME}" 2>/dev/null || true)" ]]; then
	echo "Error: ${DIR_NAME} already exists and is not empty." >&2
	exit 1
fi

mkdir -p "${DIR_NAME}"
cd "${DIR_NAME}"

echo "Cloning bare repo into .bare (only branch ${BRANCH}) ..."
git clone --bare --single-branch --branch "${BRANCH}" "${REPO_URL}" .bare

# Point the working directory at the bare repo
echo "gitdir: ./.bare" >.git

# Add worktree for the chosen branch
echo "Adding worktree for branch '${BRANCH}' ..."
git worktree add "${BRANCH}"

echo "Done!"
echo
echo "Repo URL : ${REPO_URL}"
echo "Dir      : ${DIR_NAME}"
echo "Branch   : ${BRANCH}"
echo
echo "Tips:"
echo "  - The '${BRANCH}' worktree is now available in the '${BRANCH}' directory."
echo "  - Your bare repo is in '.bare'."
echo "  - cd into '${BRANCH}' and use normal git commands (status, commit, push, etc.)."
