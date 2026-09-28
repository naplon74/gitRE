#!/usr/bin/env bash

VERSION="v1.2"

# Define XDG directories
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/gitRE"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gitRE"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/gitRE"

# Define application paths
CONFIG_FILE="$CONFIG_DIR/config.json"
OUTPUT_FILE="$STATE_DIR/repos_status.json"
PYTHON_SCRIPT="$APP_DIR/src/output.py"
LOG_FILE="$STATE_DIR/logs.txt"

# Create state directory if it doesn't exist
mkdir -p "$STATE_DIR"

# Default git & python directory (pulls from config.json using jq)
GIT=$(jq -r '.gith_path' "$CONFIG_FILE")
PYTHON=$(jq -r '.python3_path' "$CONFIG_FILE")

echo "Git_RE $VERSION"
echo "Git_RE $VERSION logs" > "$LOG_FILE"
echo >> "$LOG_FILE"
date >> "$LOG_FILE"

# Check if the git path exists
if [[ -x "$GIT" ]]; then
    echo "[SUCCESS] Git found in $GIT." >> "$LOG_FILE"
else
    echo "[ERROR] Git path specified in config.json does not exist." >> "$LOG_FILE"
    echo "[INFO] Please edit config.json and set a valid path." >> "$LOG_FILE"
    echo "[INFO] You may use commands such as 'which git' or 'whereis git' to find its location." >> "$LOG_FILE"
    echo "[EXIT] Exited with 1" >> "$LOG_FILE"
    echo "Git wasn't found please check $LOG_FILE for more information."
    exit 1
fi

# Check if the python path exists
if [[ -x "$PYTHON" ]]; then
    echo "[SUCCESS] Python found in $PYTHON." >> "$LOG_FILE"
else
    echo "[ERROR] Python path specified in config.json does not exist." >> "$LOG_FILE"
    echo "[INFO] Please edit config.json and set a valid path." >> "$LOG_FILE"
    echo "[INFO] You may use commands such as 'which python3' or 'whereis python3' to find its location." >> "$LOG_FILE"
    echo "[EXIT] Exited with 1" >> "$LOG_FILE"
    echo "Python wasn't found please check $LOG_FILE for more information."
    exit 1
fi

# Check if the rich package is installed
if ! "$PYTHON" -c "import rich" >/dev/null 2>&1; then
    echo "Python package 'rich' wasn't found on the system, check $LOG_FILE for more information."
    echo "[ERROR] Python package 'rich' is not installed." >> "$LOG_FILE"
    echo "[INFO] Install it with:" >> "$LOG_FILE"
    echo "[INFO] $PYTHON -m pip install --user rich" >> "$LOG_FILE"
    echo "[EXIT] Exited with 1" >> "$LOG_FILE"
    exit 1
else
    echo "[SUCCESS] Python package 'rich' was found." >> "$LOG_FILE"
fi

# Create a temporary file to collect objects
tmpfile=$(mktemp)

trap 'rm -f "$tmpfile"' EXIT

echo "[INFO] Starting to look for local git repos." >> "$LOG_FILE"
find ~ -type d -name ".git" 2>/dev/null | while read -r gitdir; do
    repo="${gitdir%/.git}"

    # Branch
    branch=$("$GIT" -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

    # Dirty check
    echo "Found $repo."
    echo >> "$LOG_FILE"
    echo "----------------------------------" >> "$LOG_FILE"
    echo "[INFO] $repo found." >> "$LOG_FILE"

    if "$GIT" -C "$repo" status --porcelain 2>/dev/null | grep -q .; then
        dirty=true
    else
        dirty=false
    fi

    # Fetch latest from remote (quiet)
    echo "[INFO] Running git fetch in $repo." >> "$LOG_FILE"
    "$GIT" -C "$repo" fetch --quiet 2>/dev/null

    # Ahead / Behind
    ahead=0
    behind=0

    if "$GIT" -C "$repo" rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
        counts=$("$GIT" -C "$repo" rev-list --left-right --count HEAD...@{u} 2>/dev/null)

        if [[ -n "$counts" ]]; then
            ahead=$(echo "$counts" | cut -f1)
            behind=$(echo "$counts" | cut -f2)
        fi
    fi

    echo "[INFO] Adding $repo to the json file." >> "$LOG_FILE"
    echo "----------------------------------" >> "$LOG_FILE"

    short_status=$("$GIT" -C "$repo" status -sb 2>/dev/null | head -n 1)

    # Safely create JSON object
    jq -n \
        --arg path "$repo" \
        --arg name "$(basename "$repo")" \
        --arg branch "$branch" \
        --argjson dirty "$dirty" \
        --argjson ahead "$ahead" \
        --argjson behind "$behind" \
        --arg status "$short_status" \
        '{
            path: $path,
            name: $name,
            branch: $branch,
            dirty: $dirty,
            ahead: $ahead,
            behind: $behind,
            status: $status
        }' >> "$tmpfile"
done

# Turn the lines into a proper JSON array
jq -s '.' "$tmpfile" > "$OUTPUT_FILE"

# Run the Python script
if [[ -f "$PYTHON_SCRIPT" ]]; then
    echo >> "$LOG_FILE"
    echo "[SUCCESS] No error, running $PYTHON_SCRIPT." >> "$LOG_FILE"
    echo "[EXIT] Exited with code 0." >> "$LOG_FILE"
    echo
    echo "Running python script..."
    sleep 2
    clear
    "$PYTHON" "$PYTHON_SCRIPT"
    exit 0
else
    echo >> "$LOG_FILE"
    echo "[ERROR] Python script wasn't found at $PYTHON_SCRIPT." >> "$LOG_FILE"
    echo "[EXIT] Exited with code 1." >> "$LOG_FILE"
    echo
    echo "Error: output.py not found check $LOG_FILE for more information."
    exit 1
fi