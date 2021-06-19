#!/bin/bash -ux

THIS_DIR=$(cd $(dirname $0); pwd)

cd $HOME

for file in .zshrc .tmux.conf
do
	[ ! -e $file ] && ln -s dotfiles/$file .
done

# starship config
mkdir -p $HOME/.config
ln -s dotfiles/starship.toml $HOME/.config

# zinit install
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

if [ $(uname) = Darwin ]; then 
    # mac
    mkdir ~/Pictures/ScreenShots/
    defaults write com.apple.screencapture location ~/Pictures/
    # ファインダーにホームディレクトリを表示
    chflags nohidden ~/
    # 隠しファイルを表示
    defaults write com.apple.finder AppleShowAllFiles TRUE
    # 共有フォルダで .DS_Storeファイルを作成しない
    defaults write com.apple.desktopservices DSDontWriteNetworkStores true

    xcode-select --install
    echo "installing Homebrew ..."
    which brew >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    which brew >/dev/null 2>&1 && brew doctor

    # brew本体のアップデート
    brew update

    # パッケージのアップデート
    brew upgrade
    brew upgrade --cask

    # Brewfileの中身をインストール
    brew bundle --file $THIS_DIR/Brewfile

    brew cleanup
    brew doctor
fi

cd $THIS_DIR

# install rbenv pyenv nodenv
anyenv install rbenv
anyenv install pyenv
anyenv install nodenv

pyenv install 3.8.2
pyenv install 3.7.7

# poetry install
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

# install powershell font to use robot mono for powerline.
# TODO: set the font in terminal preferences.
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
