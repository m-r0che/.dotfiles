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
- Herdr config, skill, and Pi/Claude/Codex integrations
- Shell PATH bootstrap for `~/.local/bin`, Homebrew, and npm globals
- Git defaults and global ignore file
- SSH host alias template/local include (included into `~/.ssh/config`)
- Basic macOS/Linux package lists
- Wrangler for Cloudflare development

## Commands

```bash
./dot init                       # install packages, sync configs, install tools, run doctor
./dot sync                       # merge managed config and shell hooks into home
./dot doctor                     # check expected tools/config/integrations
./dot update                     # git pull, sync, pi update --all
./dot install-herdr              # install Herdr if missing and install integrations
./dot install-herdr-integrations # install Pi/Claude/Codex Herdr integrations only
```

## Linux Node.js strategy

Linux apt systems use the NodeSource apt repository instead of relying on distro `nodejs/npm` packages, which can lag behind current Node LTS releases. The default major is Node 24 and can be changed per run:

```bash
NODE_MAJOR=22 ./dot init
```

References:

- Node official downloads: https://nodejs.org/en/download
- NodeSource distributions: https://github.com/nodesource/distributions

## Sync safety

`./dot sync` is merge-based for Pi/agent config so locally-added skills/extensions are preserved. Live app-owned Pi settings are copied only when missing; existing `~/.pi/agent/settings.json` is not overwritten by routine sync/update.

Managed Git defaults are synced to `~/.config/dotfiles/gitconfig` and included from `~/.gitconfig` without overwriting existing credential helpers or identity. Put personal identity, signing config, and machine-specific settings in `~/.gitconfig.local`.

## Herdr notes

The bootstrap installs Herdr integrations for:

```bash
herdr integration install pi
herdr integration install claude
herdr integration install codex
```

`pi-herdr` is intentionally not installed for now. The Herdr skill is included so agents running inside Herdr know how to use the Herdr CLI safely.

On macOS, prefer launching Herdr from your terminal rather than `brew services` so spawned Node-based agents inherit a full PATH.

Herdr's `manage_ssh_config` is enabled so `herdr --remote` gets keepalive and
control-socket connection reuse. This is a temporary config Herdr generates for
its own connections and does not modify your real `~/.ssh/config`.

## Remote work from your local terminal

`herdr --remote` runs a local thin client that starts/attaches a Herdr server on
a remote devbox and streams its UI back to you (keeping local desktop features
like image clipboard paste). See https://herdr.dev/docs/how-to-work/.

Provision the devbox with the same dotfiles, configure a local-only SSH alias,
then attach to a persistent session:

```bash
# Local-only: do not commit real hostnames/IPs/users.
cp ~/.dotfiles/home/.config/dotfiles/ssh_config.local.example \
  ~/.dotfiles/home/.config/dotfiles/ssh_config.local
$EDITOR ~/.dotfiles/home/.config/dotfiles/ssh_config.local
cd ~/.dotfiles && ./dot sync

# On the devbox (Ubuntu, passwordless sudo): give it parity with local.
git clone https://github.com/m-r0che/.dotfiles ~/.dotfiles   # or rsync your checkout up
cd ~/.dotfiles && ./dot init                                 # herdr + integrations + PATH + config

# From your local machine:
herdr --remote abi --session abi   # attach/create the "abi" session; ctrl+b q detaches
```

The tracked SSH config only includes an ignored local fragment:
`home/.config/dotfiles/ssh_config.local`. Keep real hostnames/IPs/users there
(or directly in `~/.ssh/config`), not in tracked files. Keep the local and remote
Herdr versions matched — `herdr --remote` auto-installs a matching build to
`~/.local/bin/herdr` on the devbox when needed.

## Secrets not tracked

This repo intentionally excludes Pi/Claude/Codex auth, sessions, caches, history, Herdr logs/socket/history, env files, and local settings.

After bootstrapping a new machine/devbox, add machine-specific Git identity and authenticate manually:

```bash
cat > ~/.gitconfig.local <<'EOF'
[user]
	name = Your Name
	email = you@example.com
EOF

gh auth login
pi /login
wrangler login
# if used:
claude
codex
```
