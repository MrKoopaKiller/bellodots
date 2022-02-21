#!/usr/bin/env bash
# set -x

backup() {
  date_dir=$(date "+%F_%H%M%S")
  mkdir -p backup/$date_dir
  echo -ne "Backuping current files to \"./backup/${date_dir}\"... "
  zsh_files="$HOME/.zshenv $HOME/.zshrc $HOME/.zsh"
  tmux_files="$HOME/.tmux.conf $HOME/.tmuxline.conf $HOME/.tmux"
  vim_files="$HOME/.config/nvim/init.vim $HOME/.vim"
  git_files="$HOME/.gitconfig"
  tar czPf ./backup/${date_dir}/zsh_bakup-${date_dir}.tar.gz $zsh_files
  tar czPf ./backup/${date_dir}/tmux_bakup-${date_dir}.tar.gz $tmux_files
  tar czPf ./backup/${date_dir}/vim_bakup-${date_dir}.tar.gz $vim_files
  tar czPf ./backup/${date_dir}/git_bakup-${date_dir}.tar.gz $git_files
  echo "Done"
}

clean() {
  echo -ne "Removing old files... "
  rm -rf fonts
  echo "Done"
}

cleanall() {
  clean
  echo -ne "Removing build files and backups... "
  rm -rf backup
  echo "Done"
}

checkdeps() {
  echo -ne 'Checking for homebrew...'
  if ! command -v brew > /dev/null; then
    read -p "[INFO] Dependency not met, you don't have homebrew installed. Install? (y/n) " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
      echo "[INFO] Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      echo "[ERROR] Dependency not met: homebrew"
      exit 1
    fi
  fi
  echo 'OK'
}

setup_fonts() {
  echo -ne "Installing powerline fonts... "
  git clone -q https://github.com/powerline/fonts.git
  powerline_fonts_dir=$( cd "$( dirname "$0" )" && pwd )
  find_command="find \"$powerline_fonts_dir\" \( -name '*.[o,t]tf' -or -name '*.pcf.gz' \) -type f -print0"

  font_dir="$HOME/Library/Fonts"
  eval $find_command | xargs -0 -I % cp "%" "$font_dir/"

  if [[ -n `which fc-cache` ]]; then
    fc-cache -f $font_dir
  fi
  echo "Done"
}

setup_tools() {
  asdf_packages=(
    'fzf'
    'golang'
    'groovy'
    'helm'
    'java'
    'jsonnet'
    'kubectl'
    'kubectx'
    'neovim'
    'nodejs'
    'yq'
    )
  brew_packages=(
    "ack"
    "asdf"
    "awscli"
    "bat"
    "coreutils"
    "curl"
    "exa"
    "git"
    "go"
    "gpg"
    "hashicorp/tap/terraform-ls"
    "icdiff"
    "jq"
    "macos-trash"
    "nmap"
    "pyenv"
    "rg"
    "stats"
    "warrensbox/tap/tfswitch"
    "tmux"
    "tree"
    "zinit"
    "zsh"
    )

  echo -ne "Installing brew and asdf tools... "
  eval brew install "${brew_packages[*]}"
  . $(brew --prefix asdf)/asdf.sh
  for index in "${asdf_packages[@]}"; do
    if [[ $index == "java" ]]; then
      version="openjdk-17.0.1"
    else 
      version="latest"
    fi
    asdf plugin add $index
    asdf install $index $version
    asdf global $index $(asdf list $index)
  done
  echo "Done"
}

config_zsh(){
  echo "Configuring zsh... "
  cp zsh/zshenv $HOME/.zshenv
  cp zsh/zshrc $HOME/.zshrc
  if [[ ! -f $HOME/.zsh/theme/minimal.zsh ]]; then
    curl -flo /Users/${USER}/.zsh/theme/minimal.zsh --create-dirs https://raw.githubusercontent.com/subnixr/minimal/master/minimal.zsh
  fi
  if [[ ! -f $HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh ]]; then
    mkdir -p $HOME/.zsh/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/plugins/zsh-syntax-highlighting
  fi
  echo "Done"
}

config_tmux() {
  echo -ne "Configuring tmux... "
  if [[ ! -f $HOME/.tmux/plugins/tpm/tpm ]]; then
    mkdir -p ~/.tmux/plugins && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
  cp tmux/tmux.conf $HOME/.tmux.conf
  cp tmux/tmuxline.conf $HOME/.tmuxline.conf
  echo "OK"
}

config_vim() {
  echo -ne "Configuring vim... "
  if [[ ! -f $HOME/.local/share/nvim/site/autoload/plug.vim ]]; then
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  fi
  mkdir -p ~/.config/nvim && cp vim/nvim.vim $HOME/.config/nvim/init.vim
  echo "Done"
}

config_git() {
  echo -ne "Configuring vim... "
  cp git/gitconfig $HOME/.gitconfig
  echo -ne "Done"
}