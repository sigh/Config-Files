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

" Try to preserve the cursor column even if it is not Vi compatible.
set nostartofline

" Set default textwidth to 80
set textwidth=80

" Keyword lookup
autocmd FileType * exec "setlocal keywordprg=vimdoc\\ -" . &ft

" Set leader to ","
let mapleader = ","

" Better Completion
set completeopt=longest,menuone,preview

" Shortcut to get current file's directory
cabbr <expr> %% <SID>CurrentWorkingDir()

function! <SID>CurrentWorkingDir()
    let l:dir = expand('%:h')
    if l:dir != ''
        return l:dir
    else
        return '.'
    endif
endfunction

" Sudo to write
cmap w!! w !sudo tee % >/dev/null

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
map j gj
map k gk

" set history to something large
set history=1000

" Restore cursor position when we load up the file
if has("autocmd")
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \ exe "normal g`\"" |
    \ endif
endif

" look up the entire directory stack for tags
set tags=./tags;/

" Switch buffers with tab
nnoremap <silent> <Tab> :bnext<CR>
nnoremap <silent> <S-Tab> :bprevious<CR>

" <Tab> is C-I, so assign jump list navi to C-P
noremap <C-P> <C-I>

" ctrl-q deletes the buffer
map <silent> <C-Q> <Esc>:BD<CR>

" Always split on right when vertical
set splitright

" Y yanks to the end of the line (more consistent with other capital letter
" commands.
noremap Y y$

" Ctrl-A on the command line goes to the start of the line (like in shell).
cnoremap <C-A> <Home>

" Ctrl-S on the command line is a shortcut for the smartcase function.
cnoremap <C-S> \=SC("")<Left><Left>

" Allow Ctrl-Z even in insert mode.
imap <C-Z> <C-O><C-Z>

