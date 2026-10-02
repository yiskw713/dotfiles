#!/bin/bash
set -euo pipefail

# ============================================================
# dotfiles setup script (idempotent)
# ============================================================

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# macOS only: Homebrew / mise bootstrap and `defaults` below assume Darwin
if [ "$(uname)" != Darwin ]; then
  echo "This script supports macOS only." >&2
  exit 1
fi

# Symlink $1 to $2. A real file/dir already at $2 is moved aside to $2.bak.<timestamp>.
link() {
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    local backup="$2.bak.$(date +%Y%m%d%H%M%S)"
    echo "  backup: $2 -> $backup"
    mv "$2" "$backup"
  fi
  ln -sfn "$1" "$2"
}

# ------------------------------------------------------------
# 1. Symlinks
# ------------------------------------------------------------
echo "Creating symlinks..."
mkdir -p ~/.config/{mise,procs,alacritty,herdr,git}

link "$DOTFILES_DIR/zsh/.zshrc"          ~/.zshrc
link "$DOTFILES_DIR/zsh/.fzf.zsh"        ~/.fzf.zsh
link "$DOTFILES_DIR/tmux/.tmux.conf"     ~/.tmux.conf
link "$DOTFILES_DIR/herdr/config.toml"   ~/.config/herdr/config.toml
link "$DOTFILES_DIR/herdr/status.sh"     ~/.config/herdr/status.sh
link "$DOTFILES_DIR/herdr/name-pane.sh"   ~/.config/herdr/name-pane.sh
link "$DOTFILES_DIR/vim/.vimrc"          ~/.vimrc
link "$DOTFILES_DIR/git/.gitconfig"      ~/.gitconfig
link "$DOTFILES_DIR/git/ignore"          ~/.config/git/ignore
link "$DOTFILES_DIR/starship/starship.toml" ~/.config/starship.toml
link "$DOTFILES_DIR/procs/config.toml"   ~/.config/procs/config.toml
link "$DOTFILES_DIR/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml
link "$DOTFILES_DIR/mise/config.toml"    ~/.config/mise/config.toml
link "$DOTFILES_DIR/mise/mise.lock"      ~/.config/mise/mise.lock

# ------------------------------------------------------------
# 2. macOS
# ------------------------------------------------------------
if [ "$(uname)" = Darwin ]; then
  echo "Configuring macOS defaults..."
  mkdir -p ~/Pictures/ScreenShots
  read_defaults() {
    defaults read com.apple.screencapture location 2>/dev/null
    defaults read com.apple.finder AppleShowAllFiles 2>/dev/null
    defaults read com.apple.desktopservices DSDontWriteNetworkStores 2>/dev/null
  }
  defaults_before="$(read_defaults || true)"
  defaults write com.apple.screencapture location ~/Pictures/ScreenShots
  chflags nohidden ~/
  defaults write com.apple.finder AppleShowAllFiles TRUE
  defaults write com.apple.desktopservices DSDontWriteNetworkStores true
  # only restart Finder / SystemUIServer when a value actually changed
  if [ "$defaults_before" != "$(read_defaults || true)" ]; then
    killall Finder SystemUIServer &>/dev/null || true
  fi

  xcode-select -p &>/dev/null || xcode-select --install

  # ----------------------------------------------------------
  # 3. Homebrew + Brewfile
  # ----------------------------------------------------------
  if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  brew update
  brew bundle --file "$DOTFILES_DIR/Brewfile"
  brew cleanup

  # VSCode / espanso
  mkdir -p ~/Library/Application\ Support/Code/User
  link "$DOTFILES_DIR/vscode/settings.json" ~/Library/Application\ Support/Code/User/settings.json
  mkdir -p ~/Library/Application\ Support/espanso/{config,match}
  for f in "$DOTFILES_DIR"/espanso/config/*; do
    link "$f" ~/Library/Application\ Support/espanso/config/"$(basename "$f")"
  done
  for f in "$DOTFILES_DIR"/espanso/match/*; do
    link "$f" ~/Library/Application\ Support/espanso/match/"$(basename "$f")"
  done
fi

# ------------------------------------------------------------
# 4. mise (python / node / go / ruby / uv / CLI tools)
# ------------------------------------------------------------
echo "Setting up mise..."
eval "$(mise activate bash --shims)"
mise install --yes

# unmaintained repo (no go.mod): mise go backend cannot build it, use go install directly.
# Pinned to a commit (no releases) so installs are reproducible.
mise exec go -- go install github.com/motemen/github-list-starred@91affcda6f452e800e52c99cc20d66ebbe3d29bf

# ------------------------------------------------------------
# 5. zsh / tmux / vim plugins
# ------------------------------------------------------------
# zsh/.zshrc sources ~/.zinit/bin/zinit.zsh
[ -d ~/.zinit/bin ] || git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin

mkdir -p ~/.zsh/completion
[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins
# vim-plug (plugins are declared in vim/.vimrc)
[ -f ~/.vim/autoload/plug.vim ] || curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# `vim -es` exits 1 even when PlugInstall succeeds, so the exit status is ignored
vim -es -u ~/.vimrc +PlugInstall +qall || true

echo "Done. Restart your shell."
