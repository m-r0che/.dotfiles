# Shared shell bootstrap managed by ~/.dotfiles.
# Safe for bash/zsh/profile; keep POSIX-compatible.

# User-local binaries: Herdr's Linux installer and pipx commonly install here.
case ":$PATH:" in
  *:"$HOME/.local/bin":*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

# Homebrew paths for macOS Apple Silicon, macOS Intel, and Linuxbrew.
# Use brew shellenv when available so HOMEBREW_* and man/info paths are correct.
for brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
  if [ -x "$brew_prefix/bin/brew" ]; then
    eval "$("$brew_prefix/bin/brew" shellenv)"
    break
  fi
done

# npm global bin fallback. npm removed `npm bin -g`; derive bin from the global prefix.
if command -v npm >/dev/null 2>&1; then
  npm_prefix="$(npm prefix -g 2>/dev/null || true)"
  npm_bin="${npm_prefix:+$npm_prefix/bin}"
  if [ -n "$npm_bin" ] && [ -d "$npm_bin" ]; then
    case ":$PATH:" in
      *:"$npm_bin":*) ;;
      *) PATH="$npm_bin:$PATH" ;;
    esac
  fi
  unset npm_bin npm_prefix
fi

export PATH
