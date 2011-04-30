" Sources:
"   http://www.linode.com/wiki/index.php/Vim_Tutorial
"   http://www.derekwyatt.org/vim/the-vimrc-file/
"   http://vim.wikia.com/wiki/Highlight_all_search_pattern_matches

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" get out of horrible vi-compatible mode
set nocompatible

" detect the type of file
filetype on

" ask what to do about unsaved/read-only files
set confirm

" automatically detected values for fileformat in this order
set fileformats=unix,dos,mac

" load filetype plugins
filetype plugin on

" load indent files for specific filetypes
filetype indent on

" Tell vim to remember certain things when we exit
"  '1000 : marks will be remembered for up to 1000 previously edited files
"  f1: store global marks
"  "1000 : will save up to 1000 lines for each register
"  :1000 : up to 1000 lines of command-line history will be remembered
"  /1000 : up to 1000 lines of search history
"  % : saves and restores the buffer list
"  n... : where to save the viminfo files
" ! : save global variables
set viminfo='1000,f1,\"1000,/1000,:1000,!,n~/.vim/.viminfo

" none of these should be word dividers, so make them not be
set iskeyword+=_,$,@,%,#

" ignore case sensitivity on search patterns
set ignorecase

" Do smart case matching (does not ignore case if we type uppercase chars)
set smartcase

" Show (partial) command in status line.
set showcmd

" Automatically save before commands like :next and :make
set autowrite

" detect filetype
set ffs=unix,dos,mac

" make vim smoother
set ttyfast

" Keyword lookup
autocmd FileType * exec "setlocal keywordprg=vimdoc\\ -" . &ft

" Set leader to ","
let mapleader = ","

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Theme/Colors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" turn on syntax highilighting and colors
syntax on

" Makes colours not fugly
if ! has("gui_running")
    set t_Co=16
endif

colorscheme peachpuff_mod

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim UI
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" number of pixel lines inserted between characters
set linespace=0

" command-line completion operates in an enhanced mode
set wildmenu
set wildmode=list:longest,full

" Display as much as possible of the last line of text
set display+=lastline

" don't split words if word wrap is on
set linebreak

" Show the line and column number of the cursor position
set ruler

" Number of screen lines to use for the command-line
" Helps avoid 'Hit enter' prompt
set cmdheight=2

" Print the line number in front of each line
set number

" do not redraw while running macros (much faster) (LazyRedraw)
set lazyredraw

" buffer becomes hidden when it is abandoned
set hidden

" make backspace work normal (indent, eol, start)
set backspace=2

" allow backspace and cursor keys to cross line boundaries
set whichwrap+=<,>,h,l,b,[,],~

" use mouse everywhere
set mouse=a
set ttymouse=xterm2

" shortens messages to avoid 'press a key' prompt
set shortmess=atI

" tell us when any line is changed via : commands
set report=0

" don't make noise on error messages
set noerrorbells

" all filchars blank
set fillchars=vert:\ ,stl:\ ,stlnc:\ ,diff:\ ,fold:\ 

" all cursor to go anywhere
set virtualedit=all

" cursor doesn't honor lines
nmap j gj
nmap k gk

" set history to something large
set history=1000

" Restore cursor position when we load up the file
if has("autocmd")
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \ exe "normal g`\"" |
    \ endif
endif

" Switch buffers with tab
nnoremap <silent> <Tab> :call <SID>NextBuffer()<CR>
nnoremap <silent> <S-Tab> :call <SID>PrevBuffer()<CR>

function! <SID>NextBuffer()
    bnext
    if MBEIsOpen() != 1
        set laststatus=0
        MiniBufExplorer
    endif
endfunction

function! <SID>PrevBuffer()
    bprevious
    if MBEIsOpen() != 1
        set laststatus=0
        MiniBufExplorer
    endif
endfunction

" <Tab> is C-I, so assign jump list navi to C-P
noremap <C-P> <C-I>

" ctrl-q deletes the buffer
map <silent> <C-Q> <Esc>:bd<CR>

" Always split on right when vertical
set splitright

