# bellodots

## Prerequisites
- [Brew for Mac OSX](http://brew.sh) 

## Configuring

  - PowerLine for MacOSX
    Install fonts of https://github.com/powerline/fonts
    Oficial Documentation:
      http://powerline.readthedocs.org/en/master/installation/osx.html

## Installation
A Makefile could be used to install:

```make install```

It's also possible to perform the installation by steps:

  `make backup` backup all current files to a backup directory

  `make checkdeps` check dependencies (brew)

  `make fonts` install powerline fonts required for vim and tmux statusbar

  `make tools` install all tools using `brew` and `asdf`

  `make config` copy config files

  `make zsh` configure zsh

  `make tmux` configure tmux

  `make vim` configure vim

  `make git` configure git


## Customs key mappings


### VIM: Key mappings

**bellodots** inherited the most part of [belovim](https://github.com/MrKoopaKiller/belovim) configuration.

The key mappings are working for both of them.

#### TMUX key mappings

**LeaderKey:** `CTRL + S`

To install all plugins run:

`Leaderkey` + `I`

|Key Combination|Result|
|-|-|
`LeaderKey` + `-`| Horizontal split
`LeaderKey` + `_`| Horizontal split main
`LeaderKey` + `\`| Vertical split
`LeaderKey` + `|`| Vertical split main
`LeaderKey` + `arows keys`| move between windows
`LeaderKey` + `c`| New tab
`LeaderKey` + `e`| Sync panels on/off (broadcast mode)
`LeaderKey` + `n`| Move to next tab
`LeaderKey` + `p`| Move previous tab
`LeaderKey` + `,`| Rename tab
`LeaderKey` + `.`| Move window
`LeaderKey` + `$`| Move window
`LeaderKey` + `C`| New window
`LeaderKey` + `s`| Show opened windows buffer
`LeaderKey` + `&`| Close window
`LeaderKey` + `x`| kill tab
`LeaderKey` + `=`| Show copy buffer
`LeaderKey` + `]`| Paste last buffer item
`LeaderKey` + `[`| Scrolling mode
`LeaderKey` + `/`| Search key
`LeaderKey` + `SHIFT` + `hjkl`| Resize active split
