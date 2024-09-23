#!/bin/bash

export ggg_v0.2.0() {
    # ANSI color codes
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    RESET='\033[0m'

    # Indent and indicators
    INDENT="  "
    START_INDICATOR="${CYAN}▶${RESET}"
    SUB_INDICATOR="${YELLOW}→${RESET}"
    END_INDICATOR="${GREEN}✔${RESET}"

    echo_start() {
        echo -e "\n${START_INDICATOR} ${BLUE}$1${RESET}"
    }

    echo_step() {
        echo -e "${INDENT}${SUB_INDICATOR} ${YELLOW}$1${RESET}"
    }

    echo_info() {
        echo -e "${INDENT}${INDENT}${CYAN}ℹ${RESET} $1"
    }

    echo_end() {
        echo -e "${END_INDICATOR} ${GREEN}$1${RESET}\n"
    }

    # Check if a commit message was provided
    if [ $# -eq 0 ]; then
        echo -e "${RED}Error: Please provide a commit message.${RESET}"
        echo "Usage: ggg_v0.2.0 <commit_message>"
        return 1
    fi

    local COMMIT_MESSAGE="$1"

    # Function to process a repository and its submodules
    process_repo() {
        local repo_path="$1"
        local repo_name="$2"
        local indent="$3"

        echo_start "${indent}Processing repository: $repo_name"

        # Save current directory to return later
        pushd "$repo_path" > /dev/null || return

        # Process all submodules first
        git submodule foreach --quiet 'echo "$path"' | while read -r submodule; do
            process_repo "$submodule" "$submodule" "$indent$INDENT"
        done

        # After processing all submodules, check if there are any changes in the current repo
        if [[ $(git status --porcelain) ]]; then
            echo_step "${indent}Changes detected in $repo_name. Committing..."
            git add .
            git commit -m "$COMMIT_MESSAGE"
            git push
            echo_info "${indent}Changes committed and pushed for $repo_name"
        else
            echo_info "${indent}No changes detected in $repo_name"
        fi

        # Return to the parent directory
        popd > /dev/null || return

        echo_end "${indent}Completed processing: $repo_name"
    }

    echo -e "${CYAN}=== Starting Git Operations ===${RESET}"
    # Start the process from the current directory
    process_repo "." "$(basename "$(pwd)")" ""
    echo -e "${CYAN}=== Git Operations Complete ===${RESET}"

    echo_end "All repositories and nested submodules checked and updated."
}

# Example usage (commented out)
# ggg_v0.2.0 "Your commit message here"
