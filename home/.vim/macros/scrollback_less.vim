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

set mouse=a
set ttymouse=xterm2

function FoldLevel(line)
  if getline(a:line) =~ '^\[\d\d:\d\d\] \[\d\+\] dilshan@[^:]\+:'
    return '>1'
  else
    return '1'
  endif
endfunction

function DiffFoldText()
  " The timestamp on the command line.
  let l:time = split(getline(v:foldstart))[0]

  " The command name.
  let l:linetext = getline(v:foldstart + 1)

  " The number of lines in the command output.
  let l:numlines = v:foldend - v:foldstart - 1

  " If the command name is fg then the real command will be printed next line.
  if l:linetext =~ '^\d\+ \$ \s*fg\>'
    let l:linetext = substitute(l:linetext, 'fg.*', 'fg: ' . getline(v:foldstart + 2), '')
    let l:numlines -= 1
  endif

  return l:time . ' ' . l:linetext . ' (' . l:numlines . ' lines)'
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
syn match command '^\[\d\d:\d\d\] \[\d\+\] dilshan@[^:]\+:.*\n\d\+ \$'
hi link command Comment
hi Folded ctermfg=4 ctermbg=8
hi FoldColumn ctermfg=4 ctermbg=7
" for the statusline.
hi User1 ctermfg=3 ctermbg=0

function ToggleFold()
  if foldclosed('.') == -1
    foldclose
  else
    foldopen
  endif
endfunction

" mouse clicks open and close folds
nnoremap <silent> <LeftRelease> :call ToggleFold()<CR>

" Put cursor at end and display position
if &wrap
  noremap <SID>L L0zb<CR>
else
  noremap <SID>L Lg0zb<CR>
endif

noremap q <Esc>:q<CR>

function MyStatusLine()
  let l:start = '[scrollback]%<'
  let l:end = ' %l/%L [%p%%] %v [%b,0x%B]'
  if foldclosed('.') >= 0 || bufnr('%') != 1
    return l:start . '%=' . l:end
  endif

  let l:save_cursor = getpos('.')
  foldclose
  let l:text = foldtextresult(foldclosed('.'))
  let l:lastline = foldclosedend('.')
  foldopen
  call setpos('.', l:save_cursor)

  let l:parts = matchlist(l:text, '\$\(.*\) (\(\d\+\) lines)$')
  let l:cmd = l:parts[1]
  let l:lines = l:parts[2]

  " Calculate the current line. Lines in the header are all line 0.
  let l:curline = l:lines - (l:lastline - line('.'))
  if l:curline < 0
    let l:curline = 0
  endif

  let l:percent = l:curline <= 0 ? 0 : (l:lines == 1 ? 100 : (l:curline-1) * 100 / (l:lines - 1))

  return l:start . '%1*' . l:cmd . '%*%= ' . l:curline . '/' . l:lines . ' [' . l:percent . '%%]' . l:end
endfunction

" Set the status line
set statusline=%!MyStatusLine()
set laststatus=2

" Go to the end of a buffer when loading a page
normal GL

" Open the first previous.
normal kzO

