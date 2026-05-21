""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   GENERAL                                    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has('termguicolors')
  set termguicolors
else
  set t_Co=16
endif

colorscheme selenized_bw

function ToggleBackground()
  if &background ==# 'dark'
    set background=light
  else
    set background=dark
  endif
endfunction

function ToggleColorscheme()
  if g:colors_name ==# 'selenized'
    colorscheme selenized_bw
  else
    colorscheme selenized
  endif
endfunction

let mode = trim(system('darkman get'))

if mode ==# 'dark'
    set background=dark
elseif mode ==# 'light'
    set background=light
endif

set mouse=a
set colorcolumn=+1
set signcolumn=yes
set number
set ruler
set showcmd
set cursorline
set incsearch
set nowrap

set splitright
set splitbelow

set encoding=utf-8
set fileencoding=utf-8

set hidden
set nobackup
set nowritebackup

set updatetime=300
set timeoutlen=500

set clipboard=unnamedplus
set shortmess+=c

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

" YAML
autocmd FileType yaml setl cursorcolumn

" html
let g:html_indent_script1 = "inc"
let g:html_indent_style1  = "inc"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   PLUGINS                                    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" install vim-plug if not found
" FROM: https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data').'/plugged')
Plug 'junegunn/vim-plug'

" file browser
Plug 'scrooloose/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" linting and completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" javascript/typescript
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'jonsmithers/vim-html-template-literals'
Plug 'ianks/vim-tsx'

" git
Plug 'tpope/vim-fugitive'

" highlight color descriptions
Plug 'norcalli/nvim-colorizer.lua'

" Terraform
Plug 'hashivim/vim-terraform'

" Copilot
Plug 'github/copilot.vim'
call plug#end()

" vim-html-template-literals

" nerdtree
let g:NERDTreeMinimalUI = 1

" nvim-colorizer.lua
lua require'colorizer'.setup()

" vim-devicons
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols = {} " needed
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols['.*\.tf\(vars\|state\|\.json\)*$'] = '󱁢'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   MAPPINGS                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <C-h> 2zh
nnoremap <C-l> 2zl
nnoremap <C-j> <C-e>
nnoremap <C-k> <C-y>

"""""""""""""""""""""""""""""""""""" leader """"""""""""""""""""""""""""""""""""

let mapleader=";"
nmap <leader>w  :set wrap!<cr>
nmap <leader>b  :call ToggleBackground()<cr>
nmap <leader>B  :call ToggleColorscheme()<cr>
nmap <leader>e  :exec':tabnew '.stdpath('config').'/init.vim'<cr>
nmap <leader>R  :exec':source '.stdpath('config').'/init.vim'<cr>
nmap <leader>n  :set relativenumber!<cr>
nmap <leader>N  :set number!<cr>
nmap <leader>h  :set nohls!<cr>
nmap <leader>t  :let &textwidth = ( &textwidth > 0 ? 0 : 80 )<cr>
nmap <leader>cl :set cursorline!<cr>
nmap <leader>cc :set cursorcolumn!<cr>
nmap <leader>f  :NERDTreeToggle<cr>
nmap <leader>p  :CocCommand prettier.formatFile<cr>
nmap <leader>C  :Copilot toggle<cr>

""""""""""""""""""""""""""""""""""" coc.nvim """""""""""""""""""""""""""""""""""

" NOTE: mappings taken from
" https://github.com/neoclide/coc.nvim/blob/release/Readme.md

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

let g:coc_snippet_next = '<tab>'
let g:coc_snippet_prev = '<s-tab>'

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Map function and class text objects
" Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Remap <C-f> and <C-b> for scroll float windows/popups.
" Note coc#float#scroll works on neovim >= 0.4.0 or vim >= 8.2.0750
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

" NeoVim-only mapping for visual mode scroll
" Useful on signatureHelp after jump placeholder of snippet expansion
if has('nvim')
  vnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#nvim_scroll(1, 1) : "\<C-f>"
  vnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#nvim_scroll(0, 1) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
