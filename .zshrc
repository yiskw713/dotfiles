# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# locale setting
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# alias
# cdls
cdls ()
{
    \cd "$@" && ls -a
}
alias cd="cdls"
alias ls="ls -a"
alias reload='exec $SHELL -l'
alias gc="google-chrome"
alias vz="vim ~/.zshrc"
alias sz="source ~/.zshrc"
# docker
alias d='docker'
alias dc='docker-compose'
alias dimg='docker image'
alias dcnt='docker container'

# zinit
source ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# starship
eval "$(starship init zsh)"

# SYMBOL=""

zinit load "mafredri/zsh-async"

# 構文のハイライト(https://github.com/zsh-users/zsh-syntax-highlighting)
zinit load "zsh-users/zsh-syntax-highlighting"

### history 設定
HISTFILE=~/.zsh_historyx
HISTSIZE=10000
SAVEHIST=10000

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "\e[A" history-beginning-search-backward-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "\e[B" history-beginning-search-forward-end
bindkey "^[[B" history-beginning-search-forward-end

# 補完候補のメニュー選択で、矢印キーの代わりにhjklで移動出来るようにする。
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

### 補完
autoload -U compinit; compinit -C

### 補完方法毎にグループ化する。
zstyle ':completion:*' format '%B%F{blue}%d%f%b'
zstyle ':completion:*' group-name ''
### 補完侯補をメニューから選択する。
### select=2: 補完候補を一覧から選択する。補完候補が2つ以上なければすぐに補完する。
zstyle ':completion:*:default' menu select=2
### 補完候補に色を付ける。
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
### 補完候補がなければより曖昧に候補を探す。
### m:{a-z}={A-Z}: 小文字を大文字に変えたものでも補完する。
### r:|[._-]=*: 「.」「_」「-」の前にワイルドカード「*」があるものとして補完する。
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} r:|[._-]=*'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

zstyle ':completion:*' keep-prefix
zstyle ':completion:*' recent-dirs-insert both

### 補完候補
### _oldlist 前回の補完結果を再利用する。
### _complete: 補完する。
### _match: globを展開しないで候補の一覧から補完する。
### _history: ヒストリのコマンドも補完候補とする。
### _ignored: 補完候補にださないと指定したものも補完候補とする。
### _approximate: 似ている補完候補も補完候補とする。
### _prefix: カーソル以降を無視してカーソル位置までで補完する。
#zstyle ':completion:*' completer _oldlist _complete _match _history _ignored _approximate _prefix
zstyle ':completion:*' completer _complete _ignored

## 補完候補をキャッシュする。
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache
## 詳細な情報を使わない
zstyle ':completion:*' verbose no

# タイプ補完
zinit load "zsh-users/zsh-autosuggestions"
zinit load "zsh-users/zsh-completions"
zinit load "chrissicool/zsh-256color"

# git の補完を効かせる
# 補完＆エイリアスが追加される
zinit load "peterhurford/git-aliases.zsh"

# ヒストリの補完を強化する
zinit load "zsh-users/zsh-history-substring-search"

#] 補完候補が複数ある時に、一覧表示
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

# for cpp
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

# for zlib
# For compilers to find zlib you may need to set:
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"

# For pkg-config to find zlib you may need to set:
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"

# anyenv
eval "$(anyenv init -)"
for D in `ls $HOME/.anyenv/envs`
do
    export PATH="$HOME/.anyenv/envs/$D/shims:$PATH"
done

export PATH="$HOME/.poetry/bin:$PATH"
