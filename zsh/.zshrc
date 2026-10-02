# ------------------
# Homebrew
# ------------------
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ------------------
# mise
# ------------------
# zoxide / eza / starship など mise 管理のツールを後続で使うので、最初に有効化する
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# ------------------
# locale setting
# ------------------
export LANG="en_US.UTF-8"

# ------------------
# alias settings
# ------------------
# zoxide https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init zsh)"

# eza: https://github.com/eza-community/eza
if [[ $(command -v eza) ]]; then
    alias eza="eza -a --icons --git -h -g"
    alias ls="eza"
    alias ll="eza -l"

    # cdls
    cdls ()
    {
        z "$@" && eza -a --icons --git -h -g
    }
else
    alias ls="ls -a"
    alias ll="ls -l"
    cdls ()
    {
        z "$@" && ls
    }
fi

# ghq
update_all_repos ()
{
    ghq list | ghq get --update --parallel
}

# https://github.com/motemen/github-list-starred
get_starred_repos ()
{
    local n_repos=${1:-10}
    github-list-starred yiskw713 | head -n $n_repos | ghq get --parallel
}

# s-search: https://github.com/zquestz/s
if [[ $(command -v s) ]]; then
    alias s="s -p google"
fi

# tre: https://github.com/dduan/tre
tre() { command tre "$@" -e vim && source "/tmp/tre_aliases_$USER" 2>/dev/null; }
alias tree="tre"

# other alias
alias ps="procs"
alias du="dust"
alias df="duf"
alias cd="cdls"
alias reload='exec $SHELL -l'
alias t="tmux"
alias h="herdr"
alias v="vim"
alias vz="vim ~/.zshrc"
alias vv="vim ~/.vimrc"
alias sz="source ~/.zshrc"
alias screensaver="pipes.sh -p 5 -t 0 -r 5000"
# container (podman)
alias d='podman'
alias dimg='podman image'
alias dcnt='podman container'
alias dnet="podman network"
# git
alias gcm='git commit -m'
alias g="git"
alias stash='git stash'
# rust
alias c="cargo"
# python
alias p="python"

# alias を使ったとき、実行前に展開後のコマンドを表示する
autoload -Uz add-zsh-hook
show_alias_expansion() {
  [[ "$1" != "$2" ]] && print -P "%F{8}→ ${2//\%/%%}%f"
}
add-zsh-hook preexec show_alias_expansion

# ------------------
# zinit
# ------------------
source ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit

# starship
eval "$(starship init zsh)"

# turbo mode (wait): prompt を先に出してプラグインを遅延ロードする
# syntax-highlighting は他のプラグイン/bindkey の後にロードする必要があるので最後
zinit load "zsh-users/zsh-completions"
zinit ice wait lucid
zinit load "zsh-users/zsh-autosuggestions"
zinit ice wait lucid
zinit load "zsh-users/zsh-syntax-highlighting"

# ------------------
# historyの設定
# ------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# ignore unnecessary history.
# Ref: https://www.m3tech.blog/entry/dotfiles-bonsai
zshaddhistory() {
    local line="${1%%$'\n'}"
    [[ ! "$line" =~ "^(cd|z|jj?|lazygit|la|ll|ls|eza)($| )" ]]
}

# https://superuser.com/questions/585003/searching-through-history-with-up-and-down-arrow-in-zsh
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# ------------------
# 補完
# ------------------
# 補完候補のメニュー選択で、矢印キーの代わりにhjkl/ctrl+hjklで移動出来るようにする。
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect '^h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect '^j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect '^k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect '^l' vi-forward-char

# for podman completion etc.
fpath=(~/.zsh/completion $fpath)
autoload -Uz compinit
# .zcompdump が24時間以内なら -C でチェックを省略して高速化し、古ければ作り直す
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
(( ${+_comps} )) && _comps[zinit]=_zinit

# 補完方法毎にグループ化する。
zstyle ':completion:*' format '%B%F{blue}%d%f%b'
zstyle ':completion:*' group-name ''
# 補完侯補をメニューから選択する。
# select=2: 補完候補を一覧から選択する。補完候補が2つ以上なければすぐに補完する。
zstyle ':completion:*:default' menu select=2
# 補完候補に色を付ける。
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# m:{a-z}={A-Z}: 小文字を大文字に変えたものでも補完する。
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

zstyle ':completion:*' keep-prefix
zstyle ':completion:*' recent-dirs-insert both

# _complete: 補完する。
# _ignored: 補完候補にださないと指定したものも補完候補とする。
zstyle ':completion:*' completer _complete _ignored

# 補完候補をキャッシュする。
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache
# 詳細な情報を使わない
zstyle ':completion:*' verbose no

# 補完候補が複数ある時に、一覧表示
setopt auto_list
# 補完キー（Tab, Ctrl+I) を連打するだけで順に補完候補を自動で補完
setopt auto_menu
# ディレクトリ名で移動可能
setopt auto_cd
# ^D でシェルを終了しない
setopt ignore_eof
# ! によるヒストリ展開 (!!, !$ など) を有効にする
setopt hist_expand
# 補完候補一覧でファイルの種別を識別マーク表示
setopt list_types
# カッコの対応などを自動的に補完
setopt auto_param_keys
# ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash
# ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt mark_dirs
# 語の途中でもカーソル位置で補完
setopt complete_in_word
# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst
# コマンドラインでも # 以降をコメントと見なす
setopt interactive_comments

# 重複したコマンドラインはヒストリに追加しない
setopt hist_ignore_dups
# 履歴をすぐに追加し、セッション間で共有する
setopt share_history
# ヒストリにhistoryコマンドを記録しない
setopt hist_no_store
# 先頭にスペースを付けたコマンドはヒストリに残さない
setopt hist_ignore_space
# ビープを無効にする
setopt no_beep
setopt no_hist_beep
setopt no_list_beep

# for claude code
export PATH="$HOME/.local/bin:$PATH"

# load settings for fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# herdr 内のシェルなら、ペイン名を自動で付ける (pane 1, pane 2, ...)
[[ -n "$HERDR_PANE_ID" ]] && ~/.config/herdr/name-pane.sh &>/dev/null &!
