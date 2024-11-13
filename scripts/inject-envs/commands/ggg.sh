#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Indent and indicators
INDENT_CHAR="  "
START_INDICATOR="${CYAN}▶${RESET}"
SUB_INDICATOR="${YELLOW}→${RESET}"
END_INDICATOR="${GREEN}✔${RESET}"
ERROR_INDICATOR="${RED}✘${RESET}"

echo_start() {
    echo -e "\n${1}${START_INDICATOR} ${BLUE}Starting:${RESET} $2"
}

echo_step() {
    echo -e "${1}${SUB_INDICATOR} ${YELLOW}$2${RESET}"
}

echo_info() {
    echo -e "${1}${MAGENTA}ℹ${RESET} $2"
}

echo_end() {
    echo -e "${1}${END_INDICATOR} ${GREEN}Completed:${RESET} $2"
}

echo_error() {
    echo -e "${1}${ERROR_INDICATOR} ${RED}Error:${RESET} $2"
}

ggg() {
    # Check if a commit message was provided
    if [ $# -eq 0 ]; then
        echo_error "" "Please provide a commit message."
        echo_info "" "Usage: ggg <commit_message>"
        return 1
    fi

    local COMMIT_MESSAGE="$1"

    # Function to process a repository and its submodules
    process_repo() {
        local repo_path="$1"
        local repo_name="$2"
        local indent="$3"

        echo_start "$indent" "Processing repository: $repo_name"

        # Save current directory to return later
        pushd "$repo_path" > /dev/null || return

        # Loop through submodules
        local oldIFS=$IFS
        IFS=$'\n'
        local submodules=($(git submodule foreach --quiet 'echo "$path"'))
        IFS=$oldIFS

        for submodule in "${submodules[@]}"; do
            if [ ! -z "$submodule" ]; then
                process_repo "$submodule" "$submodule" "$indent$INDENT_CHAR"
                # Explicitly return to parent repo after processing each submodule
                pushd "$repo_path" > /dev/null || return
            fi
        done

        # Check if there are any changes in the current repo
        if [[ $(git status --porcelain) ]]; then
            echo_step "$indent" "Changes detected in $repo_name. Committing..."
            git add .
            git commit -m "$COMMIT_MESSAGE"
            git push
            echo_info "$indent" "Changes committed and pushed for $repo_name"
            echo_end "$indent" "Finished processing: $repo_name"
        else
            :
            #echo_info "$indent" "No changes detected in $repo_name"
        fi

        # Return to the parent directory
        popd > /dev/null || return
    }

    echo -e "${CYAN}=== Starting Git Global Commit (ggg) ===${RESET}"
    # Start the process from the current directory
    process_repo "." "$(basename "$(pwd)")" ""
    echo -e "${CYAN}=== Git Global Commit (ggg) Complete ===${RESET}"
}

export -f ggg
