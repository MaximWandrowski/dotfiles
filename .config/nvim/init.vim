""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                 LOOK & FEEL                                  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has('termguicolors')
  set termguicolors
endif

set background=dark
colorscheme solarized

set mouse=a
set colorcolumn=+1
set signcolumn=yes
set number
set ruler
set showcmd
set cursorline
set incsearch

set splitright
set splitbelow

set encoding=utf-8
set fileencoding=utf-8

set nobackup
set nowritebackup

set updatetime=300
set timeoutlen=500

set clipboard=unnamedplus

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   MAPPINGS                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let mapleader=";"

map <leader>e :exec':tabnew '.stdpath('config').'/init.vim'<cr>
map <leader>r :exec':source '.stdpath('config').'/init.vim'<cr>
map <leader>n :set relativenumber!<cr>
map <leader>N :set number!<cr>
map <leader>h :set nohls!<cr>
map <leader>t :let &textwidth = ( &textwidth > 0 ? 0 : 80 )<cr>
map <leader>c :set cursorline!<cr>
map <leader>f :NERDTreeToggle<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  FILETYPES                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

filetype plugin indent on

" default
set textwidth=80
set tabstop=2
set shiftwidth=2
set smarttab
set smartindent
set autoindent
set expandtab
set autoindent

" python
autocmd FileType python setl tabstop=4
autocmd FileType python setl shiftwidth=4

" makefile
autocmd FileType make setl tabstop=8
autocmd FileType make setl shiftwidth=8
autocmd FileType make setl noexpandtab

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   PLUGINS                                    "
"                                                                              "
" FROM: https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" install vim-plug if not found
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data').'/plugged')
Plug 'junegunn/vim-plug'
" file browsing
Plug 'scrooloose/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
" linting
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" miscellaneous
Plug 'tpope/vim-fugitive'
Plug 'norcalli/nvim-colorizer.lua'
call plug#end()

let g:NERDTreeMinimalUI = 1

lua require'colorizer'.setup()
