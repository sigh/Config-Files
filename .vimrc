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
"  '100 : marks will be remembered for up to 100 previously edited files
"  "100 : will save up to 100 lines for each register
"  :100 : up to 100 lines of command-line history will be remembered
"  % : saves and restores the buffer list
"  n... : where to save the viminfo files
" ! : save global variables
set viminfo='100,\"100,:100,%,n~/.viminfo,!

" none of these should be word dividers, so make them not be
set iskeyword+=_,$,@,%,#,:

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

" make C-u and C-d scroll more slowly
set scroll=3
 
" Restore cursor position when we load up the file
if has("autocmd")
    autocmd BufReadPost * 
	\ if line("'\"") > 0 && line("'\"") <= line("$") |
	\ exe "normal g`\"" |
	\ endif 
endif
 
" Switch buffers with tab
:nnoremap <Tab> :bnext<CR>:redraw<CR>:ls<CR>
:nnoremap <S-Tab> :bprevious<CR>:redraw<CR>:ls<CR>

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
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" what to show when I hit :set list
set listchars=tab:\|\ ,trail:.,extends:>,precedes:<,eol:$

" Minimal number of screen lines to keep above and below the cursor
set scrolloff=4

" don't blink
set novisualbell

" Set the status line
set statusline=%F\ [%M%n%R%H]\ %l:%v/%L\ [%p%%]\ [%b,0x%B]

" color the status line
highlight clear StatusLine
highlight clear StatusLineNC
highlight StatusLine   term=reverse cterm=reverse
highlight StatusLineNC term=reverse ctermfg=black ctermbg=grey

" always show the status line
set laststatus=2

" always show the mode we are in
set showmode

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
nmap ,pt :%! perltidy -et=4<CR>
vmap ,pt :'<,'>! perltidy -et=4<CR>

nmap ,pc :! perl -c %<CR>

