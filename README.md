# Matthew's dotfiles

Automated, cross-platform development environment setup for macOS and Linux devboxes.

## Quick start

```bash
git clone https://github.com/m-r0che/.dotfiles ~/.dotfiles
cd ~/.dotfiles
./dot init
```

## What is managed

- Pi extensions and package settings
- Global agent skills (`~/.agents/skills`)
- Selected Claude commands/agents
- Basic macOS/Linux package lists

## Commands

```bash
./dot init      # install packages where possible, sync configs, install Pi packages
./dot sync      # copy managed config into ~/.pi, ~/.agents, ~/.claude
./dot doctor    # check expected tools/config
./dot update    # git pull, sync, pi update --all
```

## Secrets not tracked

This repo intentionally excludes Pi/Claude auth, sessions, caches, history, and local settings.
After bootstrapping a new machine/devbox, authenticate manually:

```bash
gh auth login
pi /login
wrangler login
```
