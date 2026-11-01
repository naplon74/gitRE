# Git Repo Extension - Git_RE

Simple multi-repository git status tool for Linux.

It scans your system for git repositories, collects their status, and displays a clean summary.

## Features

- Finds all git repositories under your home directory
- Shows branch, dirty/clean status and ahead / behind
- Pretty table output with [rich](https://pypi.org/project/rich/)
- Logs of every run
- Configurable git and python paths via `config.json`

## Requirements

- `bash`
- `git`
- `jq`
- `python3`
- `curl` (for the online install)

The Python package [rich](https://pypi.org/project/rich/) is installed automatically by the installer.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/naplon74/git_RE/main/install.sh | bash
```

Then run it from anywhere:

```bash
gitRE
```

To update, run the install command again.

>[!TIP]
>If `gitRE` isn't found after installing, add `~/.local/bin` to your `PATH`:
>```bash
>export PATH="$HOME/.local/bin:$PATH"
>```

## Configuration

The config file is created by the installer at `~/.config/gitRE/config.json`:

```json
{
    "gith_path": "/usr/bin/git",
    "python3_path": "/home/yourusername/.local/share/gitRE/.venv/bin/python"
}
```

>[!TIP]
>If Git_RE can't find git, use `where git` or `whereis git` to locate it and update `gith_path`.

Logs are saved in `~/.local/state/gitRE/logs.txt`.

## Uninstall

```bash    <img width="1150" height="567" alt="Screenshot From 2026-09-28 19-59-29" src="https://github.com/user-attachments/assets/5796767f-9480-46d9-869d-92d370a67298" />

curl -fsSL https://raw.githubusercontent.com/naplon74/git_RE/main/uninstall.sh | bash
```

Your config and logs are kept.

## Project Structure (Portable version - v1.1)

    git_RE/
    ├── config.json
    ├── install.sh
    ├── uninstall.sh
    ├── src/
    │   ├── git_re.sh
    │   └── output.py
    └── README.md

## Exemple output

<img width="1150" height="567" alt="Screenshot From 2026-09-28 20-01-20" src="https://github.com/user-attachments/assets/a7054db2-4d81-4191-a3dd-c50bb6d78f7d" />

>[!NOTE]
>This is a demo image.
>`Dirty` means they are modified, added, or deleted files that haven't been committed yet.

## v1.2
What's new?

- Added online installer and uninstaller.
- Config, logs and app files now follow the XDG standard.
- Added python path to `config.json`.
- Added check for the `rich` package.

## v1.1
What's new?

- Added ahead / behind in the python output table.
- Added logs.
- Added / modified relevents text.

And that's about it!

## v1.0
Inital release.
