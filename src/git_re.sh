#!/usr/bin/bash

VERSION="COPR-v1.3.0"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/main.sh"
PYTHON_SCRIPT="$SCRIPT_DIR/output.py"

show_help() {
    echo "Usage: gitRE [COMMAND]"
    echo
    echo "Commands:"
    echo "  --help       Show this help message"
    echo "  --version    Show version information"
    echo "  --skip       Skip the scan of the repo. Only display the Python output"
    echo
}

show_version() {
    echo "gitRE - Look for update with: dnf list updates | grep gitRE"
    echo
    echo "Version: $VERSION"
    echo "Source: Fedora COPR"
    . /etc/os-release
    echo "OS : $NAME $VERSION_ID"
    echo "--------"
    echo "Config : ${XDG_CONFIG_HOME:-$HOME/.config}/gitRE"
    echo "Logs : ${XDG_STATE_HOME:-$HOME/.local/state}/gitRE"
    echo "Script : /usr/libexec/gitre"
    echo "--------"
    echo "Author: naplon74"
    echo "License: GPL-3.0-or-later"
    echo "Repo: https://github.com/naplon74/gitRE"
}

case "${1:-}" in
    help|-h|--help)
        show_help
        ;;
    version|-v|--version)
        show_version
        ;;
    skip|-s|--skip)
    	exec python3 "$PYTHON_SCRIPT"
    	;;
    "")
        exec bash "$MAIN_SCRIPT"
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo "Run 'gitRE --help' for usage."
        exit 1
        ;;
esac
