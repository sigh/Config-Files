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
set viminfo='1000,f1,\"1000,/1000,:1000,n~/.viminfo,!

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Theme/Colors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" turn on syntax highilighting and colors
syntax on

" Makes colours not fugly
if &term =~ "xterm"
    if has("terminfo")
        set t_Co=8
        set t_Sf=[3%p1%dm
        set t_Sb=[4%p1%dm
    else
        set t_Co=8
        set t_Sf=[3%dm
        set t_Sb=[4%dm
    endif
endif

" color the status line
highlight clear StatusLine
highlight clear StatusLineNC
highlight StatusLineHidden  ctermfg=black ctermbg=black 
highlight StatusLine        term=reverse ctermfg=DarkYellow  ctermbg=black
highlight StatusLineNC      term=reverse ctermfg=grey ctermbg=black

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim UI
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" number of pixel lines inserted between characters
set linespace=0

" command-line completion operates in an enhanced mode
set wildmenu
set wildmode=list:longest,full

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

" make the splitters between windows be blank
set fillchars=vert:\ ,stl:\ ,stlnc:\

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
:nnoremap <silent> <Tab> :call MyTab()<CR>
:nnoremap <silent> <S-Tab> :bprevious<Bar>:MiniBufExplorer<CR>

function! MyTab()
    if MBEIsOpen() == 1
        bnext
    else
        MiniBufExplorer
    endif
endfunction

" <Tab> is C-I, so assign jump list navi to C-P
noremap <C-P> <C-I>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swith buffer with alt keys
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"NORMAL mode bindings for vim( terminal)
noremap <unique> <script> 1 :b! 1<CR>
noremap <unique> <script> 2 :b! 2<CR>
noremap <unique> <script> 3 :b! 3<CR>
noremap <unique> <script> 4 :b! 4<CR>
noremap <unique> <script> 5 :b! 5<CR>
noremap <unique> <script> 6 :b! 6<CR>
noremap <unique> <script> 7 :b! 7<CR>
noremap <unique> <script> 8 :b! 8<CR>
noremap <unique> <script> 9 :b! 9<CR>
noremap <unique> <script> 0 :b! 0<CR>
"INSERT mode bindings for vim( terminal)
inoremap <unique> <script> 1 <esc>:b! 1<CR>
inoremap <unique> <script> 2 <esc>:b! 2<CR>
inoremap <unique> <script> 3 <esc>:b! 3<CR>
inoremap <unique> <script> 4 <esc>:b! 4<CR>
inoremap <unique> <script> 5 <esc>:b! 5<CR>
inoremap <unique> <script> 6 <esc>:b! 6<CR>
inoremap <unique> <script> 7 <esc>:b! 7<CR>
inoremap <unique> <script> 8 <esc>:b! 8<CR>
inoremap <unique> <script> 9 <esc>:b! 9<CR>
inoremap <unique> <script> 0 <esc>:b! 0<CR>

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
nnoremap <silent> <Space> :nohlsearch<Bar>:CMiniBufExplorer<CR>:echo<CR>

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
set statusline=%f\ [%M%n%R%H%W]%<\ %Y\ [%{&ff}]\ %#StatusLineHidden#%=%*%l/%L%<\ [%p%%]\ %v\ [%b,0x%B]

" always show the status line
set laststatus=2

" always show the mode we are in
set showmode

" make C-u and C-d scroll more slowly (this must be set after laststatus is set)
set scroll=3

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text Formatting/Layout
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" how automatic formatting is to be done
set formatoptions=tcrqn

" take indent for new line from previous line
set autoindent

" smart autoindenting for C programs
set smartindent

" do c-style indenting
set cindent

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

if executable("pbcopy")
	" ,p pastes when in normal mode, and copies in normal mode
	vmap ,p :w !pbcopy<CR><CR>
	nmap ,p :set paste<CR>:r !pbpaste<CR>:set nopaste<CR>
else
	" ,p enters insert mode with paste on and mouse off and line numbering
	"    changes are reverted when exiting insert mode
	"    In older versions of vim, you must press <Esc> again to revert
	nmap <silent> ,p :call MyPasteMode()<CR>i

	function! MyPasteMode()
		set paste nonumber mouse=
		
		if v:version >= 700
			augroup paste 
				autocmd InsertLeave * :set nopaste number mouse=a | autocmd! paste
			augroup end
		else
			map <silent> <Esc> :set nopaste number mouse=a<CR>:unmap <Char-60>Esc><CR>
		endif
	endfunction                
endif

" Set text wrapping toggles
nmap <silent> ,w :set invwrap wrap?<CR>

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
" Move around windows
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Move the cursor to the window left of the current one
noremap <silent> ,h :wincmd h<cr>

" Move the cursor to the window below the current one
noremap <silent> ,j :wincmd j<cr>

" Move the cursor to the window above the current one
noremap <silent> ,k :wincmd k<cr>

" Move the cursor to the window right of the current one
noremap <silent> ,l :wincmd l<cr>

" Close the current window
noremap <silent> ,c :close<cr>

" Move the current window to the right of the main Vim window
noremap <silent> ,ml <C-W>L

" Move the current window to the top of the main Vim window
noremap <silent> ,mk <C-W>K

" Move the current window to the left of the main Vim window
noremap <silent> ,mh <C-W>H

" Move the current window to the bottom of the main Vim window
noremap <silent> ,mj <C-W>J

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
" Language specific
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType python,haskell,lisp set expandtab nocindent

nmap ,pt :%! perltidy -et=4<CR>
vmap ,pt :'<,'>! perltidy -et=4<CR>

nmap ,pc :! perl -c %<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLugin options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Mini-buffer explorer

let g:miniBufExplMaxSize = 1
let g:miniBufExplModSelTarget = 1 
let g:miniBufExplUseSingleClick = 1
let g:miniBufExplorerMoreThanOne = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Finally
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ensure that all our functions work when we shell out
" this must always be LAST (not working :( )
" set shellcmdflag=-ic

 
