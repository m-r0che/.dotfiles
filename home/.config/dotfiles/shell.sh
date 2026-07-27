# Shared shell bootstrap managed by ~/.dotfiles.
# Safe for bash/zsh/profile; keep POSIX-compatible.

# User-local binaries: Herdr's Linux installer and pipx commonly install here.
case ":$PATH:" in
  *:"$HOME/.local/bin":*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

# Homebrew paths for macOS Apple Silicon, macOS Intel, and Linuxbrew.
for brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
  if [ -x "$brew_prefix/bin/brew" ]; then
    case ":$PATH:" in
      *:"$brew_prefix/bin":*) ;;
      *) PATH="$brew_prefix/bin:$brew_prefix/sbin:$PATH" ;;
    esac
    break
  fi
done

# npm global bin fallback. Prefer command lookup to avoid hard-coded prefixes.
if command -v npm >/dev/null 2>&1; then
  npm_bin="$(npm bin -g 2>/dev/null || true)"
  if [ -n "$npm_bin" ] && [ -d "$npm_bin" ]; then
    case ":$PATH:" in
      *:"$npm_bin":*) ;;
      *) PATH="$npm_bin:$PATH" ;;
    esac
  fi
  unset npm_bin
fi

export PATH
