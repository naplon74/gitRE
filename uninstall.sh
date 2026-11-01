#!/usr/bin/env bash

# Define directories
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/gitRE"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gitRE"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/gitRE"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"

echo "[INFO] Uninstalling Git_RE..."
echo

# Remove command
if [[ -L "$BIN_DIR/gitRE" ]]; then
    rm "$BIN_DIR/gitRE"
    echo "[INFO] Removed gitRE command."
fi

# Remove application files
if [[ -d "$APP_DIR" ]]; then
    rm -rf "$APP_DIR"
    echo "[INFO] Removed Git_RE application files."
fi

echo
echo "[SUCCESS] Git_RE has been uninstalled."
echo
echo "[INFO] Your config and state files were kept."
echo "[INFO] Config: $CONFIG_DIR"
echo "[INFO] State:  $STATE_DIR"