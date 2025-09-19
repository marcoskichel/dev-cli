# Git Worktree Scripts

A collection of shell scripts to simplify working with Git worktrees

## Overview

These scripts help you:

- Clone repositories using a bare + worktree.
- Add new worktrees to existing repositories with consistent naming
- Set up convenient shell aliases for quick access

## Scripts

### `clone_worktree.sh`

Clones a repository as a bare repo and immediately creates a worktree for the main branch.

**Usage:**

```bash
clone_worktree.sh <repo_url> [dir_name] [branch]
```

**Examples:**

```bash
# Clone with default directory name and master branch
clone_worktree.sh git@github.com:user/project.git

# Clone into specific directory
clone_worktree.sh git@github.com:user/project.git my-project

# Clone and checkout specific branch
clone_worktree.sh git@github.com:user/project.git my-project main
```

**What it does:**

1. Creates a directory for your project
2. Clones the repository as a bare repo in `.bare`
3. Sets up a worktree for the specified branch
4. The bare repo setup allows efficient creation of additional worktrees

### `add_worktree.sh`

Adds a new worktree to an existing Git repository with automatic naming based on the project name.

**Usage:**

```bash
add_worktree.sh <name> [branch]
```

**Examples:**

```bash
# Create worktree from current branch
add_worktree.sh feature-xyz

# Create worktree from specific branch
add_worktree.sh bugfix main
```

**What it does:**

1. Creates a worktree named `<project-name>_<name>`
2. Creates a new branch with the same name as the worktree
3. Handles both regular and bare repository setups
4. Places the worktree in the appropriate location (sibling directory for regular repos, or within bare repo structure)

### `aliases.sh`

Provides convenient shell aliases for the worktree scripts.

**Aliases:**

- `gcw` or `git-clone-worktree` → `clone_worktree.sh`
- `gaw` or `git-add-worktree` → `add_worktree.sh`

## Installation

### Aliases setup

1. Clone this repository or download the scripts:

```bash
git clone git@github.com:yourusername/scripts.git ~/scripts
```

2. Make the scripts executable:

```bash
chmod +x ~/scripts/*.sh
```

3. Add the scripts directory to your PATH by adding this to your `~/.bashrc` or `~/.zshrc`:

```bash
source "$HOME/scripts/aliases.sh"
```

## Workflow Example

1. **Clone a new project:**

```bash
gcw git@github.com:user/awesome-project.git
cd awesome-project/master
```

2. **Start working on a feature:**

```bash
gaw feature-auth
cd ../awesome-project_feature-auth
# Work on your feature...
git push -u origin awesome-project_feature-auth
```

3. **Fix a bug while keeping your feature work:**

```bash
gaw hotfix main
cd ../awesome-project_hotfix
# Fix the bug...
git push -u origin awesome-project_hotfix
```

## Requirements

- Git 2.5 or later (for worktree support)
- Bash or Zsh shell
- Unix-like environment (Linux, macOS, WSL)
