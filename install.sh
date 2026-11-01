#!/usr/bin/env bash

set -e

# Define repository
REPO_URL="https://github.com/naplon74/gitRE.git"
BRANCH="main"

# Define directories
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/gitRE"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gitRE"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/gitRE"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"

echo "[INFO] Installing Git_RE v1.2..."

# Check required commands
for command in git python3 jq; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "[ERROR] $command wasn't found."
        echo "[INFO] Please install $command and run the installer again."
        exit 1
    fi
done

# Check Python dependencies
if ! python3 -c "import rich" >/dev/null 2>&1; then
    echo "[ERROR] Python package 'rich' wasn't found."
    echo "[INFO] Install it using your distribution's package manager."
    exit 1
fi

# Create directories
mkdir -p "$CONFIG_DIR"
mkdir -p "$STATE_DIR"
mkdir -p "$BIN_DIR"

# Clone or update repository
if [[ -d "$APP_DIR/.git" ]]; then
    echo "[INFO] Existing installation found."
    echo "[INFO] Updating Git_RE..."

    git -C "$APP_DIR" fetch origin "$BRANCH" --quiet
    git -C "$APP_DIR" checkout "$BRANCH" --quiet
    git -C "$APP_DIR" pull --ff-only origin "$BRANCH" --quiet
else
    echo "[INFO] Downloading Git_RE..."

    if [[ -e "$APP_DIR" ]]; then
        echo "[ERROR] $APP_DIR already exists and isn't a Git repository."
        exit 1
    fi

    git clone \
        --branch "$BRANCH" \
        --single-branch \
        --quiet \
        "$REPO_URL" \
        "$APP_DIR"
fi

# Create default configuration
if [[ ! -f "$CONFIG_DIR/config.json" ]]; then
    echo "[INFO] Creating default configuration..."

    cat > "$CONFIG_DIR/config.json" <<EOF
{
    "gith_path": "$(command -v git)",
    "python3_path": "$(command -v python3)"
}
EOF
else
    echo "[INFO] Existing configuration found, keeping it."
fi

# Create command symlink
ln -sf "$APP_DIR/src/git_re.sh" "$BIN_DIR/gitRE"

# Set executable permissions
chmod +x "$APP_DIR/src/git_re.sh"

echo
echo "[SUCCESS] Git_RE has been installed."
echo
echo "[INFO] Branch:  $BRANCH"
echo "[INFO] Command: $BIN_DIR/gitRE"
echo "[INFO] Config:  $CONFIG_DIR/config.json"
echo "[INFO] State:   $STATE_DIR"
echo

# Check PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "[WARNING] $BIN_DIR is not in your PATH."
    echo "[INFO] Add the following to your shell configuration:"
    echo
    echo 'export PATH="$HOME/.local/bin:$PATH"'
fi
