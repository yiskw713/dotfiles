call plug#begin()
Plug 'tomasiser/vim-code-dark'
Plug 'lambdalisue/fern.vim'
Plug 'itchyny/lightline.vim'
" fzf バイナリは mise 管理のものを使うので fzf#install は呼ばない
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
call plug#end()

"----------------------------------------
" General
"----------------------------------------
"文字コードをUFT-8に設定
set fenc=utf-8
" ファイルを上書きする前にバックアップを作ることを無効化
set nowritebackup
" バックアップファイルを作らない
set nobackup
" 挿入モードでバックスペースで削除できるようにする
set backspace=indent,eol,start
" wildmenuオプションを有効(vimバーからファイルを選択できる)
set wildmenu
" スワップファイルを作らない
set noswapfile
" 編集中のファイルが変更されたら自動で読み直す
set autoread
" バッファが編集中でもその他のファイルを開けるように
set hidden
" 入力中のコマンドをステータスに表示する
set showcmd
" 検索にマッチした行以外を折りたたむ(フォールドする)機能
set nofoldenable
" ヤンクでクリップボードにコピー
set clipboard=unnamed

"----------------------------------------
" 表示
"----------------------------------------
" カラースキーム
set t_ut=
colorscheme codedark
" ダーク系のカラースキームを使う
set background=dark
" 行番号を表示
set number
" 現在の行を強調表示
set cursorline
" 現在の行を強調表示（縦）
set cursorcolumn
" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore
" インデントはスマートインデント
set smartindent
" ビープ音を可視化
set visualbell
" 括弧入力時の対応する括弧を表示
set showmatch
" ステータスラインを常に表示
set laststatus=2
" メッセージ表示欄を1行にする
set cmdheight=1
let g:lightline = { 'colorscheme': 'codedark' }
" コマンドラインの補完
set wildmode=list:longest
" 省略されずに表示
set display=lastline
" 折り返し時に表示行単位での移動できるようにする
nnoremap j gj
nnoremap k gk
" シンタックスハイライトの有効化
syntax enable
" 対応する括弧の強調表示時間
set matchtime=1
" コマンドラインの履歴を10000件保存する
set history=10000
" タイトルを表示
set title

"----------------------------------------
" Tab系
"----------------------------------------
" 不可視文字を可視化(タブが「▸-」と表示される)
set list listchars=tab:\▸\-
" Tab文字を半角スペースにする
set expandtab
" Tab文字の表示幅（スペースいくつ分）
set tabstop=4
" 行頭でのTab文字の表示幅
set shiftwidth=4

"----------------------------------------
" 検索系
"----------------------------------------
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索語をハイライト表示
set hlsearch
" ESC連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

" 編集箇所のカーソルを記憶
if has("autocmd")
  augroup vimrc
    autocmd!
    " In text files, always limit the width of text to 78 characters
    autocmd BufRead *.txt set tw=78
    " When editing a file, always jump to the last cursor position
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif
  augroup END
endif

" undoの永続化(一度ファイルを閉じてもundoできる)
if has('persistent_undo')
  let undo_path = expand('~/.vim/undo')
  if !isdirectory(undo_path)
    call mkdir(undo_path, 'p', 0700)
  endif
  exe 'set undodir=' .. undo_path
  set undofile
endif

" https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
" You might have to force true color when using regular vim inside tmux as the
" colorscheme can appear to be grayscale with "termguicolors" option enabled.
if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" 行の表示を相対的な表示にする
set relativenumber
