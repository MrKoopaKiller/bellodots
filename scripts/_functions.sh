#!/usr/bin/env bash
# set -x

package_manager=""

_linux_asdf() {
  # Install asdf required to install packages
  echo "Installing 'asdf' tool"
  if [[ ! -d "${HOME}/.asdf" ]]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0
    chmod +x $HOME/.asdf/asdf.sh
    echo -ne "export PATH=${HOME}/.asdf/bin:$PATH\n" >> $HOME/.bashrc
  fi
}

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
  echo 'Checking dependencies...'
  # Linux
  if [[ $(uname) != 'Darwin' ]]; then
    # APT
    if command -v apt > /dev/null; then 
      sudo apt update ; sudo apt install -y curl git python3-pip
    fi
    # YUM
    if command -v yum > /dev/null; then
      sudo yum update ; sudo yum install -y curl git python3-pip
    fi
    _linux_asdf
  fi
  # MacOS
  if [[ $(uname) == 'Darwin' ]]; then
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
  fi
}

setup_fonts() {
  echo -ne "Installing powerline fonts... "
  git clone -q https://github.com/powerline/fonts.git
  ./fonts/install.sh
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
    "kube-ps1"
    "macos-trash"
    "nmap"
    "pyenv"
    "rg"
    "stats"
    "warrensbox/tap/tfswitch"
    "tmux"
    "zinit"
    "zsh"
    "zsh-autosuggestions"
  )
  linux_packages=(
    "ack"
    "awscli"
    "bat"
    "exa"
    "gpa"
    "gpgv2"
    "icdiff"
    "jq"
    "nmap"
    "ripgrep"
    "tmux"
    "zsh"
  )

  echo -ne "Installing tools... "
  # MacOS
  if [[ $(uname) == 'Darwin' ]]; then
    eval brew install "${brew_packages[*]}"
    . $(brew --prefix asdf)/asdf.sh
  else  
    # Linux
    for index in "${linux_packages[@]}"; do
      # APT
      if command -v apt > /dev/null; then
        sudo apt install -y $index
      fi
      # YUM
      if command -v apt > /dev/null; then
        sudo yum install -y $index
      fi
    done
    # Install tfswitch
    curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash
    # Install pyenv
    curl https://pyenv.run | bash  
  fi

  # Linux + MacOS
  for index in "${asdf_packages[@]}"; do
    if [[ $index == "java" ]]; then
      version="openjdk-17.0.1"
    else 
      version="latest"
    fi
    export PATH=${HOME}/.asdf/bin:$PATH
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
    curl -flo $HOME/.zsh/theme/minimal.zsh --create-dirs https://raw.githubusercontent.com/subnixr/minimal/master/minimal.zsh
  fi
  if [[ ! -f $HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh ]]; then
    mkdir -p $HOME/.zsh/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/plugins/zsh-syntax-highlighting
  fi
  echo "#################################"
  echo -ne "ZSH has been installed.\nTo set zsh as default terminal, use the following command:\n\n"
  echo -ne "\t chsh -s /bin/zsh\n"
  echo "#################################"
}

config_tmux() {
  echo -ne "Configuring tmux... "
  if [[ ! -f $HOME/.tmux/plugins/tpm/tpm ]]; then
    mkdir -p ~/.tmux/plugins && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
  cp tmux/tmux.conf $HOME/.tmux.conf
  cp tmux/tmuxline.conf $HOME/.tmuxline.conf
  echo "Done"
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
  echo -ne "Configuring git... "
  cp git/gitconfig $HOME/.gitconfig
  echo "Done"
}