" This only works with one file given on the command line
if argc() != 1
  qa
endif

" delete all blank lines at the start of the file
set noreadonly
1;/./-1d
set readonly

set nocp
set so=0
set hlsearch
set incsearch
nohlsearch
" Don't remember file names and positions
set viminfo=
set nows

" no swap file and smaller cmd
set noswf
set cmdheight=1
set nolist

" ensure we can scroll with mouse and still copy
set paste mouse=nicr

function FoldLevel(line)
  if getline(a:line) =~ '^\[\d\d:\d\d\] \[\d\+\] dilshan@\w\+:'
    return '>1'
  else
    return '1'
  endif
endfunction

function DiffFoldText()
  let l:time = split(getline(v:foldstart))[0]
  let l:linetext = getline(v:foldstart + 1)
  let l:sizedesc = '(' . (v:foldend - v:foldstart - 1) . ' lines)'
  return l:time . ' ' . l:linetext . ' ' . l:sizedesc
endfunction

" define folds
set foldenable
set foldmethod=expr
set foldexpr=FoldLevel(v:lnum)
set foldtext=DiffFoldText()
set foldlevel=0
set readonly
set nomodifiable

" all filchars blank
set fillchars=vert:\ ,stl:\ ,stlnc:\ ,diff:\ ,fold:\ 

" Don't consider the file modified.
set nomod

" Syntax highlighting
set background=light
hi clear
syntax reset
hi Comment ctermfg=2
syn match command '^\[\d\d:\d\d\] \[\d\d*\] dilshan@\w\w*:.*\n\d\d* \$'
hi link command Comment
hi Folded term=standout ctermfg=4 ctermbg=8
hi FoldColumn term=standout ctermfg=4 ctermbg=7

" mouse clicks open and close folds
function ToggleFold()
  if foldclosed('.') == -1
    foldclose
  else
    foldopen
  endif
endfunction
noremap <silent> <LeftMouse> <LeftMouse>:call ToggleFold()<CR>

" Used after each command: put cursor at end and display position
if &wrap
  noremap <SID>L L0zb<CR>
  " au VimEnter * normal L0zb
else
  noremap <SID>L Lg0zb<CR>
  " au VimEnter * normal Lg0zb
endif

noremap q :q<CR>

" Set the status line
set statusline=[scrollback]\ %=%l/%L%<\ [%p%%]\ %v\ [%b,0x%B]
set laststatus=2

" Go to the end of a buffer when loading a page
normal GL

