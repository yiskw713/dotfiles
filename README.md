# Dotfiles

## Usage

```sh
git clone https://github.com/yiskw713/dotfiles
cd dotfiles
sh install_procedure.sh
```

## Layout

Each tool has its own directory; `install_procedure.sh` symlinks them into place.

- `Brewfile`: Homebrew packages and casks
- `mise/config.toml`: languages (python, node, go, ruby), `uv` and CLI tools managed by [mise](https://mise.jdx.dev/)
- `zsh/`, `tmux/`, `vim/`, `git/`, `alacritty/`, `starship/`, `procs/`, `vscode/`, `espanso/`: tool configs

## Font

use `"Roboto Mono for Powerline"` for terminal and vscode.
