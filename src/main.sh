
#!/usr/bin/env bash

set -Eeuo pipefail

VERSION="v1.3"

# Define application directory
SCRIPT_PATH="$(readlink -f -- "${BASH_SOURCE[0]}")"
APP_DIR="$(dirname "$SCRIPT_PATH")"

# Define XDG directories
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gitRE"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/gitRE"

# Define application paths
CONFIG_FILE="$CONFIG_DIR/config.json"
OUTPUT_FILE="$STATE_DIR/repos_status.json"
PYTHON_SCRIPT="$APP_DIR/output.py"
LOG_FILE="$STATE_DIR/logs.txt"

# Create required directories
mkdir -p "$CONFIG_DIR" "$STATE_DIR"

# Initialize log
{
    echo "Git_RE $VERSION logs"
    echo
    date
} > "$LOG_FILE"

# Logging functions
log() {
    echo "$1" >> "$LOG_FILE"
}

error() {
    echo "[ERROR] $1"
    log "[ERROR] $1"
    log "[EXIT] Exited with code 1."
    exit 1
}

# Check required commands
for cmd in jq find grep head cut mktemp date; do
    command -v "$cmd" >/dev/null 2>&1 ||
        error "Required command '$cmd' was not found."
done

# Create default configuration if missing
if [[ ! -f "$CONFIG_FILE" ]]; then

    echo "[INFO] Configuration not found. Creating default config..."
    log "[INFO] Creating default configuration."

    GIT_PATH="$(command -v git || true)"
    PYTHON_PATH="$(command -v python3 || true)"

    [[ -n "$GIT_PATH" ]] ||
        error "Git was not found on this system."

    [[ -n "$PYTHON_PATH" ]] ||
        error "Python3 was not found on this system."

    jq -n \
        --arg git_path "$GIT_PATH" \
        --arg python3_path "$PYTHON_PATH" \
        '{
            git_path: $git_path,
            python3_path: $python3_path
        }' > "$CONFIG_FILE" ||
        error "Unable to create config.json."

else
    echo "[INFO] Existing configuration found. Loading..."
    log "[INFO] Existing configuration found."
fi

# Validate configuration
if ! jq -e '
    (.git_path | strings | length > 0) and
    (.python3_path | strings | length > 0)
' "$CONFIG_FILE" >/dev/null 2>&1; then
    error "Invalid configuration file: $CONFIG_FILE"
fi

# Load configuration
GIT="$(jq -r '.git_path' "$CONFIG_FILE")"
PYTHON="$(jq -r '.python3_path' "$CONFIG_FILE")"

# Validate executable paths
[[ -x "$GIT" ]] ||
    error "Git executable not found: $GIT"

[[ -x "$PYTHON" ]] ||
    error "Python executable not found: $PYTHON"

log "[SUCCESS] Git found at $GIT."
log "[SUCCESS] Python found at $PYTHON."

# Check Python dependencies
if ! "$PYTHON" -c "import rich" >/dev/null 2>&1; then
    log "[ERROR] Python package 'rich' is missing."
    error "Python package 'rich' is not installed. Install it using your package manager."
fi

log "[SUCCESS] Python package 'rich' found."

# Check application files
[[ -f "$PYTHON_SCRIPT" ]] ||
    error "output.py was not found at $PYTHON_SCRIPT"

# Create temporary file
TMP_FILE="$(mktemp)" ||
    error "Unable to create temporary file."

trap 'rm -f "$TMP_FILE"' EXIT

echo
echo "Git_RE $VERSION"
echo "[INFO] Scanning for local Git repositories..."

log "[INFO] Starting repository scan."

# Find local Git repositories
while IFS= read -r -d '' GIT_DIR; do

    REPO="${GIT_DIR%/.git}"

    echo "Found $REPO."

    log ""
    log "----------------------------------"
    log "[INFO] Repository: $REPO"

    # Current branch
    BRANCH="$("$GIT" -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"

    # Check uncommitted changes
    if "$GIT" -C "$REPO" status --porcelain 2>/dev/null | grep -q .; then
        DIRTY=true
    else
        DIRTY=false
    fi

    # Fetch remote changes
    log "[INFO] Fetching remote changes."
    "$GIT" -C "$REPO" fetch --quiet 2>/dev/null || true

    # Initialize ahead / behind counters
    AHEAD=0
    BEHIND=0

    # Check upstream branch
    if "$GIT" -C "$REPO" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then

        COUNTS="$("$GIT" -C "$REPO" rev-list --left-right --count 'HEAD...@{u}' 2>/dev/null || true)"

        if [[ -n "$COUNTS" ]]; then
            read -r AHEAD BEHIND <<< "$COUNTS"
        fi
    fi

    # Short repository status
    STATUS="$("$GIT" -C "$REPO" status -sb 2>/dev/null | head -n 1 || true)"

    # Add repository to JSON output
    jq -cn \
        --arg path "$REPO" \
        --arg name "$(basename "$REPO")" \
        --arg branch "$BRANCH" \
        --argjson dirty "$DIRTY" \
        --argjson ahead "$AHEAD" \
        --argjson behind "$BEHIND" \
        --arg status "$STATUS" \
        '{
            path: $path,
            name: $name,
            branch: $branch,
            dirty: $dirty,
            ahead: $ahead,
            behind: $behind,
            status: $status
        }' >> "$TMP_FILE" ||
        error "Failed to generate JSON for $REPO."

    log "[SUCCESS] Repository added to results."

done < <(find "$HOME" -type d -name ".git" -prune -print0 2>/dev/null)

# Convert JSON objects into a JSON array
jq -s '.' "$TMP_FILE" > "$OUTPUT_FILE" ||
    error "Failed to generate repository results."

log "[SUCCESS] Repository scan completed."
log "[INFO] Results saved to $OUTPUT_FILE."

# Run Python output script
echo
echo "[SUCCESS] Repository scan completed."
echo "[INFO] Starting output.py..."

log "[INFO] Running Python output script."

sleep 1
clear

"$PYTHON" "$PYTHON_SCRIPT" ||
    error "Failed to execute output.py."

log "[EXIT] Exited with code 0."

exit 0

