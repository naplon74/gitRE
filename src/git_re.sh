#!/usr/bin/env bash

VERSION="GH-v1.3.0"
SCRIPT_PATH="$(readlink -f -- "${BASH_SOURCE[0]}")"
APP_DIR="$(dirname "$SCRIPT_PATH")"

MAIN_SCRIPT="$APP_DIR/main.sh"
PYTHON_SCRIPT="$APP_DIR/output.py"

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
    echo "gitRE - Check the repo for update"
    echo
    echo "Version: $VERSION"
    echo "Source: Fedora COPR"
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
        exec "$MAIN_SCRIPT"
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo "Run 'gitRE --help' for usage."
        exit 1
        ;;
esac
