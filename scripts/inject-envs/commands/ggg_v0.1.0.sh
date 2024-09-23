#!/bin/bash

export ggg_v0.1.0() {
  echo "== running ggg_v0.1.0 =="
    # Check if a commit message was provided
    if [ $# -eq 0 ]; then
        echo "Error: Please provide a commit message."
        echo "Usage: ggg_v0.1.0 <commit_message>"
        return 1
    fi

    local COMMIT_MESSAGE="$1"

    # Function to process a repository and its submodules
    process_repo() {
        local repo_path="$1"
        local repo_name="$2"
        local indent="$3"

        echo "${indent}Processing repository: $repo_name"

        # Save current directory to return later
        pushd "$repo_path" > /dev/null || return

        # Process all submodules first
        git submodule foreach --quiet 'echo "$path"' | while read -r submodule; do
            process_repo "$submodule" "$submodule" "$indent  "
        done

        # After processing all submodules, check if there are any changes in the current repo
        if [[ $(git status --porcelain) ]]; then
            echo "${indent}Changes detected in $repo_name. Committing..."
            git add .
            git commit -m "$COMMIT_MESSAGE"
            git push
            echo "${indent}Changes committed and pushed for $repo_name"
        else
            echo "${indent}No changes detected in $repo_name"
        fi

        # Return to the parent directory
        popd > /dev/null || return
    }

    # Start the process from the current directory
    process_repo "." "$(basename "$(pwd)")" ""

    echo "All repositories and nested submodules checked and updated."
}

# Example usage (commented out)
# ggg_v0.1.0 "Your commit message here"
