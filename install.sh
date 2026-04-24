#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()    { echo "[INFO]  $*"; }
success() { echo "[OK]    $*"; }
warn()    { echo "[WARN]  $*"; }
error()   { echo "[ERROR] $*" >&2; exit 1; }

# ── Detect OS / package manager ───────────────────────────────────────────────
OS="$(uname -s)"

pkg_install() {
  # Usage: pkg_install <brew-name> <apt-name> <dnf-name> <pacman-name>
  # Pass the same name for all if they're identical across package managers.
  local brew_name="${1}"
  local apt_name="${2:-$1}"
  local dnf_name="${3:-$1}"
  local pac_name="${4:-$1}"

  if [ "$OS" = "Darwin" ]; then
    brew install "$brew_name"
  elif command -v apt-get &>/dev/null; then
    sudo apt-get install -y "$apt_name"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$dnf_name"
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm "$pac_name"
  else
    error "No supported package manager found (brew/apt/dnf/pacman). Install $brew_name manually."
  fi
}

backup_if_exists() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
    warn "Existing $target found — backing up to $backup"
    mv "$target" "$backup"
  fi
}

# ── 1. macOS: ensure Homebrew ─────────────────────────────────────────────────
if [ "$OS" = "Darwin" ]; then
  if ! command -v brew &>/dev/null; then
    info "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for the rest of this script (Apple Silicon vs Intel)
    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  else
    success "Homebrew already installed"
  fi
fi

# ── 2. Linux: update package index once ───────────────────────────────────────
if [ "$OS" = "Linux" ]; then
  if command -v apt-get &>/dev/null; then
    info "Updating apt package index..."
    sudo apt-get update -qq
  elif command -v dnf &>/dev/null; then
    info "Updating dnf package index..."
    sudo dnf check-update -q || true   # exits non-zero when updates exist; that's fine
  fi
fi

# ── 3. Neovim ─────────────────────────────────────────────────────────────────
if ! command -v nvim &>/dev/null; then
  info "Installing Neovim..."
  if [ "$OS" = "Linux" ] && command -v apt-get &>/dev/null; then
    # Ubuntu's apt neovim is often outdated — use the official PPA for 0.9+
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update -qq
    sudo apt-get install -y neovim
  else
    pkg_install neovim neovim neovim neovim
  fi
else
  success "Neovim already installed ($(nvim --version | head -1))"
fi

# ── 4. Tmux ───────────────────────────────────────────────────────────────────
if ! command -v tmux &>/dev/null; then
  info "Installing tmux..."
  pkg_install tmux tmux tmux tmux
else
  success "tmux already installed ($(tmux -V))"
fi

# ── 5. Common CLI tools ───────────────────────────────────────────────────────
# Format: "check-command|brew|apt|dnf|pacman"
declare -a TOOLS=(
  "git|git|git|git|git"
  "rg|ripgrep|ripgrep|ripgrep|ripgrep"
  "fd|fd|fd-find|fd-find|fd"
  "fzf|fzf|fzf|fzf|fzf"
  "node|node|nodejs|nodejs|nodejs"
  "lazygit|lazygit|lazygit|lazygit|lazygit"
  "python3|python3|python3|python3|python"
)

for entry in "${TOOLS[@]}"; do
  IFS='|' read -r cmd brew apt dnf pac <<< "$entry"
  if ! command -v "$cmd" &>/dev/null; then
    info "Installing $cmd..."
    pkg_install "$brew" "$apt" "$dnf" "$pac"
  else
    success "$cmd already installed"
  fi
done

# lazygit isn't in most Linux default repos — fall back to GitHub release
if ! command -v lazygit &>/dev/null && [ "$OS" = "Linux" ]; then
  info "Installing lazygit from GitHub release..."
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
  curl -Lo /tmp/lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin
  rm /tmp/lazygit.tar.gz /tmp/lazygit
  success "lazygit installed"
fi

# ── 6. Neovim config → ~/.config/nvim ─────────────────────────────────────────
NVIM_TARGET="$HOME/.config/nvim"
backup_if_exists "$NVIM_TARGET"
if [ -L "$NVIM_TARGET" ]; then
  info "Removing existing nvim symlink"
  rm "$NVIM_TARGET"
fi
mkdir -p "$HOME/.config"
ln -s "$REPO_DIR/nvim" "$NVIM_TARGET"
success "Linked $REPO_DIR/nvim → $NVIM_TARGET"

# ── 7. Tmux config → ~/.tmux.conf ─────────────────────────────────────────────
TMUX_TARGET="$HOME/.tmux.conf"
backup_if_exists "$TMUX_TARGET"
[ -L "$TMUX_TARGET" ] && rm "$TMUX_TARGET"
ln -s "$REPO_DIR/.tmux.conf" "$TMUX_TARGET"
success "Linked $REPO_DIR/.tmux.conf → $TMUX_TARGET"

# ── 8. TPM (Tmux Plugin Manager) ──────────────────────────────────────────────
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
  success "TPM already installed"
else
  info "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  success "TPM installed"
fi

# ── 9. Install tmux plugins headlessly ────────────────────────────────────────
if command -v tmux &>/dev/null && [ -f "$TPM_DIR/bin/install_plugins" ]; then
  info "Installing tmux plugins via TPM..."
  "$TPM_DIR/bin/install_plugins" || warn "TPM plugin install had errors (may be fine if tmux isn't running)"
fi

echo ""
echo "────────────────────────────────────────────────"
echo "  Setup complete! (OS: $OS)"
echo ""
echo "  Next steps:"
echo "  1. Open a new terminal session"
echo "  2. Start nvim — LazyVim will auto-install plugins on first launch"
echo "  3. Start tmux, then press prefix + I (Ctrl+s then I) to install"
echo "     tmux plugins if they weren't installed automatically"
echo "────────────────────────────────────────────────"
