SHELL := /bin/bash
MAKE_SCRIPT := ./scripts/_make.sh

install: checkdeps fonts tools config # install and configure everything
backup: ## backup current files in backup directory
	@/bin/bash $(MAKE_SCRIPT) backup	
checkdeps: ## check dependencies
	@/bin/bash $(MAKE_SCRIPT) checkdeps
fonts: clean ## install powerline fonts required for vim and tmux statusbar
	@/bin/bash $(MAKE_SCRIPT) setup_fonts
tools: checkdeps ## install all tools using brew and asdf
	@/bin/bash $(MAKE_SCRIPT) setup_tools
config: tmux vim git zsh ## copy config files 
zsh: ## configure zsh
	@/bin/bash $(MAKE_SCRIPT) config_zsh
tmux: ## configure tmux
	@/bin/bash $(MAKE_SCRIPT) config_tmux
vim: ## configure vim
	@/bin/bash $(MAKE_SCRIPT) config_vim
git: ## configure git 
	@/bin/bash $(MAKE_SCRIPT) config_git
wsl2: ## configure Windows Terminal Fonts
	@/bin/bash $(MAKE_SCRIPT) wsl2

# === Control functions
clean: 
	@/bin/bash $(MAKE_SCRIPT) clean
cleanall: 
	@/bin/bash $(MAKE_SCRIPT) cleanall

.PHONY: help backup fonts vim git tmux zsh wsl2

help: ## show this message
	@echo -e "\nUsage: \n"
	@ grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\t\033[36mmake %-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
