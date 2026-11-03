# Git Repo Extension - GitRE - COPR VERSION

<a href="https://copr.fedorainfracloud.org/coprs/naplon74/repo/package/gitre/"><img src="https://copr.fedorainfracloud.org/coprs/naplon74/repo/package/gitre/status_image/last_build.png" /></a>

![Version](https://img.shields.io/badge/Version-1.3.0-blue?logo=fedora&style=for-the-badge)

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

The Python package [rich](https://pypi.org/project/rich/) is installed automatically by the installer.

## Copr install

>[!IMPORTANT]
>This is for Fedora based distros only. Use the [main](https://github.com/naplon74/gitRE) branch for regular install.

```bash
sudo dnf copr enable naplon74/repo
sudo dnf install gitre
```

Run it with 

```bash
gitRE
```

To update, run the install command again.

## Exemple output

<img width="1150" height="567" alt="Screenshot From 2026-09-28 20-01-20" src="https://github.com/user-attachments/assets/a7054db2-4d81-4191-a3dd-c50bb6d78f7d" />

>[!NOTE]
>This is a demo image.
>`Dirty` means they are modified, added, or deleted files that haven't been committed yet.

## v1.3.0
What's new?

- COPR release
- New cli command:
      - --help
      - --version
      - --skip (Skip the scan and only runs the Python Script)
