# Function to recursively source .sh files
source_sh_files() {
    local dir="$1"

    # Loop through all files and directories in the current directory
    for item in "$dir"/*; do
        if [ -f "$item" ] && [[ "$item" == *.sh ]]; then
            # Source the .sh file
            echo "Sourcing: $item"
            source "$item"
        elif [ -d "$item" ]; then
            # If it's a directory, recurse into it
            source_sh_files "$item"
        fi
    done
}


# ref: ./snippets/uni-get-dir.sh
if [ -n "$BASH_VERSION" ]; then
    SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
elif [ -n "$ZSH_VERSION" ]; then
    SCRIPTS_DIR="$( cd "$( dirname "${(%):-%N}" )" && pwd )"
else
    SCRIPTS_DIR="$( cd "$( dirname "$0" )" && pwd )"
fi

# Start the recursive sourcing from the current directory
source_sh_files $SCRIPTS_DIR/inject-envs

echo "All .sh files have been sourced."