" Fix linewise visual selection of various text objects
nnoremap VV V
nnoremap Vit vitVkoj
nnoremap Vat vatV
nnoremap Vab vabV
nnoremap VaB vaBV
nnoremap Va{ va{V
nnoremap Va( va(V

" New line while in normal mode
map <Leader>o o<Esc>
map <Leader>O O<Esc>

" Delete entire line except indenting.
map <Leader>d ^d$

" Easy window navigation.
noremap <C-h>  <C-w>h
noremap <C-j>  <C-w>j
noremap <C-k>  <C-w>k
noremap <C-l>  <C-w>l

" allow the . to execute once for each line of a visual selection
vnoremap . :normal .<CR>

" Resize splits when the window is resized
au VimResized * exe "normal! \<c-w>="

" Motion for "next/last object". For example, "din(" would go to the next "()"
" pair
" and delete its contents.
onoremap an :<c-u>call <SID>NextTextObject('a', 'f')<cr>
xnoremap an :<c-u>call <SID>NextTextObject('a', 'f')<cr>
onoremap in :<c-u>call <SID>NextTextObject('i', 'f')<cr>
xnoremap in :<c-u>call <SID>NextTextObject('i', 'f')<cr>

onoremap al :<c-u>call <SID>NextTextObject('a', 'F')<cr>
xnoremap al :<c-u>call <SID>NextTextObject('a', 'F')<cr>
onoremap il :<c-u>call <SID>NextTextObject('i', 'F')<cr>
xnoremap il :<c-u>call <SID>NextTextObject('i', 'F')<cr>

function! s:NextTextObject(motion, dir)
  let c = nr2char(getchar())
  exe "normal! ".a:dir.c."v".a:motion.c
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Quickfix
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

map <silent> <Leader>qq :call <SID>OpenQuickfixWindow()<CR>
map <silent> <Leader>qc :cclose<CR>
map <silent> <Leader>qn :cnext<CR>
map <silent> <Leader>q<Tab> :cnext<CR>
map <silent> <Leader>qp :cprev<CR>
map <silent> <Leader>q<S-Tab> :cprev<CR>
map <silent> <Leader>Q<S-Tab> :cprev<CR>
function s:OpenQuickfixWindow()
    botright copen
endfunction

" Use ack for grep (for some reason set greprg didn't like the space)
let &grepprg="ack --column -H"
set grepformat=%f:%l:%c:%m
command -bang -complete=shellcmd -nargs=* A call s:Ack(<q-args>, "<bang>")

function! s:Ack(query, async)
    if a:async != ""
        let grep_cmd = &grepprg . ' ' . a:query
        call asynccommand#run(grep_cmd, asynchandler#quickfix(&grepformat, '[Found: %s] ack ' . a:query))
        redraw!
    else
        exec 'silent grep! ' . a:query
        redraw!
        " Couldn't get <Leader> to work
        normal ,qq
    endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swith buffer
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

" <count>- swithes to buffer <count>. With no count it switches the the previous
" buffer.
" NOTE: <C-U> is required is required to remove the line range that you get
"       when typing ':' after a count.
noremap <unique> <script> <silent> - :<C-U>call <SID>SwitchToBuffer()<CR>

" Ctrl-- will show the list of buffers and ask which to switch to
noremap <unique> <script> <silent> <C-_> :ls<CR>:b

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
        if bufexists(bufname('#'))
            e # " edit previous buffer
        else
            echohl Error
            echo "No previous buffer"
            echohl None
        endif
    elseif bufexists(v:count)
        exec "b! " . v:count
    else
        echohl Error
        echo "Buffer " . v:count . " does not exist"
        echohl None
    endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Visual Cues
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
    " Update diff
    if &diff
        diffu
    endif
    " Move screen to the left
    normal zH
    call Buftabs_show(-1)
endfunction

" Reset most things that we could have opened
function! <SID>ResetAll()
    call <SID>ResetSome()
    CDiffChanges
endfunction

" what to show when I hit :set list
set listchars=tab:·\ ,extends:»,precedes:«
set list

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

" Underline the current line. Especially useful for knowing the current line
" of an inactive window.
set cursorline

" Highlight whitespace at the end of the line
" (source: http://sartak.org/2011/03/end-of-line-whitespace-in-vim.html)
autocmd InsertEnter * syn clear EOLWS | syn match EOLWS excludenl containedin=ALL /\s\+\%#\@!$/
autocmd InsertLeave * syn clear EOLWS | syn match EOLWS excludenl containedin=ALL /\s\+$/
autocmd BufRead,BufNewFile * syn match EOLWS excludenl containedin=ALL /\s\+$/
highlight EOLWS ctermbg=red guibg=red

" Make matching paren less distracting.
highlight MatchParen ctermbg=yellow

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text Formatting/Layout
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" how automatic formatting is to be done
set formatoptions=crqn

" take indent for new line from previous line
set autoindent

" keep the existing indent structure when autoindenting
set copyindent

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
"    changes are reverted when exiting insert mode (or navigating away in any
"    way)
" While in paste mode a new tab is created so that splits don't get in the way
" of copying.
nmap <silent> <Leader>p :call <SID>MyPasteMode()<CR>i

function! <SID>MyPasteMode()
    tab split
    TName 'Paste'
    setlocal paste nonumber nolist
    augroup my_paste
        autocmd!
        autocmd InsertLeave <buffer> call <SID>MyPasteModeEnd()
        autocmd BufLeave <buffer> call <SID>MyPasteModeEnd()
        autocmd TabLeave <buffer> call <SID>MyPasteModeEnd()
        autocmd WinLeave <buffer> call <SID>MyPasteModeEnd()
    augroup END
endfunction

function! <SID>MyPasteModeEnd()
    " Remove all commands from the group
    autocmd! my_paste
    " Delete the group
    augroup! my_paste
    setlocal nopaste number list
    tabclose
endfunction

if executable("pbcopy")
    " <Leader>sp (smart paste) pastes when in normal mode, and copies in normal mode
    vmap <silent> <Leader>sp :w !pbcopy<CR><CR>
    nmap <silent> <Leader>sp :set paste<CR>:r !pbpaste<CR>:set nopaste<CR>
endif

" Set text wrapping toggles
nmap <silent> <Leader>r :set invwrap wrap?<CR>

" Strip trailing whitespace
function! <SID>StripTrailingWhitespace()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction
nmap <silent> <Leader><space> :call <SID>StripTrailingWhitespace()<CR>

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
set backupdir=~/.vim/.backup//
set directory=~/.vim/.swap// " the slashes at the end mean that the files are
                             " stored with the full path

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tabs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd VimEnter * TName 'main'

function! <SID>NameTabPrefix(prefix)
    TName a:prefix . ' ' . pathshorten(expand('%'))
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Diff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" set a larger context in diffs
set diffopt=filler,context:10

" allow us to be able to "do" in visual mode
vmap <silent> do :diffget<CR>

" DiffChanges shortcuts :)
map <silent> <Leader>dv :VDiffChanges<CR>:call <SID>NameTabPrefix('VCS Diff')<CR>
map <silent> <Leader>dV :VDiffChanges!<CR>:call <SID>NameTabPrefix('VCS Diff')<CR>
map <silent> <Leader>df :FileDiffChanges<CR>:call <SID>NameTabPrefix('File Diff')<CR>
map <silent> <Leader>dF :FileDiffChanges!<CR>:call <SID>NameTabPrefix('File Diff')<CR>
map <silent> <Leader>dd :ReturnDiffChanges!<CR>
map <silent> <Leader>dc :CDiffChanges<CR>

autocmd FileType diff call <SID>SetDiffMaps()

function! <SID>SetDiffMaps()
    map <silent> <buffer> <Leader>dv <Leader>df<Leader>dv
    map <silent> <buffer> <Leader>dV <Leader>df<Leader>dV
    map <silent> <buffer> <Leader>dt <Nop>
    map <silent> <buffer> <Leader>df :DiffOpenFile<CR>
    map <silent> <buffer> <Leader>dF :DiffOpenFile!<CR>
    map <silent> <buffer> <Leader>dd :NavDiffChanges<CR>:call <SID>NameTabPrefix('Diff')<CR>
    map <silent> <buffer> <Leader>du :VCSUpdateDiffChanges<CR>

    " TODO: when diff_changes can take patches:
    "  <Leader>dd when there is no diff window should do a diff using VCS
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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

" EasyMotion
let g:EasyMotion_keys = "abcdefghijklmnopqrstuvwxyz"

" Command-T
let g:CommandTMatchWindowReverse=1
map <silent> <Leader>t :CommandT<CR>

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
map <Leader>s :call <SID>spell()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Filetype specific autocommands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Detect Go filetype
autocmd BufNewFile,BufRead *.go set ft=go

" For some reason setlocal on the filetypes isn't working properly.
autocmd BufRead,BufNewFile * setlocal colorcolumn=
autocmd BufRead,BufNewFile *.c,*.cc,*.cpp,*.h,*.js,*.py setlocal colorcolumn=+1
highlight ColorColumn ctermbg=blue ctermfg=white

" Set some settings for editing makefiles
augroup makefile
  autocmd!
  autocmd BufRead,BufNewFile ?akefile* set noexpandtab
augroup END

" Strip trailing whitespace before writing to programming filetypes.
autocmd BufWritePre *.c,*.cc,*.cpp,*.h,*.js,*.py :call <SID>StripTrailingWhitespace()

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
" Command line window
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set Ctrl-C back to normal (not comment plugin)
autocmd CmdwinEnter * noremap <buffer> <C-c> <C-c>
autocmd CmdwinEnter * inoremap <buffer> <C-c> <C-c>

" Ctrl-q closes the window
autocmd CmdwinEnter * nnoremap <buffer> <C-q> :quit
autocmd CmdwinEnter * inoremap <buffer> <C-q> <Esc>:quit

" Re-enter command window after running command
autocmd CmdwinEnter * noremap <silent> <buffer> <CR> <CR>q:
autocmd CmdwinEnter * inoremap <silent> <buffer> <CR> <CR>q:i

" Up and down like in command line
autocmd CmdwinEnter * noremap <buffer> / /
autocmd CmdwinEnter * noremap <buffer> ? ?
autocmd CmdwinEnter * imap <buffer> <Up> <C-O>y0<C-O>:let@/='^'.@0<CR><C-O>??e+1<CR>
autocmd CmdwinEnter * imap <buffer> <Down> <C-O>y0<C-O>:let@/='^'.@0<CR><C-O>//e+1<CR>
autocmd CmdwinEnter * map <buffer> <Up> y0:let@/='^'.@0<CR>??e+1<CR>
autocmd CmdwinEnter * map <buffer> <Down> y0:let@/='^'.@0<CR>//e+1<CR>

" Start in insert mode
noremap qi q:i

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

" Keep select mode free of mapping so that things like snipMate will work
" correctly
smapclear

