# nvim_config

Personal Neovim + tmux configuration. Built on [LazyVim](https://www.lazyvim.org/).

## What's included

| Config | Installed to |
|--------|-------------|
| `nvim/` | `~/.config/nvim` |
| `.tmux.conf` | `~/.tmux.conf` |

Both are symlinked — edits in the repo are reflected immediately.

## Quick setup

Works on **macOS** and **Linux** (Debian/Ubuntu, Fedora/RHEL, Arch).

```bash
git clone https://github.com/DanielisMellow/nvim_config.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script will:

1. **macOS** — install Homebrew if missing; **Linux** — use `apt` / `dnf` / `pacman`
2. Install **Neovim**, **tmux**, and common CLI tools (`ripgrep`, `fd`, `fzf`, `node`, `lazygit`, `python3`)
3. Symlink `nvim/` → `~/.config/nvim`
4. Symlink `.tmux.conf` → `~/.tmux.conf`
5. Clone **TPM** (Tmux Plugin Manager) and install tmux plugins

> **Note for Ubuntu servers:** the script adds the `neovim-ppa/unstable` PPA to get a recent version of Neovim instead of the outdated apt default.

### After running the script

- Open **nvim** — LazyVim will bootstrap itself and install all plugins on first launch
- Open **tmux** — plugins are pre-installed; if anything is missing press `prefix + I` (`Ctrl+s` then `I`) to install

## Tmux keybindings

| Key | Action |
|-----|--------|
| `Ctrl+s` | Prefix |
| `prefix + r` | Reload tmux config |
| `prefix + h/j/k/l` | Navigate panes |
| `prefix + "` | Split horizontally (current dir) |
| `prefix + %` | Split vertically (current dir) |
| `Alt+H / Alt+L` | Previous / next window |
| `prefix + Tab` | Swap window right |
| `prefix + Shift+Tab` | Swap window left |
| `Alt + arrows` | Resize panes |

### Tmux plugins

- [tpm](https://github.com/tmux-plugins/tpm) — plugin manager
- [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) — sane defaults
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) — seamless nvim/tmux pane navigation
- [tmux-yank](https://github.com/tmux-plugins/tmux-yank) — system clipboard yank
- [tmuxifier](https://github.com/jimeh/tmuxifier) — session layouts
- [tmux-themepack](https://github.com/jimeh/tmux-themepack) — powerline/double/cyan theme

## Neovim

Based on LazyVim with custom plugins under `nvim/lua/plugins/`:

- **LSP** — mason + lsp config
- **DAP** — python debugger via nvim-dap
- **Formatting** — conform.nvim
- **Linting** — custom linting setup
- **Harpoon** — fast file navigation
- **gp.nvim** — AI assistant integration
- **Lualine** — statusline
- **Neoscroll** — smooth scrolling
- **Neotest** — test runner

## Updating

```bash
cd ~/dotfiles
git pull
```

Since the configs are symlinked, the pull is all you need — no re-running the install script.
