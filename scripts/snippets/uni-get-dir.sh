if [ -n "$BASH_VERSION" ]; then
    PARENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
elif [ -n "$ZSH_VERSION" ]; then
    PARENT_DIR="$( cd "$( dirname "${(%):-%N}" )" && pwd )"
else
    PARENT_DIR="$( cd "$( dirname "$0" )" && pwd )"
fi
