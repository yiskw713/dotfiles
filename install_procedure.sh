#!/bin/bash
set -euo pipefail

# ============================================================
# dotfiles setup script (idempotent)
# ============================================================

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

link() { ln -sfn "$1" "$2"; }

# ------------------------------------------------------------
# 1. Symlinks
# ------------------------------------------------------------
echo "Creating symlinks..."
mkdir -p ~/.config/{mise,procs,alacritty}

link "$DOTFILES_DIR/zsh/.zshrc"          ~/.zshrc
link "$DOTFILES_DIR/zsh/.fzf.zsh"        ~/.fzf.zsh
link "$DOTFILES_DIR/tmux/.tmux.conf"     ~/.tmux.conf
link "$DOTFILES_DIR/vim/.vimrc"          ~/.vimrc
link "$DOTFILES_DIR/git/.gitconfig"      ~/.gitconfig
link "$DOTFILES_DIR/starship/starship.toml" ~/.config/starship.toml
link "$DOTFILES_DIR/procs/config.toml"   ~/.config/procs/config.toml
link "$DOTFILES_DIR/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml
link "$DOTFILES_DIR/mise/config.toml"    ~/.config/mise/config.toml

# ------------------------------------------------------------
# 2. macOS
# ------------------------------------------------------------
if [ "$(uname)" = Darwin ]; then
  echo "Configuring macOS defaults..."
  mkdir -p ~/Pictures/ScreenShots
  defaults write com.apple.screencapture location ~/Pictures/
  chflags nohidden ~/
  defaults write com.apple.finder AppleShowAllFiles TRUE
  defaults write com.apple.desktopservices DSDontWriteNetworkStores true

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
  ln -sf "$DOTFILES_DIR"/espanso/config/* ~/Library/Application\ Support/espanso/config/
  ln -sf "$DOTFILES_DIR"/espanso/match/*  ~/Library/Application\ Support/espanso/match/
fi

# ------------------------------------------------------------
# 4. mise (python / node / go / ruby / uv / CLI tools)
# ------------------------------------------------------------
echo "Setting up mise..."
eval "$(mise activate bash --shims)"
mise install --yes

# unmaintained repo (no go.mod): mise go backend cannot build it, use go install directly
mise exec go -- go install github.com/motemen/github-list-starred@master

# ------------------------------------------------------------
# 5. zsh / tmux / vim plugins
# ------------------------------------------------------------
[ -d ~/.zinit ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

mkdir -p ~/.zsh/completion
[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
[ -d ~/.vim/pack/plugins/start/lightline ] || git clone https://github.com/itchyny/lightline.vim ~/.vim/pack/plugins/start/lightline
[ -d ~/.vim/bundle/Vundle.vim ] || git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

echo "Done. Restart your shell."
