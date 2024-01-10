#!/usr/bin/env bash

backup() {
  date_dir=$(date "+%F_%H%M%S")
  mkdir -p backup/$date_dir
  echo -ne "Backuping current files to \"$PWD/backup/${date_dir}\"... "
  fish_files="$HOME/.config/fish/config.fish $HOME/.config/omf"
  tmux_files="$HOME/.tmux.conf $HOME/.tmuxline.conf $HOME/.tmux"
  vim_files="$HOME/.config/nvim/init.vim"
  git_files="$HOME/.gitconfig"
  tar czPf ./backup/${date_dir}/bellodots_backup-${date_dir}.tar.gz $fish_files $tmux_files $nvim_files $git_files
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
  echo "Checking dependencies..."
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
  brew_packages=(
    "ack"
    "ansible"
    "autojump"
    "awscli"
    "coreutils"
    "curl"
    "docker-compose"
    "docker"
    "eza"
    "fish"
    "fzf"
    "git"
    "gpg-suite-no-mail"
    "helm"
    "icdiff"
    "jq"
    "kubectl"
    "macos-trash"
    "neovim"
    "pipenv"
    "pyenv"
    "ripgrep"
    "tfswitch"
    "tgswitch"
    "tmux"
  )
  linux_packages=(
    "ack"
    "awscli"
    "eza"
    "fish"
    "gpa"
    "gpgv2"
    "helm"
    "icdiff"
    "jq"
    "kubectl"
    "neovim"
    "ripgrep"
    "tmux"
    "trash-cli"
    "xclip"
    "xsel"
  )

  echo -ne "Installing tools... "
  # MacOS
  if [[ $(uname) == 'Darwin' ]]; then
    eval brew install "${brew_packages[*]}"
  else  
    ## Linux
    sudo apt update
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
}

config_fish(){
  echo "Configuring fish..."
  FISH_BIN=$(which fish)
  cp -f fish/config.fish $HOME/.config/fish/
  cp -fR fish/omf $HOME/.config/
  sudo ln -sf $FISH_BIN /usr/local/bin/fish
  if [[ ! -n $(rg -c fish /etc/shells) ]]; then
    echo $FISH_BIN | sudo tee -a /etc/shells
  fi
  chsh -s /usr/local/bin/fish
  #Get Oh-my-fish
  curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
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

config_nvim() {
  echo -ne "Configuring vim... "
  if [[ ! -f $HOME/.local/share/nvim/site/autoload/plug.vim ]]; then
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  fi
  mkdir -p ~/.config/nvim && cp vim/nvim.vim $HOME/.config/nvim/init.vim
}

config_git() {
  echo -ne "Configuring git... "
  cp git/gitconfig $HOME/.gitconfig
  echo "Done"
}

wsl2(){
  echo "Installing fonts package for Windows Terminal..."
  powershell.exe -ExecutionPolicy Bypass -File fonts/install.ps1
}