# Detect shell and get script directory
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
	# Bash
	SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
	# Zsh - use 0 variable which contains the script path
	SCRIPT_DIR="$(dirname "$0")"
	# If $0 is just "zsh" or "-zsh", we're in interactive mode
	if [[ "$0" == "zsh" ]] || [[ "$0" == "-zsh" ]] || [[ "$0" == "/bin/zsh" ]]; then
		# Fallback for interactive shell
		SCRIPT_DIR="$HOME/scripts"
	fi
else
	# Fallback - assume script is in ~/scripts
	SCRIPT_DIR="$HOME/scripts"
fi

export PATH="$PATH:$SCRIPT_DIR"

alias git-clone-worktree=clone_worktree.sh
alias gcw=git-clone-worktree

alias git-add-worktree=add_worktree.sh
alias gaw=git-add-worktree

alias copy-master-config-files=copy_master_config_files.sh
alias cmcf=copy-master-config-files
