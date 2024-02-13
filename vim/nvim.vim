" vim:fdm=marker:fdl=3
set number          " Print the line number in front of each line
set hidden          " When off a buffer is unloaded when it is abandoned
set splitbelow      " Put the new window below the current one
set splitright      " Put the new window right of the current one
set lazyredraw      " Do not redrawn while executing commands that have not been typed
set list
:set listchars=nbsp:☠,tab:▸\ ,eol:¬

let mapleader="\<Space>"

" indentation
set smartindent     " Do smart autoindenting when starting a new line
set autoindent      " Copy indent from current line when starting a new line
set expandtab       " Use the appropriate number of spaces to insert a <Tab>
set tabstop=2       " Number of spaces that a <Tab> in the file counts for
set shiftwidth=2    " Number of spaces to use for each step of (auto)indent
set softtabstop=2   " Number of spaces that a <Tab> counts for in editing operations

" Enable persistent undo so that undo history persists across vim sessions
set undofile

" A comma separated list of options for Insert mode completion
set completeopt=menu

" color and theme
set background=dark
try
  colorscheme Tomorrow-Night
catch /^Vim\%((\a\+)\)\=:E185/
  " deal with it
endtry

highlight NonText guibg=#060606
highlight Folded  guibg=#0A0A0A guifg=#9090D0

" ignore stuff
set wildignore+=.git/**,.gitkeep,*.BACKUP.*,*.BASE.*,*.LOCAL.*,*.REMOTE.*
set wildignore+=vendor/**,coverage/**,tmp/**,*/tmp/*,*.so,*.swp,*.zip,log/**
set wildignore+=backup/**,*.sql,*.dump,*.tmp,*.min.js
set wildignore+=*.png,*.PNG,*.JPG,*.jpg,*.JPEG,*.jpeg,*.GIF,*.gif,*.pdf,*.PDF

" vim mappings
" call sudo with w!!
cmap w!! w !sudo tee % >/dev/null
" yank from the cursor to the end of the line, to be consistent with C and D
nnoremap Y y$
" don't mess with wrap movement
nnoremap j gj
nnoremap k gk
" tab navigation
nnoremap <Tab> :tabnext<CR>
nnoremap <S-Tab> :tabprevious<CR>
" Copy to system clipboard
nnoremap <Leader>y "+y
vnoremap <Leader>y "+y
" Paste from system clipboard
nnoremap <Leader>p "+p
vnoremap <Leader>p "+p
nnoremap <Leader>P "+P
vnoremap <Leader>P "+P
" terminal navigation
tnoremap <Esc> <C-\><C-n>
nnoremap <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>
" search helpers
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g# g#zz

call plug#begin('~/.local/share/nvim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'w0rp/ale'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'tpope/vim-obsession' 
Plug 'dhruvasagar/vim-prosession'
Plug 'jlanzarotta/bufexplorer'
Plug 'preservim/nerdtree'
call plug#end() " Initialize plugin system

set rtp+=~/Homebrew/opt/fzf 
let g:fzf_layout = { 'down': '~20%' }
let g:fzf_buffers_jump = 1 " [Buffers] Jump to the existing window if possible

nmap <silent> <leader>f :FZF<CR>      " fzf
nmap <silent> <leader>G :GFiles<CR>   " fzf
nmap <silent> <leader>h :Helptags<CR> " fzf
map <leader>nt :NERDTreeToggle<CR>    " NERDTree plugin map key
" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)
" Insert mode completion
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

" airline {{{
" " Use powerline fonts on airline
let g:airline_theme='minimalist'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#syntastic#enabled = 1
" }}}

set hidden          " TextEdit might fail if hidden is not set.
" set cmdheight=2   " More space for displaying messages.
set updatetime=300

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Enable backup and undo by default
let s:dir      = has('win32') ? '$APPDATA/Vim' : isdirectory($HOME.'/Library') ? '~/Library/Vim' : empty($XDG_DATA_HOME) ? '~/.local/share/vim' : '$XDG_DATA_HOME/vim'
let &backupdir = expand(s:dir) . '/backup//'
let &undodir   = expand(s:dir) . '/undo//'
let g:yankring_history_dir = expand(s:dir) . '/tmp//'                " YankRing temp dir
set undofile

if !isdirectory(expand(s:dir))
  call system("mkdir -p " . expand(s:dir) . "/{backup,undo,tmp}")
end

" StripTrailingWhitespaces: Remove traling spaces in the entire text.
function! <SID>StripTrailingWhitespaces()
  let _s=@/
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  let @/=_s
  call cursor(l, c)
endfunction

" DelBlank: Delete blank lines in the entire text.
function! <SID>DelBlank()
   let _s=@/
   let l = line(".")
   let c = col(".")
   :g/^\n\{2,}/d
   let @/=_s
   call cursor(l, c)
endfun

" Wipeout: Destroy all buffers that are not open in any tabs or windows.
function! <SID>Wipeout()
  let l:buffers = range(1, bufnr('$'))
  let l:currentTab = tabpagenr()
  try
    let l:tab = 0
    while l:tab < tabpagenr('$')
      let l:tab += 1

      let l:win = 0
      while l:win < winnr('$')
        let l:win += 1
        " l:buffers list
        let l:thisbuf = winbufnr(l:win)
        call remove(l:buffers, index(l:buffers, l:thisbuf))
      endwhile
    endwhile

    if len(l:buffers)
      execute 'bwipeout' join(l:buffers)
    endif
  finally
    execute 'tabnext' l:currentTab
  endtry
endfunction

" Call function Delblank
nnoremap <silent> <F9> :call <SID>DelBlank()<CR>
" Call function StripTrailingWhitespaces
nnoremap <silent> <F10> :call <SID>StripTrailingWhitespaces()<CR>
" Call function Wipeout
nnoremap <silent> <F7> :call <SID>Wipeout()<CR>
" Remove numbers and formatter
imap <F12> <c-o>:set list! \| set nu!<CR>
map <F12> :set list! \| set nu!<CR>
" Managing tabs
:noremap <leader>, :bprev<CR>
:noremap <leader>. :bnext<CR>
noremap <leade>n :tabnew<CR>
" Save and exit
nnoremap <leader>x :x!<CR>
" Save file
nnoremap <leader>w :w<CR>
" Quit file without save
nnoremap <leader>q :q!<CR>
" Hide search highlights
nnoremap <leader>h :set hlsearch!<CR>
" Clean search highlight
nmap <silent> <leader>/ :nohlsearch<CR>
" autocmd VimEnter * echo "=> bellodots 2"