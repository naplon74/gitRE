
#!/usr/bin/env bash

set -e

# Define repository
REPO_URL="https://github.com/naplon74/gitRE.git"
BRANCH="main"
VERSION="v1.2"

# Define directories
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/gitRE"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gitRE"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/gitRE"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"

MAIN_SCRIPT="$APP_DIR/src/main.sh"
OUTPUT_SCRIPT="$APP_DIR/src/output.py"
CONFIG_FILE="$CONFIG_DIR/config.json"

echo "[INFO] Installing Git_RE $VERSION..."

# Check required commands
for cmd in git python3 jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[ERROR] $cmd wasn't found."
        echo "[INFO] Please install $cmd and run the installer again."
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
mkdir -p "$CONFIG_DIR" "$STATE_DIR" "$BIN_DIR"

# Clone or update repository
if [[ -d "$APP_DIR/.git" ]]; then
    echo "[INFO] Existing installation found."
    echo "[INFO] Updating Git_RE..."

    git -C "$APP_DIR" fetch origin "$BRANCH" --quiet
    git -C "$APP_DIR" checkout "$BRANCH" --quiet
    git -C "$APP_DIR" pull --ff-only origin "$BRANCH" --quiet

else
    if [[ -e "$APP_DIR" ]]; then
        echo "[ERROR] $APP_DIR already exists and isn't a Git repository."
        exit 1
    fi

    echo "[INFO] Downloading Git_RE..."

    git clone \
        --branch "$BRANCH" \
        --single-branch \
        --quiet \
        "$REPO_URL" \
        "$APP_DIR"
fi

# Check application files
if [[ ! -f "$MAIN_SCRIPT" || ! -f "$OUTPUT_SCRIPT" ]]; then
    echo "[ERROR] Application files are missing."
    exit 1
fi

# Create default configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[INFO] Creating default configuration..."

    jq -n \
        --arg git_path "$(command -v git)" \
        --arg python3_path "$(command -v python3)" \
        '{
            git_path: $git_path,
            python3_path: $python3_path
        }' > "$CONFIG_FILE"
else
    echo "[INFO] Existing configuration found, keeping it."
fi

# Set executable permissions
chmod +x "$MAIN_SCRIPT"
chmod +x "$OUTPUT_SCRIPT"

# Create command symlink
ln -sfn "$MAIN_SCRIPT" "$BIN_DIR/gitRE"

echo
echo "[SUCCESS] Git_RE has been installed."
echo
echo "[INFO] Branch:  $BRANCH"
echo "[INFO] Command: $BIN_DIR/gitRE"
echo "[INFO] Config:  $CONFIG_FILE"
echo "[INFO] State:   $STATE_DIR"
echo

# Check PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "[WARNING] $BIN_DIR is not in your PATH."
    echo "[INFO] Add the following to your shell configuration:"
    echo
    echo 'export PATH="$HOME/.local/bin:$PATH"'
fi