noremap Y y$

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swith buffer with alt keys
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" NORMAL mode bindings
noremap <unique> <script> 1 :b! 1<CR>
noremap <unique> <script> 2 :b! 2<CR>
noremap <unique> <script> 3 :b! 3<CR>
noremap <unique> <script> 4 :b! 4<CR>
noremap <unique> <script> 5 :b! 5<CR>
noremap <unique> <script> 6 :b! 6<CR>
noremap <unique> <script> 7 :b! 7<CR>
noremap <unique> <script> 8 :b! 8<CR>
noremap <unique> <script> 9 :b! 9<CR>
noremap <unique> <script> <silent> - :call <SID>SwitchToBuffer()<CR>
" INSERT mode bindings
inoremap <unique> <script> 1 <esc>:b! 1<CR>
inoremap <unique> <script> 2 <esc>:b! 2<CR>
inoremap <unique> <script> 3 <esc>:b! 3<CR>
inoremap <unique> <script> 4 <esc>:b! 4<CR>
inoremap <unique> <script> 5 <esc>:b! 5<CR>
inoremap <unique> <script> 6 <esc>:b! 6<CR>
inoremap <unique> <script> 7 <esc>:b! 7<CR>
inoremap <unique> <script> 8 <esc>:b! 8<CR>
inoremap <unique> <script> 9 <esc>:b! 9<CR>
inoremap <unique> <script> 0 <esc>:b! 10<CR>

function! <SID>SwitchToBuffer()
    if v:count == 0
        e # " edit previous buffer
    else
        exec "b! " . v:count
    endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Visual Cues
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" show matching brackets for a moment
set showmatch

" how many tenths of a second to blink matching brackets for
set matchtime=5

" highlight searched phrases
set hlsearch

" highlight as you type you search phrase
set incsearch

" Press Space to turn off highlighting and clear any message already displayed.
" Also turn off MBE
noremap <silent> <Space> <Esc>:call <SID>ResetSome()<Bar>:nohlsearch<Bar>:pwd<CR>

" Ctrl-Space
noremap <silent> <Nul>   <Esc>:call <SID>ResetAll()<Bar>:nohlsearch<Bar>:pwd<CR>

" Reset only somethings
function! <SID>ResetSome()
    CMiniBufExplorer
    set laststatus=2
    if &diff
        diffu
    endif
endfunction

" Reset most things that we could have opened
function! <SID>ResetAll()
    call <SID>ResetSome()
    CDiffChanges
endfunction

" what to show when I hit :set list
set listchars=tab:\|\ ,trail:.,extends:>,precedes:<,eol:$

" Minimal number of screen lines to keep above and below the cursor
set scrolloff=4

" Make side scrolling act more naturally
set sidescrolloff=10
set sidescroll=1

" don't blink
set novisualbell

" Set the status line
set statusline=%f\ [%M%n%R%H%W]%<\ %Y\ [%{&ff}]\ %=%l/%L%<\ [%p%%]\ %v\ [%b,0x%B]

" always show the status line
set laststatus=2

" always show the mode we are in
set showmode

" make C-u and C-d scroll more slowly
" set scroll=3   " This keeps being reset so overwrite c-u c-d
noremap <C-U> 3<C-Y>
noremap <C-D> 3<C-E>

" Highlight whitespace at the end of the line
" (source: http://sartak.org/2011/03/end-of-line-whitespace-in-vim.html)
autocmd InsertEnter * syn clear EOLWS | syn match EOLWS excludenl /\s\+\%#\@!$/
autocmd InsertLeave * syn clear EOLWS | syn match EOLWS excludenl /\s\+$/
highlight EOLWS ctermbg=red guibg=red

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text Formatting/Layout
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" how automatic formatting is to be done
set formatoptions=crqn

" take indent for new line from previous line
set autoindent

" keep the existing indent structure when autoindenting
set copyindent

" do c-style indenting
set cindent

" Tab and Shift-Tab indent in visual mode
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" tab spacing (settings below are just to unify it)
set tabstop=4

" unify
set softtabstop=4

" unify
set shiftwidth=4

set expandtab " no tabs

" do not wrap lines
set nowrap

" use tabs at the start of a line, spaces elsewhere
set smarttab

" <Leader>p enters insert mode with paste on and mouse off and line numbering
"    changes are reverted when exiting insert mode
"    In older versions of vim, you must press <Esc> again to revert
nmap <silent> <Leader>p :call <SID>MyPasteMode()<CR>i
vmap <silent> <Leader>p :call <SID>MyPasteMode()<CR>i

function! <SID>MyPasteMode()
    set paste nonumber mouse=
    map <silent> <Esc> :set nopaste number mouse=a<CR>:unmap <Char-60>Esc><CR>
endfunction

if executable("pbcopy")
    " <Leader>sp (smart paste) pastes when in normal mode, and copies in normal mode
    vmap <silent> <Leader>sp :w !pbcopy<CR><CR>
    nmap <silent> <Leader>sp :set paste<CR>:r !pbpaste<CR>:set nopaste<CR>
endif

