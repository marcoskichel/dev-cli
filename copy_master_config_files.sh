#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   copy_master_config_files.sh
#
# Copies non-versioned config files from the master worktree to the current directory.
# Useful for copying .env files and other untracked configuration files between worktrees.

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
	echo "Error: Not in a git repository" >&2
	exit 1
fi

# Get current branch name
CURRENT_BRANCH="$(git branch --show-current)"
if [[ -z "${CURRENT_BRANCH}" ]]; then
	echo "Error: Could not determine current branch" >&2
	exit 1
fi

# Check if we're already in master
if [[ "${CURRENT_BRANCH}" == "master" ]]; then
	echo "Error: Already in master branch. This script is meant to be run from other worktrees." >&2
	exit 1
fi

# Find master worktree path
MASTER_PATH=""
while IFS= read -r line; do
	if [[ $line == *"[master]" ]]; then
		MASTER_PATH="$(echo "$line" | awk '{print $1}')"
		break
	fi
done < <(git worktree list)

if [[ -z "${MASTER_PATH}" ]]; then
	echo "Error: Could not find master worktree" >&2
	exit 1
fi

if [[ ! -d "${MASTER_PATH}" ]]; then
	echo "Error: Master worktree path does not exist: ${MASTER_PATH}" >&2
	exit 1
fi

echo "Master worktree found at: ${MASTER_PATH}"
echo "Current worktree: $(pwd)"
echo

# Find untracked and ignored files in master worktree
UNTRACKED_FILES=()
while IFS= read -r file; do
	# Skip directories and only include config-like files
	if [[ -f "${MASTER_PATH}/${file}" ]]; then
		# Include common config file patterns
		if [[ "$file" =~ \.(env|config|ini|conf|yaml|yml|json|toml)$ ]] ||
		   [[ "$file" =~ ^\.env ]] ||
		   [[ "$file" =~ ^\..*rc$ ]] ||
		   [[ "$file" =~ \.local$ ]]; then
			UNTRACKED_FILES+=("$file")
		fi
	fi
done < <(cd "${MASTER_PATH}" && git ls-files --others)

if [[ ${#UNTRACKED_FILES[@]} -eq 0 ]]; then
	echo "No untracked config files found in master worktree."
	exit 0
fi

echo "Found ${#UNTRACKED_FILES[@]} config file(s) to copy:"
for file in "${UNTRACKED_FILES[@]}"; do
	echo "  - $file"
done
echo

# Copy files
COPIED_COUNT=0
SKIPPED_COUNT=0
for file in "${UNTRACKED_FILES[@]}"; do
	SOURCE="${MASTER_PATH}/${file}"
	DEST="./${file}"

	# Skip if file already exists in current worktree
	if [[ -f "$DEST" ]]; then
		echo "Skipped (already exists): $file"
		((SKIPPED_COUNT++))
		continue
	fi

	# Create directory if needed
	DEST_DIR="$(dirname "$DEST")"
	if [[ "$DEST_DIR" != "." && ! -d "$DEST_DIR" ]]; then
		mkdir -p "$DEST_DIR"
	fi

	# Copy file with preserved permissions and timestamps
	if cp -p "$SOURCE" "$DEST"; then
		echo "Copied: $file"
		((COPIED_COUNT++))
	else
		echo "Failed to copy: $file" >&2
	fi
done

echo
if [[ $SKIPPED_COUNT -gt 0 ]]; then
	echo "Successfully copied ${COPIED_COUNT} file(s), skipped ${SKIPPED_COUNT} existing file(s)."
else
	echo "Successfully copied ${COPIED_COUNT} file(s)."
fi