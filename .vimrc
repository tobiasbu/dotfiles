"
" PLUGINS
"
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Theme
" Plug 'joshdick/onedark.vim'

" Initialize plugin system
call plug#end()

"
" Vim config
"
set encoding=utf-8	
set nu! 	  	" show line numbers
set tabstop=2
set shiftwidth=2
set expandtab
set mouse=a
set title
set cursorline
set guifont=Iosevka\ Term\ Nerd\ Font\ Complete\ Mono\ 12
set guicursor=


if (has("termguicolors"))
  set termguicolors " this variable must be enabled for colors to be applied properly
endif

syntax enable
" colorscheme onedark

" 
" Keymaps
"
  
" alt + up/down = move line 
nnoremap <A-Down> :m .+1<CR>==
nnoremap <A-Up> :m .-2<CR>==
inoremap <A-Down> <Esc>:m .+1<CR>==gi
inoremap <A-Up> <Esc>:m .-2<CR>==gi
vnoremap <A-Down> :m '>+1<CR>gv=gv
