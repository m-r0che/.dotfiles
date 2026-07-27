# Dotfiles maintenance instructions

This repo manages cross-platform agent/dev environment config.

Do not commit secrets, auth files, model stores, sessions, Claude history, or project-local confidential files.
Prefer portable shell and Node/npm tooling. macOS and Linux devboxes must both work.
Cloudflare is the default infrastructure choice; keep Wrangler/Workers guardrails installed.
