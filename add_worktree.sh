#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   add_worktree.sh <name> [branch]
#
# Examples:
#   add_worktree.sh test           # Creates worktree 'test' from current branch
#   add_worktree.sh test main      # Creates worktree 'test' from main branch

if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <name> [branch]" >&2
	echo "  Creates a worktree with the specified name" >&2
	exit 1
fi

NAME="$1"
BRANCH="${2:-}"

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
	echo "Error: Not in a git repository" >&2
	exit 1
fi

# Fetch all remote branches to ensure they're available locally
echo "Fetching all remote branches..."
git fetch --all

WORKTREE_NAME="${NAME}"
NEW_BRANCH="${NAME}"

# Determine base branch
if [[ -n "${BRANCH}" ]]; then
	BASE_BRANCH="${BRANCH}"
else
	BASE_BRANCH="$(git branch --show-current)"
	if [[ -z "${BASE_BRANCH}" ]]; then
		BASE_BRANCH="HEAD"
	fi
fi

# Determine worktree location based on repository type
if [[ -d "../.bare" ]]; then
	# We're in a worktree of a bare repo, create sibling worktree
	WORKTREE_PATH="../${WORKTREE_NAME}"
	CD_PATH="../${WORKTREE_NAME}"
elif [[ -d ".bare" ]]; then
	# We're in the root of a bare repo, create worktree here
	WORKTREE_PATH="./${WORKTREE_NAME}"
	CD_PATH="${WORKTREE_NAME}"
else
	# Regular repo, create in parent directory
	WORKTREE_PATH="../${WORKTREE_NAME}"
	CD_PATH="../${WORKTREE_NAME}"
fi

# Check if worktree already exists
if git worktree list | grep -q "${WORKTREE_NAME}"; then
	echo "Error: Worktree '${WORKTREE_NAME}' already exists" >&2
	exit 1
fi

# Check if the directory already exists
if [[ -e "${WORKTREE_PATH}" ]]; then
	echo "Error: Directory '${WORKTREE_PATH}' already exists" >&2
	exit 1
fi

# Check if a branch with the worktree name already exists
if git show-ref --verify --quiet "refs/heads/${NEW_BRANCH}"; then
	echo "Error: Branch '${NEW_BRANCH}' already exists" >&2
	exit 1
fi

# Create new worktree with new branch
echo "Creating worktree '${WORKTREE_NAME}' with new branch '${NEW_BRANCH}' based on '${BASE_BRANCH}'"
git worktree add -b "${NEW_BRANCH}" "${WORKTREE_PATH}" "${BASE_BRANCH}"
echo "Created worktree '${WORKTREE_NAME}' with branch '${NEW_BRANCH}'"

echo
echo "Done! You can now:"
echo "  cd ${CD_PATH}"
