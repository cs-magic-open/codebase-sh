# Logging configuration
SCRIPT_NAME="inject-envs"

# Normalize LOG_LEVEL to numeric value
case "${LOG_LEVEL:-2}" in
    ERROR|error|1) LOG_LEVEL=1 ;;
    WARN|warn|2) LOG_LEVEL=2 ;;
    INFO|info|3) LOG_LEVEL=3 ;;
    DEBUG|debug|4) LOG_LEVEL=4 ;;
    0) LOG_LEVEL=0 ;;
    *) LOG_LEVEL=2 ;;  # Default to WARN level
esac

# Support quiet mode
if [ "$CODEBASE_SH_QUIET" = "1" ]; then
    LOG_LEVEL=0
fi

# Logging functions
log_debug() { [ "$LOG_LEVEL" -ge 4 ] && echo "[DEBUG][$SCRIPT_NAME] $*" >&2; }
log_info()  { [ "$LOG_LEVEL" -ge 3 ] && echo "[INFO][$SCRIPT_NAME] $*" >&2; }
log_warn()  { [ "$LOG_LEVEL" -ge 2 ] && echo "[WARN][$SCRIPT_NAME] $*" >&2; }
log_error() { [ "$LOG_LEVEL" -ge 1 ] && echo "[ERROR][$SCRIPT_NAME] $*" >&2; }

# Function to recursively source .sh files
source_sh_files() {
    local dir="$1"
    # echo "[DEBUG] Entering directory: $dir"

    # Check if directory exists
    if [ ! -d "$dir" ]; then
        log_error "Directory does not exist: $dir"
        return 1
    fi

    # Loop through all files and directories in the current directory
    for item in "$dir"/*; do
        # Check if glob pattern matched anything
        if [ ! -e "$item" ]; then
            log_debug "No items found in directory: $dir"
            continue
        fi
        
        if [ -f "$item" ] && [[ "$item" == *.sh ]]; then
            # Source the .sh file
            log_debug "Sourcing: $item"
            if source "$item"; then
                log_debug "Successfully sourced: $item"
            else
                log_error "Failed to source: $item (exit code: $?)"
            fi
        elif [ -d "$item" ]; then
            # If it's a directory, recurse into it
            # echo "[DEBUG] Recursing into directory: $item"
            source_sh_files "$item"
        else
            log_debug "Skipping non-.sh file: $item"
        fi
    done
}


# ref: ./snippets/uni-get-dir.sh
log_debug "Detecting shell type..."
if [ -n "$BASH_VERSION" ]; then
    log_debug "Using BASH shell detection"
    SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
elif [ -n "$ZSH_VERSION" ]; then
    log_debug "Using ZSH shell detection"
    SCRIPTS_DIR="$( cd "$( dirname "${(%):-%N}" )" && pwd )"
else
    log_debug "Using generic shell detection"
    SCRIPTS_DIR="$( cd "$( dirname "$0" )" && pwd )"
fi

log_info "Scripts directory: $SCRIPTS_DIR"
TARGET_DIR="$SCRIPTS_DIR/inject-envs"
log_info "Target directory for sourcing: $TARGET_DIR"

# Start the recursive sourcing from the current directory
log_info "Starting recursive sourcing..."
source_sh_files "$TARGET_DIR"

log_info "All .sh files have been sourced."
