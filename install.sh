#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()    { echo "[INFO]  $*"; }
success() { echo "[OK]    $*"; }
warn()    { echo "[WARN]  $*"; }
error()   { echo "[ERROR] $*" >&2; exit 1; }

# ── Detect OS / package manager ───────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"   # x86_64, arm64 (macOS), aarch64 (64-bit Pi), armv7l (32-bit Pi)

# version_ge A B → succeeds when A >= B (semver-ish, via `sort -V`)
version_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

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

# ── Parse flags ───────────────────────────────────────────────────────────────
usage() {
  cat <<'EOF'
Usage: ./install.sh [--nvim] [--tmux]

  --nvim    Neovim, its CLI tools (ripgrep, fd, fzf, node, lazygit, uv, Rust)
            and the ~/.config/nvim symlink
  --tmux    tmux, the ~/.tmux.conf symlink, TPM and tmux plugins
  -h, --help

With no flags, sets up both.
EOF
}

WANT_NVIM=false
WANT_TMUX=false
for arg in "$@"; do
  case "$arg" in
    --nvim)    WANT_NVIM=true ;;
    --tmux)    WANT_TMUX=true ;;
    -h|--help) usage; exit 0 ;;
    *)         usage >&2; error "Unknown option: $arg" ;;
  esac
done
if [ "$WANT_NVIM" = false ] && [ "$WANT_TMUX" = false ]; then
  WANT_NVIM=true
  WANT_TMUX=true
fi

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

  # Base build tools: a C compiler/linker for rustc and nvim-treesitter parsers,
  # curl for the upstream installers below, unzip for Mason. macOS gets these
  # from the Xcode command line tools that Homebrew installs.
  # The tmux-only setup needs none of these.
  if [ "$WANT_NVIM" = true ]; then
    info "Installing base build tools (curl, C compiler, unzip)..."
    if command -v apt-get &>/dev/null; then
      sudo apt-get install -y curl build-essential unzip
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y curl gcc gcc-c++ make unzip
    elif command -v pacman &>/dev/null; then
      sudo pacman -S --needed --noconfirm curl base-devel unzip
    fi
  fi
fi

