# Instructions for future me


### zsh and oh-my-zsh
1. https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH
2. https://ohmyz.sh/#install

### git setup

```
git config --global user.email "you@example.com"
git config --global user.name "Tobias Ulrich"
```

### vim 

1. Check you have vim.tiny installed:

```
readlink -f `which vi`
```

2. If true, then:

```
sudo apt update
sudo apt install vim
sudo apt-get install vim-gui-common
sudo apt-get install vim-runtime
```

3. Install [VimPlug](https://github.com/junegunn/vim-plug)

4. Then, open vim and run `PlugInstall` to install plugins.

#### Clipboard support

1. Check if is available

```
vim --version | grep clipboard
```

2. If not, install vim-gtk that incluedes clipboard support

```
sudo apt-get install -y vim-gtk 
```

3. If yes then add to .vimrc (already added)

```
set clipboard=unnamedplus
set clipboard+=unnamed
```

- To copy `y`;  to clipboard `"+y` = Ctrl+Alt+C/V
- To paste `p`; to clipboard `"+p`

#### NERDTree with icons

Plugin [vim-devicons][https://github.com/ryanoasis/vim-devicons] (added already)

Download from this IosevkaTerm  [link](https://github.com/ryanoasis/nerd-fonts/releases) and setup in the terminal.


### Font manager

1. Installing:

- With font-manager on Ubuntu and derivatives:

```
    sudo add-apt-repository ppa:font-manager/staging
    sudo apt-get update
    sudo apt install font-manager
```

If your not based in Ubuntu, try to check you distro package installer. Otherwise, manual install:

  1. Run `mkdir ~/.local/share/fonts`
  2. Run `mv ~/Downloads/iosevka.ttc ~/.local/share/fonts/iosevka.ttc`
  3. Select font in terminal 
    - Iovsevka Fixed Regular
    - Iovsevka Term Regular
