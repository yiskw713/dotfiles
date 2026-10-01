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
- `zsh/`, `tmux/`, `herdr/`, `vim/`, `git/`, `alacritty/`, `starship/`, `procs/`, `vscode/`, `espanso/`: tool configs

## Font

Terminal (Alacritty) and VS Code use `"HackGen35 Console NF"`, installed via the `font-hackgen-nerd` cask in the `Brewfile` (`brew bundle`).