" Set text wrapping toggles
nmap <silent> <Leader>w :set invwrap wrap?<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Folding
" Enable folding, but by default make it act like folding is off, because
" folding is annoying in anything but a few rare cases
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Turn on folding
set foldenable

" Make folding indent sensitive
set foldmethod=indent

" Don't autofold anything (but I can still fold manually)
set foldlevel=100

" don't open folds when you search into them
set foldopen-=search

" don't open folds when you undo stuff
set foldopen-=undo

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File Explorer
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" should I split vertically
let g:explVertical=1

" width of 35 pixels
let g:explWinSize=35

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Backup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" create backup directories
silent ! mkdir -p ~/.vim/.backup
silent ! mkdir -p ~/.vim/.swap

" set backup to go to backup directories
set backup
set backupdir=~/.vim/.backup
set directory=~/.vim/.swap

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Diff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" set a larger context in diffs
set diffopt=filler,context:10

" allow us to be able to "do" in visual mode
vmap <silent> do :diffget<CR>

" DiffChanges shortcuts :)
map <silent> <Leader>dv :VDiffChanges<CR>
map <silent> <Leader>dV :VDiffChanges!<CR>
map <silent> <Leader>df :FileDiffChanges<CR>
map <silent> <Leader>dF :FileDiffChanges!<CR>
map <silent> <Leader>dt :TDiffChanges<CR>
map <silent> <Leader>dd :ReturnDiffChanges!<CR>
map <silent> <Leader>du <Leader>dd:VCSUpdateDiffChanges<CR>

autocmd FileType diff call <SID>SetDiffMaps()

function! <SID>SetDiffMaps()
    map <silent> <buffer> <Leader>dv <Leader>df<Leader>dv
    map <silent> <buffer> <Leader>dV <Leader>df<Leader>dV
    map <silent> <buffer> <Leader>dt <Nop>
    map <silent> <buffer> <Leader>df :DiffOpenFile<CR>
    map <silent> <buffer> <Leader>dF :DiffOpenFile!<CR>
    map <silent> <buffer> <Leader>dd <Leader>df:NavPatchDiffChanges<CR>
    map <silent> <buffer> <Leader>du :VCSUpdateDiffChanges<CR>

    " TODO: when diff_changes can take patches:
    "  <Leader>dd when there is no diff window should do a diff using VCS
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language specific
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType python,haskell,lisp setlocal expandtab nocindent

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLugin options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Mini-buffer explorer

let g:miniBufExplMaxSize = 1
let g:miniBufExplModSelTarget = 1
let g:miniBufExplUseSingleClick = 1
let g:miniBufExplorerMoreThanOne = 1
let g:miniBufExplSplitBelow = 1

" NERD_commenter

let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
map  <silent> <Leader>cc <plug>NERDCommenterAlignBoth
map  <silent> <Leader>cu <plug>NERDCommenterUncomment
map  <silent> <Leader>c<space> <plug>NERDCommenterToggle
nmap <silent> <Leader>c$ <plug>NERDCommenterToEOL
nmap <silent> <Leader>ca <plug>NERDCommenterAppend
nmap <silent> <C-c> <plug>NERDCommenterTogglej
vmap <silent> <C-c> <plug>NERDCommenterToggle
imap <silent> <C-c> <plug>NERDCommenterInInsert

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Spelling
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Language is always en_au
set spelllang=en_au

" Helper to toggle spelling
function s:spell()
	if ! &l:spell
		echo  "Spell check on"
		setlocal spell
	else
		echo "Spell check off"
		setlocal nospell
	endif
endfunction

" <Leader>s toggles spelling on and off
map  <Leader>s :call <SID>spell()<CR>
imap <Leader>s <Esc>:call <SID>spell()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Filetype switching
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nmap <Bslash>c   :call <SID>fileswitch('c')<CR>
nmap <Bslash>cc  :call <SID>fileswitch('cc')<CR>
nmap <Bslash>ccp :call <SID>fileswitch('cc')<CR>
nmap <Bslash>h   :call <SID>fileswitch('h')<CR>
nmap <Bslash>\   :call <SID>fileswitch('')<CR>

function s:fileswitch(ext)
    let l:fileswitch_prev = expand('%')
    if a:ext != ""
        exec "find %:t:r." . a:ext
    elseif exists("b:fileswitch_prev")
        exec "find " . b:fileswitch_prev
    endif
    let b:fileswitch_prev = l:fileswitch_prev
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpful commands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Calculator
command! -nargs=+ Calc :r! python -c "from math import *; print <args>"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Finally
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ensure that all our functions work when we shell out
" this must always be LAST (not working :( )
" set shellcmdflag=-ic

