# ------------------
# Homebrew
# ------------------
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ------------------
# locale setting
# ------------------
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# ------------------
# alias settings
# ------------------
# zoxide https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init zsh)"
if [[ $(command -v z) ]]; then
    alias cd="z"
fi

# eza: https://github.com/eza-community/eza
if [[ $(command -v eza) ]]; then
    alias eza="eza -a --icons --git -h -g"
    alias ls="eza"

    # cdls
    cdls ()
    {
        cd "$@" && eza -a --icons --git -h -g
    }
else
    alias ls="ls -a"
    cdls ()
    {
        cd "$@" && ls
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
alias cat="bat"
alias cd="cdls"
alias reload='exec $SHELL -l'
alias t="tmux"
alias v="vim"
alias vz="vim ~/.zshrc"
alias vv="vim ~/.vimrc"
alias sz="source ~/.zshrc"
alias screensaver="pipes.sh -p 5 -t 0 -r 5000"
# docker
alias d='docker'
alias dc='docker-compose'
alias dimg='docker image'
alias dcnt='docker container'
alias dnet="docker network"
# git
alias gcm='git commit -m'
alias g="git"
alias push='git push origin'
alias pull='git pull origin'
alias stash='git stash'
# rust
alias c="cargo"
# python
alias p="python"

# ------------------
# zinit
# ------------------
source ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# starship
eval "$(starship init zsh)"

zinit load "zsh-users/zsh-autosuggestions"
zinit load "zsh-users/zsh-completions"
zinit load "zsh-users/zsh-syntax-highlighting"

# ------------------
# historyの設定
# ------------------
HISTFILE=~/.zsh_historyx
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

# for docker completion etc.
fpath=(~/.zsh/completion $fpath)
autoload -Uz compinit && compinit -C

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

# ヒストリの補完を強化する
zinit load "zsh-users/zsh-history-substring-search"

# 補完候補が複数ある時に、一覧表示
setopt auto_list
# 補完キー（Tab, Ctrl+I) を連打するだけで順に補完候補を自動で補完
setopt auto_menu
# ディレクトリ名で移動可能
setopt auto_cd
# ^D でシェルを終了しない
setopt ignore_eof
# 補完時にヒストリを自動的に展開する
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

# 履歴をすぐに追加する（通常はシェル終了時）
setopt inc_append_history
# 重複したコマンドラインはヒストリに追加しない
setopt hist_ignore_dups
# 履歴の共有
setopt share_history
# ヒストリにhistoryコマンドを記録しない
setopt hist_no_store
# ビープを無効にする
setopt no_beep
setopt no_hist_beep
setopt no_list_beep

# ------------------
# mise
# ------------------
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# for claude code
export PATH="$HOME/.local/bin:$PATH"

# load settings for fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