if [ "$WANT_NVIM" = true ]; then
  # ── 3. Neovim ───────────────────────────────────────────────────────────────
  # LazyVim needs a recent Neovim. brew/dnf/pacman track upstream closely, but
  # Debian, Ubuntu and Raspberry Pi OS ship versions too old for it (and PPAs are
  # Ubuntu-only), so apt systems get the official release tarball instead.
  MIN_NVIM_VERSION="0.11.2"

  nvim_version() { nvim --version 2>/dev/null | head -1 | sed 's/^NVIM v\([0-9.]*\).*/\1/'; }

  install_nvim_release() {
    local nvim_arch
    case "$ARCH" in
      x86_64)        nvim_arch="x86_64" ;;
      aarch64|arm64) nvim_arch="arm64" ;;
      *)
        warn "No official Neovim build for $ARCH — falling back to apt (may be too old for LazyVim)"
        sudo apt-get install -y neovim
        return
        ;;
    esac
    info "Installing latest Neovim release (linux-$nvim_arch) to /opt..."
    curl -fLo /tmp/nvim.tar.gz \
      "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.tar.gz"
    sudo rm -rf "/opt/nvim-linux-${nvim_arch}"
    sudo tar -C /opt -xzf /tmp/nvim.tar.gz
    sudo ln -sf "/opt/nvim-linux-${nvim_arch}/bin/nvim" /usr/local/bin/nvim
    rm /tmp/nvim.tar.gz
    hash -r
  }

  if command -v nvim &>/dev/null && version_ge "$(nvim_version)" "$MIN_NVIM_VERSION"; then
    success "Neovim already installed ($(nvim --version | head -1))"
  elif [ "$OS" = "Linux" ] && command -v apt-get &>/dev/null; then
    if command -v nvim &>/dev/null; then
      warn "Neovim $(nvim_version) is older than $MIN_NVIM_VERSION — installing the release build"
    fi
    install_nvim_release
  elif command -v nvim &>/dev/null; then
    warn "Neovim $(nvim_version) is older than $MIN_NVIM_VERSION — upgrade it with your package manager"
  else
    info "Installing Neovim..."
    pkg_install neovim neovim neovim neovim
  fi

  # ── 4. Common CLI tools ─────────────────────────────────────────────────────
  # Format: "check-command|brew|apt|dnf|pacman"
  declare -a TOOLS=(
    "git|git|git|git|git"
    "rg|ripgrep|ripgrep|ripgrep|ripgrep"
    "fd|fd|fd-find|fd-find|fd"
    "fzf|fzf|fzf|fzf|fzf"
    "node|node|nodejs|nodejs|nodejs"
    "npm|node|npm|npm|npm"
    "lazygit|lazygit|lazygit|lazygit|lazygit"
    "python3|python3|python3|python3|python"
  )

  for entry in "${TOOLS[@]}"; do
    IFS='|' read -r cmd brew apt dnf pac <<< "$entry"
    # Debian's fd-find package installs the binary as `fdfind`
    if [ "$cmd" = "fd" ] && command -v fdfind &>/dev/null; then
      success "fd already installed (as fdfind)"
    elif ! command -v "$cmd" &>/dev/null; then
      info "Installing $cmd..."
      # Non-fatal: some tools (e.g. lazygit) aren't packaged everywhere and have
      # a fallback below.
      pkg_install "$brew" "$apt" "$dnf" "$pac" || warn "Package manager could not install $cmd"
    else
      success "$cmd already installed"
    fi
  done

  # Expose Debian's `fdfind` as `fd`. ~/.local/bin is on PATH via ~/.profile on
  # Debian/Ubuntu once the directory exists.
  if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    success "Linked fdfind → ~/.local/bin/fd"
  fi

  # lazygit isn't in most Linux default repos — fall back to GitHub release
  if ! command -v lazygit &>/dev/null && [ "$OS" = "Linux" ]; then
    case "$ARCH" in
      x86_64)        lg_arch="x86_64" ;;
      aarch64|arm64) lg_arch="arm64" ;;
      armv6l|armv7l) lg_arch="armv6" ;;
      *)             lg_arch="" ;;
    esac
    if [ -z "$lg_arch" ]; then
      warn "No lazygit release build for $ARCH — skipping"
    else
      info "Installing lazygit from GitHub release ($lg_arch)..."
      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
        | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
      curl -fLo /tmp/lazygit.tar.gz \
        "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${lg_arch}.tar.gz"
      tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
      sudo install /tmp/lazygit /usr/local/bin
      rm /tmp/lazygit.tar.gz /tmp/lazygit
      success "lazygit installed"
    fi
  fi

  # ── 5. uv (Astral — fast Python package & venv manager) ─────────────────────
  # Policy: install from the system package manager where possible. Astral does
  # NOT ship an apt/dnf repo, so when the packaged uv is missing or older than the
  # floor below, fall back to Astral's official installer (the "source" for the
  # latest build; it also supports `uv self update` afterwards).
  # Bump this if a plugin/tool starts needing a newer uv than your distro ships.
  MIN_UV_VERSION="0.9.0"

  install_uv_upstream() {
    info "Installing uv via Astral installer (latest upstream)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # uv installs to ~/.local/bin; expose it for the rest of this script
    export PATH="$HOME/.local/bin:$PATH"
  }

  if command -v uv &>/dev/null; then
    success "uv already installed ($(uv --version))"
  elif [ "$OS" = "Darwin" ]; then
    info "Installing uv via Homebrew..."
    brew install uv
  elif command -v dnf &>/dev/null; then
    # Fedora/RHEL: check what the repos would give us before committing to dnf
    uv_candidate="$(dnf --quiet repoquery --queryformat='%{version}\n' uv 2>/dev/null | sort -V | tail -1)"
    if [ -n "$uv_candidate" ] && version_ge "$uv_candidate" "$MIN_UV_VERSION"; then
      info "Installing uv $uv_candidate via dnf..."
      sudo dnf install -y uv
    else
      warn "dnf uv is ${uv_candidate:-unavailable} (< $MIN_UV_VERSION) — using Astral installer instead"
      install_uv_upstream
    fi
  elif command -v pacman &>/dev/null; then
    info "Installing uv via pacman..."
    sudo pacman -S --noconfirm uv
  else
    # Debian/Ubuntu and everything else: no reliably-fresh package → go upstream
    install_uv_upstream
  fi

  if command -v uv &>/dev/null; then
    success "uv ready ($(uv --version))"
  else
    warn "uv installed to ~/.local/bin — open a new shell (or add it to PATH) to use it"
  fi

  # ── 6. Rust toolchain (rustup) ──────────────────────────────────────────────
  # Policy exception, same shape as the uv one above: this goes upstream on every
  # platform rather than through the package manager.
  #   * rust-analyzer / clippy / rustfmt must match the compiler version they are
  #     analysing, and only rustup keeps them in lockstep. Distro `rust` packages
  #     ship no component management and are usually stale.
  #   * Homebrew *does* package rustup, but keg-only — it links `rustup` and
  #     leaves cargo/rustc/rust-analyzer unlinked in $(brew --prefix rustup)/bin,
  #     so it needs manual PATH surgery outside this repo to be usable at all.
  # The upstream installer puts everything in ~/.cargo/bin and wires up PATH
  # itself, which is also the layout every Rust doc and tutorial assumes.

  if command -v rustup &>/dev/null; then
    success "rustup already installed ($(rustup --version 2>/dev/null | head -1))"
  else
    info "Installing Rust via rustup.rs (upstream)..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi

  # Make cargo's bin dir visible for the rest of this script, whether rustup was
  # just installed or was already present.
  [ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"

  if command -v rustup &>/dev/null; then
    # rustaceanvim expects rust-analyzer on PATH (it deliberately does not use the
    # mason copy), and the nvim config lints with clippy on save.
    info "Ensuring Rust components: rust-analyzer, clippy, rustfmt, rust-src..."
    for component in rust-analyzer clippy rustfmt rust-src; do
      rustup component add "$component" >/dev/null 2>&1 \
        || warn "Could not add Rust component '$component'"
    done
    success "Rust ready ($(rustc --version 2>/dev/null || echo 'restart your shell to use rustc'))"
  else
    warn "rustup not on PATH — open a new shell, or add ~/.cargo/bin to PATH"
  fi

  # ── 7. Neovim config → ~/.config/nvim ───────────────────────────────────────
  NVIM_TARGET="$HOME/.config/nvim"
  backup_if_exists "$NVIM_TARGET"
  if [ -L "$NVIM_TARGET" ]; then
    info "Removing existing nvim symlink"
    rm "$NVIM_TARGET"
  fi
  mkdir -p "$HOME/.config"
  ln -s "$REPO_DIR/nvim" "$NVIM_TARGET"
  success "Linked $REPO_DIR/nvim → $NVIM_TARGET"
fi

if [ "$WANT_TMUX" = true ]; then
  # ── 8. Tmux ─────────────────────────────────────────────────────────────────
  if ! command -v tmux &>/dev/null; then
    info "Installing tmux..."
    pkg_install tmux tmux tmux tmux
  else
    success "tmux already installed ($(tmux -V))"
  fi

  # ── 9. Tmux config → ~/.tmux.conf ───────────────────────────────────────────
  TMUX_TARGET="$HOME/.tmux.conf"
  backup_if_exists "$TMUX_TARGET"
  [ -L "$TMUX_TARGET" ] && rm "$TMUX_TARGET"
  ln -s "$REPO_DIR/.tmux.conf" "$TMUX_TARGET"
  success "Linked $REPO_DIR/.tmux.conf → $TMUX_TARGET"

  # ── 10. TPM (Tmux Plugin Manager) ───────────────────────────────────────────
  TPM_DIR="$HOME/.tmux/plugins/tpm"
  if [ -d "$TPM_DIR" ]; then
    success "TPM already installed"
  else
    info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    success "TPM installed"
  fi

  # ── 11. Install tmux plugins headlessly ─────────────────────────────────────
  if command -v tmux &>/dev/null && [ -f "$TPM_DIR/bin/install_plugins" ]; then
    info "Installing tmux plugins via TPM..."
    "$TPM_DIR/bin/install_plugins" || warn "TPM plugin install had errors (may be fine if tmux isn't running)"
  fi
fi

echo ""
echo "────────────────────────────────────────────────"
echo "  Setup complete! (OS: $OS)"
echo ""
echo "  Next steps:"
if [ "$WANT_NVIM" = true ]; then
  echo "  • Open a new terminal session (picks up ~/.cargo/bin for Rust)"
  echo "  • Start nvim — LazyVim will auto-install plugins on first launch"
fi
if [ "$WANT_TMUX" = true ]; then
  echo "  • Start tmux, then press prefix + I (Ctrl+s then I) to install"
  echo "    tmux plugins if they weren't installed automatically"
fi
echo "────────────────────────────────────────────────"
