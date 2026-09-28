#!/usr/bin/env bash

# Define repository
REPO_URL="https://github.com/naplon74/git_RE.git"
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

# Create directories
mkdir -p "$CONFIG_DIR"
mkdir -p "$STATE_DIR"
mkdir -p "$BIN_DIR"

# Clone repository
if [[ -d "$APP_DIR/.git" ]]; then
    echo "[INFO] Git_RE is already installed."
    echo "[INFO] Updating existing installation..."

    git -C "$APP_DIR" fetch origin "$BRANCH" --quiet
    git -C "$APP_DIR" checkout "$BRANCH" --quiet
    git -C "$APP_DIR" pull origin "$BRANCH" --quiet
else
    echo "[INFO] Downloading Git_RE from $BRANCH..."

    rm -rf "$APP_DIR"

    git clone \
        --branch "$BRANCH" \
        --single-branch \
        --quiet \
        "$REPO_URL" \
        "$APP_DIR"
fi

# Create Python virtual environment
if [[ ! -d "$APP_DIR/.venv" ]]; then
    echo "[INFO] Creating Python virtual environment..."
    python3 -m venv "$APP_DIR/.venv"
fi

# Install Python dependencies
echo "[INFO] Installing Python dependencies..."
"$APP_DIR/.venv/bin/python" -m pip install --quiet --upgrade pip
"$APP_DIR/.venv/bin/python" -m pip install --quiet rich

# Create default config
if [[ ! -f "$CONFIG_DIR/config.json" ]]; then
    echo "[INFO] Creating config.json..."

    cat > "$CONFIG_DIR/config.json" <<EOF
{
    "gith_path": "$(command -v git)",
    "python3_path": "$APP_DIR/.venv/bin/python"
}
EOF
else
    echo "[INFO] Existing config.json found, keeping it."
fi

# Create command symlink
ln -sf "$APP_DIR/src/git_re.sh" "$BIN_DIR/gitRE"

# Make scripts executable
chmod +x "$APP_DIR/src/git_re.sh"

if [[ -f "$APP_DIR/uninstall.sh" ]]; then
    chmod +x "$APP_DIR/uninstall.sh"
fi

echo
echo "[SUCCESS] Git_RE has been installed."
echo
echo "[INFO] Branch:  $BRANCH"
echo "[INFO] Command: $BIN_DIR/gitRE"
echo "[INFO] Config:  $CONFIG_DIR/config.json"
echo "[INFO] State:   $STATE_DIR"
echo

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "[INFO] $BIN_DIR is not currently in your PATH."
    echo "[INFO] Add it to your shell configuration to run gitRE from anywhere."
fi
